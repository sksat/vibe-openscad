// ============================================
// マグカップ (OpenSCAD)
// 外径 80mm / 高さ 100mm / 肉厚 4mm / 底厚 6mm
// 側面中央にリング状の取手(リング半径 12mm)
// ============================================
$fn = 96;

// --- カップ本体の寸法 ---
outer_d  = 80;               // 外径
height   = 100;              // 高さ
wall_t   = 4;                // 肉厚
bottom_t = 6;                // 底面の厚み

outer_r  = outer_d / 2;      // 外半径 = 40
inner_r  = outer_r - wall_t; // 内半径 = 36

// --- 取手の寸法 ---
handle_r  = 12;              // リングの半径(リング中心線までの半径)
handle_t  = 3.5;             // リングの太さ(断面円の半径) → 指穴の直径 = 2*(12-3.5) = 17mm
handle_z  = height / 2;      // 取手を付ける高さ(カップの中心高さ)

// リング中心の X 位置:
// リング中心線が外周に接するようにし、断面の内側半分を壁に埋め込んで一体化させる。
// これによりリングの穴は完全に外周の外側に出て、指を通せる。
handle_cx = outer_r + handle_r;

// 外側の円柱(本体)
module body() {
    cylinder(h = height, r = outer_r);
}

// 内側のくり抜き(底面 bottom_t を残し、上面は突き抜けさせる)
module cavity() {
    translate([0, 0, bottom_t])
        cylinder(h = height, r = inner_r);
}

// リング状の取手(トーラス)。+X 方向(半径方向)に飛び出す
module handle() {
    translate([handle_cx, 0, handle_z])
        rotate([90, 0, 0])              // リングを鉛直面(XZ 平面)に立てる
            rotate_extrude()
                translate([handle_r, 0])
                    circle(r = handle_t);
}

module mug() {
    difference() {
        union() {
            body();
            handle();
        }
        cavity();   // 取手が内側に食い込んでも飲み物の空間はきれいに残す
    }
}

mug();