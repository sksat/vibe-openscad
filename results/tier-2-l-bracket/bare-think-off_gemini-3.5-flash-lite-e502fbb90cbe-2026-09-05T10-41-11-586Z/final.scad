// パラメータ設定
width = 50;       // フランジの幅
depth = 40;       // 水平面の奥行き
height = 40;      // 垂直面の高さ
thickness = 3;    // 板厚

// M4皿穴のパラメータ
hole_d = 4.5;     // 貫通穴の直径
csk_d = 8.0;      // 皿座面の直径
csk_depth = 2.0;  // 皿座面の深さ
edge_margin = 10; // 縁からの距離

// 穴の位置計算
// 幅方向の中心から左右に配置
hole_x1 = edge_margin;
hole_x2 = width - edge_margin;

// 水平面の穴のY位置（原点から縁に向かって）
hole_y = depth - edge_margin;

// 垂直面の穴のZ位置（原点から上に向かって）
hole_z = height - edge_margin;

module l_bracket() {
    difference() {
        // L字のベース形状 (内側コーナーが原点)
        union() {
            // 水平面 (+Y方向へ奥行き分)
            cube([width, depth, thickness]);
            // 垂直面 (+Z方向へ高さ分)
            cube([width, thickness, height]);
        }

        // --- 水平面の皿穴 (2個) ---
        // 皿座面を下面(-Z方向)から加工するため、配置して反転・平行移動
        // 貫通穴はZ軸方向に長く抜く
        translate([0, 0, 0]) {
            // 左側の穴
            translate([hole_x1, hole_y, 0])
                horizontal_countersunk_hole();
            // 右側の穴
            translate([hole_x2, hole_y, 0])
                horizontal_countersunk_hole();
        }

        // --- 垂直面の皿穴 (2個) ---
        // 皿座面を前面(-Y方向)から加工
        translate([0, 0, 0]) {
            // 左側の穴
            translate([hole_x1, 0, hole_z])
                vertical_countersunk_hole();
            // 右側の穴
            translate([hole_x2, 0, hole_z])
                vertical_countersunk_hole();
        }
    }
}

// 水平面用皿穴（下面からボルトを入れるため、-Z方向に向かって皿座面を作る）
module horizontal_countersunk_hole() {
    // 貫通穴 (板厚を貫通)
    cylinder(d = hole_d, h = thickness + 1, $fn = 32);
    // 皿座面 (下面 = z=0 から内側へ向けて掘る)
    translate([0, 0, -0.01])
        cylinder(d = hole_d, d2 = csk_d, h = csk_depth + 0.01, $fn = 32);
}

// 垂直面用皿穴（前面からボルトを入れるため、-Y方向に向かって皿座面を作る）
module vertical_countersunk_hole() {
    // 貫通穴 (板厚を貫通 -Y方向)
    rotate([-90, 0, 0])
        cylinder(d = hole_d, h = thickness + 1, $fn = 32);
    // 皿座面 (前面 = y=0 から内側へ向けて掘る)
    rotate([-90, 0, 0])
        cylinder(d = hole_d, d2 = csk_d, h = csk_depth + 0.01, $fn = 32);
}

// 実行
l_bracket();