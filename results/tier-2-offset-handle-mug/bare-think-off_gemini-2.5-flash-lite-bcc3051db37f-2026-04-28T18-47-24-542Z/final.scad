// マグカップのパラメータ
outer_diameter = 80;
inner_diameter = 70;
wall_thickness = (outer_diameter - inner_diameter) / 2;
height = 90;
bottom_thickness = 6;

// 取手のパラメータ
handle_inner_height = 30;
handle_inner_width = 25;
handle_thickness = 5; // 本体との接続部分の厚み
handle_outer_radius = (handle_inner_width / 2) + handle_thickness;
handle_inner_radius = handle_inner_width / 2;
handle_connection_height_offset = (height - handle_inner_height) / 2; // 取手を高さ中央に配置するためのオフセット

// マグ本体の作成
module mug_body() {
    difference() {
        // 外側の円筒
        cylinder(h = height, d = outer_diameter, $fn = 100);
        // 内側の円筒 (飲み物用空間)
        translate([0, 0, bottom_thickness]) {
            cylinder(h = height - bottom_thickness, d = inner_diameter, $fn = 100);
        }
    }
}

// 取手の作成
module mug_handle() {
    // 取手の内側の空間の形状を定義
    handle_inner_shape = linear_extrude(height = handle_thickness, $fn = 100) {
        square([handle_inner_width, handle_inner_height], center = true);
    };

    // 取手の外側の形状を定義 (D字の半円部分)
    handle_outer_shape = linear_extrude(height = handle_thickness, $fn = 100) {
        hull() {
            translate([0, 0, 0]) circle(r = handle_outer_radius, $fn = 100);
            translate([handle_inner_width, 0, 0]) circle(r = handle_outer_radius, $fn = 100);
        }
    };

    // 取手の全体形状
    union() {
        // 外側の形状 (半円部分)
        translate([0, 0, handle_connection_height_offset]) {
            rotate([0, 90, 0]) { // Y軸周りに回転して本体に接続する向きにする
                union() {
                    // 円筒部分
                    cylinder(h = handle_thickness, d = handle_outer_radius * 2, $fn = 100);
                    // 半円部分を補完する部分
                    translate([0, 0, -handle_outer_radius]) { // Y軸方向にずらす
                        hull() {
                            translate([0, 0, 0]) circle(r = handle_outer_radius, $fn = 100);
                            translate([0, 0, handle_inner_height]) circle(r = handle_outer_radius, $fn = 100);
                        }
                    }
                }
            }
        }

        // 取手の内側の空間をくり抜く
        translate([0, 0, handle_connection_height_offset]) {
            rotate([0, 90, 0]) { // Y軸周りに回転して本体に接続する向きにする
                translate([0, 0, -handle_inner_height / 2]) { // Y軸中央に配置
                    handle_inner_shape;
                }
            }
        }
    }
}

// マグカップ本体と取手を結合
union() {
    mug_body();

    // 取手を本体の +X 軸方向に配置
    translate([outer_diameter / 2, 0, 0]) { // 本体外周に接続
        rotate([0, 0, 90]) { // Z軸周りに回転して+X方向へ
            mug_handle();
        }
    }
}