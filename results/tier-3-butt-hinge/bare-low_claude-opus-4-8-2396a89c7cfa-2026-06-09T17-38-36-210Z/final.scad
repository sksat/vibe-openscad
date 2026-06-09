// 家具用 小型バット蝶番 (butt hinge) - 180°開状態
// ピン軸中心線 = Y軸, knuckle外径8, ピン径4

$fn = 60;

// パラメータ
leaf_len   = 30;   // 縦(Y方向, ヒンジ軸方向)
leaf_w     = 25;   // 横(開く方向)
leaf_t     = 2;    // 板厚
pin_d      = 4;    // ピン径
pin_len    = 32;   // ピン長
knuckle_od = 8;    // knuckle外径
knuckle_id = 4.6;  // knuckle内径(ピン+0.3クリア)
seg        = 6;    // 各knuckle長
n_seg      = 5;    // 分割数

// knuckle の y 開始位置 (X=0中心, Y方向に並ぶ, 中心が原点)
// 5等分: y = -15..15, 各6mm → 区間 [-15,-9],[-9,-3],[-3,3],[3,9],[9,15]
function seg_y(i) = -leaf_len/2 + i*seg;  // i番目区間の開始y

// 皿穴 (M3): 表面 φ6×深さ1 テーパ + φ3.2貫通
module csk_hole() {
    // 板厚方向 Z に貫通。板の上面 z = +leaf_t/2 側にテーパ
    translate([0,0,-leaf_t/2-0.1])
        cylinder(d=3.2, h=leaf_t+0.2);
    translate([0,0,leaf_t/2-1])
        cylinder(d1=3.2, d2=6, h=1+0.01);
    translate([0,0,leaf_t/2])
        cylinder(d=6, h=0.1); // 表面開口
}

// knuckle (筒) 1個: 区間 i
module knuckle(i) {
    translate([0, seg_y(i), 0])
    rotate([-90,0,0])
        difference() {
            cylinder(d=knuckle_od, h=seg);
            translate([0,0,-0.1])
                cylinder(d=knuckle_id, h=seg+0.2);
        }
}

// 板本体 (knuckle側を X=knuckle_od/2 から leaf_w 伸ばす)
// 板は z 中心0, 厚さ leaf_t。X方向 sign(+1=右, -1=左)
module leaf_plate(sgn) {
    x0 = knuckle_od/2;
    translate([sgn*x0, -leaf_len/2, -leaf_t/2])
        cube([leaf_w, leaf_len, leaf_t]);
}

// 板 + knuckle に皿穴を開ける
// 皿穴位置: knuckleから離れた側, 縦8mm間隔3個
module leaf(sgn, seg_indices) {
    // ねじ穴のX位置(板の外側寄り)
    hole_x = sgn*(knuckle_od/2 + leaf_w - 6);
    difference() {
        union() {
            leaf_plate(sgn);
            for (i = seg_indices) knuckle(i);
        }
        // 皿穴 3個 (y = -8,0,8)
        for (dy = [-8,0,8])
            translate([hole_x, dy, 0]) csk_hole();
    }
}

// ピン軸
module pin() {
    rotate([-90,0,0])
        translate([0,0,-pin_len/2])
            cylinder(d=pin_d, h=pin_len);
}

// 配置
// 左板(x<0): 外側2個 + 中央1個 = 区間 0,2,4
color("Silver")  leaf(-1, [0,2,4]);
// 右板(x>0): 中間2個 = 区間 1,3
color("LightGray") leaf( 1, [1,3]);
// ピン軸
color("Gold") pin();