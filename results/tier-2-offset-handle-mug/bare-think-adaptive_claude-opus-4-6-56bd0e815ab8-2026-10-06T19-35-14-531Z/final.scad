$fn = 64;

module mug_body() {
    difference() {
        cylinder(r = 40, h = 90);
        translate([0, 0, 6])
            cylinder(r = 35, h = 90);
    }
}

module handle() {
    tube_r = 5;       // handle tube radius
    a      = 30;      // ellipse semi-axis in X (outward from mug surface)
    b      = 20;      // ellipse semi-axis in Z (vertical)
    cx     = 40;      // ellipse center X  (on mug outer wall)
    cz     = 45;      // ellipse center Z  (mug mid-height)

    steps = 48;
    for (i = [0 : steps - 1]) {
        a1 = -90 + i       * 180 / steps;
        a2 = -90 + (i + 1) * 180 / steps;
        hull() {
            translate([cx + a * cos(a1), 0, cz + b * sin(a1)])
                sphere(r = tube_r);
            translate([cx + a * cos(a2), 0, cz + b * sin(a2)])
                sphere(r = tube_r);
        }
    }
}

union() {
    mug_body();
    handle();
}