// OpenSCAD: マグカップ（修正版）
// 単位: mm

$fn = 120; // 円を滑らかに

// -------- パラメータ --------
mug_outer_r = 40;    // 外半径 (外径 80)
mug_inner_r = 35;    // 内半径 (内径 70)
mug_h = 90;          // 高さ
bottom_thickness = 6;

handle_wall = 8;            // 取手の厚み（外側と内側の差）
inner_open_w = 25;          // 取手内側空間の幅 (指 3 本ぐらい)
inner_open_h = 30;          // 取手内側空間の高さ

// 小さく重なりを持たせて本体に確実に接続する（面接触を避ける）
overlap = 1;

// 取手外側の半円半径（内側幅の半分 + 壁厚）
R_out = inner_open_w/2 + handle_wall; // = 12.5 + handle_wall

// 取手の平面（フラット面）の X 座標（本体外周に少し食い込ませる）
flat_face_x = mug_outer_r - overlap; // フラット面を本体外周より overlap mm 内側にする
outer_center_x = flat_face_x + R_out; // 半円中心の X

// 取手の垂直サイズ
handle_extrude_h = inner_open_h + 2*handle_wall; // 内空間より上下に壁分を確保
mug_center_z = mug_h/2;
handle_z_bottom = mug_center_z - handle_extrude_h/2;
inner_void_z = mug_center_z - inner_open_h/2;

// -------- モジュール --------
module mug() {
    difference() {
        // 外側の円筒
        translate([0,0,0]) cylinder(h=mug_h, r=mug_outer_r);
        // 内側の空洞（底面の厚みを残す）
        translate([0,0,bottom_thickness]) cylinder(h=mug_h - bottom_thickness, r=mug_inner_r);
    }
}

module handle_piece() {
    // 取手外形（半円＋フラット面）を押し出し、内側の指空間を差し引く
    difference() {
        // 外形: 半円（外側が半円、内側がフラット）
        translate([0,0,handle_z_bottom])
            linear_extrude(height = handle_extrude_h, center = false, convexity = 10)
                intersection() {
                    // 半径 R_out の円（右側半分を残す）
                    translate([outer_center_x, 0]) circle(r=R_out);
                    // フラット面で切る矩形（左端を flat_face_x - 1 にして確実に切断）
                    translate([flat_face_x - 1, -(R_out + 10)])
                        square([ (outer_center_x + R_out) - (flat_face_x - 1) + 20, 2*(R_out + 10) ]);
                }

        // 取手内側の空間（指を入れる部分）を差し引く
        // 左端を flat_face_x に合わせ、幅 inner_open_w、高さ inner_open_h、中央位置は inner_void_z
        translate([flat_face_x, -(R_out + 10), inner_void_z])
            cube([inner_open_w, 2*(R_out + 10), inner_open_h]);
    }
}

// -------- 組み立て --------
union() {
    mug();
    handle_piece();
}