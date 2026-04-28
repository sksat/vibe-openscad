// M8規格準拠の六角ボルト（頭部 hex 5.3mm high, シャンク 直径8mm 長さ30mm, 中心軸 = +Z, 頭部底面 z=0）

// 定数
R = 13 / sqrt(3); // hex の circumradius（ across-flats = 13mm を満たす）
head_height = 5.3;
shank_d = 8;
shank_r = shank_d / 2;
shank_h = 30;

// 六角形の頂点（中心を原点、正のX軸方向に頂点を置くよう配置）
points = [
  [ R, 0 ],
  [ R/2, R*sqrt(3)/2 ],
  [ -R/2, R*sqrt(3)/2 ],
  [ -R, 0 ],
  [ -R/2, -R*sqrt(3)/2 ],
  [ R/2, -R*sqrt(3)/2 ]
];

// ヘッド部（底面を z=0 に配置、+Z方向に伸長）
module head() {
  linear_extrude(height = head_height) polygon(points);
}

// シャンク部（底辺を z=0 から -30 まで、中心軸は +Z）
module shank() {
  translate([0, 0, -shank_h])
    cylinder(h = shank_h, r = shank_r, center = false, $fn = 64);
}

// 組み立て
union() {
  head();          // z = 0 〜 head_height
  shank();         // z = -30 〜 0
}