// 50mm角の立方体の中央にz軸方向の直径20mm貫通穴

difference() {
    cube([50, 50, 50], center=true);
    cylinder(h=60, d=20, center=true);
}