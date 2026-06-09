// =====================================================
// L字金具 (L-bracket) with M4 countersunk holes
// 内側コーナーが原点
// 水平フランジ: +Y 方向 / 垂直フランジ: +Z 方向
// =====================================================

$fn = 64;

// ---- パラメータ ----
width       = 50;    // フランジ幅 (X)
h_depth     = 40;    // 水平フランジ奥行き (Y)
v_height    = 40;    // 垂直フランジ高さ (Z)
t           = 3;     // 板厚
hole_d      = 4.5;   // M4 貫通穴径
cs_d        = 8;     // 皿座面径
cs_depth    = 2;     // 皿座面深さ
edge_offset = 10;    // 縁からの穴位置
eps         = 0.1;   // ブーリアン用マージン

hole_x = width / 2 - edge_offset;   // 穴の X 位置 (±15mm)

// ---- 皿穴(ローカル +Z 軸方向、z=0 が外側の面)----
module csk_hole() {
    // 貫通穴 Φ4.5
    translate([0, 0, -eps])
        cylinder(h = t + 2 * eps, d = hole_d);
    // 皿座面(円錐)Φ8 → Φ4.5、深さ 2mm
    translate([0, 0, -eps])
        cylinder(h  = cs_depth + eps,
                 d1 = cs_d + eps * (cs_d - hole_d) / cs_depth,
                 d2 = hole_d);
}

// ---- 本体 ----
module bracket_body() {
    union() {
        // 水平フランジ(上面 z=0、+Y 方向)
        translate([-width / 2, 0, -t])
            cube([width, h_depth, t]);
        // 垂直フランジ(内面 y=0、+Z 方向、コーナー部を含む)
        translate([-width / 2, -t, -t])
            cube([width, t, v_height + t]);
    }
}

// ---- 組み立て ----
difference() {
    bracket_body();

    // 水平フランジの皿穴(皿座面は下側=外側)
    for (sx = [-1, 1])
        translate([sx * hole_x, h_depth / 2, -t])
            csk_hole();

    // 垂直フランジの皿穴(皿座面は -Y 側=外側)
    for (sx = [-1, 1])
        translate([sx * hole_x, -t, v_height / 2])
            rotate([-90, 0, 0])
                csk_hole();
}