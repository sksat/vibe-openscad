// マグカップ

$fn = 100;

// 本体パラメータ
outer_d = 80;
inner_d = 70;
height = 90;
bottom_thickness = 6;

// 取手パラメータ
handle_inner_h = 30;   // 取手の内側の空間高さ
handle_inner_w = 25;   // 取手の内側の空間幅
handle_thickness = 8;  // 取手の太さ
handle_depth = 10;     // 取手の奥行き(押し出し方向)

module mug_body() {
    difference() {
        cylinder(d = outer_d, h = height);
        translate([0, 0, bottom_thickness])
            cylinder(d = inner_d, h = height - bottom_thickness + 1);
    }
}

module handle() {
    // 取手は +X 方向に付く D 字形状
    // 外側のD字 - 内側のD字 で輪郭を作り、Y方向に押し出す
    
    outer_w = handle_inner_w + 2 * handle_thickness;
    outer_h = handle_inner_h + 2 * handle_thickness;
    
    // 本体側のX位置(本体外周にしっかり食い込ませる)
    base_x = outer_d / 2 - 2;
    
    translate([base_x, -handle_depth/2, height/2])
        rotate([-90, 0, 0])
            linear_extrude(height = handle_depth)
                difference() {
                    // 外側D字
                    union() {
                        square([outer_w/2, outer_h], center = false)
                            ;
                        translate([0, outer_h/2 - outer_h/2 + 0, 0]);
                        // 半円部分
                    }
                    // 内側D字をくり抜く
                }
}

// 上記が複雑なので書き直し
module d_shape(w, h) {
    // 左端が直線(x=0)、右側が半円のD字
    // w: 全体の幅、h: 高さ
    // 半円の半径 = h/2、矩形部分の幅 = w - h/2
    rect_w = w - h/2;
    union() {
        if (rect_w > 0)
            translate([0, -h/2]) square([rect_w, h]);
        translate([rect_w, 0]) circle(d = h);
    }
}

module handle2() {
    outer_w = handle_inner_w + handle_thickness; // 直線部+半円分相当に調整
    outer_h = handle_inner_h + 2 * handle_thickness;
    inner_w = handle_inner_w;
    inner_h = handle_inner_h;
    
    base_x = outer_d / 2 - 3; // 本体に少し食い込ませる
    
    translate([base_x, 0, height/2])
        rotate([90, 0, 0])
            linear_extrude(height = handle_depth, center = true)
                difference() {
                    d_shape(outer_w + handle_thickness, outer_h);
                    translate([0, 0])
                        d_shape(inner_w + handle_thickness/2, inner_h);
                }
}

union() {
    mug_body();
    handle2();
}