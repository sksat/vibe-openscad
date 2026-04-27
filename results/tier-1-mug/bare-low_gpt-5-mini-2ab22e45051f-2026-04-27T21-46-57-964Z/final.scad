// OpenSCAD: マグカップ（外径80mm, 高さ100mm, 肉厚4mm, 底厚6mm, リング状取手）
// 単位: mm

$fn = 120; // 表示を滑らかにする

// パラメータ
outer_dia = 80;
outer_r = outer_dia / 2;
height = 100;

wall_thickness = 4;
inner_r = outer_r - wall_thickness;

base_thickness = 6;
inner_height = height - base_thickness; // 内部の高さ（底を除く）

handle_cross_r = 12;              // 取手の断面半径（リングの太さ）
handle_center_offset = outer_r + handle_cross_r; // 取手の中心線が外径方向に飛び出す距離
handle_center_z = height / 2;     // 取手の中心高さ（カップの中心高さ）

// 本体（外側）
module mug_outer() {
    translate([0,0,0])
        cylinder(r=outer_r, h=height, center=false);
}

// 本体（内側：くり抜き用）
module mug_inner() {
    // 内側は底部の厚みを残してくり抜く（高さは内側の空間高さ）
    translate([0,0,base_thickness])
        cylinder(r=inner_r, h=inner_height, center=false);
}

// リング状取手（トーラスをrotate_extrudeで作る）
// 2D平面上で中心を (handle_center_offset, handle_center_z) にした円を回転させる
module handle_ring() {
    // rotate_extrude は 2D の y 座標を z に変換するので、
    // circle を (x=handle_center_offset, y=handle_center_z) に移動して回転させる
    translate([0,0,0])
        rotate_extrude(convexity=10)
            translate([handle_center_offset, handle_center_z])
                circle(r=handle_cross_r);
}

// 組み立て
difference() {
    union() {
        mug_outer();
        handle_ring();
    }
    // 内部をくり抜く（飲み物を入れられる形にする）
    mug_inner();
}