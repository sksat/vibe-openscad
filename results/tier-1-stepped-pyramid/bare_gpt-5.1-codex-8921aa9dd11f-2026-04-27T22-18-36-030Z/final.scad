module layer(size) {
    cube([size, size, 10], center=true);
}

layer(60);
translate([0, 0, 10]) layer(40);
translate([0, 0, 20]) layer(20);