$fn = 100;
outer_d = 80;      // 外径
wall_t = 4;        // 肉厚（壁厚）
bottom_thick = 6;  // 底面厚み
inner_h = outer_d - 2*wall_t;   // 内部直径
total_h = 100;
handle_radial = 12;        // 取手の飛び出し半径
handle_minor = 8;           // 取手の厚み

// カップ全体（外側の円柱）
cup_outer = cylinder(d=outer_d, h=total_h, r=outer_d/2);

// 内部空洞（壁厚を除く）
inner_cyl_start_z = bottom_thick;
inner_h = outer_d - 2*wall_t; // 内部直径
inner_cyl = translate([wall_t, wall_t, inner_cyl_start_z]) \
    cylinder(d=inner_h, h=outer_d - inner_cyl_start_z, r=inner_h/2);

// カップを組み立て
cup_body = difference() {
    cup_outer;
    inner_cyl;
};

// 中心高さ（半分の高さ）に取手を付ける
handle_center_z = total_h/2;
handle = translate([0, 0, handle_center_z]) \
    torus(r=handle_minor, R=(inner_d/2) + handle_radial);

// 全体モジュール
module mug() {
    cup_body;
    handle;
}