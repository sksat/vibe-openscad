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
handle_thickness = 8;  // 取手の太さ

module mug_body() {
    difference() {
        cylinder(d = outer_d, h = height);
        translate([0, 0, bottom_thickness])
            cylinder(d = inner_d, h = height - bottom_thickness + 0.01);
    }
}

module handle() {
    // 取手は XZ 平面上に置いた 2D D 字形状を作り、Y 方向に押し出す
    // 取手全体: 高さ(Z) = handle_inner_h + 2*handle_thickness
    //          幅(X)  = handle_inner_w + handle_thickness(本体側の壁分)
    
    handle_outer_h = handle_inner_h + 2 * handle_thickness; // Z 方向
    handle_outer_w = handle_inner_w + handle_thickness;     // X 方向
    
    z_center = height / 2;
    // 本体外周に少し食い込ませて確実に union
    x_base = outer_d/2 - 1;
    
    translate([x_base, 0, z_center])
        rotate([90, 0, 0])  // XZ平面の2D図形をXY平面で描き、Y押し出し→rotateで縦に
            translate([0, 0, -handle_thickness/2])
                linear_extrude(height = handle_thickness)
                    difference() {
                        // 外形 D 字 (XY平面で X方向に伸びる、Y軸が高さ方向)
                        hull() {
                            // 本体側の直線部(Y軸方向の薄い長方形)
                            translate([0, 0])
                                square([0.1, handle_outer_h], center = true);
                            // 外側の半円
                            translate([handle_outer_w - handle_outer_h/2, 0])
                                circle(d = handle_outer_h);
                        }
                        // 内側の穴 (D字の内側)
                        hull() {
                            translate([handle_thickness, 0])
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