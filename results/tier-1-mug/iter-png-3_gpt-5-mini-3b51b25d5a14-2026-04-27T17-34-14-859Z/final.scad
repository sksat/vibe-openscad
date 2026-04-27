// OpenSCAD: マグカップ（外径80mm、高さ100mm、肉厚4mm、底厚6mm、リング状取手）
$fn = 160;

// 本体パラメータ
outer_d = 80;
outer_r = outer_d / 2;
height = 100;

wall_thickness = 4;
inner_r = outer_r - wall_thickness;

bottom_thickness = 6;
cavity_height = height - bottom_thickness + 0.1; // 余裕を少し持たせる

// 取手パラメータ
handle_protrusion = 12;    // カップ外周からの突出量（外周からの最大は outer_r + handle_protrusion）
handle_tube_r = 3.5;       // 取手断面の半径（チューブ半径）
handle_angle = 360;        // リング状にするため360度
handle_center_z = height / 2; // 取手の中心高さ（カップ中心高さ）

// トーラス中心線半径（トーラスの中心線が原点からどれだけ離れているか）
torus_R = outer_r + handle_protrusion - handle_tube_r;

// マグカップ本体（外殻から内側をくり抜く）
module mug_body() {
    difference() {
        // 外側の筒（底を含む）
        cylinder(h = height, r = outer_r);
        // 内側の空洞（底厚分だけ上げてくり抜く）
        translate([0, 0, bottom_thickness])
            cylinder(h = cavity_height, r = inner_r + 0.01);
    }
}

// リング状取手（トーラス）を作成して側面に配置
module handle() {
    // まず rotate_extrude でトーラスを作る（XY平面の円を回転）
    // その後、Y軸回りに90度回転して垂直面に配置し、高さを合わせる
    translate([0, 0, handle_center_z])
        rotate([0, 90, 0])
            rotate_extrude(angle = handle_angle)
                translate([torus_R, 0, 0])
                    circle(r = handle_tube_r);
}

// 完成モデル
union() {
    mug_body();
    handle();
}