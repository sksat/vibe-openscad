difference() {
    // 50mm角の立方体を原点中心に配置
    cube([50, 50, 50], center = true);
    // 直径20mmの穴をz軸方向に貫通（原点中心）
    translate([0, 0, 0])
        cylinder(h = 60, d = 20, center = true, $fn = 100);
}