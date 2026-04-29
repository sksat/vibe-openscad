module gp2y0d413k0f() {

  // 本体ケース (Carbonic ABS)
  cube([20.45, 13.5, 6.7], center = true);

  // レンズケース突起
  translate([0, 6.75, 3.35])
    cube([10.1, 5.8, 3.35], center = true);

  // 発光部レンズ (円形)
  translate([-4.2, 6.75, 3.35 + 1.5/2])
    cylinder(r=1.5, h=0.1, $fn=30);

  // 受光部レンズ (矩形)
  translate([4.2, 6.75, 3.35 + 1.5/2])
    cube([3.8, 1.5, 0.1], center = true);

  // PWB
  translate([0, -6.75/2, -3.35])
    cube([16.3, 4.5, 0.5], center = true);

  // コネクタ (簡易表現)
  translate([0, -8.15, -3.35])
    cube([7, 2, 1], center = true);
}

gp2y0d413k0f();