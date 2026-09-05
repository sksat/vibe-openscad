$fn = 64;

// ---------- 基本寸法 ----------
leaf_length    = 30;
leaf_width     = 25;
leaf_thickness = 2;

pin_diameter   = 4;
pin_length     = 32;

knuckle_od     = 8;
knuckle_id     = 4.6;
knuckle_length = 6;

screw_d        = 3.2;
countersink_d  = 6;
countersink_h  = 1;

hinge_radius   = knuckle_od / 2;
pin_overhang   = 1;

// Y方向の円柱
module cylinder_y(d, h) {
    rotate([-90, 0, 0])
        cylinder(d = d, h = h);
}

// M3用皿穴（上面 Z=+1 側から加工）
module countersunk_hole(x, y) {
    // 貫通穴
    translate([x, y, -leaf_thickness])
        cylinder(d = screw_d, h = leaf_thickness * 3);

    // 皿穴テーパ
    translate([x, y, leaf_thickness / 2 - countersink_h])
        cylinder(
            h  = countersink_h,
            d1 = screw_d,
            d2 = countersink_d
        );
}

// 左板用 knuckle
module left_knuckle(y0) {
    union() {
        // 筒部
        translate([0, y0, 0])
            cylinder_y(knuckle_od, knuckle_length);

        // 左板との接続部
        translate([-hinge_radius - 0.02, y0, -leaf_thickness / 2])
            cube([1.37, knuckle_length, leaf_thickness]);
    }
}

// 右板用 knuckle
module right_knuckle(y0) {
    union() {
        // 筒部
        translate([0, y0, 0])
            cylinder_y(knuckle_od, knuckle_length);

        // 右板との接続部
        translate([hinge_radius - 1.35, y0, -leaf_thickness / 2])
            cube([1.37, knuckle_length, leaf_thickness]);
    }
}

// 左板: knuckle は Y=0,12,24
module left_leaf() {
    difference() {
        union() {
            // 30 x 25 x 2 mm の左板
            translate([
                -hinge_radius - leaf_width,
                0,
                -leaf_thickness / 2
            ])
                cube([leaf_width, leaf_length, leaf_thickness]);

            // 左側 knuckle 3個
            for (y0 = [0, 12, 24])
                left_knuckle(y0);
        }

        // 左側 knuckle の軸穴
        for (y0 = [0, 12, 24])
            translate([0, y0 - 0.01, 0])
                cylinder_y(knuckle_id, knuckle_length + 0.02);

        // 左板のM3皿穴 3個
        for (y = [7, 15, 23])
            countersunk_hole(-hinge_radius - leaf_width + 6, y);
    }
}

// 右板: knuckle は Y=6,18
module right_leaf() {
    difference() {
        union() {
            // 30 x 25 x 2 mm の右板
            translate([
                hinge_radius,
                0,
                -leaf_thickness / 2
            ])
                cube([leaf_width, leaf_length, leaf_thickness]);

            // 右側 knuckle 2個
            for (y0 = [6, 18])
                right_knuckle(y0);
        }

        // 右側 knuckle の軸穴
        for (y0 = [6, 18])
            translate([0, y0 - 0.01, 0])
                cylinder_y(knuckle_id, knuckle_length + 0.02);

        // 右板のM3皿穴 3個
        for (y = [7, 15, 23])
            countersunk_hole(hinge_radius + leaf_width - 6, y);
    }
}

// ピン軸: Y=-1 ～ 31
module hinge_pin() {
    translate([0, -pin_overhang, 0])
        cylinder_y(pin_diameter, pin_length);
}

// ---------- 完成状態: 180度開 ----------
color([0.38, 0.42, 0.46])
    left_leaf();

color([0.42, 0.46, 0.50])
    right_leaf();

color([0.18, 0.20, 0.22])
    hinge_pin();