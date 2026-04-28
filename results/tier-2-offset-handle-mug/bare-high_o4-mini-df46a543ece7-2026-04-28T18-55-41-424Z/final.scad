// mug 本体パラメータ
outer_d = 80;
inner_d = 70;
height = 90;
bottom_t = 6;

// 取手パラメータ
handle_open_h = 30;    // 空間 高さ
handle_open_w = 25;    // 空間 幅
handle_wall   = 5;     // 取手肉厚
handle_depth  = 20;    // 取手奥行

// 計算
wall_t   = (outer_d - inner_d)/2;  // マグ肉厚 5
R_i      = handle_open_h/2;
rect_i   = handle_open_w - R_i;
T        = handle_wall;
R_o      = R_i + T;
rect_o   = rect_i + T;

// D字形状モジュール（半円＋直線）
module D_shape(r, rect_w) {
  union() {
    translate([0, -r]) square([rect_w, 2*r]);
    difference() {
      translate([rect_w, 0]) circle(r = r, $fn = 64);
      translate([-1000, -1000]) square([rect_w + 1000, 2000]);
    }
  }
}
// D字リング（外側D−内側D）
module D_ring() {
  difference() {
    D_shape(R_o, rect_o);
    translate([T, 0]) D_shape(R_i, rect_i);
  }
}
// 取手形状
module handle() {
  rotate([90, 0, 0])
    linear_extrude(height = handle_depth, center = true)
      D_ring();
}
// マグ本体
module mug() {
  difference() {
    cylinder(r = outer_d/2, h = height, $fn = 100);
    translate([0, 0, bottom_t])
      cylinder(r = inner_d/2, h = height - bottom_t, $fn = 100);
  }
}

// 結合
union() {
  mug();
  translate([outer_d/2, 0, height/2])
    handle();
}