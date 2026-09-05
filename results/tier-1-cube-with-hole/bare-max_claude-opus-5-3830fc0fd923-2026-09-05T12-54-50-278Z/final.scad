// 50mm角の立方体に、中央をZ軸方向に貫通する直径20mmの穴を開けたモデル

$fn = 100;

cube_size = 50;
hole_d = 20;

difference() {
    // 50mm角の立方体（原点を中心に配置）
    cube([cube_size, cube_size, cube_size], center = true);

    // 中央をZ軸方向に貫通する穴（余裕を持たせて長めにする）
    cylinder(h = cube_size + 2, d = hole_d, center = true);
}