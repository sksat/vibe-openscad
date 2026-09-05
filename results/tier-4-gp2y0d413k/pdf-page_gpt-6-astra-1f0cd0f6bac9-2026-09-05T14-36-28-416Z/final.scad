/*
 Sharp GP2Y0D413K0F 距離センサ
 単位: mm

 座標:
   X : 本体の長手方向（受光側が +X）
   Y : コネクタ突出方向が -Y
   Z : 光学面が +Z、PWB / 背面側が -Z

 原点:
   コネクタを除く本体外形 29.45 × 13.05 × 13.5 の中心。

 図面の主要寸法を使用。
 レンズ曲率、ケース肉厚、コネクタ内部、端子形状は外観近似。
 奥行13.5と、参考寸法(6.3)＋7.1の差0.1はケース前段厚へ吸収。
*/

$fn = 80;
eps = 0.02;

// ---------- 主要寸法 ----------
body_w = 29.45;
body_h = 13.05;
body_d = 13.5;

rear_depth = 7.1;
nose_h = 8.4;
lens_case_h = 7.2;
lens_case_depth = 2.0;

emitter_case_w = 7.5;
detector_case_w = 16.3;
optical_case_gap = 4.15;
optical_edge_margin = 0.75;

emitter_x = -body_w/2 + 4.5;
detector_x = emitter_x + 19.7;

emitter_case_x =
    -body_w/2 + optical_edge_margin + emitter_case_w/2;

detector_case_x =
    -body_w/2 + optical_edge_margin
    + emitter_case_w + optical_case_gap + detector_case_w/2;

z_back = -body_d/2;
z_front = body_d/2;
z_shoulder = z_back + rear_depth;
z_nose = z_front - lens_case_depth;

connector_w = 10.1;
overall_h = 18.9;
connector_bottom_y = body_h/2 - overall_h;

pwb_t = 1.2;
pwb_back_z = z_back + 3.3;
pwb_front_z = pwb_back_z + pwb_t;

// 以下のコネクタ細部寸法は図からの近似
connector_front_z = z_back + 9.2;
connector_top_y = -4.7;
connector_core_top_y = -6.1;

pin_pitch = 2.0;
pin_size = 0.5;
pin_z = z_back + 7.5;

// ---------- 色 ----------
case_color = [0.065, 0.067, 0.073];
rim_color = [0.095, 0.098, 0.105];
window_color = [0.070, 0.035, 0.045];
lens_color = [0.16, 0.075, 0.095];
connector_color = [0.88, 0.86, 0.78];
pwb_color = [0.35, 0.23, 0.11];
metal_color = [0.72, 0.74, 0.77];
pad_color = [0.68, 0.52, 0.24];

// ---------- 補助形状 ----------
module box_between(x0, x1, y0, y1, z0, z1) {
    translate([x0, y0, z0])
        cube([x1-x0, y1-y0, z1-z0]);
}

module centered_xy_box(x, y, w, h, z0, z1) {
    box_between(
        x-w/2, x+w/2,
        y-h/2, y+h/2,
        z0, z1
    );
}

// 平らな基部と、楕円体による凸レンズ面。
// 頂点は z_tip、外周面は z_tip-cap_h。
module optical_lens(x, radius, z_base, z_tip, cap_h) {
    z_equator = z_tip - cap_h;

    translate([x, 0, z_base])
        cylinder(
            r = radius,
            h = z_equator-z_base+eps
        );

    intersection() {
        translate([x, 0, z_equator])
            scale([radius, radius, cap_h])
                sphere(r=1);

        centered_xy_box(
            x, 0,
            2*radius+eps, 2*radius+eps,
            z_equator, z_tip+eps
        );
    }
}

// ---------- 本体ケース ----------
module main_case() {
    color(case_color)
        union() {
            // 背面側: 高さ13.05、奥行7.1
            centered_xy_box(
                0, 0, body_w, body_h,
                z_back, z_shoulder
            );

            // 光学側の段付き部分: 高さ8.4
            centered_xy_box(
                0, 0, body_w, nose_h,
                z_shoulder-eps, z_nose
            );
        }
}

// ---------- 投光部 ----------
module emitter() {
    aperture_r = 3.05;

    color(rim_color)
        difference() {
            centered_xy_box(
                emitter_case_x, 0,
                emitter_case_w, lens_case_h,
                z_nose-eps, z_front
            );

            translate([emitter_x, 0, z_nose+0.35])
                cylinder(
                    r = aperture_r,
                    h = lens_case_depth+eps
                );
        }

    // レンズ周囲の暗い座面
    color(window_color)
        translate([emitter_x, 0, z_nose+0.32])
            cylinder(r=aperture_r, h=0.50);

    // 同心円状の保持縁
    color(case_color)
        translate([emitter_x, 0, z_front-0.42])
            difference() {
                cylinder(r=3.02, h=0.32);
                translate([0, 0, -eps])
                    cylinder(r=2.68, h=0.32+2*eps);
            }

    color(lens_color)
        optical_lens(
            x = emitter_x,
            radius = 2.65,
            z_base = z_nose+0.68,
            z_tip = z_front-0.04,
            cap_h = 0.66
        );
}

// ---------- 受光部 ----------
module detector() {
    border = 0.60;
    aperture_w = detector_case_w - 2*border;
    aperture_h = lens_case_h - 2*border;

    color(rim_color)
        difference() {
            centered_xy_box(
                detector_case_x, 0,
                detector_case_w, lens_case_h,
                z_nose-eps, z_front
            );

            centered_xy_box(
                detector_case_x, 0,
                aperture_w, aperture_h,
                z_nose+0.35, z_front+eps
            );
        }

    // 横長の可視光カット窓
    color(window_color)
        centered_xy_box(
            detector_case_x, 0,
            aperture_w, aperture_h,
            z_nose+0.32, z_front-0.62
        );

    // 図の受光レンズ周辺の楕円状輪郭を近似
    color(case_color)
        intersection() {
            translate([detector_x, 0, z_front-0.60])
                scale([1.32, 1, 1])
                    cylinder(r=3.0, h=0.29);

            centered_xy_box(
                detector_case_x, 0,
                aperture_w, aperture_h,
                z_front-0.61, z_front-0.30
            );
        }

    color(lens_color)
        optical_lens(
            x = detector_x,
            radius = 2.35,
            z_base = z_front-0.58,
            z_tip = z_front-0.04,
            cap_h = 0.42
        );
}

// ---------- PWB ----------
module circuit_board() {
    color(pwb_color)
        union() {
            // ケース内に収まる基板部分
            centered_xy_box(
                0, 0,
                body_w-1.2, body_h-1.0,
                pwb_back_z, pwb_front_z
            );

            // コネクタ背面に露出する舌部
            box_between(
                -connector_w/2, connector_w/2,
                connector_bottom_y, -3.8,
                pwb_back_z, pwb_front_z
            );
        }

    // 背面側の端子ランド（近似）
    color(pad_color)
        for (i=[-1:1])
            centered_xy_box(
                i*pin_pitch,
                connector_bottom_y+2.65,
                1.15, 3.8,
                pwb_back_z-0.04,
                pwb_back_z+eps
            );
}

// ---------- 3極コネクタ ----------
module connector_shell() {
    rail_w = 1.1;
    cavity_w = 7.9;
    cavity_back_z = pwb_front_z+0.50;
    cavity_front_z = connector_front_z-0.55;

    color(connector_color)
        difference() {
            union() {
                // コネクタ主部
                box_between(
                    -connector_w/2, connector_w/2,
                    connector_bottom_y, connector_core_top_y,
                    pwb_front_z-eps, connector_front_z
                );

                // 上端の左右ガイド
                for (s=[-1, 1])
                    centered_xy_box(
                        s*(connector_w/2-rail_w/2),
                        (connector_bottom_y+connector_top_y)/2,
                        rail_w,
                        connector_top_y-connector_bottom_y,
                        pwb_front_z-eps, connector_front_z
                    );
            }

            // 嵌合口は -Y 向き
            box_between(
                -cavity_w/2, cavity_w/2,
                connector_bottom_y-eps, -7.15,
                cavity_back_z, cavity_front_z
            );

            // 開口側のキー溝
            box_between(
                -1.15, 1.15,
                connector_bottom_y-eps,
                connector_bottom_y+1.1,
                cavity_front_z-eps,
                connector_front_z+eps
            );
        }
}

// 端子は90度曲げ形状の近似。
// 正面から左→右: 1 Vo、2 GND、3 Vcc。
module connector_pins() {
    pin_bottom_y = connector_bottom_y+0.9;
    pin_bend_y = -7.25;

    color(metal_color)
        for (i=[-1:1]) {
            x = i*pin_pitch;

            // 嵌合口内の接点: Y方向
            box_between(
                x-pin_size/2, x+pin_size/2,
                pin_bottom_y, pin_bend_y+pin_size/2,
                pin_z-pin_size/2, pin_z+pin_size/2
            );

            // PWBへ向かう端子脚: -Z方向
            box_between(
                x-pin_size/2, x+pin_size/2,
                pin_bend_y-pin_size/2,
                pin_bend_y+pin_size/2,
                z_back+0.8, pin_z+pin_size/2
            );
        }
}

// ---------- 組立 ----------
module GP2Y0D413K0F() {
    main_case();
    emitter();
    detector();
    circuit_board();
    connector_shell();
    connector_pins();
}

GP2Y0D413K0F();