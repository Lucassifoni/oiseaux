mod dof;
mod parabola;
use std::fmt::Display;

use dof::DepthAndColorMap;
use image::ImageError;
use parabola::Segment;
use rustler::ResourceArc;

#[rustler::nif]
pub fn non_parallel_rayfan_coords(
    focal_length: f64,
    radius: f64,
    source_distance: f64,
    source_height: f64,
    rays: i32,
) -> Vec<Segment> {
    parabola::non_parallel_rayfan_coords(focal_length, radius, source_distance, source_height, rays)
}

#[rustler::nif]
pub fn reflection_angle(
    focal_length: f64,
    y: f64,
    source_distance: f64,
    source_height: f64,
) -> f64 {
    parabola::reflection_angle(focal_length, y, source_distance, source_height)
}

#[derive(Debug, rustler::NifStruct)]
#[module = "Optics.RxopticsNif.ImageHandlingError"]
pub struct ImageHandlingError {
    msg: String,
}
impl Display for ImageHandlingError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.msg)
    }
}

fn load(env: rustler::Env, _info: rustler::Term) -> bool {
    rustler::resource!(DepthAndColorMap, env);
    true
}

#[rustler::nif]
pub fn load_image(path: String) -> Result<ResourceArc<DepthAndColorMap>, ImageHandlingError> {
    match dof::load_image(path) {
        Ok(a) => Ok(ResourceArc::new(a)),
        Err(_) => Err(ImageHandlingError {
            msg: "Failed to load image".to_string(),
        }),
    }
}

#[rustler::nif]
pub fn blur(
    res: rustler::ResourceArc<DepthAndColorMap>,
    scene_distance: f64,
    sensor_distance: f64,
    pxsize: f64,
    radius: f64,
    base_fl: f64,
) -> Result<Vec<u8>, ImageHandlingError> {
    match dof::blur(
        res,
        scene_distance,
        sensor_distance,
        pxsize,
        radius,
        base_fl,
    ) {
        Ok(v) => Ok(v),
        Err(_) => Err(ImageHandlingError {
            msg: "Failed to blur image".to_string(),
        }),
    }
}

#[rustler::nif]
pub fn blur_diam_px_from_base_fl(
    base_fl: f64,
    radius: f64,
    rd: f64,
    sensor_distance: f64,
    px_size: f64,
) -> f64 {
    dof::blur_diam_px_from_base_fl(base_fl, radius, rd, sensor_distance, px_size)
}

rustler::init!(
    "Elixir.Optics.RxopticsNif",
    [
        non_parallel_rayfan_coords,
        reflection_angle,
        load_image,
        blur,
        blur_diam_px_from_base_fl
    ],
    load = load
);
