// ===============================
//  マグカップ (OpenSCAD)
//  外径 80mm / 高さ 100mm / 肉厚 4mm / 底厚 6mm
//  半径 12mm のリング状取手付き
// ===============================

$fn = 96;

// --- カップ本体のパラメータ ---
outer_d  = 80;    // 外径
height   = 100;   // 高さ
wall     = 4;     // 側面の肉厚
bottom   = 6;     // 底面の厚み

outer_r  = outer_d / 2;
inner_r  = outer_r - wall;

// --- 取手のパラメータ ---
handle_r      = 12;          // リングの半径(中心線の半径)
handle_tube_r = 4;           // リングの太さ(断面の半径)
handle_z      = height / 2;  // 取手の取り付け高さ(カップ中心高さ)

// リングの内側の穴がカップ外周の外に出るように、
// リング中心を外周より外側に配置する
handle_x = outer_r + handle_r - handle_tube_r;

// --- カップの外形(無垢の円柱) ---
module cup_body() {
    cylinder(r = outer_r, h = height);
}

// --- 内側のくり抜き(底厚を残す) ---
module cavity() {
    translate([0, 0, bottom])
        cylinder(r = inner_r, h = height - bottom + 1);
}

// --- リング状の取手(トーラス) ---
module handle() {
    translate([handle_x, 0, handle_z])
        rotate([90, 0, 0])             // リングを縦向き(XZ平面)にする
            rotate_extrude($fn = 96)
                translate([handle_r, 0, 0])
                    circle(r = handle_tube_r, $fn = 48);
}

// --- 組み立て ---
difference() {
    union() {
        cup_body();
        handle();
    }
    // 取手がカップ内部に食い込んだ部分も一緒に除去する
    cavity();
}