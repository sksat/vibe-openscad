difference() {
    // L 字金具本体
    union() {
        // 水平フランジ (X×Y×Z = 50×40×3)
        cube([50, 40, 3]);
        // 垂直フランジ (X×Y×Z = 50×3×40)
        cube([50, 3, 40]);
    }

    // 水平面の皿穴 (Z 軸方向)
    for (x = [10, 40]) {
        // 貫通穴 Φ4.5mm
        translate([x, 20, -1])
            cylinder(d=4.5, h=5);
        // 皿座面 Φ8mm 深さ 2mm (外側は Z=3 側)
        translate([x, 20, 1])
            cylinder(d=8, h=2);
    }

    // 垂直面の皿穴 (Y 軸方向)
    for (z = [10, 30]) {
        // 貫通穴 Φ4.5mm
        translate([25, -1, z])
            rotate([-90, 0, 0])
            cylinder(d=4.5, h=5);
        // 皿座面 Φ8mm 深さ 2mm (外側は Y=3 側)
        translate([25, 1, z])
            rotate([-90, 0, 0])
            cylinder(d=8, h=2);
    }
}