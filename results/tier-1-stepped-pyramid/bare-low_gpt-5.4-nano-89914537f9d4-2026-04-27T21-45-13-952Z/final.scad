// 3段の階段状ピラミッド（中心揃え）
$fn = 100;

module plate(size_xy, height, z=0) {
    half = size_xy / 2;
    translate([0, 0, z])
        cube([size_xy, size_xy, height], center=true);
}

// 板サイズ
base_xy = 60;
mid_xy  = 40;
top_xy  = 20;
h = 10;

// 3段積み
union() {
    plate(base_xy, h, 0);     // 下段
    plate(mid_xy,  h, h);     // 中段
    plate(top_xy,  h, 2*h);   // 上段
}