/*
 * Sharp GP2Y0A21YK0F Distance Sensor
 * Units: mm
 */

$fn = 50;

// 寸法定義
BODY_L = 29.5;
BODY_W = 13.0;
BODY_H = 8.4;

FLANGE_L = 37.0;
FLANGE_H = 1.5; // 厚み（図中 2-1.5 参照）
HOLE_DIST = 14.75 * 2; // 29.5
HOLE_D = 3.2;

LENS_BASE_W = 7.5; // R3.75 * 2
LENS_PITCH = 20.0;
LENS_PROTRUSION = 2.0;

PWB_H = 1.2;
TOTAL_H = 13.5;
CONN_W = 10.1;

// 色の定義
COLOR_BODY = [0.2, 0.2, 0.2];
COLOR_LENS = [0.1, 0.1, 0.1];
COLOR_PWB = [0.2, 0.3, 0.1];
COLOR_CONN = [0.9, 0.9, 0.9];

module gp2y0a21yk0f() {
    // 1. メインボディ (Black plastic case)
    // 原点を本体の中心にするため、Z方向は -BODY_H/2 から BODY_H/2
    color(COLOR_BODY)
    difference() {
        union() {
            // 中心ブロック
            cube([BODY_L, BODY_W, BODY_H], center = true);
            
            // 取付フランジ (左右の耳)
            translate([0, 0, -BODY_H/2 + FLANGE_H/2])
            hull() {
                cube([BODY_L, BODY_W, FLANGE_H], center = true);
                for(s = [-1, 1]) {
                    translate([s * (FLANGE_L/2 - 3.75), 0, 0])
                    cylinder(d = 7.5, h = FLANGE_H, center = true);
                }
            }
        }
        
        // 取付穴
        for(s = [-1, 1]) {
            translate([s * HOLE_DIST/2, 0, -BODY_H/2])
            cylinder(d = HOLE_D, h = FLANGE_H * 3, center = true);
        }
    }

    // 2. レンズ部分 (Lens Case / Protrusions)
    color(COLOR_LENS) {
        for(s = [-1, 1]) {
            translate([s * LENS_PITCH/2, 0, BODY_H/2 + LENS_PROTRUSION/2])
            difference() {
                // レンズ外装
                cube([LENS_BASE_W, BODY_W, LENS_PROTRUSION], center = true);
                // 実際のレンズっぽい窪み（装飾的表現）
                translate([0, 0, 0.5])
                cylinder(d = 6, h = LENS_PROTRUSION, center = true);
            }
        }
    }

    // 3. PWB (基板部分)
    // 図面より、全高 13.5mm。上端から下端まで。
    // 上面レンズ端(BODY_H/2 + 2.0) から PWB下面までの距離を合わせる
    pwb_z_pos = BODY_H/2 + LENS_PROTRUSION - 13.5 + PWB_H/2;
    
    translate([0, 0, pwb_z_pos])
    color(COLOR_PWB)
    cube([BODY_L - 2, BODY_W - 1, PWB_H], center = true);

    // 4. コネクタ (Connector)
    // PWBの下に配置
    color(COLOR_CONN)
    translate([0, 0, pwb_z_pos - PWB_H/2 - (13.5 - 8.4 - 2.0 - 1.2)/2])
    cube([CONN_W, 6.0, 13.5 - 8.4 - 2.0 - 1.2], center = true);
}

// 実行
gp2y0a21yk0f();