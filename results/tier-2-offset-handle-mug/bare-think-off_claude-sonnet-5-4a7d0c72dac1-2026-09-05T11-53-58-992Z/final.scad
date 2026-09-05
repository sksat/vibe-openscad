// マグカップ本体と取手

$fn = 100;

// 本体パラメータ
outer_radius = 40;      // 外径80mm
inner_radius = 35;      // 内径70mm
mug_height = 90;
bottom_thickness = 6;

// 取手パラメータ
handle_inner_height = 30;
handle_inner_width = 25;
handle_thickness = 8;      // 取手の太さ(押し出し断面の直径)
handle_center_z = mug_height / 2;

module mug_body() {
    difference() {
        cylinder(h = mug_height, r = outer_radius);
        translate([0, 0, bottom_thickness])
            cylinder(h = mug_height, r = inner_radius);
    }
}

// D字型取手
// 外側が半円、本体側が直線のD字形状の断面を、上下に扫掠(スイープ)して立体を作る
module handle() {
    // D字の内側空間サイズ
    inner_w = handle_inner_width;   // X方向の内側幅(本体からの張り出し量)
    inner_h = handle_inner_height;  // Z方向の内側高さ

    // 全体の外形サイズ(内側 + 太さ分)
    outer_w = inner_w + handle_thickness;
    outer_h = inner_h + handle_thickness * 2;

    // 本体外周に接続するX位置
    x_base = outer_radius - 1; // 少しめり込ませて確実に union

    translate([x_base, 0, handle_center_z]) {
        rotate([90, 0, 0]) {
            linear_extrude(height = handle_thickness, center = true) {
                difference() {
                    // 外側のD字形状(半円 + 直線側)
                    d_shape(outer_w, outer_h);
                    // 内側のD字形状をくり抜く(内側空間)
                    d_shape_inner(inner_w, inner_h, handle_thickness);
                }
            }
        }
    }
}

// D字形状:左側が直線(本体側)、右側が半円
module d_shape(w, h) {
    r = h / 2;
    union() {
        // 直線部分(左側の四角)
        translate([-1, -h/2])
            square([r + 1, h]);
        // 半円部分(右側)
        translate([r, 0])
            circle(r = r);
    }
}

// 内側(くり抜き用)のD字形状。thicknessの分だけ小さくする
module d_shape_inner(w, h, thickness) {
    r = h / 2;
    union() {
        translate([-1, -h/2])
            square([r + 1, h]);
        translate([r, 0])
            circle(r = r);
    }
}

// 取手全体をより正確に:内側空間を確保しつつ外形はD字
module handle_solid() {
    inner_w = handle_inner_width;
    inner_h = handle_inner_height;
    t = handle_thickness;

    outer_h = inner_h + 2 * t;
    outer_r = outer_h / 2;

    x_base = outer_radius - 2; // 本体にめり込ませる

    translate([x_base, 0, handle_center_z]) {
        rotate([90, 0, 0]) {
            linear_extrude(height = t, center = true) {
                difference() {
                    // 外形:左が直線、右が半円のD字
                    hull() {
                        translate([0, -outer_r])
                            square([1, outer_h]);
                        translate([outer_r, 0])
                            circle(r = outer_r);
                    }
                    // 内側の穴:同じくD字型にくり抜き、指が入る空間を作る
                    translate([t, 0]) {
                        inner_r = inner_h / 2;
                        hull() {
                            translate([0, -inner_r])
                                square([1, inner_h]);
                            translate([inner_w - inner_r, 0])
                                circle(r = inner_r);
                        }
                    }
                }
            }
        }
    }
}

module mug_with_handle() {
    union() {
        mug_body();
        handle_solid();
    }
}

mug_with_handle();