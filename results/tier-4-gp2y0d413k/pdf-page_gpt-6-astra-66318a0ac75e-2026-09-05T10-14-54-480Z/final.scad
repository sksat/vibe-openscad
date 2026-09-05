// Sharp GP2Y0D413K0F
// 単位: mm。本体ケースの中心を原点とし、前面を +Y、上面を +Z とする。
// 発光部は -X 側、受光部は +X 側。
// 指示のない公差: ±0.3 mm。
// 窓の細部、コネクタ内部および端子断面は、図の外観に基づく簡易表現。

$fn = 80;
eps = 0.01;

// ---------- 図面寸法 ----------
body_w = 29.45;
body_h = 13.05;
body_d = 7.1;                  // ±0.1
overall_d = 13.5;
overall_h = 18.9;

shoulder_h = 8.4;
nose_h = 7.2;
nose_d = 2;

emitter_nose_w = 7.5;
nose_gap = 4.15;
receiver_nose_w = 16.3;

connector_w = 10.1;
pwb_t = 1.2;
pwb_rear_offset = 3.3;         // 参考寸法

emitter_center_offset = 4.5;  // * レンズ中心の参照寸法
optical_center_pitch = 19.7;  // * レンズ中心間の参照寸法

// 全奥行き13.5と本体奥行き7.1を優先。
// 前方突出量は6.4となり、参考寸法(6.3)との差は0.1。
projection_d = overall_d - body_d;
shoulder_d = projection_d - nose_d;

// ---------- 図から概算した、寸法指示のない細部 ----------
emitter_aperture_d = 5.3;
emitter_bezel_d = 6.3;
receiver_aperture_w = 15.0;
receiver_aperture_h = 6.0;
receiver_optic_d = 4.6;
window_recess = 0.12;
lens_t = 0.45;

connector_d = 4.8;
connector_wall = 0.7;
pin_pitch = 2.0;
pin_size = 0.45;
socket_depth = 3.8;
solder_tail_length = 2.2;

// ---------- 基準位置 ----------
body_front = body_d / 2;
body_back = -body_d / 2;
body_bottom = -body_h / 2;

shoulder_front = body_front + shoulder_d;
lens_front = body_front + projection_d;
assembly_bottom = body_h / 2 - overall_h;

nose_margin =
    (body_w - emitter_nose_w - nose_gap - receiver_nose_w) / 2;

emitter_nose_left = -body_w / 2 + nose_margin;
receiver_nose_left =
    emitter_nose_left + emitter_nose_w + nose_gap;

emitter_x = -body_w / 2 + emitter_center_offset;
receiver_x = emitter_x + optical_center_pitch;

emitter_nose_x = emitter_nose_left + emitter_nose_w / 2;
receiver_nose_x = receiver_nose_left + receiver_nose_w / 2;

pwb_back = body_back + pwb_rear_offset;
pwb_front = pwb_back + pwb_t;
pwb_y = (pwb_back + pwb_front) / 2;
pwb_h = body_bottom - assembly_bottom;

connector_back = pwb_front;
connector_front = connector_back + connector_d;
connector_y = (connector_back + connector_front) / 2;
connector_h = body_bottom - assembly_bottom;

// ---------- 材料色 ----------
case_color = [0.075, 0.075, 0.08];
bezel_color = [0.12, 0.12, 0.13];
lens_color = [0.17, 0.055, 0.065];
optic_color = [0.24, 0.075, 0.085];
pwb_color = [0.43, 0.28, 0.12];
connector_color = [0.88, 0.87, 0.80];
metal_color = [0.73, 0.75, 0.77];

// +Y 方向の円柱
module cylinder_y(d, length) {
    rotate([-90, 0, 0])
        cylinder(d = d, h = length);
}

module block_between(x0, x1, y0, y1, z0, z1) {
    translate([x0, y0, z0])
        cube([x1 - x0, y1 - y0, z1 - z0]);
}

// ---------- 本体ケース: Carbonic ABS ----------
module main_case() {
    color(case_color)
        cube([body_w, body_d, body_h], center = true);
}

// ---------- 前面レンズケース ----------
module lens_case() {
    color(case_color)
    difference() {
        union() {
            // 本体から前方へ張り出す、幅いっぱいの段。
            translate([
                0,
                body_front + shoulder_d / 2,
                0
            ])
                cube(
                    [body_w, shoulder_d, shoulder_h],
                    center = true
                );

            // 発光部側の突起。
            translate([
                emitter_nose_x,
                shoulder_front + nose_d / 2,
                0
            ])
                cube(
                    [emitter_nose_w, nose_d, nose_h],
                    center = true
                );

            // 受光部側の突起。
            translate([
                receiver_nose_x,
                shoulder_front + nose_d / 2,
                0
            ])
                cube(
                    [receiver_nose_w, nose_d, nose_h],
                    center = true
                );
        }

        // 円形窓の座ぐり。
        translate([
            emitter_x,
            lens_front - lens_t - window_recess,
            0
        ])
            cylinder_y(
                emitter_bezel_d,
                lens_t + window_recess + eps
            );

        // 矩形窓。
        translate([
            receiver_nose_x,
            lens_front - (lens_t + window_recess) / 2 + eps / 2,
            0
        ])
            cube([
                receiver_aperture_w,
                lens_t + window_recess + eps,
                receiver_aperture_h
            ], center = true);
    }

    // 発光部の円形リム。前面から突出させない。
    color(bezel_color)
    translate([emitter_x, lens_front - window_recess, 0])
    difference() {
        cylinder_y(emitter_bezel_d, window_recess);
        translate([0, -eps, 0])
            cylinder_y(
                emitter_aperture_d,
                window_recess + 2 * eps
            );
    }
}

// ---------- 可視光カット樹脂レンズ ----------
module lenses() {
    // 左: 円形の発光窓。
    color(lens_color)
    translate([
        emitter_x,
        lens_front - window_recess - lens_t,
        0
    ])
        cylinder_y(emitter_bezel_d, lens_t);

    // 右: 矩形の受光窓。
    color(lens_color)
    translate([
        receiver_nose_x,
        lens_front - window_recess - lens_t / 2,
        0
    ])
        cube([
            receiver_aperture_w,
            lens_t,
            receiver_aperture_h
        ], center = true);

    // 図中の *19.7 で指定される受光光学中心。
    // 矩形窓内に見える円形部分を薄い面として簡易表現。
    color(optic_color)
    translate([
        receiver_x,
        lens_front - window_recess - eps,
        0
    ])
        cylinder_y(receiver_optic_d, 2 * eps);
}

// ---------- PWB: 紙フェノール薄板 ----------
// 側面図の1.2はY方向の板厚。
// 基板は水平板ではなく、下方へ延びるXZ平面の薄板。
module pwb() {
    color(pwb_color)
    translate([
        0,
        pwb_y,
        assembly_bottom + pwb_h / 2
    ])
        cube([connector_w, pwb_t, pwb_h], center = true);
}

// ---------- JCTC 12001W90-3P-HF: 簡易3極コネクタ ----------
module connector() {
    color(connector_color)
    difference() {
        union() {
            translate([
                0,
                connector_y,
                assembly_bottom + connector_h / 2
            ])
                cube([
                    connector_w,
                    connector_d,
                    connector_h
                ], center = true);

            // 前面図に見える左右の立ち上がり。
            for (side = [-1, 1])
                translate([
                    side * (connector_w / 2 - connector_wall / 2),
                    (body_front + connector_front) / 2,
                    (body_bottom - shoulder_h / 2) / 2
                ])
                    cube([
                        connector_wall,
                        connector_front - body_front,
                        -shoulder_h / 2 - body_bottom
                    ], center = true);
        }

        // 下向きに開口する3極の嵌合部。
        for (i = [-1, 0, 1])
            translate([
                i * pin_pitch,
                connector_y,
                assembly_bottom + socket_depth / 2 - eps / 2
            ])
                cube([
                    1.5,
                    connector_d - 2 * connector_wall,
                    socket_depth + eps
                ], center = true);
    }

    color(metal_color)
    for (i = [-1, 0, 1]) {
        // 嵌合部内の接点。下端より突出させない。
        block_between(
            i * pin_pitch - pin_size / 2,
            i * pin_pitch + pin_size / 2,
            connector_y - pin_size / 2,
            connector_y + pin_size / 2,
            assembly_bottom + 0.8,
            assembly_bottom + socket_depth + 0.2
        );

        // ライトアングル端子の基板側の脚。
        block_between(
            i * pin_pitch - pin_size / 2,
            i * pin_pitch + pin_size / 2,
            pwb_back - solder_tail_length,
            connector_y + pin_size / 2,
            assembly_bottom + socket_depth - pin_size / 2,
            assembly_bottom + socket_depth + pin_size / 2
        );
    }
}

// ---------- 組み立て ----------
main_case();
lens_case();
lenses();
pwb();
connector();