difference() {
    // 50mm角の立方体（原点を中心に配置）
    cube([50, 50, 50], center = true);
    // 直径20mmの穴をz軸方向に貫通（立方体の中心に配置）
    cylinder(h = 60, d = 20, center = true, $fn = 100);
}