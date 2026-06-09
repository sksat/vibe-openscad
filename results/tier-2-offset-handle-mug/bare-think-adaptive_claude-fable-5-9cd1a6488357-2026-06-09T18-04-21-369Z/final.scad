// =============================
// マグカップ(取手は +X 方向のみ)
// =============================
$fn = 96;

// ---- 本体パラメータ ----
outer_d  = 80;   // 外径
inner_d  = 70;   // 内径(肉厚 5mm)
mug_h    = 90;   // 高さ
bottom_t = 6;    // 底面厚み

// ---- 取手パラメータ ----
handle_in_w  = 25;  // 取手内側の幅(X方向の指スペース)
handle_in_h  = 30;  // 取手内側の高さ(Z方向の指スペース)
handle_t     = 8;   // 取手の断面厚み
handle_depth = 8;   // 取手の奥行き(Y方向)
embed        = 5;   // 本体壁への食い込み量(マニフォールド確保)

// D字形状(平らな辺が x=0 側、外側が半円)
module d_shape(w, h, ext = 0) {
    r = h / 2;
    union() {
        // 本体側の直線部(extぶん壁に食い込ませる)
        translate([-ext, -r]) square([w - r + ext, h]);
        // 外側の半円部
        translate([w - r, 0]) circle(r);
    }
}

// 取手(XZ平面上のD字リングをY方向に厚み付け)
module handle() {
    rotate([90, 0, 0])
        linear_extrude(height = handle_depth, center = true)
            difference() {
                // 外側Dシェイプ(壁に食い込む延長付き)
                d_shape(handle_in_w + handle_t,
                        handle_in_h + 2 * handle_t,
                        embed);
                // 内側Dシェイプ(指の入る空間 30 x 25)
                d_shape(handle_in_w, handle_in_h);
            }
}

// ---- 組み立て ----
union() {
    // 本体:円筒から内側をくり抜く(底厚 6mm を残す)
    difference() {
        cylinder(h = mug_h, d = outer_d);
        translate([0, 0, bottom_t])
            cylinder(h = mug_h, d = inner_d);
    }

    // 取手:+X 側面、高さ方向の中央に配置
    translate([outer_d / 2, 0, mug_h / 2])
        handle();
}