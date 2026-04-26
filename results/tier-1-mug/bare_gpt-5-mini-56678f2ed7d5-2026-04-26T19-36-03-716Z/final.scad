// OpenSCAD: マグカップ（外径80mm、高さ100mm、肉厚4mm、底厚6mm、リング状取手）
// 単位: mm

$fn = 128;

outer_d = 80;
outer_r = outer_d / 2;
height = 100;

wall_thickness = 4;
inner_r = outer_r - wall_thickness;

bottom_thickness = 6;
cavity_height = height - bottom_thickness;

// 取手パラメータ
handle_protrusion = 12;       // カップ外周からの突出量（外周からはみ出す距離）
handle_tube_r = 10;           // 取手断面の半径（チューブ半径）
handle_angle = 220;           // 取手の巻き角度（度）。180なら半円、220でやや多めに巻く
handle_center_z = height/2;   // 取手の高さ（カップ中心高さ）

// トーラス中心線半径（外側の最大は outer_r + handle_protrusion）
torus_R = outer_r + handle_protrusion - handle_tube_r;

// マグカップ本体（外殻 - 内空洞）
module mug_body() {
    difference() {
        // 外側の筒（底も含む）
        translate([0,0,0]) cylinder(h = height, r = outer_r);
        // 内側の空洞（底厚分だけ上げてくり抜く）
        translate([0,0,bottom_thickness]) cylinder(h = cavity_height, r = inner_r);
    }
}

// リング状取手（トーラスのセグメント）
module handle() {
    // 2DプロファイルをZ軸回転でトーラス（セグメント）を作成し、回転して垂直面に配置
    translate([0,0,handle_center_z])
        rotate([0,90,0])  // トーラスを縦向きにする（XZ平面に配置）
            rotate_extrude(angle = handle_angle)
                translate([torus_R, 0, 0])
                    circle(r = handle_tube_r);
}

// 完成モデル
union() {
    mug_body();
    handle();
}