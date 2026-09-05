$fn = 100;

outer_d = 80;
outer_r = outer_d / 2;
height = 100;
wall = 4;
bottom = 6;

inner_r = outer_r - wall;
inner_height = height - bottom;

handle_r = 12; // 取手のリング半径(取っ手の輪の半径)
handle_tube_r = 4; // 取手の管の太さ
handle_center_height = height / 2;

module cup_body() {
    difference() {
        cylinder(h = height, r = outer_r);
        translate([0, 0, bottom])
            cylinder(h = inner_height + 1, r = inner_r);
    }
}

module handle() {
    // 取手をカップ外周に接するように配置
    translate([outer_r + handle_r - 2, 0, handle_center_height])
        rotate([90, 0, 0])
            torus(handle_r, handle_tube_r);
}

module torus(r, tube_r) {
    rotate_extrude(convexity = 10)
        translate([r, 0, 0])
            circle(r = tube_r);
}

union() {
    cup_body();
    handle();
}