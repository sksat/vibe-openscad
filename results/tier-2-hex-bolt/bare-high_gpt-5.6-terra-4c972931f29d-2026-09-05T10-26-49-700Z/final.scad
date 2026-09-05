// M8 六角ボルト（ねじ山省略）
// 単位: mm

across_flats = 13;
head_height  = 5.3;
shank_diameter = 8;
shank_length   = 30;

// 六角形の外接円半径: 対辺距離 / √3
head_radius = across_flats / sqrt(3);

union() {
    // 頭部: 底面 z=0、+Z 方向へ配置
    cylinder(
        h = head_height,
        r = head_radius,
        $fn = 6
    );

    // シャンク: z<0 側へ配置
    translate([0, 0, -shank_length])
        cylinder(
            h = shank_length,
            d = shank_diameter,
            $fn = 64
        );
}