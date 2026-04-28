// M8 Hex Bolt (corrected)

// Dimensions
head_af = 13;      // Across-flats (二面幅)
head_height = 5.3;
shank_dia = 8;
shank_len = 30;

// cylinder(..., $fn=6) を使用する場合、radius は「外接円の半径」を指定する必要があります。
// 対辺距離(head_af)の六角形において、外接円の半径 r は head_af / sqrt(3) です。
hex_radius = head_af / sqrt(3);

union() {
    // 頭部の底面を z=0 に配置
    cylinder(r = hex_radius, h = head_height, $fn = 6);
    
    // シャンクを z<0 側に配置
    translate([0, 0, -shank_len])
        cylinder(d = shank_dia, h = shank_len, $fn = 50);
}