// M8 六角ボルト (ねじ山省略モデル)

$fn = 64;

// 頭部 (対辺距離 13mm, 高さ 5.3mm)
// cylinderのrは外接円半径 = 対辺 / sqrt(3)
module bolt_head() {
    cylinder(d = 13 / cos(180/6), h = 5.3, $fn = 6);
}

// シャンク (直径 8mm, 長さ 30mm)
module shank() {
    translate([0, 0, -30])
    cylinder(d = 8, h = 30);
}

union() {
    bolt_head();
    shank();
}