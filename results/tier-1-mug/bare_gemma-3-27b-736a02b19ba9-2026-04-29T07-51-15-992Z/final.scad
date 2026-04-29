// マグカップのパラメータ
outer_diameter = 80;
height = 100;
wall_thickness = 4;
bottom_thickness = 6;
handle_radius = 12;

// 内径
inner_diameter = outer_diameter - 2 * wall_thickness;

// モジュール：マグカップ本体
module mug() {
  difference() {
    cylinder(h = height, r = outer_diameter / 2);
    translate([0, 0, bottom_thickness]) cylinder(h = height - bottom_thickness, r = inner_diameter / 2);
  }
}

// モジュール：取手
module handle() {
  rotate_extrude() {
    translate([handle_radius, 0]) circle(r = wall_thickness);
  }
}

// メイン処理
union() {
  mug();
  translate([outer_diameter / 2 + handle_radius - wall_thickness, 0, height/2]) rotate([0,90,0]) handle();
  translate([-outer_diameter / 2 - handle_radius + wall_thickness, 0, height/2]) rotate([0,90,0]) handle();
}