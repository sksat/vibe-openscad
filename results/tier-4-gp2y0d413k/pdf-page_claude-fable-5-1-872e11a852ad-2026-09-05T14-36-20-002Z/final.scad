// Sharp GP2Y0D413K0F 距離センサ 外形モデル
// 単位: mm
// 座標系: 本体中心を原点、幅方向 X、高さ方向 Y (+Y 上面)、
//         取付面 (PWB / コネクタ側) を -Z、レンズ面を +Z
$fn = 64;

// ---------- 主要寸法 (データシートより) ----------
W        = 29.45;   // 全幅
H_CASE   = 13.05;   // ケース高さ
D_REAR   = 7.1;     // 後部本体 (PWB 側) の奥行
D_FRONT  = 6.3;     // 前部レンズケースの奥行 (レンズ突出を含む)
D_LENS   = 2.0;     // レンズ突出量
D_TOTAL  = D_REAR + D_FRONT;   // 13.4

H_FRONT  = 8.4;     // 前部レンズケース高さ
H_LENS   = 7.2;     // レンズ部高さ
LENS_CY  = 3.75;    // レンズ中心高さ (ケース下面基準)

X_EMIT   = 4.5;     // 発光側レンズ中心 (左端基準)
X_DET    = 4.5 + 19.7; // 受光側レンズ中心 (左端基準)

BLK_L    = 7.5;     // 前部左ブロック幅
BLK_GAP  = 4.15;    // ブロック間隙間
BLK_R    = 16.3;    // 前部右ブロック幅

H_TOTAL  = 18.9;    // コネクタ下端までの全高
H_BELOW  = H_TOTAL - H_CASE;   // ケース下面より下の突出 5.85

CONN_W   = 10.1;    // コネクタ幅
CONN_D   = 3.3;     // コネクタ奥行
PWB_T    = 1.2;     // PWB 厚さ
PWB_W    = 12.0;    // PWB 露出部の幅 (参考)

// 原点オフセット
x0 = -W/2;                  // 左端
y0 = -H_CASE/2;             // ケース下面
z_rear  = -D_TOTAL/2;       // 後端 (取付面)
z_step  = z_rear + D_REAR;  // 前部ブロック開始
z_front = D_TOTAL/2;        // レンズ先端

module rear_body() {
    // 後部本体 (角を少し面取り)
    translate([x0, y0, z_rear])
        cube([W, H_CASE, D_REAR]);
}

module front_block(x_start, width) {
    translate([x0 + x_start, y0, z_step])
        cube([width, H_FRONT, D_FRONT - D_LENS]);
}

module lens_bump(x_start, width, cx, r) {
    // レンズ突出部 (高さ 7.2) と 円形レンズ
    difference() {
        translate([x0 + x_start + 0.3, y0 + LENS_CY - H_LENS/2, z_step + (D_FRONT - D_LENS)])
            cube([width - 0.6, H_LENS, D_LENS]);
        // レンズ周りの浅い窪み
        translate([x0 + cx, y0 + LENS_CY, z_front - 0.4])
            cylinder(r = r + 0.6, h = 1);
    }
    // レンズ本体
    color([0.35, 0.05, 0.05])
    translate([x0 + cx, y0 + LENS_CY, z_step + (D_FRONT - D_LENS)])
        cylinder(r = r, h = D_LENS - 0.2);
}

module detector_window() {
    // 受光側の矩形窓枠 (前面の浅い段差)
    translate([x0 + 13.0, y0 + 0.4, z_step + (D_FRONT - D_LENS) - 0.01])
        difference() {
            cube([15.6, H_FRONT - 0.8, 0.4]);
            translate([0.6, 0.6, -0.1]) cube([14.4, H_FRONT - 2.0, 0.6]);
        }
}

module pwb() {
    color([0.75, 0.6, 0.35])
    translate([-PWB_W/2, y0 - 4.5, z_rear + CONN_D])
        cube([PWB_W, 4.5 + 2, PWB_T]);
}

module connector() {
    color([0.9, 0.9, 0.9])
    difference() {
        translate([-CONN_W/2, y0 - H_BELOW, z_rear])
            cube([CONN_W, H_BELOW, CONN_D]);
        // 相手コネクタ挿入口 (下面)
        translate([-CONN_W/2 + 1.0, y0 - H_BELOW - 0.01, z_rear + 0.6])
            cube([CONN_W - 2.0, 3.5, CONN_D - 1.2]);
    }
    // 端子 ①②③ (1.5 mm ピッチ)
    color([0.8, 0.8, 0.5])
    for (i = [-1, 0, 1])
        translate([i * 1.5 - 0.25, y0 - H_BELOW + 0.5, z_rear + CONN_D/2 - 0.25])
            cube([0.5, 5.0, 0.5]);
}

module sensor() {
    color([0.15, 0.15, 0.15]) {
        rear_body();
        front_block(0, BLK_L);
        front_block(BLK_L + BLK_GAP, BLK_R);
        detector_window();
    }
    color([0.15, 0.15, 0.15]) {
        lens_bump(0, BLK_L, X_EMIT, 2.5);
        lens_bump(BLK_L + BLK_GAP, BLK_R, X_DET, 2.2);
    }
    pwb();
    connector();
}

sensor();