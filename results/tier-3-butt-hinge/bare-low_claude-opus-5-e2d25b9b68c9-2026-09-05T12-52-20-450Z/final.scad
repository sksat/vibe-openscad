// =====================================================
// 家具用 小型バット蝶番 (butt hinge)  — 180° 開いた状態
//   ・左板 (x<0) : knuckle 3個 (外側2 + 中央1)
//   ・右板 (x>0) : knuckle 2個 (中間2)
//   ・ピン軸     : φ4 x 32mm  (Y軸に一致)
// =====================================================

$fn = 64;

// ---------- パラメータ ----------
LEAF_LEN    = 30;    // ヒンジ軸方向(Y)の長さ
LEAF_WID    = 25;    // 開く方向(X)の幅
LEAF_TH     = 2;     // 板厚

PIN_D       = 4;     // ピン軸径
PIN_LEN     = 32;    // ピン軸長
CLR         = 0.3;   // クリアランス

KN_OD       = 8;             // knuckle 外径
KN_ID       = PIN_D + CLR;   // knuckle 内径 = 4.6
KN_SEG      = LEAF_LEN / 5;  // 6mm
KN_GAP      = 0.2;           // knuckle 同士の Y 方向すきま

SCREW_D     = 3.2;   // 貫通穴
CS_D        = 6;     // 皿穴径
CS_DEPTH    = 1;     // 皿テーパ深さ
HOLE_PITCH  = 8;     // 穴ピッチ(Y方向)
HOLE_X      = 18;    // knuckle 中心からのねじ穴位置(板中心寄り外側)

EPS         = 0.01;

// Y 方向 5 分割の各セグメント中心
function seg_y(i) = -LEAF_LEN/2 + KN_SEG/2 + i*KN_SEG;   // i = 0..4

// ---------- モジュール ----------

// knuckle 1個 (Y方向に長さ len、中心 yc)
module knuckle(yc, len) {
    translate([0, yc - len/2, 0])
        rotate([-90, 0, 0])
            difference() {
                cylinder(h = len, d = KN_OD);
                translate([0, 0, -EPS])
                    cylinder(h = len + 2*EPS, d = KN_ID);
            }
}

// 皿穴 (板の上面 z = +LEAF_TH/2 から見て)
module countersunk_hole() {
    // 貫通穴
    translate([0, 0, -LEAF_TH])
        cylinder(h = LEAF_TH*2, d = SCREW_D);
    // テーパ部(上面から深さ CS_DEPTH)
    translate([0, 0, LEAF_TH/2 - CS_DEPTH])
        cylinder(h = CS_DEPTH, d1 = SCREW_D, d2 = CS_D);
    // 上面より上は逃がし
    translate([0, 0, LEAF_TH/2 - EPS])
        cylinder(h = 2, d = CS_D);
}

// 板 1枚 (+X 方向に伸びる形で作り、必要なら mirror して使う)
//   knuckle_idx : この板が持つ knuckle のセグメント番号リスト
module leaf(knuckle_idx) {
    difference() {
        union() {
            // 平板:X = KN_OD/2 - 1 あたりから外へ伸ばし、
            // knuckle と滑らかに繋げる(接続部を少し重ねる)
            translate([0, -LEAF_LEN/2, -LEAF_TH/2])
                cube([LEAF_WID, LEAF_LEN, LEAF_TH]);

            // knuckle 本体
            for (i = knuckle_idx)
                knuckle(seg_y(i), KN_SEG - KN_GAP);

            // knuckle と板のつなぎ(ウェブ)
            for (i = knuckle_idx)
                translate([0, seg_y(i) - (KN_SEG - KN_GAP)/2, -LEAF_TH/2])
                    cube([KN_OD/2, KN_SEG - KN_GAP, LEAF_TH]);
        }
        // ピン穴(板と重なる部分も貫通させる)
        translate([0, -PIN_LEN, 0])
            rotate([-90, 0, 0])
                cylinder(h = PIN_LEN*2, d = KN_ID);

        // ねじ穴 3個
        for (k = [-1, 0, 1])
            translate([HOLE_X, k * HOLE_PITCH, 0])
                countersunk_hole();
    }
}

// ピン軸
module pin() {
    translate([0, -PIN_LEN/2, 0])
        rotate([-90, 0, 0])
            union() {
                cylinder(h = PIN_LEN, d = PIN_D);
                // 端部の面取り風ヘッド
                cylinder(h = 0.6, d = PIN_D + 0.8);
                translate([0, 0, PIN_LEN - 0.6])
                    cylinder(h = 0.6, d = PIN_D + 0.8);
            }
}

// ---------- アセンブリ(180° 開) ----------

// 左板:knuckle は 外側2個(0,4) + 中央1個(2)
color("Silver")
    mirror([1, 0, 0])
        leaf([0, 2, 4]);

// 右板:knuckle は 中間2個(1,3)
color("LightSteelBlue")
    leaf([1, 3]);

// ピン軸
color("DimGray")
    pin();