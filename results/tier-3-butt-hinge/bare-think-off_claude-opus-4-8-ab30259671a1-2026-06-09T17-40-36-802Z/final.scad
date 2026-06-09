// 小型バット蝶番(butt hinge) 180°開いた状態
// ピン軸中心線 = Y軸、左板 x<0、右板 x>0

$fn = 64;

// パラメータ
leaf_w     = 25;    // 横(開く方向)
leaf_h     = 30;    // 縦(軸方向)
leaf_t     = 2;     // 板厚
pin_d      = 4;     // ピン直径
pin_len    = 32;    // ピン長さ
knuckle_od = 8;     // knuckle外径
knuckle_id = pin_d + 0.3; // 内径(クリアランス)
seg        = leaf_h / 5;  // 6mm

// 皿穴パラメータ
csk_outer  = 6;     // 皿穴上面直径
csk_depth  = 1;     // テーパ深さ
hole_d     = 3.2;   // 貫通穴
hole_pitch = 8;     // 縦方向ピッチ

knuckle_r  = knuckle_od / 2;

// ---- knuckle(筒部) ----
// y0: 開始Y位置, len: 長さ
module knuckle(y0, len) {
    translate([0, y0, 0])
        rotate([-90, 0, 0])
            difference() {
                cylinder(h = len, d = knuckle_od);
                translate([0, 0, -1])
                    cylinder(h = len + 2, d = knuckle_id);
            }
}

// ---- 皿穴(板の中央付近、貫通)----
// 板の上面を Z = knuckle_r、下面を Z = knuckle_r - leaf_t と想定して使用
module countersink_at(x, y, top_z, t) {
    translate([x, y, 0]) {
        // 貫通穴
        translate([0, 0, top_z - t - 1])
            cylinder(h = t + 2, d = hole_d);
        // 皿テーパ(上面から)
        translate([0, 0, top_z - csk_depth])
            cylinder(h = csk_depth + 0.01, d1 = hole_d, d2 = csk_outer);
    }
}

// ---- 板本体(平板部) ----
// dir = -1 (左, x<0), +1 (右, x>0)
// 板の平面は knuckle中心からオフセットして同一平面(180°開)になるよう配置
// 板上面 Z = knuckle_r, 下面 Z = knuckle_r - leaf_t
module leaf_plate(dir) {
    // x: knuckle中心(X=0)から leaf_w 伸びる
    // knuckleと重なる部分は接続用に knuckle_r まで含める
    x_inner = 0;
    x_outer = dir * (knuckle_r + leaf_w);
    x_lo = min(x_inner, x_outer);
    x_hi = max(x_inner, x_outer);
    translate([x_lo, 0, knuckle_r - leaf_t])
        cube([x_hi - x_lo, leaf_h, leaf_t]);
}

// ---- 左板(knuckle 3個: 外側2 + 中央1)----
module left_leaf() {
    color("silver")
    difference() {
        union() {
            // 平板
            leaf_plate(-1);
            // knuckle 外側2 + 中央1 -> セグメント 0,2,4
            knuckle(0 * seg, seg);
            knuckle(2 * seg, seg);
            knuckle(4 * seg, seg);
            // 板とknuckleをつなぐウェブ(knuckle中心から板へ)
        }
        // ピン穴(共有)
        translate([0, -1, 0])
            rotate([-90, 0, 0])
                cylinder(h = leaf_h + 2, d = knuckle_id);
        // 皿穴 3個(板の外側)
        cx = -(knuckle_r + leaf_w - 6);
        top_z = knuckle_r;
        for (i = [0:2])
            countersink_at(cx, leaf_h/2 + (i-1)*hole_pitch, top_z, leaf_t);
    }
}

// ---- 右板(knuckle 2個: 中間2)----
module right_leaf() {
    color("gray")
    difference() {
        union() {
            leaf_plate(1);
            // knuckle 中間2 -> セグメント 1,3
            knuckle(1 * seg, seg);
            knuckle(3 * seg, seg);
        }
        translate([0, -1, 0])
            rotate([-90, 0, 0])
                cylinder(h = leaf_h + 2, d = knuckle_id);
        cx = (knuckle_r + leaf_w - 6);
        top_z = knuckle_r;
        for (i = [0:2])
            countersink_at(cx, leaf_h/2 + (i-1)*hole_pitch, top_z, leaf_t);
    }
}

// ---- ピン軸 ----
module pin() {
    color("gold")
    translate([0, -1, 0])     // 両端1mmずつ飛び出す
        rotate([-90, 0, 0])
            cylinder(h = pin_len, d = pin_d);
}

// ---- 組み立て(180°開いた状態)----
left_leaf();
right_leaf();
pin();