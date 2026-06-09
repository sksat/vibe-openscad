// マグカップ
// 外径 80mm、高さ 100mm、肉厚 4mm、底面厚み 6mm
// 半径 12mm のリング状取手付き

$fn = 120;

outer_d  = 80;            // 外径
outer_r  = outer_d / 2;   // 外半径 (40mm)
height   = 100;           // 高さ
wall     = 4;             // 側面の肉厚
bottom   = 6;             // 底面の厚み

handle_r = 12;            // 取手リングの半径
handle_t = 4;             // 取手の断面(パイプ)半径
handle_z = height / 2;    // 取手の取り付け高さ(中央)
handle_cx = outer_r + handle_r - 2;  // 取手中心の X 位置(壁に少し食い込ませる)

// カップ本体(外形)
module cup_body() {
    cylinder(h = height, r = outer_r);
}

// 内側のくり抜き(飲み物が入る空間)
module cavity() {
    translate([0, 0, bottom])
        cylinder(h = height - bottom + 1, r = outer_r - wall);
}

// リング状の取手(トーラス)
module handle() {
    translate([handle_cx, 0, handle_z])
        rotate([90, 0, 0])  // リングを垂直に立てる
            rotate_extrude(angle = 360)
                translate([handle_r, 0, 0])
                    circle(r = handle_t);
}

// 組み立て:本体と取手を結合した後で内側をくり抜く
// (取手が内部空間に飛び出さないようにするため)
difference() {
    union() {
        cup_body();
        handle();
    }
    cavity();
}