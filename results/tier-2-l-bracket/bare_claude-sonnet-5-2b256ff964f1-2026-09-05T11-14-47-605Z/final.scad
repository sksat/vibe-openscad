// =========================================
// L字金具 (L-bracket) with countersunk holes
// =========================================

width      = 50;   // X方向:幅
depth      = 40;   // Y方向:水平面の奥行き
height     = 40;   // Z方向:垂直面の高さ
thick      = 3;    // 板厚

hole_d     = 4.5;  // 貫通穴径 (M4用)
csk_d      = 8;    // 皿座面径
csk_depth  = 2;    // 皿座面深さ
edge_off   = 10;   // 縁からの穴中心オフセット

hole_x = width/2 - edge_off;  // = 15
eps    = 0.5;                 // ブーリアン演算用の余裕

$fn = 64;

// ---------- 本体形状 ----------
module bracket_body(){
    union(){
        // 水平面: 内側面 Z=0 (原点), 外側面 Z=-thick
        translate([-width/2, 0, -thick])
            cube([width, depth, thick]);

        // 垂直面: 内側面 Y=0 (原点), 外側面 Y=-thick
        translate([-width/2, -thick, 0])
            cube([width, thick, height]);

        // 内側コーナーを埋める補強ブロック(折り曲げ部の連続性確保)
        translate([-width/2, -thick, -thick])
            cube([width, thick, thick]);
    }
}

// ---------- 水平面用 皿穴(Z方向に貫通、外側=下面に皿座面) ----------
module h_hole(x, y){
    translate([x, y, 0]){
        // 貫通穴
        translate([0, 0, -thick - eps])
            cylinder(h = thick + 2*eps, d = hole_d);

        // 皿座面(外側 Z=-thick 側が広い)
        translate([0, 0, -thick - eps])
            cylinder(h = csk_depth + eps, r1 = csk_d/2, r2 = hole_d/2);
    }
}

// ---------- 垂直面用 皿穴(Y方向に貫通、外側=背面に皿座面) ----------
module v_hole(x, z){
    translate([x, 0, z])
        rotate([-90, 0, 0]){
            // 貫通穴
            translate([0, 0, -thick - eps])
                cylinder(h = thick + 2*eps, d = hole_d);

            // 皿座面(外側 Y=-thick 側が広い)
            translate([0, 0, -thick - eps])
                cylinder(h = csk_depth + eps, r1 = csk_d/2, r2 = hole_d/2);
        }
}

// ---------- 全ての穴 ----------
module all_holes(){
    // 水平面: 中心線 Y = depth/2, 左右対称にX方向へオフセット
    h_hole( hole_x, depth/2);
    h_hole(-hole_x, depth/2);

    // 垂直面: 中心線 Z = height/2, 左右対称にX方向へオフセット
    v_hole( hole_x, height/2);
    v_hole(-hole_x, height/2);
}

// ---------- 最終形状 ----------
difference(){
    bracket_body();
    all_holes();
}