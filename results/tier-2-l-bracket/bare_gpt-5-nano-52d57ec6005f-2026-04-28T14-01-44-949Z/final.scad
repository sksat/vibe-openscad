// OpenSCAD: L字金具 (L-bracket) - Horizontal plate (XY) + Vertical plate (XZ)
// 内側コーナーを原点に配置: 水平面は +Y 方向、垂直面は +Z 方向に伸びる
// 皿穴: 各面に 2 個ずつ、合計 4 個（M4、Φ4.5 の貫通穴 + 皿座面 Φ8 の深さ 2）
// 皿座面は外側に向ける

difference() {
  // 基本となる二枚の板を union で作成
  union() {
    // 水平板: 50 x 40 x 3 (X × Y × Z)
    cube([50, 40, 3], center=false);
    // 垂直板: 50 x 3 x 40 (X × Y × Z)  ここでは厚さを Y方向の 3mm と解釈
    cube([50, 3, 40], center=false);
  }

  // 水平板の皿穴2個
  // centerline: 水平板の centerline は Y = 20 の位置で左右対称 (X=10, 40)
  translate([10, 20, 0])
    cylinder(h=3, r=2.25, center=false);           // 貫通穴 Φ4.5
  translate([10, 20, 1])
    cylinder(h=2, r1=2.25, r2=4, center=false);    // 皿座面 Φ8 × 深さ 2

  translate([40, 20, 0])
    cylinder(h=3, r=2.25, center=false);
  translate([40, 20, 1])
    cylinder(h=2, r1=2.25, r2=4, center=false);

  // 垂直板の皿穴2個
  // 垂直板の厚さ方向を +X 方向と考え、中心位置を確保
  // 2 本とも X 軸方向に貫通する穴を作成（中心点は垂直板の中心ライン上）
  // 穴1
  translate([0, 10, 20])
    rotate([0, 90, 0])
    cylinder(h=3, r=2.25, center=false);
  translate([1, 10, 20])
    rotate([0, 90, 0])
    cylinder(h=2, r1=2.25, r2=4, center=false);

  // 穴2
  translate([0, 40, 20])
    rotate([0, 90, 0])
    cylinder(h=3, r=2.25, center=false);
  translate([1, 40, 20])
    rotate([0, 90, 0])
    cylinder(h=2, r1=2.25, r2=4, center=false);
}