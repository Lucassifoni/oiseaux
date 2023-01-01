mod parabola;
use parabola::Segment;

#[rustler::nif]
pub fn non_parallel_rayfan_coords(focal_length: f32, radius: f32, source_distance: f32, rays: i32) -> Vec<Segment> {
    parabola::non_parallel_rayfan_coords(focal_length, radius, source_distance, rays)
}

rustler::init!("Elixir.Optics.RxopticsNif", [non_parallel_rayfan_coords]);
