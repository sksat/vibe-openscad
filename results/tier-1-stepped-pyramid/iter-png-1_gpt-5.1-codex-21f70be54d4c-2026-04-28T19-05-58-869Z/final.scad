module layer(size, z_center) {
    translate([0, 0, z_center])
        cube([size, size, 10], center=true);
}

layer(60, 5);
layer(40, 15);
layer(20, 25);