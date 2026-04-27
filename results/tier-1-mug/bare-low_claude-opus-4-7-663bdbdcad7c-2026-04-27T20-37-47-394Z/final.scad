$fn = 100;

outer_d = 80;
height  = 100;
wall    = 4;
bottom  = 6;
handle_r = 12;       // リング取手の中心半径
handle_tube = 6;     // 取手の太さ(チューブ半径)

module mug() {
    difference() {
        cylinder(d = outer_d, h = height);
        translate([0, 0, bottom])
            cylinder(d = outer_d - 2*wall, h = height);
    }
}

module handle() {
    translate([outer_d/2 + handle_r - handle_tube/2, 0, height/2])
        rotate([90, 0, 0])
            rotate_extrude()
                translate([handle_r, 0, 0])
                    circle(r = handle_tube);
}

union() {
    mug();
    handle();
}