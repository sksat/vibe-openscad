// マグカップのパラメータ
outer_diameter = 80;
inner_diameter = 70;
height = 90;
bottom_thickness = 6;
handle_width = 25;
handle_height = 30;

// モジュール定義: 円筒形本体
module mug_body() {
  difference() {
    cylinder(h = height, r = outer_diameter / 2);
    translate([0, 0, -1]) cylinder(h = height + 2, r = inner_diameter / 2); // 内側をくり抜く
    translate([0, 0, -bottom_thickness]) cylinder(h = bottom_thickness, r = outer_diameter / 2); // 底面を作る
  }
}

// モジュール定義: D字型の取手
module handle() {
  difference() {
    union() {
      translate([outer_diameter/2 - handle_width/2,0,-handle_height/2]) cube([handle_width, outer_diameter/2, handle_height]);
      translate([outer_diameter/2 - handle_width/2, -outer_diameter/2 + 1, -handle_height/2]) cylinder(r = outer_diameter/2, h=handle_height); // 半円部分をくり抜く
    }

    // 内側空間を作る
    translate([outer_diameter/2 - handle_width/2+5,0,-handle_height/2]) cube([handle_width-10, outer_diameter/2, handle_height]);
  }
}


// メイン処理
union() {
  mug_body();

  translate([outer_diameter / 2, 0, height / 2 - handle_height / 2]) rotate([0,90,0]) handle(); // +X軸方向に取手を配置
}