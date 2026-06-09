// ===== マグカップ =====
$fn = 120;

// --- パラメータ ---
outer_d  = 80;    // 外径 [mm]
cup_h    = 100;   // 高さ [mm]
wall_t   = 4;     // 側面の肉厚 [mm]
bottom_t = 6;     // 底面の厚み [mm]

handle_r = 12;    // 取手リングの半径(大半径) [mm]
handle_t = 5;     // 取手の太さ(断面円の半径) [mm]

// --- 取手(トーラス形状) ---
module handle() {
    // リングが垂直(カップ軸を含む面内)になるよう回転
    rotate([90, 0, 0])
        rotate_extrude(convexity = 10)
            translate([handle_r, 0])
                circle(r = handle_t);
}

// --- 本体 ---
difference() {
    union() {
        // カップ外形
        cylinder(d = outer_d, h = cup_h);

        // 取手:中心高さに配置し、壁にめり込ませて接合
        // 外周から (2*handle_r) 程度はみ出し、指を通せる
        translate([outer_d/2 + handle_r - handle_t, 0, cup_h/2])
            handle();
    }

    // 内側のくり抜き(底面 bottom_t を残して上面まで貫通)
    // ※取手が内側に食い込んだ分もここで除去される
    translate([0, 0, bottom_t])
        cylinder(d = outer_d - 2*wall_t, h = cup_h);
}