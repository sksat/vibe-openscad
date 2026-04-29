// --- 寸法設定 ---
outer_diameter = 80; // 外径 (mm)
height = 100;        // 高さ (mm)
wall_thickness = 4;  // 側面肉厚 (mm)
bottom_thickness = 6; // 底面の厚み (mm)

// --- 取っ手の設定 ---
handle_radius = 12; // 取っ手の半径 (mm)
handle_position_offset = 0; // 取っ手の外側からの突出量（ここでは単純にR+handle_radiusで定義）

// --- 計算値 ---
outer_radius = outer_diameter / 2;
inner_radius = outer_radius - wall_thickness;

// 底面の形状を考慮した内部の円の半径 (底厚6mmを考慮)
inner_bottom_radius = inner_radius - bottom_thickness;


// --- 本体 (マグカップ本体) ---

// 1. 外側の円筒 (最も外側のシェル)
cylinder(h = height, r = outer_radius);

// 2. 内側のくり抜き (飲み物が入る空間)
// 底面の厚み6mmを考慮して内側を定義
difference() {
    // 本体全体（外側の形状）
    cylinder(h = height, r = outer_radius);

    // 内部のくり抜き
    // 内径は、外径から側面肉厚と底厚を引いた値で定義される必要があるが、ここでは単純に内側の円筒をくり抜く。
    translate([0, 0, -0.1]) { // Z軸方向に少し下に開始
        cylinder(h = height + 0.2, r = inner_radius);
    }
}


// --- 取っ手 (リング状) の追加 ---

// 取っ手の中心高さ (カップの中心、高さ50mmの位置)
handle_center_z = height / 2;

// 取っ手を配置するための計算
// 取っ手は外側からR=12mm飛び出す。外側の円筒の半径は40mm。
// 取っ手の内側の円（くぼみ）の半径は、外側R=40 - (壁厚+取手の突出量)
handle_inner_radius = outer_radius - wall_thickness - handle_radius;

// 取っ手本体を生成するための計算
rotate([0, 0, 90]) { // Z軸を回転させて円盤として配置
    difference() {
        // 外側のリング部分 (外径40mmから始まる)
        cylinder(h = height + 10, r1 = outer_radius + handle_radius, r2 = outer_radius);

        // 内側の穴（くぼみ）
        cylinder(h = height + 10, r = handle_inner_radius);
    }
}