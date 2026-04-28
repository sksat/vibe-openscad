module l_bracket(length_x = 50, length_y = 40, thickness = 3) {
    // 水平面
    cube([length_x, length_y, thickness]);
    // 垂直面
    translate([0, 0, length_y])
    rotate([90, 0, 0])
    cube([length_x, thickness, length_y]);
}

module countersunk_hole(screw_size = "M4") {
    $fn=30; // 円の滑らかさ

    // M4 ねじ用貫通穴
    if (screw_size == "M4") {
        hole_diameter = 4.5;
        countersink_diameter = 8;
        countersink_depth = 2;
    } else {
        // デフォルトまたはエラー処理
        hole_diameter = 4.5;
        countersink_diameter = 8;
        countersink_depth = 2;
    }

    // 皿座面
    cylinder(h = countersink_depth, d1 = countersink_diameter, d2 = countersink_diameter);
    // 貫通穴
    translate([0, 0, countersink_depth])
    cylinder(h = 10, d = hole_diameter); // 十分な長さを確保
}

// パラメータ設定
bracket_length_x = 50;
bracket_length_y = 40;
bracket_thickness = 3;
hole_margin_from_edge = 10;

// L字金具本体
l_bracket(bracket_length_x, bracket_length_y, bracket_thickness);

// 皿穴 (水平面)
// 右側
translate([bracket_length_x / 2, (bracket_length_y - bracket_length_y/4) , bracket_thickness]) // 中心線上の位置調整
rotate([0, 0, 0])
translate([- (bracket_length_x/2 - hole_margin_from_edge), - (bracket_length_y - hole_margin_from_edge) , 0]) // 穴の位置調整
rotate([0, 90, 0])
countersunk_hole();

// 左側
translate([bracket_length_x / 2, (bracket_length_y / 4), bracket_thickness]) // 中心線上の位置調整
rotate([0, 0, 0])
translate([- (bracket_length_x/2 - hole_margin_from_edge), - (bracket_length_y - hole_margin_from_edge) , 0]) // 穴の位置調整
rotate([0, 90, 0])
countersunk_hole();

// 皿穴 (垂直面)
// 上側
translate([bracket_length_x / 2, 0, bracket_length_y]) // 中心線上の位置調整
rotate([0, 90, 0])
translate([- (bracket_length_x/2 - hole_margin_from_edge), - (bracket_length_y - hole_margin_from_edge) , 0]) // 穴の位置調整
rotate([0, 0, 0])
countersunk_hole();

// 下側
translate([bracket_length_x / 2, 0, bracket_length_y]) // 中心線上の位置調整
rotate([0, 90, 0])
translate([- (bracket_length_x/2 - hole_margin_from_edge), - (bracket_length_y / 4), 0]) // 穴の位置調整
rotate([0, 0, 0])
countersunk_hole();

// 穴をくり抜くための差分モジュール
module subtract_holes() {
    // 水平面の穴
    translate([bracket_length_x/2, bracket_length_y/2, bracket_thickness]) {
        translate([-bracket_length_x/4, 0, 0]) {
            rotate([0, 90, 0])
            countersunk_hole();
        }
        translate([bracket_length_x/4, 0, 0]) {
            rotate([0, 90, 0])
            countersunk_hole();
        }
    }

    // 垂直面の穴
    translate([bracket_length_x/2, bracket_thickness/2, bracket_length_y/2]) {
        translate([0, 0, bracket_length_y/4]) {
            rotate([90, 0, 0])
            countersunk_hole();
        }
        translate([0, 0, -bracket_length_y/4]) {
            rotate([90, 0, 0])
            countersunk_hole();
        }
    }
}

difference() {
    l_bracket(bracket_length_x, bracket_length_y, bracket_thickness);
    subtract_holes();
}