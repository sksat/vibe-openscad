// ===========================================
//  M8 六角ボルト (JIS/ISO 準拠寸法・ねじ山省略)
// ===========================================

$fn = 96;

// --- 寸法パラメータ ---
head_af     = 13;    // 頭部 対辺距離 (across-flats)
head_h      = 5.3;   // 頭部 高さ
shank_d     = 8;     // シャンク 直径 (M8)
shank_len   = 30;    // シャンク 長さ

// 対辺距離 -> 外接円半径 (対角距離/2)
function af2r(af) = af / sqrt(3);

// --- 六角頭部 ---
module hex_head() {
    cylinder(h = head_h, r = af2r(head_af), $fn = 6);
}

// --- シャンク(軸部) ---
module shank() {
    translate([0, 0, -shank_len])
        cylinder(h = shank_len, d = shank_d);
}

// --- ボルト本体 ---
module m8_hex_bolt() {
    union() {
        hex_head();   // z =  0 〜 +5.3
        shank();      // z = -30 〜  0
    }
}

m8_hex_bolt();