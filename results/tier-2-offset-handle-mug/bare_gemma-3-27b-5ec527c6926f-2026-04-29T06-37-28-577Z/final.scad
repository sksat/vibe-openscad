// マグカップのパラメータ
outer_diameter = 80;
inner_diameter = 70;
height = 90;
bottom_thickness = 6;
handle_width = 25;
handle_height = 30;

// モジュール定義：円筒形マグ本体
module mug_body() {
  difference() {
    cylinder(h = height, r = outer_diameter / 2);
    translate([0, 0, -bottom_thickness]) cylinder(h = bottom_thickness, r = inner_diameter / 2);
    cylinder(h = height + bottom_thickness, r = inner_diameter / 2);
  }
}

// モジュール定義：D字型取手
module handle() {
  linear_extrude(height = handle_height) {
    difference() {
      circle(r = handle_width / 2);
      translate([handle_width/2,0]) square([handle_width, handle_width]);
    }
  }
}

// マグカップ全体の作成
module mug_with_handle() {
  union() {
    mug_body();
    translate([outer_diameter / 2 + handle_width/2, 0, height / 2 - handle_height / 2])
      rotate([0,90,0])
        handle();
  }
}

// マグカップの表示
mug_with_handle();