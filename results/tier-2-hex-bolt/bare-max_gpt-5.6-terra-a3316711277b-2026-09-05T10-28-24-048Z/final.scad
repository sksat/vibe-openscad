// M8 六角ボルト（ねじ山省略）

across_flats = 13;
head_height  = 5.3;
shank_diameter = 8;
shank_length   = 30;

module m8_hex_bolt() {
    union() {
        // 頭部：底面 z=0、+Z 方向へ高さ 5.3 mm
        cylinder(
            h = head_height,
            r = across_flats / sqrt(3),
            $fn = 6
        );

        // シャンク：頭部底面から -Z 方向へ 30 mm
        translate([0, 0, -shank_length])
            cylinder(
                h = shank_length,
                d = shank_diameter,
                $fn = 64
            );
    }
}

m8_hex_bolt();