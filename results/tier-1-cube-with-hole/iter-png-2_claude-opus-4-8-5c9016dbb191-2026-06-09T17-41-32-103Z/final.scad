difference() {
    // 50mm角の立方体（原点に配置）
    cube([50, 50, 50]);
    // 直径20mmの穴をz軸方向に貫通（立方体の中心に配置）
    translate([25, 25, -5])
        cylinder(h = 60, d = 20, $fn = 100);
}