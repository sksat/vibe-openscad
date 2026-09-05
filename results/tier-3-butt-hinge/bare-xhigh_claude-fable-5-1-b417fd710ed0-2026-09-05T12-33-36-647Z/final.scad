// ============================================================
//  家具用 小型バット蝶番(butt hinge)
//  3 パーツ構成: 左板 / 右板 / ピン軸  … 180° 開いた状態で配置
//
//  座標系
//   - ピン軸の中心線 = Y 軸(ピンは +Y 方向)
//   - 板の平らな面は Z 軸に直交
//   - 左板は x<0 側、右板は x>0 側に伸びる
//   - knuckle は X=0, Z=0 を中心とし、Y 方向に 6mm ずつ並ぶ
//
//  板は取付面(下面)が knuckle 外周に接する位置に置いているため、
//  右板を Y 軸まわりに回転させても左板と干渉せず 0° まで閉じられる。
// ============================================================

$fn = 72;

// ---------------- 寸法パラメータ ----------------
leaf_len    = 30;    // 板の縦(ヒンジ軸方向 = Y)
leaf_w      = 25;    // 板の横(開く方向 = X)
leaf_t      = 2;     // 板厚

pin_d       = 4;     // ピン軸 直径
pin_len     = 32;    // ピン軸 長さ(両端 1mm ずつ突出)
pin_clear   = 0.3;   // ピンと穴の片側クリアランス
bore_d      = pin_d + 2*pin_clear;   // knuckle 内径 = 4.6mm

knuckle_od  = 8;     // knuckle 外径
knuckle_r   = knuckle_od/2;
n_seg       = 5;                     // 縦 30mm を 5 等分
seg_len     = leaf_len/n_seg;        // = 6mm
knuckle_gap = 0.2;   // 隣接 knuckle 端面間の軸方向すき間
notch_clear = 0.3;   // 相手 knuckle との半径方向すき間

left_segs   = [0, 2, 4];   // 左板 knuckle: 外側 2 個 + 中央 1 個
right_segs  = [1, 3];      // 右板 knuckle: 中間 2 個

leaf_z0     = -knuckle_r;  // 板の下面(取付面)の Z。knuckle 外周に接する

// ねじ穴(M3 皿穴)
hole_x      = 17;    // 軸から穴中心までの距離(knuckle から離れた側)
hole_pitch  = 8;     // 縦方向ピッチ
hole_n      = 3;
hole_d      = 3.2;   // 貫通穴
cs_d        = 6;     // 皿穴 表面径
cs_depth    = 1;     // 皿穴 深さ

open_angle  = 180;   // 開き角(動作確認用。180 = 完全に開いた状態)

eps = 0.01;

// ---------------- 補助モジュール ----------------

// Y 軸に沿った円柱(y0 → y1)
module ycyl(d, y0, y1) {
    translate([0, y0, 0])
        rotate([-90, 0, 0])
            cylinder(d = d, h = y1 - y0);
}

// knuckle i の Y 範囲(隣接部にすき間、両端は板端いっぱい)
function seg_y0(i) = i*seg_len + (i > 0         ? knuckle_gap/2 : 0);
function seg_y1(i) = (i+1)*seg_len - (i < n_seg-1 ? knuckle_gap/2 : 0);

// knuckle(筒部)
module knuckle(i) {
    ycyl(knuckle_od, seg_y0(i), seg_y1(i));
}

// 相手 knuckle が入る切り欠き(半径方向にクリアランス付き)
module notch(i) {
    ycyl(knuckle_od + 2*notch_clear,
         i*seg_len     - knuckle_gap/2,
         (i+1)*seg_len + knuckle_gap/2);
}

// M3 皿穴(表面 d6 → 深さ 1mm でテーパ + d3.2 貫通)
module screw_hole(x, y) {
    top = leaf_z0 + leaf_t;          // 板の表面(皿穴側)
    translate([x, y, 0]) {
        // 貫通穴
        translate([0, 0, leaf_z0 - 1])
            cylinder(d = hole_d, h = leaf_t + 2);
        // 皿テーパ
        translate([0, 0, top - cs_depth])
            cylinder(d1 = hole_d, d2 = cs_d, h = cs_depth);
        // 表面上の逃げ
        translate([0, 0, top - eps])
            cylinder(d = cs_d, h = 1);
    }
}

// ---------------- 板(leaf) ----------------
// side: -1 = 左板(x<0), +1 = 右板(x>0)
module leaf(side, segs, other_segs) {
    difference() {
        union() {
            // 平板(相手 knuckle 用の切り欠き付き)
            difference() {
                translate([side > 0 ? 0 : -leaf_w, 0, leaf_z0])
                    cube([leaf_w, leaf_len, leaf_t]);
                for (i = other_segs) notch(i);
            }
            // 自分の knuckle
            for (i = segs) knuckle(i);
        }
        // ピン穴(全長貫通)
        ycyl(bore_d, -1, leaf_len + 1);
        // 皿穴 3 個(縦方向 8mm ピッチ、板中央に対称)
        for (k = [0 : hole_n - 1])
            screw_hole(side * hole_x,
                       leaf_len/2 + (k - (hole_n - 1)/2) * hole_pitch);
    }
}

// ---------------- ピン軸 ----------------
module pin() {
    ext = (pin_len - leaf_len)/2;    // 両端の突出量 = 1mm
    ycyl(pin_d, -ext, leaf_len + ext);
}

// ---------------- 組み立て ----------------
// 左板(knuckle 3 個: 0,2,4)
color("Silver")
    leaf(-1, left_segs, right_segs);

// 右板(knuckle 2 個: 1,3) … open_angle < 180 で +Z 側へ折れる
color("LightGray")
    rotate([0, -(180 - open_angle), 0])
        leaf(+1, right_segs, left_segs);

// ピン軸
color("Goldenrod")
    pin();