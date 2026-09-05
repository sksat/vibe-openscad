/*
 * Sharp GP2Y0A21YK0F
 * 単位: mm
 *
 * X: 本体長手方向（発光側が -X、受光側が +X）
 * Y: コネクタ突出方向が -Y
 * Z: 光学面が +Z、PWB / 取付面側が -Z
 *
 * 原点は、取付耳・コネクタを除く本体外形
 * 29.5 × 13 × 13.5 mm の中心。
 *
 * 図面に寸法のない肉厚、内部形状、レンズ曲率、
 * コネクタ細部は外観に基づく近似。
 */

$fn = 80;
eps = 0.02;

// ---------- 主要寸法 ----------
body_x = 29.5;
body_y = 13;
body_z = 13.5;

z_back       = -body_z / 2;
z_front      =  body_z / 2;
z_shoulder   = z_back + 7.2;
z_lens_base  = z_front - 2;

mount_pitch  = 37;
mount_radius = 3.75;
mount_hole_d = 3.2;
mount_t      = 1.5;

bridge_y = 8.4;

emitter_x  = -body_x / 2 + 4.5;
receiver_x = emitter_x + 20;

emitter_case_x = 7.5;
receiver_case_x = 16.3;
case_gap = 4.15;
lens_case_y = 7.2;

emitter_case_left  = emitter_x - emitter_case_x / 2;
receiver_case_left = emitter_case_left
                   + emitter_case_x + case_gap;

connector_width = 10.1;
overall_y = 18.95;
connector_end_y = body_y / 2 - overall_y;

pcb_t = 1.2;
pcb_back_z = z_back + 3.3;
pcb_front_z = pcb_back_z + pcb_t;

// ---------- 色 ----------
case_color      = [0.055, 0.058, 0.065];
lens_color      = [0.095, 0.045, 0.070];
pcb_color       = [0.28, 0.18, 0.075];
connector_color = [0.89, 0.88, 0.81];
metal_color     = [0.72, 0.73, 0.75];

// ---------- 基本形状 ----------
module box_between(x0, x1, y0, y1, z0, z1) {
    translate([x0, y0, z0])
        cube([x1-x0, y1-y0, z1-z0]);
}

// XY 面内の長円形。軸方向は Z。
module capsule_z(x0, x1, y, radius, z0, height) {
    hull() {
        translate([x0, y, z0])
            cylinder(r=radius, h=height);
        translate([x1, y, z0])
            cylinder(r=radius, h=height);
    }
}

// 球面キャップ付きレンズ。最大 Z は z_front 未満。
module domed_lens(x, y, radius=2.9) {
    cap_h = 0.55;
    cap_base = z_front - 0.62;
    sphere_r = (radius*radius + cap_h*cap_h) / (2*cap_h);

    union() {
        translate([x, y, z_lens_base + 0.3])
            cylinder(
                r=radius,
                h=cap_base - (z_lens_base + 0.3) + eps
            );

        intersection() {
            translate([x, y, cap_base + cap_h - sphere_r])
                sphere(r=sphere_r);

            translate([x, y, cap_base])
                cylinder(r=radius, h=cap_h + eps);
        }
    }
}

// ---------- 取付耳 ----------
module mounting_ear_positive() {
    // 半円形端部と本体への接続部
    translate([0, 0, z_back])
        linear_extrude(height=mount_t)
            union() {
                translate([mount_pitch/2, 0])
                    circle(r=mount_radius);

                translate([body_x/2 - eps, -mount_radius])
                    square([
                        mount_pitch/2 - body_x/2 + eps,
                        2*mount_radius
                    ]);
            }

    // 本体側の斜め補強。詳細寸法は図面外形からの近似。
    hull() {
        box_between(
            body_x/2 - 0.3, body_x/2 + eps,
            -mount_radius, mount_radius,
            z_back, z_back + 5.25
        );

        box_between(
            mount_pitch/2 - 0.15, mount_pitch/2,
            -mount_radius, mount_radius,
            z_back, z_back + mount_t
        );
    }
}

module mounting_ears() {
    mounting_ear_positive();
    mirror([1, 0, 0])
        mounting_ear_positive();
}

// ---------- 黒色ケース ----------
module housing() {
    color(case_color)
        difference() {
            union() {
                // 後部ケース：全幅 13 mm
                box_between(
                    -body_x/2, body_x/2,
                    -body_y/2, body_y/2,
                    z_back, z_shoulder
                );

                // 光学部側の段付きケース：幅 8.4 mm
                box_between(
                    -body_x/2, body_x/2,
                    -bridge_y/2, bridge_y/2,
                    z_shoulder - eps, z_lens_base
                );

                mounting_ears();

                // 発光側レンズケース
                box_between(
                    emitter_case_left,
                    emitter_case_left + emitter_case_x,
                    -lens_case_y/2, lens_case_y/2,
                    z_lens_base - eps, z_front
                );

                // 受光側レンズケース
                box_between(
                    receiver_case_left,
                    receiver_case_left + receiver_case_x,
                    -lens_case_y/2, lens_case_y/2,
                    z_lens_base - eps, z_front
                );
            }

            // 2-φ3.2 貫通穴、中心間距離 37
            for (x = [-mount_pitch/2, mount_pitch/2])
                translate([x, 0, z_back - 1])
                    cylinder(d=mount_hole_d, h=body_z + 2);

            // 背面の PWB 収容部
            box_between(
                -body_x/2 + 1.2, body_x/2 - 1.2,
                -body_y/2 + 1.2, body_y/2 - 1.2,
                z_back - eps, pcb_back_z + 0.1
            );

            // コネクタ／基板タブ用切欠き
            box_between(
                -connector_width/2 - 0.1,
                 connector_width/2 + 0.1,
                -body_y/2 - eps, -4.15,
                pcb_back_z - 0.1, z_shoulder + eps
            );

            // 発光側開口
            translate([emitter_x, 0, z_lens_base + 0.25])
                cylinder(
                    r=3.05,
                    h=z_front-z_lens_base + 1
                );

            // 受光側開口：図の外観に合わせた長円形
            capsule_z(
                receiver_x - 1.8, receiver_x,
                0, 3.05,
                z_lens_base + 0.25,
                z_front-z_lens_base + 1
            );

            // 受光側の浅い矩形リセス
            box_between(
                receiver_case_left + 0.65,
                receiver_case_left + receiver_case_x - 0.65,
                -lens_case_y/2 + 0.6,
                 lens_case_y/2 - 0.6,
                z_front - 0.14, z_front + eps
            );
        }
}

// ---------- 光学レンズ ----------
module lenses() {
    color(lens_color) {
        domed_lens(emitter_x, 0);

        hull() {
            domed_lens(receiver_x - 1.8, 0);
            domed_lens(receiver_x, 0);
        }
    }
}

// ---------- PWB ----------
module pwb() {
    color(pcb_color)
        union() {
            box_between(
                -body_x/2 + 0.9, body_x/2 - 0.9,
                -body_y/2 + 0.9, body_y/2 - 0.9,
                pcb_back_z, pcb_front_z
            );

            // コネクタ下の突出タブ
            box_between(
                -connector_width/2, connector_width/2,
                connector_end_y, -body_y/2 + 1.3,
                pcb_back_z, pcb_front_z
            );
        }
}

// ---------- 3極コネクタ（外観近似） ----------
module connector() {
    socket_front_y = connector_end_y + 0.12;
    socket_back_y  = -4.8;

    socket_width = 8.0;
    socket_z0 = pcb_front_z;
    socket_z1 = z_back + 9.3;

    color(connector_color)
        difference() {
            union() {
                box_between(
                    -socket_width/2, socket_width/2,
                    socket_front_y, socket_back_y,
                    socket_z0, socket_z1
                );

                // 側方の取付フランジ
                for (s = [-1, 1])
                    translate([
                        s*(socket_width/2 + 0.45),
                        (socket_front_y + socket_back_y)/2,
                        socket_z0 + 0.55
                    ])
                        cube([
                            0.95,
                            socket_back_y-socket_front_y,
                            1.1
                        ], center=true);
            }

            // 嵌合口は -Y に開口
            box_between(
                -3.25, 3.25,
                socket_front_y - eps, socket_back_y - 1.0,
                socket_z0 + 0.75, socket_z1 - 0.7
            );

            // 上側のラッチ逃げ
            box_between(
                -1.45, 1.45,
                socket_front_y - eps, socket_front_y + 1.7,
                socket_z1 - 0.85, socket_z1 + eps
            );
        }

    // 2 mm ピッチのコンタクトと基板側端子（近似）
    color(metal_color)
        for (x = [-2, 0, 2]) {
            box_between(
                x-0.25, x+0.25,
                socket_front_y + 0.8, socket_back_y - 0.6,
                socket_z0 + 2.0, socket_z0 + 2.5
            );

            box_between(
                x-0.25, x+0.25,
                socket_back_y - 1.1, socket_back_y - 0.6,
                z_back + 1.2, socket_z0 + 2.5
            );

            // 背面側のはんだランド
            translate([x, socket_back_y - 0.85, pcb_back_z - 0.07])
                cylinder(d=1.25, h=0.1);
        }
}

// ---------- アセンブリ ----------
module GP2Y0A21YK0F() {
    housing();
    lenses();
    pwb();
    connector();
}

GP2Y0A21YK0F();