// Sharp GP2Y0A21YK0F 距離センサの概略モデル
// 単位: mm
// X: 横幅、Y: 上下、Z: 光軸方向
// 本体中心を原点とし、光学面を +Z、PWB / コネクタ側を -Z とする。

$fn = 64;

// 主な寸法
body_w       = 29.5;
body_h       = 8.4;
body_d       = 10.2;
mount_pitch  = 37.0;
mount_r      = 3.75;
mount_hole_d = 3.2;
lens_pitch   = 20.0;
lens_d       = 6.3;

// 角を丸めた直方体（指定サイズは丸め後の外形寸法）
module rounded_box(size, r=0.4) {
    minkowski() {
        cube([size[0]-2*r, size[1]-2*r, size[2]-2*r], center=true);
        sphere(r=r, $fn=20);
    }
}

// 左右の取付耳。穴はZ方向に貫通。
module mounting_ears() {
    difference() {
        union() {
            // 円形の取付耳
            for (s=[-1, 1]) {
                translate([s*mount_pitch/2, 0, -4.65])
                    cylinder(r=mount_r, h=1.2, center=true);
            }

            // 耳とケースをつなぐ薄い部分
            for (s=[-1, 1]) {
                translate([s*16.45, 0, -4.65])
                    cube([5.0, 4.0, 1.2], center=true);
            }
        }

        for (s=[-1, 1]) {
            translate([s*mount_pitch/2, 0, -4.65])
                cylinder(d=mount_hole_d, h=3.0, center=true);
        }
    }
}

// 前面の光学レンズ
module lens(xpos, lens_color=[0.12, 0.18, 0.22, 0.85]) {
    // レンズ外周の段差
    translate([xpos, 0, 5.45])
        cylinder(d=lens_d+0.8, h=0.7, center=true);

    // レンズ面
    color(lens_color)
        translate([xpos, 0, 5.88])
            cylinder(d=lens_d, h=0.45, center=true);
}

// センサ本体
module sensor_body() {
    color([0.16, 0.16, 0.16])
        rounded_box([body_w, body_h, body_d], 0.45);

    // 前面カバー
    color([0.10, 0.10, 0.10])
        translate([0, 0, 5.05])
            rounded_box([28.4, 7.5, 1.0], 0.3);

    // 光学レンズ：図面正面視で左が発光側、右が受光側
    color([0.25, 0.25, 0.25]) {
        translate([-lens_pitch/2, 0, 5.42])
            cylinder(d=lens_d+0.8, h=0.65, center=true);
        translate([ lens_pitch/2, 0, 5.42])
            cylinder(d=lens_d+0.8, h=0.65, center=true);
    }

    lens(-lens_pitch/2, [0.22, 0.22, 0.20, 1.0]);
    lens( lens_pitch/2, [0.12, 0.18, 0.23, 0.88]);

    // 背面カバーの継ぎ目を表す薄いプレート
    color([0.13, 0.13, 0.13])
        translate([0, 0, -5.05])
            cube([27.8, 7.2, 0.25], center=true);
}

// PWBとコネクタ。取り付け面側（-Z）に配置。
module pcb_and_connector() {
    // PWB
    color([0.30, 0.24, 0.13])
        translate([0, -4.65, -5.55])
            cube([10.1, 2.7, 0.35], center=true);

    // 3極コネクタ本体
    color([0.82, 0.82, 0.78])
        translate([0, -5.35, -6.65])
            cube([10.1, 2.6, 2.0], center=true);

    // コネクタ端子（Vo / GND / Vcc）
    color([0.72, 0.70, 0.58])
        for (xpos=[-2.5, 0, 2.5]) {
            translate([xpos, -5.35, -8.0])
                cube([0.55, 0.55, 1.5], center=true);
        }

    // 基板上の端子接点
    color([0.72, 0.70, 0.58])
        for (xpos=[-2.5, 0, 2.5]) {
            translate([xpos, -4.55, -5.34])
                cylinder(d=0.65, h=0.08, center=true);
        }
}

// 組み立て
union() {
    sensor_body();
    mounting_ears();
    pcb_and_connector();
}