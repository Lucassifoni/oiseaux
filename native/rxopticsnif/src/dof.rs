use image::{
    self, DynamicImage, GenericImageView, GrayImage, ImageError, Luma, Rgba, RgbaImage,
};

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
    let pixels = a.pixels().into_iter();

    let mut rgba_out = RgbaImage::new(a.width(), a.height());
    let mut depth_out = GrayImage::new(a.width(), a.height());

    for (x, y, rgba) in pixels {
        let [r, g, b, a] = rgba.0;
        rgba_out.put_pixel(x, y, Rgba::<u8>([r, g, b, 255]));
        depth_out.put_pixel(x, y, Luma::<u8>([a]));
    }

    let w = a.width();
    let mut depth_and_color_vec = DepthAndColorMap {
        width: w,
        height: a.height(),
        values: vec![],
    };

    let mut i = 0;

    for px in depth_out.pixels().into_iter() {
        let y = i % w;
        let x = i / w;
        let rgbax = rgba_out.get_pixel(y, x);
        depth_and_color_vec.values.push(DepthAndColorPx {
            x,
            y,
            d: px.0[0],
            rgba: [rgbax.0[0], rgbax.0[1], rgbax.0[2], rgbax.0[3]],
        });
        i += 1;
    }
    depth_and_color_vec.values.sort_by(|a, b| a.d.cmp(&b.d));
    depth_and_color_vec
}
