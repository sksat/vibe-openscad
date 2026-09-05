// M8 六角ボルト（ねじ山省略・円柱シャンク）
// 頭部底面が z=0、頭部は +Z 側、シャンクは -Z 側へ伸びる

// ---- パラメータ ----
head_af   = 13;    // 頭部 対辺距離 (across-flats) [mm]
head_h    = 5.3;   // 頭部 高さ [mm]
shank_d   = 8;     // シャンク 直径 [mm]
shank_len = 30;    // シャンク 長さ [mm]

// 対辺距離 -> 六角形の外接円直径
head_d = head_af / cos(30);

$fn = 96;

// ---- 頭部（六角柱） ----
module hex_head() {
    // $fn=6 の cylinder は頂点が外接円上に乗る六角柱になる
    cylinder(d = head_d, h = head_h, $fn = 6);
}

// ---- シャンク（円柱） ----
module shank() {
    // 頭部内部にわずかに食い込ませて確実に結合させる（外形寸法は変わらない）
    eps = 0.01;
    translate([0, 0, -shank_len])
        cylinder(d = shank_d, h = shank_len + eps);
}

// ---- ボルト全体 ----
module hex_bolt() {
    union() {
        hex_head();
        shank();
    }
}

hex_bolt();