// 50mm 角の立方体の中央に、直径20mmの貫通穴をz軸方向に開ける
difference() {
    cube([50, 50, 50], center=true);
    cylinder(d=20, h=100, center=true, $fn=100);
}