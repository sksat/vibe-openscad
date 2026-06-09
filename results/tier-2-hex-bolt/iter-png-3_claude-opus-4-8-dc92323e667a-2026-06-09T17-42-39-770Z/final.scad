// M8 六角ボルト
// 頭部: 対辺距離 13mm, 高さ 5.3mm
// シャンク: 直径 8mm, 長さ 30mm

across_flats = 13;
head_height = 5.3;
shank_diameter = 8;
shank_length = 30;

// 対辺距離から外接円半径を計算
head_radius = across_flats / 2 / cos(30);

module hex_bolt() {
    // 頭部(六角柱) z=0 から z=head_height へ
    cylinder(h = head_height, r = head_radius, $fn = 6);

    // シャンク(円柱) z=0 から z=-shank_length へ
    translate([0, 0, -shank_length])
        cylinder(h = shank_length, d = shank_diameter, $fn = 64);
}

hex_bolt();