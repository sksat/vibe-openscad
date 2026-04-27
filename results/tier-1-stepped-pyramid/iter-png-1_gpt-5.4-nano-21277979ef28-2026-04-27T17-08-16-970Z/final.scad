// 3段の階段状ピラミッド（中心揃え）

module plate(size_xy, h, center=true) {
    cube([size_xy, size_xy, h], center=center);
}

bottom_size = 60;
mid_size    = 40;
top_size    = 20;

bottom_h = 10;
mid_h    = 10;
top_h    = 10;

union() {
    // 底板：底面が z=0
    translate([0, 0, bottom_h/2])
        plate(bottom_size, bottom_h, center=true);

    // 中板：中板の底面が底板の上面（z=10）
    translate([0, 0, bottom_h + mid_h/2])
        plate(mid_size, mid_h, center=true);

    // 上板：上板の底面が中板の上面（z=20）
    translate([0, 0, bottom_h + mid_h + top_h/2])
        plate(top_size, top_h, center=true);
}