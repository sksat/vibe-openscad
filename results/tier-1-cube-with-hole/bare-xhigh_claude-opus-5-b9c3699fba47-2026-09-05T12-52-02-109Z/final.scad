// 50mm角の立方体の中央に直径20mmの貫通穴（z軸方向）

cube_size = 50;
hole_d = 20;

difference() {
    // 立方体（原点中心）
    cube([cube_size, cube_size, cube_size], center = true);

    // z軸方向の貫通穴（両端を少し延長して確実に貫通させる）
    cylinder(h = cube_size + 2, d = hole_d, center = true, $fn = 100);
}