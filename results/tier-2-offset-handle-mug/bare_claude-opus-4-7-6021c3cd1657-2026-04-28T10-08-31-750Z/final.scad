// マグカップ

$fn = 100;

// 本体パラメータ
outer_d = 80;
inner_d = 70;
height = 90;
bottom_thickness = 6;

// 取手パラメータ
handle_inner_h = 30;   // 取手内側の高さ
handle_inner_w = 25;   // 取手内側の幅(本体からの突き出し)
handle_thickness = 8;  // 取手の太さ(指を握る部分の太さ)

module mug_body() {
    difference() {
        cylinder(d = outer_d, h = height);
        translate([0, 0, bottom_thickness])
            cylinder(d = inner_d, h = height);
    }
}

module handle() {
    // 取手の外形と内側の空間
    // 取手は +X 側に配置
    // 外側 D 形状: 全体高さ = handle_inner_h + 2*handle_thickness
    // 全体幅 = handle_inner_w + handle_thickness(本体側は本体内に埋め込む)
    
    handle_outer_h = handle_inner_h + 2 * handle_thickness;
    handle_outer_w = handle_inner_w + handle_thickness;
    
    // 中央高さに配置
    z_center = height / 2;
    
    // 本体側へ少し食い込ませて確実にunion
    x_start = outer_d/2 - 2;
    
    translate([x_start, 0, z_center])
        rotate([90, 0, 0])
            linear_extrude(height = handle_outer_h, center = true)
                difference() {
                    // 外形 D 字
                    hull() {
                        // 本体側の直線部分(細い長方形)
                        translate([0, -handle_outer_h/2 + handle_outer_h/2, 0])
                            square([0.1, handle_outer_h], center = true);
                        // 外側の半円
                        translate([handle_outer_w - handle_outer_h/2, 0])
                            circle(d = handle_outer_h);
                    }
                    // 内側の穴(D字の内側)
                    hull() {
                        translate([handle_thickness, 0, 0])
                            square([0.1, handle_inner_h], center = true);
                        translate([handle_thickness + handle_inner_w - handle_inner_h/2, 0])
                            circle(d = handle_inner_h);
                    }
                }
}

union() {
    mug_body();
    handle();
}