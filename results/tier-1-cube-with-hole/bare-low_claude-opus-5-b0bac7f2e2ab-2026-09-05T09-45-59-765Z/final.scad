// 50mm角の立方体に、中央をz軸方向に貫通する直径20mmの穴
$fn = 100;

cube_size = 50;
hole_d = 20;

difference() {
    // 立方体（原点中心）
    cube([cube_size, cube_size, cube_size], center = true);

    // z軸方向の貫通穴（少し長めにして確実に貫通させる）
    cylinder(h = cube_size + 2, d = hole_d, center = true);
}