$fn = 100;

difference() {
    // 50mm角の立方体
    cube(50, center = true);

    // 直径20mmの貫通穴（z軸方向）
    // 上下の面をきれいに貫通させるため、高さを少し大きく（60mm）設定しています
    cylinder(h = 60, d = 20, center = true);
}