// マグカップ パラメータ
outer_d = 80;      // 外径
inner_d = 70;      // 内径
mug_h   = 90;      // 高さ
bottom_t = 6;      // 底厚

// 取手パラメータ
handle_inner_h = 30; // 取手内側の空間 高さ
handle_inner_w = 25; // 取手内側の空間 幅(径方向)
handle_thick   = 8;  // 取手の太さ(円管の直径方向の太さ)
handle_depth   = 12; // 取手のZ軸に垂直な厚み(押し出し方向)

$fn = 96;

module mug_body() {
    difference() {
        cylinder(d = outer_d, h = mug_h);
        translate([0, 0, bottom_t])
            cylinder(d = inner_d, h = mug_h - bottom_t + 1);
    }
}

module handle_2d() {
    // 外側半径と内側半径
    r_outer = handle_inner_w/2 + handle_thick + handle_inner_h/2 - handle_inner_w/2;
    // シンプルに: 外側半円の半径 = 内側高さ/2 + 太さ
    // ここでは内側形状を 高さ handle_inner_h × 幅 handle_inner_w の角丸長方形にする方針ではなく
    // D字形状にするため、以下のように構築する
    
    // 外側 D 形状(半円 + 直線):
    // 半円の半径 = handle_inner_h/2 + handle_thick
    R = handle_inner_h/2 + handle_thick;
    // 取手全体の幅(径方向) = handle_inner_w + handle_thick (本体側は本体に埋め込む)
    
    difference() {
        // 外形:本体接続部(矩形)+ 半円 で D 字
        union() {
            // 本体側の矩形部分(本体外周から外側へ伸びる接続部)
            // x: 0 ~ handle_inner_w
            translate([-1, -R])
                square([handle_inner_w + 1, 2*R]);
            // 外側半円
            translate([handle_inner_w, 0])
                circle(r = R);
        }
        // 内側のくり抜き(指が入る空間)
        union() {
            translate([-1, -handle_inner_h/2])
                square([handle_inner_w - handle_thick + 1 + 0.01, handle_inner_h]);
            translate([handle_inner_w - handle_thick, 0])
                circle(r = handle_inner_h/2);
        }
    }
}

module handle() {
    // +X 方向に取手を配置
    // 本体外周(x = outer_d/2)に接続するため、取手の起点を内側に少し食い込ませる
    overlap = 2;
    translate([outer_d/2 - overlap, 0, mug_h/2 - handle_depth/2])
        rotate([0, 0, 0])
            linear_extrude(height = handle_depth)
                handle_2d();
}

// 本体と取手をunion、内側くり抜きは本体側で完結しているのでそのままunionでOK
union() {
    mug_body();
    handle();
}