// ============================================================
//  家具用 小型バット蝶番 (Butt Hinge) --- 180°オープン状態
//  Parts : 左板(left leaf) / 右板(right leaf) / ピン軸(pin)
//
//  座標系:
//    ピン軸の中心線 = Y 軸 (+Y 方向), 板の平面は Z 軸に直交
//    左板 = x<0 側, 右板 = x>0 側 (180°開)
//    z = 0 の面 = 相手板との合わせ面(ピン軸を含む平面)
//    板本体は z = -leaf_t 〜 0 に配置 → 両板の平面は同一平面
//    (この配置により 0°まで畳むと2枚が面接触する実物どおりの構造)
// ============================================================

$fn = 96;

/* ------------------- パラメータ ------------------- */
leaf_len    = 30;                 // 板 縦 (Y = ヒンジ軸方向)
leaf_w      = 25;                 // 板 横 (X = 開く方向 / 軸中心から先端まで)
leaf_t      = 2;                  // 板厚

knuckle_d   = 8;                  // knuckle 外径
n_seg       = 5;                  // 縦30mmの分割数
seg_len     = leaf_len / n_seg;   // = 6mm (1区画)
knuckle_gap = 0.2;                // 隣接knuckleのY逃げ(0にすると各6mmぴったり)

pin_d       = 4;                  // ピン軸 直径
pin_len     = 32;                 // ピン軸 長さ(両端約1mm突出)
pin_clr     = 0.3;                // 片側クリアランス
pin_hole_d  = pin_d + 2*pin_clr;  // = 4.6mm 穴

barrel_clr  = 0.2;                // 相手knuckle外周に対する板側の逃げ

screw_d     = 3.2;                // M3 貫通穴
cs_d        = 6.0;                // 皿穴 大径
cs_h        = 1.0;                // 皿(テーパ)深さ
screw_x     = 18;                 // ねじ穴 X 位置(knuckleから離れた側)
screw_pitch = 8;                  // ねじ穴 Y ピッチ
screw_n     = 3;                  // ねじ穴 個数

left_segs   = [0, 2, 4];          // 左板のknuckle : 外側2個 + 中央1個
right_segs  = [1, 3];             // 右板のknuckle : 中間2個

eps  = 0.01;
over = 0.2;

// 区画 i (0..4) の中心 Y 座標 : -12, -6, 0, 6, 12
function seg_cy(i) = -leaf_len/2 + seg_len*(i + 0.5);

/* ------------------- ヘルパ ------------------- */
// Y 軸方向の円柱
module y_cyl(y0, len, d) {
    translate([0, y0, 0]) rotate([-90, 0, 0]) cylinder(h = len, d = d);
}

// 皿穴(z=0 の面から見て φ6×深さ1のテーパ + φ3.2 貫通)
module cs_hole() {
    translate([0, 0, -leaf_t - 1]) cylinder(h = leaf_t + 2, d = screw_d);
    translate([0, 0, -cs_h])
        cylinder(h = cs_h + over, d1 = screw_d,
                 d2 = cs_d + over*(cs_d - screw_d)/cs_h);
}

/* ------------------- 板(+X 側で生成) ------------------- */
module leaf_half(my_segs, other_segs) {
    difference() {
        union() {
            // 板 30 x 25 x t
            translate([0, -leaf_len/2, -leaf_t]) cube([leaf_w, leaf_len, leaf_t]);
            // 自分の knuckle
            for (i = my_segs)
                y_cyl(seg_cy(i) - (seg_len - knuckle_gap)/2,
                      seg_len - knuckle_gap, knuckle_d);
        }
        // ピン穴(全長)
        y_cyl(-leaf_len/2 - 1, leaf_len + 2, pin_hole_d);

        // 相手 knuckle の逃げ(その区画は板をバレル外周まで削る)
        for (i = other_segs)
            y_cyl(seg_cy(i) - seg_len/2 - eps, seg_len + 2*eps,
                  knuckle_d + 2*barrel_clr);

        // M3 皿穴 3個
        for (k = [0 : screw_n - 1])
            translate([screw_x,
                       -screw_pitch*(screw_n - 1)/2 + screw_pitch*k, 0])
                cs_hole();
    }
}

/* ------------------- 各パーツ ------------------- */
module right_leaf() { leaf_half(right_segs, left_segs); }
module left_leaf()  { mirror([1, 0, 0]) leaf_half(left_segs, right_segs); }

module hinge_pin() {
    ch = 0.4;   // 端面の面取り
    translate([0, -pin_len/2, 0]) rotate([-90, 0, 0])
        union() {
            cylinder(h = ch, d1 = pin_d - 2*ch, d2 = pin_d);
            translate([0, 0, ch])            cylinder(h = pin_len - 2*ch, d = pin_d);
            translate([0, 0, pin_len - ch])  cylinder(h = ch, d1 = pin_d, d2 = pin_d - 2*ch);
        }
}

/* ------------------- 組立(180°開) ------------------- */
module hinge_assembly() {
    color("Silver")         left_leaf();
    color("LightSteelBlue") right_leaf();
    color("DimGray")        hinge_pin();
}

/* ------------------- 出力 ------------------- */
part = "assembly";   // "assembly" / "left" / "right" / "pin"

if      (part == "assembly") hinge_assembly();
else if (part == "left")     left_leaf();
else if (part == "right")    right_leaf();
else if (part == "pin")      hinge_pin();