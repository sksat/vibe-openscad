// Sharp GP2Y0A21YK0F 測距センサの外形モデル
// 単位: mm
// 原点: 本体の中心
// +Z: 光学窓側、-Z: PWB・コネクタ側
//
// データシートに示された外形、取付穴間隔、光学中心間隔を基準にした
// 外観モデル。細部の段差やコネクタ内部は概略形状。

$fn = 72;

body_w = 29.5;
body_h = 13.5;
body_back = -4.2;
body_front = 4.2;

hole_pitch = 37;
hole_d = 3.2;
ear_r = 3.75;
ear_thickness = 1.2;

emitter_x = -10.25;
detector_x = 9.75;       // 光学中心間隔 20 mm

case_color = [0.105, 0.105, 0.11];
trim_color = [0.19, 0.19, 0.20];
lens_color = [0.10, 0.14, 0.17];
metal_color = [0.72, 0.72, 0.69];

module rounded_rect(w, h, r) {
    offset(r = r)
        square([w - 2*r, h - 2*r], center = true);
}

module rounded_box(w, h, z0, depth, r = 0.35) {
    translate([0, 0, z0])
        linear_extrude(height = depth)
            rounded_rect(w, h, r);
}

module mounting_ears() {
    color(case_color)
    difference() {
        union() {
            for (side = [-1, 1]) {
                translate([0, 0, body_back])
                    linear_extrude(height = ear_thickness)
                        hull() {
                            translate([side * 14.1, 0])
                                square([1.3, 7.5], center = true);
                            translate([side * hole_pitch/2, 0])
                                circle(r = ear_r);
                        }
            }
        }

        for (side = [-1, 1])
            translate([side * hole_pitch/2, 0, body_back - 0.1])
                cylinder(h = ear_thickness + 0.2, d = hole_d);
    }
}

module main_case() {
    color(case_color)
    difference() {
        rounded_box(body_w, body_h,
                    body_back, body_front - body_back, 0.35);

        // 光学部の浅い窪み
        translate([emitter_x, 0, body_front - 0.65])
            cylinder(h = 0.8, d = 6.9);

        translate([detector_x, 0, body_front - 0.65])
            cylinder(h = 0.8, d = 7.2);
    }

    // 正面、光学窓周囲の矩形フレーム
    color(trim_color) {
        translate([emitter_x, 0, body_front])
            linear_extrude(height = 0.35)
                difference() {
                    square([7.7, 7.5], center = true);
                    circle(d = 6.45);
                }

        translate([9.25, 0, body_front])
            linear_extrude(height = 0.35)
                difference() {
                    square([16.3, 7.5], center = true);
                    translate([0.5, 0])
                        circle(d = 6.9);
                }
    }

    // 窓の奥に見えるレンズ
    color(lens_color) {
        translate([emitter_x, 0, body_front - 0.54])
            cylinder(h = 0.17, d = 5.7);

        translate([detector_x, 0, body_front - 0.54])
            cylinder(h = 0.17, d = 6.1);
    }
}

module connector() {
    // 本体の下寄りにある、-Z 向きの3極コネクタ
    connector_y = -9.65;
    connector_rear = -8.4;

    color(case_color)
    difference() {
        translate([0, connector_y, connector_rear])
            linear_extrude(height = 4.2)
                rounded_rect(10.1, 6.0, 0.35);

        // 挿入口
        translate([-4.12, connector_y - 2.36, connector_rear - 0.1])
            cube([8.24, 4.72, 2.55]);
    }

    // 挿入口内の絶縁体
    color(trim_color)
        translate([0, connector_y, -6.05])
            cube([7.65, 4.15, 0.65], center = true);

    // 3極の接点
    color(metal_color)
        for (x = [-2, 0, 2])
            translate([x, connector_y, -7.12])
                cube([0.55, 2.65, 0.25], center = true);
}

module sensor() {
    mounting_ears();
    main_case();
    connector();
}

sensor();