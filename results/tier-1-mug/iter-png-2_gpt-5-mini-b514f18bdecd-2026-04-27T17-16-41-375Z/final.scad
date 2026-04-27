// OpenSCAD: マグカップ（外径80mm、高さ100mm、肉厚4mm、底厚6mm、リング状取手）
// 修正: 取手の向きと配置を修正（rotate_extrude の後で回転・配置する）
// 高解像度
$fn = 200;

outer_d = 80;
outer_r = outer_d / 2;
height = 100;

wall_thickness = 4;
inner_r = outer_r - wall_thickness;

bottom_thickness = 6;
cavity_height = height - bottom_thickness;

// 取手パラメータ
handle_protrusion = 12;       // カップ外周からの突出量（外周からはみ出す距離）
handle_tube_r = 3;            // 取手断面の半径（チューブ半径）
handle_angle = 360;           // 取手の巻き角度（度）。リング状にするため360
handle_center_z = height/2;   // 取手の高さ（カップ中心高さ）

// トーラス中心線半径（外側の最大は outer_r + handle_protrusion）
torus_R = outer_r + handle_protrusion - handle_tube_r;

// マグカップ本体（外殻 - 内空洞）
module mug_body() {
    difference() {
        // 外側の筒（底も含む）
        cylinder(h = height, r = outer_r);
        // 内側の空洞（底厚分だけ上げてくり抜く）
        // 少し余分に高さを持たせて上面の干渉を防ぐ
        translate([0,0,bottom_thickness]) cylinder(h = cavity_height + 1, r = inner_r);
    }
}

// リング状取手（トーラス）
// rotate_extrude でトーラスを作成した後に回転して垂直面に配置
module handle() {
    // まず Z 軸周りに回転してトーラスを作る（XY 平面上の円を回転）
    torus = rotate_extrude(angle = handle_angle)
                translate([torus_R, 0, 0])
                    circle(r = handle_tube_r);

    // トーラスをカップ側面に対して垂直に配置し、中心高さに移動
    translate([0,0,handle_center_z])
        rotate([0,90,0])
            children();
}

// 完成モデル
union() {
    mug_body();
    // ハンドルを配置（children() を使うため直接展開）
    // ここで先に定義した torus を展開
    // (OpenSCAD は module 内での children() 使用を許容しないため、直接同等の構造を記述)
    translate([0,0,handle_center_z])
        rotate([0,90,0])
            rotate_extrude(angle = handle_angle)
                translate([torus_R, 0, 0])
                    circle(r = handle_tube_r);
}