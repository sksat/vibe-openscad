// 50mm角の立方体に、直径20mmのZ軸方向貫通穴を開けたモデル

cube_size = 50;
hole_d    = 20;

$fn = 100;

difference() {
    // 50mm角の立方体（原点を中心に配置）
    cube([cube_size, cube_size, cube_size], center = true);

    // 中央を z 軸方向に貫通する直径20mmの穴
    cylinder(h = cube_size + 1, d = hole_d, center = true);
}