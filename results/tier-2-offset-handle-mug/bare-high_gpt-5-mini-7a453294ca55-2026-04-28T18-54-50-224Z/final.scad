// OpenSCAD: D-shaped mug with handle on +X side
$fn = 120;

// --- Parameters ---
outer_d = 80;            // 外径
inner_d = 70;            // 内径
r_out = outer_d/2;
r_in  = inner_d/2;
height = 90;             // 高さ
bottom_thickness = 6;    // 底面の厚み

// 取手パラメータ
handle_inner_height = 30;   // 取手内側の高さ (Z)
handle_vert_margin = 5;     // 上下の余裕（取手の上下の接続部）
handle_height = handle_inner_height + 2*handle_vert_margin;
z_center = height/2;
handle_z_bottom = z_center - handle_height/2;

handle_flat_x = r_out - 2;  // 直線側の平面 X (マグに重なるように2mmオーバーラップ)
handle_cx = handle_flat_x;  // 半円の中心 X
R_handle_outer = 32;        // 半円の半径（外側）

// 取手内側の空間（指定どおり 高さ 30mm × 幅 25mm）
cavity_height = handle_inner_height;   // Z: 30
cavity_width_y = 25;                   // Y: 25
cavity_depth_x = 25;                   // X方向の深さ（マグ外周からの距離）←幅の解釈に合わせて設定
cavity_x_left = r_out;                 // 左端をマグ外周に合わせる（x = 40）
cavity_y_len = cavity_width_y;
cavity_z_bottom = z_center - cavity_height/2;

// --- 出力 ---
union() {
  // 本体（外筒 - 内筒）
  difference() {
    // 外筒
    cylinder(h = height, r = r_out, center = false);
    // 内筒（底厚を残すために z = bottom_thickness から高さを短くする）
    translate([0,0,bottom_thickness])
      cylinder(h = height - bottom_thickness, r = r_in, center = false);
  }

  // 取手（外形は半円（D字外側）、本体と確実に重なるように平面側を内側に少しオーバーラップ）
  difference() {
    // 半円を2Dで作って押し出す（右向きの半円：平面は x = handle_cx）
    translate([0,0,handle_z_bottom])
      linear_extrude(height = handle_height, center = false, convexity = 10)
        intersection() {
          translate([handle_cx, 0]) circle(R_handle_outer);
          // 半平面 (x >= handle_cx) を作るための大きな四角形
          translate([handle_cx, -1000]) square([10000, 2000]);
        }

    // 取手内側の空間（矩形スロット）を差し引く（高さは正確に 30mm、幅 25mm）
    translate([cavity_x_left, -cavity_y_len/2, cavity_z_bottom])
      cube([cavity_depth_x, cavity_y_len, cavity_height], center = false);
  }
}