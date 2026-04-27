difference() {
    // 50mm 角の立方体
    cube(50, center = true);
    
    // 直径 20mm の貫通穴（z軸方向）
    cylinder(h = 60, r = 10, center = true, $fn = 32);
}