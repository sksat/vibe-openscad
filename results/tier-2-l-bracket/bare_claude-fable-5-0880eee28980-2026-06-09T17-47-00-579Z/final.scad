// L-bracket with countersunk holes (M4)
$fn = 64;

// ---- parameters ----
width     = 50;   // 幅 (X)
depth     = 40;   // 水平面の奥行き (+Y)
height    = 40;   // 垂直面の高さ (+Z)
t         = 3;    // 板厚

hole_d    = 4.5;  // M4 貫通穴
cs_d      = 8;    // 皿座面径
cs_depth  = 2;    // 皿座面深さ
edge_off  = 10;   // 縁からのオフセット
eps       = 0.1;  // ブーリアン用マージン

// 皿穴モジュール: 外側表面が z=0、+Z 方向に貫通
module csk_hole(thickness) {
    // 貫通穴
    translate([0, 0, -eps])
        cylinder(h = thickness + 2*eps, d = hole_d);
    // 皿座面(円錐)
    cylinder(h = cs_depth, d1 = cs_d, d2 = hole_d);
    // 表面側の食い込みマージン
    translate([0, 0, -eps])
        cylinder(h = eps + 0.01, d = cs_d);
}

difference() {
    // ---- 本体 ----
    union() {
        // 水平フランジ(上面が z=0、+Y 方向に伸びる)
        translate([-width/2, 0, -t])
            cube([width, depth, t]);
        // 垂直フランジ(内面が y=0、+Z 方向に伸びる)
        translate([-width/2, -t, -t])
            cube([width, t, height + t]);
    }

    // ---- 水平面の皿穴(皿座面は下側=外側) ----
    for (x = [-(width/2 - edge_off), (width/2 - edge_off)])
        translate([x, depth/2, -t])
            csk_hole(t);

    // ---- 垂直面の皿穴(皿座面は背面側=外側) ----
    for (x = [-(width/2 - edge_off), (width/2 - edge_off)])
        translate([x, -t, height/2])
            rotate([-90, 0, 0])
                csk_hole(t);
}