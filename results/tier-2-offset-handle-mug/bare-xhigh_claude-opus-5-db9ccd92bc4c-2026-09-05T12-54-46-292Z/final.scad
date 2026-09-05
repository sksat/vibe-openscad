/* ============================================================
   マグカップ(取手は +X 方向のみ / D 字形状)
   ============================================================ */

$fn = 96;

/* ---- 本体パラメータ ---- */
outer_d  = 80;      // 外径
inner_d  = 70;      // 内径(肉厚 5mm)
mug_h    = 90;      // 全高
bottom_t = 6;       // 底の厚み

/* ---- 取手パラメータ ---- */
handle_hole_h = 30; // 取手内側の空間:高さ
handle_hole_w = 25; // 取手内側の空間:幅
handle_t      = 8;  // 取手の太さ(半径方向)
handle_w      = 12; // 取手の幅(Y方向)
handle_z      = mug_h / 2;   // 取手の中心高さ(マグ中央)

eps   = 0.01;
R_out = outer_d / 2;
R_in  = inner_d / 2;

/* ---- 取手の 2D 断面(XZ 平面用) ----
   外側:半円 / 本体側:直線 の D 字形
   左端は本体外周より handle_t だけ内側に食い込ませて確実に接続 */
module handle_2d() {
    r_i = handle_hole_h / 2;                 // 内側半円半径 = 15
    r_o = r_i + handle_t;                    // 外側半円半径 = 23
    x_i = R_out;                             // 内側空間の直線部(本体外周)
    x_o = x_i - handle_t;                    // 外形の直線部(本体内部へ埋没)
    cx  = x_i + handle_hole_w - r_i;         // 半円の中心 X

    difference() {
        // 外形(D 字)
        hull() {
            translate([x_o, -r_o]) square([eps, 2 * r_o]);
            translate([cx, 0]) circle(r = r_o);
        }
        // 内側の空間(D 字・30 x 25)
        hull() {
            translate([x_i, -r_i]) square([eps, 2 * r_i]);
            translate([cx, 0]) circle(r = r_i);
        }
    }
}

/* ---- 取手(+X 側のみ・Y 方向に厚み) ---- */
module handle() {
    translate([0, 0, handle_z])
        rotate([90, 0, 0])
            linear_extrude(height = handle_w, center = true)
                handle_2d();
}

/* ---- マグ本体 + 取手 ---- */
module mug() {
    difference() {
        union() {
            cylinder(h = mug_h, d = outer_d);   // 外形
            handle();                           // 取手(確実に union)
        }
        // 内側の中空(底厚 6mm を残して上面は開口)
        translate([0, 0, bottom_t])
            cylinder(h = mug_h - bottom_t + eps, d = inner_d);
    }
}

mug();