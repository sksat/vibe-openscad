// 小型バット蝶番（家具用）
// 開いた状態（180°）

$fn = 64;

// パラメータ
leaf_length = 30;      // 板の縦（ピン軸方向）
leaf_width = 25;       // 板の横（開く方向）
leaf_thick = 2;        // 板厚
pin_dia = 4;           // ピン軸直径
pin_len = 32;          // ピン長さ
knuckle_od = 8;        // knuckle 外径
knuckle_id = pin_dia + 0.3;  // 4.6mm
knuckle_seg = leaf_length / 5;  // 6mm
clearance = 0.2;       // knuckle 同士のクリアランス（モデル上は 0 でも可）

// 皿穴パラメータ
csk_outer_dia = 6;
csk_depth = 1;
csk_through_dia = 3.2;
hole_pitch = 8;

// ===== knuckle（筒）モジュール =====
// Y方向に長さ seg_len の筒を、Y=y0 を始点として作る
module knuckle(y0, seg_len) {
    translate([0, y0, 0])
        rotate([-90, 0, 0])
            difference() {
                cylinder(d = knuckle_od, h = seg_len);
                translate([0, 0, -0.1])
                    cylinder(d = knuckle_id, h = seg_len + 0.2);
            }
}

// ===== 板の平板部分（knuckle 側を knuckle と接続するための形状）=====
// 板は厚さ leaf_thick、縦 leaf_length、横 leaf_width
// 板の knuckle 側端は knuckle 外径の半分（半径 4mm）に接する位置から伸びる
// X=0（ピン軸中心）から見て、板はピン軸の中心からオフセットした位置に配置
//
// 開いた状態で板の表面（皿穴側、外側）は Z = +leaf_thick/2 にしたい
// → 平らな面の中央 Z = 0、板の上面 Z = +1、下面 Z = -1
// knuckle 外径 8mm（半径 4mm）の中心は X=0, Y は leaf 中心、Z=0
// 板はピン中心線から横方向に伸び、knuckle の外周に接続する
// 左板: x < 0 側に伸びる。板の右端（knuckle 接続側）は X = 0 で knuckle と接する
//      → 板の右端は X = 0、左端は X = -leaf_width
//      knuckle と板の重なり部分: knuckle 半径 4mm、板厚 1mm 上下
//      板を knuckle の中心側まで伸ばして hull で接続するのが一般的
// 右板: x > 0 側に伸びる。板の左端（knuckle 接続側）は X = 0
//      → 板の左端は X = 0、右端は X = +leaf_width

// 左板の平板部
module left_leaf_plate() {
    // 板の右端が knuckle 中心 X=0 まで来るようにする
    // 板: X = [-leaf_width, 0], Y = [0, leaf_length], Z = [-leaf_thick/2, +leaf_thick/2]
    translate([-leaf_width, 0, -leaf_thick/2])
        cube([leaf_width, leaf_length, leaf_thick]);
}

module right_leaf_plate() {
    // 板: X = [0, leaf_width], Y = [0, leaf_length], Z = [-leaf_thick/2, +leaf_thick/2]
    translate([0, 0, -leaf_thick/2])
        cube([leaf_width, leaf_length, leaf_thick]);
}

// ===== 皿穴モジュール =====
// 板の表面（Z = +leaf_thick/2）から見て皿穴。Z軸方向に貫通
module countersunk_hole() {
    // 貫通穴
    translate([0, 0, -leaf_thick/2 - 0.1])
        cylinder(d = csk_through_dia, h = leaf_thick + 0.2);
    // 皿穴部（テーパ）: 表面で 6mm、深さ 1mm で 3.2mm に絞る
    translate([0, 0, leaf_thick/2 - csk_depth])
        cylinder(d1 = csk_through_dia, d2 = csk_outer_dia, h = csk_depth + 0.01);
}

// ===== 左板（皿穴付き、knuckle 3個付き）=====
module left_leaf() {
    difference() {
        union() {
            left_leaf_plate();
            // knuckle: 外側2個 + 中央1個
            // 5等分の区切り: Y = 0,6,12,18,24,30
            // 左板は区間 [0,6], [12,18], [24,30]
            knuckle(0, knuckle_seg);
            knuckle(2 * knuckle_seg, knuckle_seg);
            knuckle(4 * knuckle_seg, knuckle_seg);
        }
        // 皿穴 3個（板の knuckle から離れた側 = 左板では x が小さい側）
        // Y方向の位置: 中央 Y = leaf_length/2 = 15、ピッチ 8mm → Y = 7, 15, 23
        // X方向の位置: 板の中央付近、knuckle から離れた側
        // 板は X=[-25,0]、knuckle 側 = X=0 付近、離れた側 = X=-25 付近
        // 皿穴中心 X は板の中央寄り、knuckle から離れた側
        // ここでは X = -leaf_width/2 = -12.5 とする（板中央）
        // ただし「knuckle から離れた側」を強調するなら X = -leaf_width + 8 = -17 など
        // ここは板中央に配置
        for (i = [0:2]) {
            translate([-leaf_width/2 + 5, leaf_length/2 + (i-1) * hole_pitch, 0])
                countersunk_hole();
        }
        // ピン軸通し穴（knuckle 部分は既に内径あるが、念のため板部にも貫通させない）
    }
}

// ===== 右板（皿穴付き、knuckle 2個付き）=====
module right_leaf() {
    difference() {
        union() {
            right_leaf_plate();
            // knuckle: 中間2個
            // 右板は区間 [6,12], [18,24]
            knuckle(knuckle_seg, knuckle_seg);
            knuckle(3 * knuckle_seg, knuckle_seg);
        }
        // 皿穴 3個
        for (i = [0:2]) {
            translate([leaf_width/2 - 5, leaf_length/2 + (i-1) * hole_pitch, 0])
                countersunk_hole();
        }
    }
}

// ===== ピン軸 =====
module pin() {
    // Y軸方向、Y = -1 から Y = leaf_length + 1 まで（長さ 32mm）
    translate([0, -1, 0])
        rotate([-90, 0, 0])
            cylinder(d = pin_dia, h = pin_len);
}

// ===== 組み立て（180° 開いた状態）=====
// 色分けして出力
color("Silver") left_leaf();
color("Gray") right_leaf();
color("DarkGray") pin();