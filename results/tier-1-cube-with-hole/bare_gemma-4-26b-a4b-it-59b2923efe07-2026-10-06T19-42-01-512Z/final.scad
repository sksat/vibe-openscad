$fn = 100;

difference() {
    // 50mm 角の立方体
    cube(50, center = true);
    
    // 直径 20mm の貫通穴 (z軸方向)
    // 貫通を確実にするため、高さを少し長く設定
    cylinder(h = 52, d = 20, center = true);
}