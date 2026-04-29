module gp2y0a21yk0f() {

  // 本体ケース
  cube([48, 13.5, 16], center = true);

  // レンズ部突起
  translate([0, -3.75, 8]) cube([37, 6.5, 5], center = true);

  // 発光側レンズ窓
  translate([9.5, -2.5, 11.5]) cylinder(h=1, r=1.5, $fn=30);

  // 受光側レンズ窓
  translate([-9.5, -2.5, 11.5]) cylinder(h=1, r=1.5, $fn=30);

  // 連結バー
  cube([48, 2, 6], center = true);
  translate([0, -13.5 + 1, -3]) cube([48, 2, 6], center = true);

  // 取付穴
  translate([20, -12.5, -3]) cylinder(h=6, r=1.2, $fn=30);
  translate([-20, -12.5, -3]) cylinder(h=6, r=1.2, $fn=30);

  // ケーブル取り出し切欠き
  translate([0, -14.5, -3]) cube([8, 2, 1], center = true);

  // ケーブル (簡易表現)
  translate([0, -16, 0]) cylinder(h=10, r=0.5, $fn=30);
}

gp2y0a21yk0f();