// Sharp GP2Y0A21YK0F Distance Measuring Sensor
// Units: mm
// Coordinate system: Center of the sensor body at [0, 0, 0]

$fn = 50;

module gp2y0a21yk0f() {
    // Main Body (Black plastic case)
    // Width (X): 37 mm
    // Depth (Y): 8.4 mm (lens case adds 6.3mm -> total Y is roughly 14.7, let's use outline dimensions)
    // Height (Z): 13.5 mm (excluding mounting tabs)
    
    // Overall dimensions from datasheet:
    // Width = 37 mm (mounting flanges span wider, total width 37, mounting holes at centers of R3.75 ends)
    // Let's build it piece by piece centering the main rectangular body at origin.
    
    // Main sensor housing
    color("dimgray")
    translate([0, 0, 0])
        cube([29.5, 8.4, 13.5], center = true);

    // Lens case (front protrusion)
    color("black")
    translate([0, 8.4/2 + 6.3/2, 0])
        cube([29.5, 6.3, 13.5], center = true);

    // Lenses (Light emitter (left) and Light detector (right))
    // Distance between lens centers = 20.0 mm
    color("darkred") {
        translate([-10, 8.4/2 + 6.3 + 0.1, 0])
            rotate([90, 0, 0])
                cylinder(r = 3.2, h = 1, center = true);
        translate([10, 8.4/2 + 6.3 + 0.1, 0])
            rotate([90, 0, 0])
                cylinder(r = 3.2, h = 1, center = true);
    }

    // Mounting Flanges (Left and Right with 3.2mm holes)
    // Total width = 37 mm between outer radii (R3.75 ends)
    // The main body is 29.5 wide. Flanges extend on both sides.
    color("dimgray") {
        // Left flange
        translate([-37/2 + 3.75, 0, -13.5/2 + 7.2/2]) // Approximate vertical position
            difference() {
                union() {
                    cube([37 - 29.5, 8.4, 7.2], center = true);
                    // R3.75 ends
                    translate([-(37/2 - 3.75) + (-29.5/2), 0, 0])
                        cylinder(r = 3.75, h = 7.2, center = true);
                }
                // Mounting hole d=3.2
                translate([-(37/2 - 3.75) + (-29.5/2), 0, 0])
                    cylinder(r = 3.2/2, h = 10, center = true);
            }

        // Right flange
        translate([37/2 - 3.75, 0, -13.5/2 + 7.2/2])
            difference() {
                union() {
                    cube([37 - 29.5, 8.4, 7.2], center = true);
                    translate([(37/2 - 3.75) - (29.5/2), 0, 0])
                        cylinder(r = 3.75, h = 7.2, center = true);
                }
                // Mounting hole d=3.2
                translate([(37/2 - 3.75) - (29.5/2), 0, 0])
                    cylinder(r = 3.2/2, h = 10, center = true);
            }
    }

    // Connector (Backside)
    // Width = 10.1 mm, protrudes backward
    color("white")
    translate([0, -8.4/2 - 3.3/2, 0])
        cube([10.1, 3.3, 10], center = true);

    // Connector Pins (3 pins)
    color("gold")
    for (i = [-1, 0, 1]) {
        translate([i * 2.0, -8.4/2 - 3.3 - 1, 0])
            cube([0.6, 2, 6], center = true);
    }
}

// Render the sensor
gp2y0a21yk0f();