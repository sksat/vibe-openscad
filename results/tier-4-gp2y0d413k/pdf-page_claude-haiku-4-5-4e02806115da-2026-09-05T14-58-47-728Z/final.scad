// Sharp GP2Y0D413K0F Distance Sensor - OpenSCAD Model
// Unit: mm
// Origin: Center of the device, Z-axis points toward the front (opposite to mounting face)

// Main body case
module main_case() {
    // Main rectangular body
    cube([29.45, 13.65, 10.1], center=true);
}

// Light emitter (IR LED) - left side
module light_emitter() {
    translate([-9.7/2 - 1.5, 0, 5.05]) {
        cylinder(r=2.5, h=1.5, center=true, $fn=32);
    }
}

// Light detector - right side
module light_detector() {
    translate([9.7/2 + 1.5, 0, 5.05]) {
        // Main sensor lens
        cylinder(r=2.0, h=1.2, center=true, $fn=32);
    }
}

// Lens case (protruding part)
module lens_case() {
    translate([9.7/2 + 1.5, 0, 5.05]) {
        cylinder(r=2.2, h=2.3, center=true, $fn=32);
    }
}

// Connector - at the bottom
module connector() {
    // Connector body
    translate([0, 0, -5.05 - 1.2/2]) {
        cube([10.1, 7.5, 1.2], center=true);
    }
    // Connector pins area
    translate([0, 0, -5.05 - 1.2 - 0.8]) {
        cube([6.0, 4.15, 1.6], center=true);
    }
}

// PWB (Printed Wiring Board) mounting pads
module pwb() {
    translate([0, 0, -5.05 - 0.5]) {
        cube([29.45, 13.65, 0.3], center=true);
    }
}

// Terminal pins (3 pins)
module terminal_pins() {
    pin_positions = [
        [-2.5, -3.0],
        [0, -3.0],
        [2.5, -3.0]
    ];
    
    for (pos = pin_positions) {
        translate([pos[0], pos[1], -5.05 - 0.5 - 1.5]) {
            cube([0.4, 0.4, 3.0], center=true);
        }
    }
}

// Mounting bracket/tab (left side)
module mounting_tab() {
    translate([-14.725/2 - 2, 0, -5.05 + 0.75]) {
        cube([3.75, 13.65, 1.5], center=true);
    }
}

// Mounting bracket/tab (right side)
module mounting_tab_right() {
    translate([14.725/2 + 2, 0, -5.05 + 0.75]) {
        cube([3.75, 13.65, 1.5], center=true);
    }
}

// Complete assembly
module gp2y0d413k0f() {
    // Main body
    color([0.2, 0.2, 0.2])
    main_case();
    
    // Light emitter
    color([1, 0, 0])
    light_emitter();
    
    // Light detector lens
    color([0.8, 0.8, 1])
    light_detector();
    
    // Lens case
    color([0.3, 0.3, 0.3])
    lens_case();
    
    // Connector
    color([0.4, 0.4, 0.4])
    connector();
    
    // PWB
    color([0.6, 0.4, 0.2])
    pwb();
    
    // Terminal pins
    color([0.8, 0.8, 0.8])
    terminal_pins();
    
    // Mounting tabs
    color([0.3, 0.3, 0.3])
    mounting_tab();
    mounting_tab_right();
}

// Render the sensor
gp2y0d413k0f();

// Optional: Add coordinate system for reference
module coordinate_system() {
    // X axis (red)
    color([1, 0, 0]) translate([0, 0, 0]) cylinder(r=0.2, h=10, center=true, $fn=16);
    // Y axis (green)
    color([0, 1, 0]) rotate([90, 0, 0]) cylinder(r=0.2, h=10, center=true, $fn=16);
    // Z axis (blue)
    color([0, 0, 1]) rotate([0, 90, 0]) cylinder(r=0.2, h=10, center=true, $fn=16);
}

// Uncomment to show coordinate system
// coordinate_system();