// ============================================================
//  小型バット蝶番(家具用) - 180° 開いた状態
//  パーツ: 左板(leaf) / 右板(leaf) / ピン軸
//  座標系: ピン軸中心線 = Y軸 (+Y 方向), 板面は Z に直交
// ============================================================
$fn = 64;

/* ---------------- パラメータ ---------------- */
leaf_len     = 30;        // 板の縦 (ヒンジ軸 = Y 方向)
leaf_w       = 25;        // 板の横 (開く方向 = X 方向)
leaf_t       = 2;         // 板厚 (Z 方向)

pin_d        = 4;         // ピン軸 直径
pin_len      = 32;        // ピン軸 長さ (両端 1mm ずつ突出)

knuckle_od   = 8;         // knuckle 外径
pin_hole_d   = 4.6;       // knuckle 内径 (ピン + 0.3mm クリアランス)

seg_n        = 5;                  // knuckle 分割数
seg_len      = leaf_len / seg_n;   // = 6mm
gap          = 0.2;                // knuckle 同士の回転クリアランス

screw_hole_d = 3.2;       // M3 貫通穴
cs_d         = 6;         // 皿穴 表面径
cs_depth     = 1;         // 皿穴 テーパ深さ
screw_pitch  = 8;         // 穴ピッチ (Y 方向)
screw_off_x  = 18;        // ピン軸から穴列までの距離

eps = 0.01;

left_segs  = [0, 2, 4];   // 左板: 外側 2 個 + 中央 1 個
right_segs = [1, 3];      // 右板: 中間 2 個

/* ---------------- モジュール ---------------- */

// knuckle 1 区画 (Y 軸沿いの筒, 区画番号 i)
module knuckle(i) {
    translate([0, i * seg_len, 0])
        rotate([-90, 0, 0])
            cylinder(h = seg_len, d = knuckle_od);
}

// 相手側 knuckle が入る切り欠き (クリアランス付き)
module knuckle_cut(i) {
    translate([-(knuckle_od/2 + 0.5),
               i * seg_len - gap,
               -(knuckle_od/2 + 0.5)])
        cube([knuckle_od + 1,
              seg_len + 2 * gap,
              knuckle_od + 1]);
}

// M3 皿穴 ×3 (side = +1: 右板, -1: 左板, 表面 z = +leaf_t/2 から皿)
module screw_holes(side) {
    for (i = [-1, 0, 1]) {
        translate([side * screw_off_x,
                   leaf_len/2 + i * screw_pitch, 0]) {
            // 貫通穴 d3.2
            translate([0, 0, -leaf_t])
                cylinder(h = 2 * leaf_t, d = screw_hole_d);
            // テーパ皿 (表面 d6 → 深さ 1mm)
            translate([0, 0, leaf_t/2 - cs_depth])
                cylinder(h = cs_depth, d1 = screw_hole_d, d2 = cs_d);
            // 表面の縁を確実に抜く
            translate([0, 0, leaf_t/2 - eps])
                cylinder(h = 1, d = cs_d);
        }
    }
}

// 板 (side = -1: x<0 へ, +1: x>0 へ / own: 自分の knuckle 区画)
module leaf(side, own, other) {
    difference() {
        union() {
            // 平板 30 × 25 × t2 (ピン中心面 z=0 をはさむ)
            translate([side > 0 ? 0 : -leaf_w, 0, -leaf_t/2])
                cube([leaf_w, leaf_len, leaf_t]);
            // 自分の knuckle
            for (i = own) knuckle(i);
        }
        // 相手 knuckle 用の切り欠き
        for (i = other) knuckle_cut(i);
        // ピン穴 (d4.6 貫通)
        translate([0, -1, 0])
            rotate([-90, 0, 0])
                cylinder(h = leaf_len + 2, d = pin_hole_d);
        // ねじ穴
        screw_holes(side);
    }
}

// ピン軸 d4 × L32 (Y = -1 〜 31, 両端 1mm 突出)
module hinge_pin() {
    translate([0, (leaf_len - pin_len) / 2, 0])
        rotate([-90, 0, 0])
            cylinder(h = pin_len, d = pin_d);
}

/* ---------------- 組み立て (180° 開) ---------------- */

color("LightSteelBlue") leaf(-1, left_segs,  right_segs); // 左板 (x<0)
color("LightSteelBlue") leaf( 1, right_segs, left_segs);  // 右板 (x>0)
color("Goldenrod")      hinge_pin();                      // ピン軸