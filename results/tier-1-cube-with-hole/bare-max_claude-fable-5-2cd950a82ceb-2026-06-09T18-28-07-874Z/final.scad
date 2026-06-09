// 円柱の滑らかさ
$fn = 100;

difference() {
    // 50mm 角の立方体(原点中心)
    cube([50, 50, 50], center = true);

    // 直径 20mm の貫通穴(z 軸方向、確実に貫通させるため高さに余裕を持たせる)
    cylinder(h = 52, d = 20, center = true);
}