// Bottom base
cube([60, 60, 10]);

// Middle layer
translate([10, 10, 10]) {
    cube([40, 40, 10]);
}

// Top layer
translate([20, 20, 20]) {
    cube([20, 20, 10]);
}