difference() {
    // 50mm角の立方体（中心に配置）
    cube(50, center = true);

    // 直径20mmの貫通穴（z軸方向）
    // 確実に貫通させるため、高さを少し（52mm）大きくしています
    cylinder(h = 52, d = 20, center = true, $fn = 100);
}