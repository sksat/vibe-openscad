// 3段の階段状ピラミッド（中心揃え）

module plate(size_xy, h) {
    cube([size_xy, size_xy, h], center=true);
}

bottom_size = 60;
mid_size    = 40;
top_size    = 20;

h = 10; // 各段の高さ（課題指定）

union() {
    // 底板：z=0〜10
    translate([0, 0, h/2])
        plate(bottom_size, h);

    // 中板：z=10〜20
    translate([0, 0, h + h/2])
        plate(mid_size, h);

    // 上板：z=20〜30
    translate([0, 0, 2*h + h/2])
        plate(top_size, h);
}