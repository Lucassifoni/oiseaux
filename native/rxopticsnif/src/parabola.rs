use rustler::NifStruct;

#[derive(Clone, Copy, NifStruct)]
#[module = "Optics.Point"]
pub struct Point {
    x: f64,
    y: f64,
}

#[derive(Clone, Copy, NifStruct)]
#[module = "Optics.Segment"]
pub struct Segment {
    a: Point,
    b: Point,
}

fn x_coord_on_parabola(focal_length: f64, y: f64) -> f64 {
    return y * y / 4.0 / focal_length;
}

fn parabola_coords(radius: f64, focal_length: f64) -> Vec<Point> {
    let mut out: Vec<Point> = vec![];
    let my = -radius as i32;
    for y in my..radius as i32 {
        let x = x_coord_on_parabola(focal_length, y as f64);
        out.push(Point { x: x, y: y as f64 })
    }
    out
}

fn parallel_rayfan_coords(radius: f64, focal_length: f64, rays: i32) -> Vec<Segment> {
    let mut out: Vec<Segment> = vec![];
    let base_y = -radius;
    let step = (radius.abs() / rays as f64) * 2.0;
    for i in 0..rays {
        let y = base_y as f64 + i as f64 * step;
        let x = x_coord_on_parabola(focal_length, y);
        out.push(Segment {
            a: Point { x: x, y: y },
            b: Point {
                x: 9999999999999.0,
                y: 0.0,
            },
        });
        out.push(Segment {
            a: Point { x: x, y: y },
            b: Point {
                x: focal_length,
                y: 0.0,
            },
        });
    }
    out
}

fn normal_coords(focal_length: f64, y: f64) -> Segment {
    let x = x_coord_on_parabola(focal_length, y);
    let dx = -2.0 * x;
    let dy = -y;
    Segment {
        a: Point {
            x: -dy + x,
            y: dx + y,
        },
        b: Point {
            x: dy + x,
            y: -dx + y,
        },
    }
}

fn tangent_coords(focal_length: f64, y: f64) -> Segment {
    let x = x_coord_on_parabola(focal_length, y);
    let dx = -2.0 * x;
    let dy = -y;
    Segment {
        a: Point { x: -x, y: 0.0 },
        b: Point {
            x: x - dx,
            y: y - dy,
        },
    }
}

fn segment_delta(s: Segment) -> Segment {
    Segment {
        a: Point { x: 0.0, y: 0.0 },
        b: Point {
            x: s.b.x - s.a.x,
            y: s.b.y - s.a.y,
        },
    }
}

fn angle_with_x_axis(s: Segment) -> f64 {
    let derived = segment_delta(s);
    derived.b.y.atan2(derived.b.x)
}

fn angle_between_segments(a: Segment, b: Segment) -> f64 {
    angle_with_x_axis(b) - angle_with_x_axis(a)
}

fn point_and_angle_to_x_coord(p: Point, angle: f64) -> f64 {
    let slope = angle.tan();
    if slope == 0.0 {
        9999999999999.0
    } else {
        ((slope * p.x) - p.y) / slope
    }
}

pub fn non_parallel_rayfan_coords(
    focal_length: f64,
    radius: f64,
    source_distance: f64,
    source_height: f64,
    rays: i32,
) -> Vec<Segment> {
    let mut out: Vec<Segment> = vec![];
    let base_y = -radius;
    let base_x = source_distance;
    let step = radius.abs() / rays as f64 * 2.0;
    for i in 0..(rays + 1) {
        let y = base_y as f64 + i as f64 * step;
        let x = x_coord_on_parabola(focal_length, y);
        out.push(Segment {
            a: Point { x, y },
            b: Point {
                x: base_x,
                y: source_height,
            },
        });
        out.push(reflection_coords(
            focal_length,
            y,
            source_distance,
            source_height,
        ));
    }
    out
}

pub fn reflection_angle(f: f64, y: f64, source_distance: f64, source_height: f64) -> f64 {
    let x = x_coord_on_parabola(f, y);
    let v1: Segment = Segment {
        b: Point { x, y },
        a: Point {
            x: source_distance,
            y: source_height,
        },
    };
    let normal = normal_coords(f, y);
    let angle = angle_between_segments(v1, normal);
    angle_with_x_axis(v1) + (2.0 * angle)
}

pub fn reflection_coords(
    focal_length: f64,
    y: f64,
    source_distance: f64,
    source_height: f64,
) -> Segment {
    let output_angle = reflection_angle(focal_length, y, source_distance, source_height);
    let x = x_coord_on_parabola(focal_length, y);
    let ray_length = 2.5 * focal_length;
    Segment {
        a: Point { x, y },
        b: Point {
            x: x + (ray_length * output_angle.cos()).abs(),
            y: y + ray_length * -output_angle.sin(),
        },
    }
}

pub fn reflection_coords_onaxis(focal_length: f64, y: f64, source_distance: f64) -> Segment {
    let x = x_coord_on_parabola(focal_length, y);
    let v1: Segment = Segment {
        b: Point { x, y },
        a: Point {
            x: source_distance,
            y: 0.0,
        },
    };
    let normal = normal_coords(focal_length, y);
    let angle = angle_between_segments(v1, normal);
    let output_angle = angle_with_x_axis(v1) + (2.0 * angle);
    let x_coord = point_and_angle_to_x_coord(Point { x, y }, output_angle);
    Segment {
        a: Point { x, y },
        b: Point { x: x_coord, y: 0.0 },
    }
}

pub fn effective_fl(focal_length: f64, radius: f64, source_distance: f64) -> f64 {
    (reflection_coords_onaxis(focal_length, radius, source_distance)
        .b
        .x
        + reflection_coords_onaxis(focal_length, 1.0, source_distance)
            .b
            .x)
        / 2.0
}

pub fn spread(focal_length: f64, radius: f64, source_distance: f64) -> f64 {
    let min = reflection_coords_onaxis(focal_length, 1.0, source_distance)
        .b
        .x;
    let max = reflection_coords_onaxis(focal_length, radius, source_distance)
        .b
        .x;
    min - max
}

pub fn vfov(sensor_height: f64, efl: f64) -> f64 {
    2.0 * (sensor_height / 2.0 / efl).atan()
}

pub fn hfov(sensor_width: f64, efl: f64) -> f64 {
    2.0 * (sensor_width / 2.0 / efl).atan()
}

pub fn projected_hfov(hfov: f64, dist: f64) -> f64 {
    hfov.tan() * dist
}

pub fn projected_vfov(vfov: f64, dist: f64) -> f64 {
    vfov.tan() * dist
}

pub fn blur_size(radius: f64, efl: f64, sensor_distance: f64, lspread: f64) -> f64 {
    let angle = (radius / efl).tan();
    let pos = efl - sensor_distance;
    angle.sin() * pos * 2.0
}

pub fn airy(focal_length: f64, radius: f64) -> f64 {
    2.44 * 550.0 / 1000.0 / 1000.0 * (focal_length / (2.0 * radius))
}

pub fn dawes(radius: f64) -> f64 {
    11.6 / (radius * 2.0 / 10.0)
}
