// マグカップ仕様
outer_d = 80;         // 外径
height = 100;         // 高さ
wall   = 4;           // 肉厚
bottom = 6;           // 底面厚

// 取手仕様（リング状）
handle_r_tube  = 12;  // 取手の断面半径（丸断面）
handle_R_major = 30;  // リングの主半径（指を通す空間の大きさ）
attach_overlap = 1;   // カップ外周との重なり量

$fn = 128;

// トーラス（リング状取手）
module torus(R, r) {
  rotate([90, 0, 0])  // 軸をY方向へ
    rotate_extrude(angle = 360)
      translate([R, 0, 0])
        circle(r = r);
}

// マグ本体
module mug_body() {
  outer_r = outer_d/2;
  inner_r = outer_r - wall;
  difference() {
    // 外形
    cylinder(r = outer_r, h = height);
    // 内側くり抜き（底6mm残し）
    translate([0, 0, bottom])
      cylinder(r = inner_r, h = height - bottom);
  }
}

// 取手の配置（中心高さ、外周から十分はみ出す）
module handle() {
  outer_r = outer_d/2;
  // カップ外周と少し重なるようにX方向へ配置
  translate([outer_r + handle_r_tube - attach_overlap, 0, height/2])
    torus(handle_R_major, handle_r_tube);
}

// 組み立て
union() {
  mug_body();
  handle();
}