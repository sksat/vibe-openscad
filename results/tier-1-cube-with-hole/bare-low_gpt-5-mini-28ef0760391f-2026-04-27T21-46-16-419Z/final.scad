// 50mm 角の立方体の中央に直径20mmの貫通穴（z軸方向）を開ける

difference() {
    cube([50, 50, 50], center = true);
    // 十分な高さを持たせて貫通させる
    cylinder(h = 60, d = 20, center = true, $fn = 100);
}