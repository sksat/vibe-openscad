// 3段の階段状ピラミッド（中心揃え）

module plate(size_xy, h, z=0, center=true) {
    cube([size_xy, size_xy, h], center=center);
}

bottom_size = 60;
mid_size    = 40;
top_size    = 20;

bottom_h = 10;
mid_h    = 10;
top_h    = 10;

// 板はそれぞれ高さ10mmで積み上げ（各段の中心を揃える）
translate([0, 0, 0])
union() {
    // 底板：z方向は下端が0になるように配置
    plate(bottom_size, bottom_h, z=bottom_h/2);

    // 中板：底板の上に載せる
    translate([0, 0, bottom_h])
        plate(mid_size, mid_h, z=mid_h/2);

    // 上板：中板の上に載せる
    translate([0, 0, bottom_h + mid_h])
        plate(top_size, top_h, z=top_h/2);
}