// マグカップ: 外径80mm, 高さ100mm, 肉厚4mm, 底面厚6mm
// 取手: 半径12mmのリング状、中心高さ付近に配置

$fn = 128;

outer_d = 80;
outer_r = outer_d/2;   // 40
height  = 100;
wall    = 4;
bottom  = 6;

inner_r = outer_r - wall; // 36

handle_R = 12;  // リング半径
handle_r = 4;   // リング断面半径（太さ）
handle_z = height/2; // 中心高さ
handle_out_offset = 1; // 外周から更に押し出す量（内側に貫通しないように少し外へ）

module cup_body() {
  difference() {
    cylinder(h=height, r=outer_r);
    translate([0,0,bottom]) cylinder(h=height-bottom, r=inner_r);
  }
}

module torus(R, r) {
  rotate_extrude(angle=360)
    translate([R,0,0])
      circle(r=r);
}

module handle() {
  // y軸方向を回転軸にするリング（x-z平面に見える円）
  // カップ外周から十分はみ出すように外側へ配置
  translate([outer_r + handle_R + handle_out_offset, 0, handle_z])
    rotate([0,90,0])
      torus(handle_R, handle_r);
}

union() {
  cup_body();
  handle();
}