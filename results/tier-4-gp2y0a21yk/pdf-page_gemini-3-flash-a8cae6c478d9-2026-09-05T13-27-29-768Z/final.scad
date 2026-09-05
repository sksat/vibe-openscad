/*
 * Sharp GP2Y0A21YK0F IR Distance Sensor
 * Unit: mm
 * Origin: Center of the main body (29.5 x 13.0 x 13.5)
 */

$fn = 50;

// 色の定義
COLOR_BODY = [0.2, 0.2, 0.2];
COLOR_LENS = [0.1, 0.1, 0.1];
COLOR_CONN = [0.9, 0.9, 0.8];

module gp2y0a21yk0f() {
    // 基本寸法
    body_w = 29.5;
    body_h = 13.0;
    body_d = 13.5;
    
    // 取付フランジの厚みと位置
    flange_t = 2.0;
    // レンズ前面から取付面までの距離は 6.3mm
    // 本体の中心(y=0)から見ると、前面は body_d/2 = 6.75
    // 取付面(y) = 6.75 - 6.3 = 0.45
    mount_y = (body_d / 2) - 6.3;

    // レンズ中心位置 (左端から 4.5mm と 穴間隔 20mm)
    // 左端は -29.5/2 = -14.75
    lens_L_x = -14.75 + 4.5; // -10.25
    lens_R_x = lens_L_x + 20; // 9.75

    union() {
        // --- メインボディ (背面側) ---
        color(COLOR_BODY)
        difference() {
            union() {
                // 本体ブロック
                cube([body_w, body_d, body_h], center=true);
                
                // 取付フランジ (耳の部分)
                // 幅37mm, 中心間29.5mm
                translate([0, mount_y - flange_t/2, 0])
                hull() {
                    translate([-body_w/2, 0, 0]) rotate([90, 0, 0]) 
                        cylinder(d=7.5, h=flange_t, center=true);
                    translate([body_w/2, 0, 0]) rotate([90, 0, 0]) 
                        cylinder(d=7.5, h=flange_t, center=true);
                }
            }

            // 取付穴 (φ3.2mm)
            for(x = [-14.75, 14.75]) {
                translate([x, mount_y, 0]) rotate([90, 0, 0]) 
                    cylinder(d=3.2, h=10, center=true);
            }
        }

        // --- レンズケース (前面突出部) ---
        color(COLOR_BODY)
        for(x = [lens_L_x, lens_R_x]) {
            translate([x, (body_d/2) - 6.3/2, 0])
                cube([10, 6.3, 10], center=true);
        }

        // --- レンズ (窓部分) ---
        color(COLOR_LENS)
        for(x = [lens_L_x, lens_R_x]) {
            translate([x, body_d/2, 0]) rotate([-90, 0, 0]) 
                cylinder(d=7, h=0.5, center=false);
        }

        // --- コネクタハウジング (底面) ---
        // 幅10.1mm, 本体の中心から右側に向かって配置
        color(COLOR_CONN)
        translate([5.05, 0, -body_h/2 - 2.5])
            cube([10.1, body_d, 5], center=true);
            
        // コネクタ突起 (簡易)
        color(COLOR_CONN)
        translate([5.05, 0, -body_h/2 - 5])
            cube([8, 10, 2], center=true);
    }
}

// 実行
gp2y0a21yk0f();