// OpenSCAD: マグカップ (指定寸法) + D字取手（+X 側のみ）
// 単位: mm

$fn = 120; // 円を滑らかに

// -------- パラメータ --------
mug_outer_r = 40;    // 外半径 (外径 80)
mug_inner_r = 35;    // 内半径 (内径 70)
mug_h = 90;          // 高さ
bottom_thickness = 6;

handle_overlap = 1;          // 本体へめり込み量（接合確実化）
flat_face_x = mug_outer_r - handle_overlap; // 取手の本体接触面の X 座標 (本体側直線)
inner_open_w = 25;          // 取手内側空間の幅 (radial direction)
inner_open_h = 30;          // 取手内側空間の高さ (vertical direction)
handle_wall = 8;            // 取手の外側と内側の間の厚み（適度に確保）
R_out = inner_open_w + handle_wall; // 外側半円の半径（平面投影）
handle_extrude_h = 40;      // 取手全体の垂直厚み（内空間高さより大きく取る）
mug_center_z = mug_h/2;

// 取手配置用座標
outer_center_x = flat_face_x + R_out; // 外側半円の中心 x
inner_void_left_x = mug_outer_r;      // 内側空間の左端をマグ本体外周(=40)に合わせる（本体への穴の侵入を防ぐ）
inner_void_right_x = inner_void_left_x + inner_open_w;

// Z 配置
handle_z_bottom = mug_center_z - handle_extrude_h/2; // 取手外形の下端 (global Z)
inner_void_z = mug_center_z - inner_open_h/2;        // 内空間の下端 (global Z)

// -------- モジュール --------
module mug() {
    // 外殻 - 中空底付きの円筒
    difference() {
        // 外側
        translate([0,0,0]) cylinder(h=mug_h, r=mug_outer_r);
        // 内側の空間（底厚を残す）
        translate([0,0,bottom_thickness]) cylinder(h=mug_h - bottom_thickness, r=mug_inner_r);
    }
}

module handle_piece() {
    // 2D 外側半円形 (flat_face_x を直径の線とする半円)
    outer2d = intersection() {
        translate([outer_center_x, 0]) circle(r=R_out);
        // 半平面 x >= flat_face_x をつくる大きな矩形
        translate([flat_face_x, - (R_out + 10)]) square([ (outer_center_x+R_out) - flat_face_x + 10, 2*(R_out + 10) ]);
    }

    // 取手の外形を押し出してグローバル空間に配置
    outer_extruded = translate([0,0,handle_z_bottom]) linear_extrude(height = handle_extrude_h, center = false, convexity = 10) outer2d;

    // 取手内側の指を入れる空間（長方形で簡潔に）
    inner_void = translate([inner_void_left_x, -inner_open_h/2, inner_void_z]) cube([inner_open_w, inner_open_h, inner_open_h], center = false);

    // 内空間を差し引いて取手本体を得る
    difference() {
        outer_extruded;
        inner_void;
    }
}

// -------- 組み立て --------
union() {
    // 本体
    mug();

    // 取手（+X 側のみ）
    // 差し引きを済ませた取手本体をそのまま union する（flat_face_x による少しのめり込みで確実に接続）
    handle_piece();
}