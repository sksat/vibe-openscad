$fn = 100;

difference() {
    // 50mm角の立方体
    cube(50, center = true);

    // 直径20mmの貫通穴（z軸方向）
    // 抜きやすくするために高さは少し余裕を持たせています
    cylinder(h = 60, d = 20, center = true);
}