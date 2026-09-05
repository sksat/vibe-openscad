// 50mm角の立方体に、直径20mmの貫通穴(z軸方向)

difference() {
    // 50mm角の立方体(中心を原点に配置)
    cube([50, 50, 50], center = true);

    // 直径20mmの貫通穴(z軸方向)
    cylinder(h = 60, d = 20, center = true, $fn = 100);
}