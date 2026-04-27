// Parameters
h = 10;

// Single centered layer helper
module layer(size, z) {
    translate([-size/2, -size/2, z]) cube([size, size, h]);
}

// Layers
layer(60, 0);
layer(40, h);
layer(20, 2*h);