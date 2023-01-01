use rustler::NifStruct;

#[derive(Clone, Copy, NifStruct)]
#[module = "Optics.Point"]
pub struct Point {
    x: f32,
    y: f32,
}

#[derive(Clone, Copy, NifStruct)]
#[module = "Optics.Segment"]
pub struct Segment {
    a: Point,
    b: Point,
}

fn x_coord_on_parabola(focal_length: f32, y: f32) -> f32 {
    return y * y / 4.0 / focal_length;
}

fn parabola_coords(radius: f32, focal_length: f32) -> Vec<Point> {
    let mut out: Vec<Point> = vec![];
    let my = -radius as i32;
    for y in my..radius as i32 {
        let x = x_coord_on_parabola(focal_length, y as f32);
        out.push(Point { x: x, y: y as f32 })
    }
    out
}

fn parallel_rayfan_coords(radius: f32, focal_length: f32, rays: i32) -> Vec<Segment> {
    let mut out: Vec<Segment> = vec![];
    let base_y = -radius;
    let step = (radius.abs() / rays as f32) * 2.0;
    for i in 0..rays {
        let y = base_y as f32 + i as f32 * step;
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

fn normal_coords(focal_length: f32, y: f32) -> Segment {
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

fn tangent_coords(focal_length: f32, y: f32) -> Segment {
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

pub fn non_parallel_rayfan_coords(
    focal_length: f32,
    radius: f32,
    source_distance: f32,
    rays: i32,
) -> Vec<Segment> {
    let mut out: Vec<Segment> = vec![];
    let base_y = -radius;
    let base_x = source_distance;
    let step = radius.abs() / rays as f32 * 2.0;
    for i in 0..(rays + 1) {
        let y = base_y as f32 + i as f32 * step;
        let x = x_coord_on_parabola(focal_length, y);
        out.push(Segment {
            a: Point { x, y },
            b: Point { x: base_x, y: 0.0 },
        });
        out.push(reflection_coords(focal_length, y, source_distance));
    }
    out
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

fn angle_with_x_axis(s: Segment) -> f32 {
    let derived = segment_delta(s);
    derived.b.y.atan2(derived.b.x)
}

fn angle_between_segments(a: Segment, b: Segment) -> f32 {
    angle_with_x_axis(b) - angle_with_x_axis(a)
}

fn point_and_angle_to_x_coord(p: Point, angle: f32) -> f32 {
    let slope = angle.tan();
    if slope == 0.0 {
        9999999999999.0
    } else {
        ((slope * p.x) - p.y) / slope
    }
}

fn reflection_coords(focal_length: f32, y: f32, source_distance: f32) -> Segment {
    let x = x_coord_on_parabola(focal_length, y);
    let v1 = Segment {
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
