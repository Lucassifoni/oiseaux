use image::{
    self, DynamicImage, GenericImageView, GrayImage, ImageBuffer, ImageError, Luma, Pixel, Rgba,
    RgbaImage,
};
use imageproc::drawing::{Blend, Canvas};
use std::error::Error;
use std::ops::Deref;

use crate::parabola;

pub fn load_image(file_name: String) -> Result<DepthAndColorMap, ImageError> {
    match image::open(file_name) {
        Ok(a) => Ok(to_depth_and_color_map(a)),
        Err(b) => Err(b),
    }
}

#[derive(Clone, Copy)]
pub struct DepthAndColorPx {
    x: u32,
    y: u32,
    d: u8,
    rgba: [u8; 4],
}

#[derive(Clone)]
pub struct DepthAndColorMap {
    width: u32,
    height: u32,
    values: Vec<DepthAndColorPx>,
}

fn to_depth_and_color_map(a: DynamicImage) -> DepthAndColorMap {
    let w = GenericImageView::width(&a);
    let h = GenericImageView::height(&a);

    let mut depth_and_color_vec = DepthAndColorMap {
        width: w,
        height: h,
        values: vec![],
    };

    for (x, y, rgba) in a.pixels().into_iter() {
        let [r, g, b, a] = rgba.0;
        depth_and_color_vec.values.push(DepthAndColorPx {
            y,
            x,
            d: a,
            rgba: [r, g, b, 255],
        });
    }

    depth_and_color_vec.values.sort_by(|a, b| a.d.cmp(&b.d));
    depth_and_color_vec
}

fn map_depth_to_distance(depth: u8, scene_distance: f64, scene_depth: f64) -> f64 {
    let mul = scene_depth / 255.0;
    (255.0 - depth as f64) * mul + scene_distance
}

// https://stackoverflow.com/questions/50731636/how-do-i-encode-a-rust-piston-image-and-get-the-result-in-memory
fn encode_png<P, Container>(img: &ImageBuffer<P, Container>) -> Result<Vec<u8>, ImageError>
where
    P: Pixel<Subpixel = u8> + 'static,
    Container: Deref<Target = [P::Subpixel]>,
{
    let mut buf = Vec::new();
    let encoder = image::png::PNGEncoder::new(&mut buf);
    encoder.encode(img, img.width(), img.height(), P::COLOR_TYPE)?;
    Ok(buf)
}

pub fn blur_diam_px_from_base_fl(
    base_fl: f64,
    radius: f64,
    source_distance: f64,
    sensor_distance: f64,
    px_size: f64,
) -> f64 {
    let efl = crate::parabola::effective_fl(base_fl, radius, source_distance);
    let spread = crate::parabola::spread(efl, radius, source_distance);
    (crate::parabola::blur_size(radius, efl, sensor_distance, spread) / px_size) / 16.0
}

fn draw_image(destination: &mut ImageBuffer<Rgba<u8>, Vec<u8>>, source: &DepthAndColorMap) -> () {
    let width = source.width;
    for x in 0..source.width {
        for y in 0..source.height {
            destination.draw_pixel(x, y, Rgba(source.values[(y * width + x) as usize].rgba));
        }
    }
}

fn premultiply(c: &mut ImageBuffer<Rgba<u8>, Vec<u8>>, orig: &DepthAndColorMap) {
    for value in orig.values.iter() {
        let p = c.get_pixel_mut(value.x, value.y);
        if p.0[3] == 0 {
            let px = value.rgba;
            p.0 = px;
            p.0[3] = 0;
        }
    }
}

fn predraw(c: &mut ImageBuffer<Rgba<u8>, Vec<u8>>, orig: &DepthAndColorMap) {
    for value in orig.values.iter() {
        let p = c.get_pixel_mut(value.x, value.y);
        p.0 = value.rgba;
    }
}

pub fn blur(
    res: rustler::ResourceArc<DepthAndColorMap>,
    scene_distance: f64,
    sensor_distance: f64,
    pxsize: f64,
    radius: f64,
    base_fl: f64,
) -> Result<Vec<u8>, ImageError> {
    let scene_width = scene_distance * (0.51 * std::f64::consts::PI / 180.0).tan();
    let tile_size = scene_width / 3.69;
    let scene_depth = ((tile_size * 2.0_f64.sqrt() * 6.0) / 2.0) * 3.0_f64.sqrt() * 2.0;
    let depth_color_map: &DepthAndColorMap = &*res;
    let mut current_blur = -1.0;
    let mut bv = -2.0;
    let mut out = Blend(RgbaImage::new(
        depth_color_map.width,
        depth_color_map.height,
    ));
   // predraw(&mut out.0, depth_color_map);
    let mut drawer = Blend(RgbaImage::from_pixel(
        depth_color_map.width,
        depth_color_map.height,
        image::Rgba([255, 255, 255, 0]),
    ));
    let mut blurrer = RgbaImage::from_pixel(
        depth_color_map.width,
        depth_color_map.height,
        image::Rgba([255, 255, 255, 0]),
    );
    for val in depth_color_map.values.iter() {
        let p = *val;
        let x = p.x;
        let y = p.y;
        let d = map_depth_to_distance(p.d, scene_distance, scene_depth);
        let r = p.rgba[0];
        let g = p.rgba[1];
        let b = p.rgba[2];
        let elf = parabola::effective_fl(base_fl, radius, d);
        let spread = parabola::spread(elf, radius, d);
        let blur_diam_px =
            (parabola::blur_size(radius, elf, sensor_distance, spread) / pxsize) / 8.0 + 0.15;
        bv = ((blur_diam_px * 10.0).trunc() / 10.0).abs();
        let color = Rgba([r, g, b, 255]);
        imageproc::drawing::draw_filled_circle_mut(&mut drawer, (x as i32, y as i32), 1, color);
        if bv != current_blur {
            image::imageops::overlay(&mut blurrer, &drawer.0, 0, 0);
            premultiply(&mut blurrer, &depth_color_map);
            blurrer = imageproc::filter::gaussian_blur_f32(&mut blurrer, bv as f32);
            for x in 0..depth_color_map.width {
                for y in 0..depth_color_map.height {
                    out.draw_pixel(x, y, *blurrer.get_pixel(x, y));
                }
            }
            drawer = Blend(RgbaImage::from_pixel(
                depth_color_map.width,
                depth_color_map.height,
                image::Rgba([255, 255, 255, 0]),
            ));
            blurrer = RgbaImage::from_pixel(
                depth_color_map.width,
                depth_color_map.height,
                image::Rgba([255, 255, 255, 0]),
            );
            current_blur = bv;
        }
    }
    image::imageops::overlay(&mut blurrer, &drawer.0, 0, 0);
    premultiply(&mut blurrer, &depth_color_map);
    blurrer = imageproc::filter::gaussian_blur_f32(&mut blurrer, bv as f32);
    for x in 0..depth_color_map.width {
        for y in 0..depth_color_map.height {
            out.draw_pixel(x, y, *blurrer.get_pixel(x, y));
        }
    }
    encode_png(&out.0)
}
