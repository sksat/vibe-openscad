// 修正 OpenSCAD: L字金具 (水平板: 50x40x3, 垂直板: 3x50x40, 内側コーナー原点(0,0,0))
// 水平面は +Y 方向、垂直面は +Z 方向に伸びる
// 皿穴は各面2個ずつ、計4個、M4 countersunk (Φ4.5 穴 + Φ8 × 深さ2 の皿座面)
// 各穴は面の中心線上、面の縁から10mm内側、左右対称に配置
difference() {
  union() {
    // 水平板: 50 (X) × 40 (Y) × 3 (Z)
    cube([50, 40, 3], center=false);
    // 垂直板: 3 (X) × 50 (Y) × 40 (Z)
    cube([3, 50, 40], center=false);
  }

  // 水平板の皿穴 (2個、貫通穴 Φ4.5, 皿座面 Φ8 × 深さ 2)
  // 中心点: (X, Y) = (10, 20) と (40, 20)
  translate([10, 20, 0]) cylinder(h=3, r=2.25, center=false);
  translate([40, 20, 0]) cylinder(h=3, r=2.25, center=false);

  // 水平板の皿座面（外側へ向ける: 上面側 z=3 に向かう）
  translate([10, 20, 1]) cylinder(h=2, r1=2.25, r2=4, center=false);
  translate([40, 20, 1]) cylinder(h=2, r1=2.25, r2=4, center=false);

  // 垂直板の皿穴 (2個、貫通穴 Φ4.5, 皿座面 Φ8 × 深さ 2)
  // 貫通方向を X 軸に合わせるため、穴を X 軸方向に貫通させる
  translate([0, 10, 20]) rotate([0, 90, 0]) cylinder(h=3, r=2.25, center=false);
  translate([0, 40, 20]) rotate([0, 90, 0]) cylinder(h=3, r=2.25, center=false);

  // 垂直板の皿座面（外側へ向ける: ボルト頭が当たる側は +X 側）
  // 座の深さ 2, 座径 Φ8, 先端径Φ4.5 を X 軸方向に配置
  translate([1, 10, 20]) rotate([0, 90, 0]) cylinder(h=2, r1=2.25, r2=4, center=false);
  translate([1, 40, 20]) rotate([0, 90, 0]) cylinder(h=2, r1=2.25, r2=4, center=false);
}