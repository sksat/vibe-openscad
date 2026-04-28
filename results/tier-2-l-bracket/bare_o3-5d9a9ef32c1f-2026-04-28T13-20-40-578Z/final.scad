// L-bracket with countersunk holes
$fn = 64;                       // smoothness for cylinders

//---------------------------------
// Geometry parameters
//---------------------------------
thickness = 3;                  // plate thickness
width     = 50;                 // width (X)
length    = 40;                 // depth / height (Y or Z)
edge_off  = 10;                 // distance of holes from edge
hole_d    = 4.5;                // clearance hole diameter (M4)
csk_d     = 8;                  // countersink diameter
csk_depth = 2;                  // countersink depth

//---------------------------------
// Helper modules
//---------------------------------
module csk_hole_z(x, y)
{
    // axis: Z  (horizontal flange)
    translate([x, y, -thickness])
    {
        // countersink
        cylinder(d = csk_d, h = csk_depth, center = false);
        // through hole
        cylinder(d = hole_d, h = thickness + 2, center = false);
    }
}

module csk_hole_y(x, z)
{
    // axis: Y  (vertical flange)
    // countersink
    translate([x, thickness - csk_depth, z])
        rotate([90, 0, 0]) cylinder(d = csk_d, h = csk_depth, center = false);
    // through hole
    translate([x, 0, z])
        rotate([90, 0, 0]) cylinder(d = hole_d, h = thickness + 2, center = false);
}

//---------------------------------
// Bracket assembly
//---------------------------------
difference()
{
    // Plates
    union()
    {
        // Horizontal flange (lies in XY, thickness in -Z)
        translate([-width/2, 0, -thickness])
            cube([width, length, thickness], center = false);

        // Vertical flange (lies in XZ, thickness in +Y)
        translate([-width/2, 0, 0])
            cube([width, thickness, length], center = false);
    }

    // Holes in horizontal flange
    for (x = [-width/2 + edge_off, width/2 - edge_off])
        csk_hole_z(x, length/2);

    // Holes in vertical flange
    for (x = [-width/2 + edge_off, width/2 - edge_off])
        csk_hole_y(x, length - edge_off);
}