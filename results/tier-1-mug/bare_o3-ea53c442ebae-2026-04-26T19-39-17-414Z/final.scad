// マグカップ寸法
outer_d = 80;        // 外径
outer_r = outer_d/2;
height  = 100;       // 全高
wall    = 4;         // 肉厚
bottom  = 6;         // 底厚

// 内部計算
inner_r = outer_r - wall;
inner_h = height - bottom;

// 取手寸法
handle_R = 12;       // リングの半径
handle_r = 4;        // リングの太さ(チューブ半径)
handle_z = height/2; // 取手位置（高さ方向で中央）

$fn = 128;           // 滑らかさ

// カップ本体
module cup() {
    difference() {
        cylinder(h = height, r = outer_r);
        translate([0,0,bottom])
            cylinder(h = inner_h, r = inner_r);
    }
}

// トーラス(リング)生成
module torus(R, r) {
    rotate_extrude()
        translate([R, 0, 0])
            circle(r = r);
}

// 取手
module handle() {
    translate([outer_r, 0, handle_z])   // 外周位置へ移動
        rotate([0, 90, 0])              // 垂直面に立てる
            torus(handle_R, handle_r);
}

// 組み立て
union() {
    cup();
    handle();
}