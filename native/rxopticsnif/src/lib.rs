mod parabola;
use parabola::Segment;

#[rustler::nif]
pub fn non_parallel_rayfan_coords(focal_length: f64, radius: f64, source_distance: f64, source_height: f64, rays: i32) -> Vec<Segment> {
    parabola::non_parallel_rayfan_coords(focal_length, radius, source_distance, source_height, rays)
}

#[rustler::nif]
pub fn reflection_angle(focal_length: f64, y: f64, source_distance: f64, source_height: f64) -> f64 {
    parabola::reflection_angle(focal_length, y, source_distance, source_height)
}

rustler::init!("Elixir.Optics.RxopticsNif", [non_parallel_rayfan_coords, reflection_angle]);
