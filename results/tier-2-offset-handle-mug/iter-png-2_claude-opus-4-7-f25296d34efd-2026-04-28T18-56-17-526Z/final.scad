// マグカップ

$fn = 100;

// 本体パラメータ
outer_d = 80;
inner_d = 70;
height = 90;
bottom_thickness = 6;

// 取手パラメータ
handle_inner_h = 30;   // 取手内側の高さ(Z方向)
handle_inner_w = 25;   // 取手内側の幅(本体からの突き出し方向 = X)
handle_thickness = 8;  // 取手の太さ(Y方向の厚み)

module mug_body() {
    difference() {
        cylinder(d = outer_d, h = height);
        translate([0, 0, bottom_thickness])
            cylinder(d = inner_d, h = height - bottom_thickness + 0.01);
    }
}

module handle() {
    // XZ 平面に D 字形状を 2D で描き、Y 方向に linear_extrude して厚みを付ける。
    // 描画後、X-Z 平面の 2D を扱うため、いったん XY で描いて rotate([90,0,0]) で立てる。
    
    handle_outer_h = handle_inner_h + 2 * handle_thickness; // Z 方向の総高さ
    handle_outer_w = handle_inner_w + handle_thickness;     // X 方向の総幅(本体面から外へ)
    
    z_center = height / 2;
    // 本体外周に少し食い込ませて確実に union
    x_base = outer_d/2 - 1;
    
    translate([x_base, 0, z_center])
        rotate([90, 0, 0])  // XY平面で描いた図形のY軸→Z軸に立てる
            translate([0, 0, -handle_thickness/2])
                linear_extrude(height = handle_thickness)
                    difference() {
                        // 外形 D 字: 左端(本体側)は直線、右側は半円
                        hull() {
                            // 本体側の直線部(Y軸方向に伸びる細長い長方形)
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