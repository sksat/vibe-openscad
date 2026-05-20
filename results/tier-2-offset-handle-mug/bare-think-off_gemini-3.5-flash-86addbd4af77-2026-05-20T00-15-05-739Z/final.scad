// マグカップのパラメータ
body_outer_dia = 80;
body_inner_dia = 70;
body_height = 90;
bottom_thickness = 6;

// 取っ手のパラメータ
handle_inner_h = 30;
handle_inner_w = 25;
handle_thickness = 10; // 取っ手の太さ

$fn = 100; // 円の分割数（滑らかさ）

module mug_body() {
    difference() {
        // 外側円筒
        cylinder(d = body_outer_dia, h = body_height);
        
        // 内側中空部分（底の厚みを残す）
        translate([0, 0, bottom_thickness])
            cylinder(d = body_inner_dia, h = body_height - bottom_thickness + 1);
    }
}

module mug_handle() {
    // 取っ手の中心位置をマグの中央高さに合わせ、+X方向に配置
    handle_y_offset = body_height / 2;
    handle_x_offset = body_outer_dia / 2 - 2; // 少し本体にめり込ませてunionを確実にする

    translate([handle_x_offset, 0, handle_y_offset]) {
        rotate([90, 0, 90]) { // YZ平面に沿うように回転
            difference() {
                // 取っ手の外形（D字型の角丸長方形を表現するために2D offsetを使用）
                linear_extrude(height = handle_thickness, center = true) {
                    difference() {
                        // 外側の輪郭
                        hull() {
                            translate([0, -(handle_inner_h/2 + handle_thickness)])
                                circle(r = handle_thickness);
                            translate([0, handle_inner_h/2 + handle_thickness])
                                circle(r = handle_thickness);
                            translate([handle_inner_w + handle_thickness, 0])
                                circle(r = handle_inner_h/2 + handle_thickness);
                        }
                        // 内側の穴
                        hull() {
                            translate([0, -handle_inner_h/2])
                                circle(r = 0.1);
                            translate([0, handle_inner_h/2])
                                circle(r = 0.1);
                            translate([handle_inner_w, 0])
                                circle(r = handle_inner_h/2);
                        }
                        // 本体側（X<=0）をカットして平らにし、接続を安定させる
                        translate([-handle_thickness*2, -(handle_inner_h + handle_thickness*2)])
                            square([handle_thickness*2, (handle_inner_h + handle_thickness*2)*2]);
                    }
                }
            }
        }
    }
}

// 本体と取っ手の結合
union() {
    mug_body();
    mug_handle();
}