// Mug parameters
outer_d = 80;     // 外径
height  = 100;   // 高さ
wall    = 4;     // 肉厚
bottom  = 6;     // 底面厚み

outer_r = outer_d / 2;
inner_r = outer_r - wall;

// Handle parameters
handle_major_r = 12; // 半径 12mm（リング状取手の大きさ）
handle_tube_r  = wall; // 取手の断面半径（肉厚に合わせる）
handle_center_z = height / 2;

handle_depth = 20; // 取手の側面方向の厚み（見た目調整）

$fn = 100;

module torus(R=12, r=4) {
    rotate_extrude(convexity=10, $fn=200)
        translate([R, 0, 0])
            circle(r=r, $fn=100);
}

module mug() {
    difference() {
        // 外形
        cylinder(h=height, r=outer_r);

        // 内側をくり抜き（底厚 bottom から上）
        translate([0, 0, bottom])
            cylinder(h=height - bottom, r=inner_r);
    }
}

module handle() {
    // 取手（Y軸方向にリング状）
    axis_x = outer_r - (handle_major_r - handle_tube_r);

    handle_torus =
        translate([axis_x, 0, handle_center_z])
        rotate([90, 0, 0])
            torus(handle_major_r, handle_tube_r);

    // 側面に付くようにクリップ（内側には入れすぎない／局所に留める）
    x_clip_min = inner_r;
    x_clip_max = outer_r + handle_major_r + handle_tube_r + 10;
    clip_dx = x_clip_max - x_clip_min;

    clip_cube = translate([x_clip_min, -handle_depth/2, 0])
        cube([clip_dx, handle_depth, height], center=false);

    intersection() {
        handle_torus;
        clip_cube;
    }
}

// Final model
union() {
    mug();
    handle();
}