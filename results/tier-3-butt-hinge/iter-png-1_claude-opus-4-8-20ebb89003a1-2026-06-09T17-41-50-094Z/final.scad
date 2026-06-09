// ============================================================
// 家具用 小型バット蝶番 (butt hinge)
// 開いた状態 (180°) で配置
// ============================================================

$fn = 64;

// ---------- パラメータ ----------
leaf_w      = 25;    // 板の横幅 (開く方向)
leaf_h      = 30;    // 板の縦 (ヒンジ軸方向)
leaf_t      = 2;     // 板厚

pin_d       = 4;     // ピン軸 直径
pin_len     = 32;    // ピン軸 長さ

knuckle_od  = 8;     // knuckle 外径
knuckle_id  = 4.6;   // knuckle 内径 (ピン + 0.3 クリアランス)
seg         = 6;     // knuckle 1個の高さ (30/5)

// 皿穴 (M3)
screw_pitch = 8;     // 縦方向ピッチ
cs_d        = 6;     // 皿(テーパ) 直径
cs_depth    = 1;     // 皿深さ
hole_d      = 3.2;   // 貫通穴 直径

// 板の内側端 (knuckle に接続する位置の絶対値)
inner = knuckle_od/2 - leaf_t; // = 2

// ============================================================
// knuckle (筒) : Y方向に立てた円筒 (中心 X=0,Z=0)
// ============================================================
module knuckle(y0, h) {
    translate([0, y0, 0])
        rotate([-90, 0, 0])
            difference() {
                cylinder(h = h, d = knuckle_od);
                translate([0, 0, -1])
                    cylinder(h = h + 2, d = knuckle_id);
            }
}

// ============================================================
// 皿穴 (板を貫通) : Z方向
// 板の上面 z = leaf_t/2, 下面 z = -leaf_t/2 (板は z=0 中心)
// ============================================================
module countersink(x, y) {
    translate([x, y, 0]) {
        // 貫通穴
        translate([0, 0, -leaf_t/2 - 1])
            cylinder(h = leaf_t + 2, d = hole_d);
        // 皿(テーパ) : 上面側
        translate([0, 0, leaf_t/2 - cs_depth])
            cylinder(h = cs_depth + 0.01,
                     d1 = hole_d, d2 = cs_d);
    }
}

// ============================================================
// 平板部 (板は z=0 を中心に厚さ leaf_t)
//   dir = -1 : 左板 (x<0)
//   dir = +1 : 右板 (x>0)
// ============================================================
module leaf_plate(dir) {
    if (dir < 0) {
        // 左板 : x = -inner - leaf_w  ～  -inner
        difference() {
            translate([-inner - leaf_w, -leaf_h/2, -leaf_t/2])
                cube([leaf_w, leaf_h, leaf_t]);
            sx = -inner - leaf_w + 5;
            for (i = [-1, 0, 1])
                countersink(sx, i * screw_pitch);
        }
    } else {
        // 右板 : x = inner  ～  inner + leaf_w
        difference() {
            translate([inner, -leaf_h/2, -leaf_t/2])
                cube([leaf_w, leaf_h, leaf_t]);
            sx = inner + leaf_w - 5;
            for (i = [-1, 0, 1])
                countersink(sx, i * screw_pitch);
        }
    }
}

// ============================================================
// knuckle と板をつなぐウェブ
//   dir = -1 : 左側 (x : -inner ～ 0)
//   dir = +1 : 右側 (x : 0 ～ inner)
// knuckle 中心(X=0)から板内側端まで隙間なく接続
// ============================================================
module web(dir, y0, h) {
    if (dir < 0)
        translate([-inner, y0, -leaf_t/2])
            cube([inner, h, leaf_t]);
    else
        translate([0, y0, -leaf_t/2])
            cube([inner, h, leaf_t]);
}

// ============================================================
// 左板 : knuckle を外側2個 + 中央1個 (segment 0,2,4)
// ============================================================
module left_leaf() {
    color("Silver") {
        leaf_plate(-1);
        for (i = [0, 2, 4]) {
            knuckle(-leaf_h/2 + i*seg, seg);
            web(-1, -leaf_h/2 + i*seg, seg);
        }
    }
}

// ============================================================
// 右板 : knuckle を中間2個 (segment 1,3)
// ============================================================
module right_leaf() {
    color("LightSteelBlue") {
        leaf_plate(1);
        for (i = [1, 3]) {
            knuckle(-leaf_h/2 + i*seg, seg);
            web(1, -leaf_h/2 + i*seg, seg);
        }
    }
}

// ============================================================
// ピン軸 : Y軸に沿う円柱 (両端 1mm 飛び出す)
// ============================================================
module pin() {
    color("Gold")
        translate([0, -pin_len/2, 0])
            rotate([-90, 0, 0])
                cylinder(h = pin_len, d = pin_d);
}

// ============================================================
// 組み立て (180° 開いた状態)
// ============================================================
left_leaf();
right_leaf();
pin();