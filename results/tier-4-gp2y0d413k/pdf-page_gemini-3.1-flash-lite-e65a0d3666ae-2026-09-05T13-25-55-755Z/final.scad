// Sharp GP2Y0D413K0F Distance Sensor
// Units: mm
// Origin: Center of the main body

$fn = 50;

module gp2y0d413k0f() {
    // Main Body Dimensions
    width = 29.45;
    height = 13.5;
    depth = 13.05; // Lens case section depth
    
    // Lens positions from center (horizontal)
    // Left: 4.5 from left edge (14.725 - 4.5 = 10.225 from center)
    // Right: 19.7 from left edge (19.7 - 14.725 = 4.975 from center)
    
    union() {
        // Main rectangular housing
        translate([0, 0, -height/2 + (height - 9.0)/2]) // Adjusted for overall shape
        cube([width, 9.0, height], center=true);
        
        // Lens section (protruding)
        translate([0, (depth - 9.0)/2, 0])
        cube([width, depth, 8.4], center=true);
        
        // Lenses
        lens_d = 7.2;
        translate([-10.225, (depth - 9.0)/2, 0])
            cylinder(d=lens_d, h=depth+2, center=true);
        translate([4.975, (depth - 9.0)/2, 0])
            cylinder(d=lens_d, h=depth+2, center=true);
            
        // Connector / PWB section
        // 10.1 wide, 1.2 thick PWB
        translate([0, -9.0/2 - 1.2/2, -height/2 + 3])
        cube([10.1, 1.2, 5], center=true);
    }
}

// Render the model
color("gray") gp2y0d413k0f();

// Reference grid for visual confirmation
%cube([29.45, 18.9, 13.5], center=true);