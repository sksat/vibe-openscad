$fn = 60;

pin_d   = 4;
pin_len = 32;
clr     = 0.3;
kn_od   = 8;
leaf_w  = 25;   // X方向
leaf_l  = 30;   // Y方向(軸方向)
t       = 2;    // 板厚

hole_pitch = 8;
hole_x     = 18;   // 軸からの距離
hole_ys    = [7, 15, 23];

module screw_hole(x, y) {
    translate([x, y, -t/2 - 0.5])
        cylinder(d = 3.2, h = t + 1);
    // 皿穴(表面 z=+1 側)
    translate([x, y, t/2 - 1])
        cylinder(d1 = 3.2, d2 = 6, h = 1.01);
}

module knuckle(y0) {
    difference() {
        translate([0, y0, 0])
            rotate([-90, 0, 0])
                cylinder(d = kn_od, h = 6);
        translate([0, y0 - 0.5, 0])
            rotate([-90, 0, 0])
                cylinder(d = pin_d + clr, h = 7);
    }
}

module leaf(side, kn_ys) {  // side = -1(左) / +1(右)
    union() {
        difference() {
            // 板本体(z = -1..+1)
            translate([side > 0 ? 0 : -leaf_w, 0, -t/2])
                cube([leaf_w, leaf_l, t]);
            // ねじ穴
            for (y = hole_ys)
                screw_hole(side * hole_x, y);
            // knuckle 部の干渉を避ける切り欠き
            translate([-kn_od/2 * (side > 0 ? 1 : 1) * 1, -1, -t/2 - 0.5])
                translate([side > 0 ? -kn_od/2 + kn_od/2 : 0, 0, 0])
                    cube(0.001); // dummy
        }
        for (y0 = kn_ys)
            knuckle(y0);
    }
}

// 左板: knuckle 3個(両端 + 中央)
color("LightGray") leaf(-1, [0, 12, 24]);

// 右板: knuckle 2個(中間)
color("Silver") leaf(1, [6, 18]);

// ピン軸
color("Gold")
    translate([0, -1, 0])
        rotate([-90, 0, 0])
            cylinder(d = pin_d, h = pin_len);