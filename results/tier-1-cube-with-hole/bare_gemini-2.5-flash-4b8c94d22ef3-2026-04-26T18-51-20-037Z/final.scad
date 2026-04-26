difference() {
    // 50mm角の立方体を中央に配置
    cube(size = 50, center = true);

    // 直径20mm（半径10mm）の円柱を中央に配置し、
    // 立方体の高さを超える十分な高さを与えてZ軸方向に貫通させる
    cylinder(r = 10, h = 60, center = true);
}