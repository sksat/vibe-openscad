// M8 六角ボルト（ねじ山省略）
// 単位: mm

head_across_flats = 13;
head_height = 5.3;
shank_diameter = 8;
shank_length = 30;

// 正六角形の外接円半径 = 対辺距離 / sqrt(3)
head_radius = head_across_flats / sqrt(3);

union() {
    // 頭部: z = 0 ～ 5.3
    cylinder(
        h = head_height,
        r = head_radius,
        center = false,
        $fn = 6
    );

    // シャンク: z = -30 ～ 0
    translate([0, 0, -shank_length])
        cylinder(
            h = shank_length,
            d = shank_diameter,
            center = false,
            $fn = 96
        );
}