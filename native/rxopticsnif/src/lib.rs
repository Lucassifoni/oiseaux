mod dof;
mod parabola;
use std::fmt::Display;

use dof::DepthAndColorMap;
use parabola::Segment;
use rustler::ResourceArc;

fn load(env: rustler::Env, _info: rustler::Term) -> bool {
    rustler::resource!(DepthAndColorMap, env);
    true
}

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

#[rustler::nif]
pub fn load_image(path: String) -> Result<ResourceArc<DepthAndColorMap>, ImageHandlingError> {
    match dof::load_image(path) {
        Ok(a) => Ok(ResourceArc::new(a)),
        Err(_) => Err(ImageHandlingError {
            msg: "Failed to load image".to_string(),
        }),
    }
}

rustler::init!(
    "Elixir.Optics.RxopticsNif",
    [non_parallel_rayfan_coords, reflection_angle, load_image],
    load = load
);
