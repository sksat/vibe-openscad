// 50mm角の立方体に、直径20mmのZ軸方向貫通穴

$fn = 100;

difference() {
    // 50mm角の立方体（中心を原点に配置）
    cube([50, 50, 50], center = true);

    // 中央を貫通する直径20mmの穴（Z軸方向）
    cylinder(h = 60, d = 20, center = true);
}