// =====================================================
//  家具用 小型バット蝶番 (butt hinge)  -- 180°開いた状態
//  ・左板 (x<0) / 右板 (x>0) / ピン軸 (Y軸上)
// =====================================================

$fn = 96;

// ---------------- パラメータ ----------------
leaf_w   = 25;              // 板の横幅（開く方向）
leaf_l   = 30;              // 板の縦（ヒンジ軸方向）
leaf_t   = 2;               // 板厚

pin_d    = 4;               // ピン軸径
pin_len  = 32;              // ピン軸長（両端 1mm ずつ突出）

knu_od   = 8;               // knuckle 外径
pin_clr  = 0.3;             // ピンとのクリアランス
knu_id   = pin_d + pin_clr; // 4.6mm 穴

seg      = leaf_l / 5;      // 6mm × 5 等分
ax_gap   = 0.1;             // knuckle 軸方向クリアランス（片側）
rad_clr  = 0.2;             // 相手 knuckle 逃げの半径クリアランス

left_segs  = [0, 2, 4];     // 左板: 外側2個 + 中央1個
right_segs = [1, 3];        // 右板: 中間2個

screw_pitch = 8;            // ネジ穴ピッチ（Y方向）
screw_d     = 3.2;          // 貫通穴径
cs_d        = 6;            // 皿穴径
cs_depth    = 1;            // 皿深さ
screw_x     = 17;           // ピン軸からのネジ穴距離

eps = 0.01;

// ---------------- ヘルパ ----------------
// Y 軸方向の円柱（y0 -> y1）
module ycyl(d, y0, y1) {
    translate([0, y0, 0])
        rotate([-90, 0, 0])
            cylinder(d = d, h = y1 - y0);
}

function seg_y0(i) = -leaf_l/2 + i * seg;
function seg_y1(i) = -leaf_l/2 + (i + 1) * seg;

// M3 皿穴（+Z 面が表）
module countersunk_hole() {
    // 貫通穴
    translate([0, 0, -leaf_t/2 - 1])
        cylinder(d = screw_d, h = leaf_t + 2);
    // テーパ（表面 φ6 → 深さ1で φ3.2）
    translate([0, 0, leaf_t/2 - cs_depth])
        cylinder(d1 = screw_d, d2 = cs_d, h = cs_depth + eps);
    // 表面より上の逃げ
    translate([0, 0, leaf_t/2 - eps])
        cylinder(d = cs_d, h = 1);
}

// ---------------- 板本体（-X 方向に伸びる基本形） ----------------
module hinge_leaf(my_segs, other_segs) {
    difference() {
        union() {
            // 平板
            translate([-leaf_w, -leaf_l/2, -leaf_t/2])
                cube([leaf_w, leaf_l, leaf_t]);
            // 自分の knuckle
            for (i = my_segs)
                ycyl(knu_od, seg_y0(i), seg_y1(i));
        }

        // 相手 knuckle の逃げ（軸方向・半径方向クリアランス込み）
        for (i = other_segs)
            ycyl(knu_od + 2 * rad_clr,
                 seg_y0(i) - ax_gap,
                 seg_y1(i) + ax_gap);

        // ピン穴（全長貫通）
        ycyl(knu_id, -leaf_l, leaf_l);

        // M3 皿穴 ×3
        for (k = [-1, 0, 1])
            translate([-screw_x, k * screw_pitch, 0])
                countersunk_hole();
    }
}

// ---------------- 各パーツ ----------------
module left_leaf() {
    color("Silver")
        hinge_leaf(left_segs, right_segs);
}

module right_leaf() {
    color("LightSteelBlue")
        mirror([1, 0, 0])
            hinge_leaf(right_segs, left_segs);
}

module hinge_pin() {
    color("DimGray")
        ycyl(pin_d, -pin_len/2, pin_len/2);
}

// ---------------- 組み立て（180° 開） ----------------
module butt_hinge() {
    left_leaf();
    right_leaf();
    hinge_pin();
}

butt_hinge();