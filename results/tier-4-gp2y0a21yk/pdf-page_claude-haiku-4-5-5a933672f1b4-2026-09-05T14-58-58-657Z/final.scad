// Sharp GP2Y0A21YK0F Distance Measuring Sensor
// Unit: mm
// Origin at center of device, -Z direction is mounting side (PWB/Connector)

module gp2y0a21yk0f() {
    // Main body dimensions
    body_length = 29.5;  // Total length
    body_width = 13;     // Total width
    body_height = 13.5;  // Total height
    
    // Position so mounting side is at -Z
    translate([0, 0, body_height/2]) {
        
        // Main case body
        cube([body_width, body_length, body_height], center=true);
        
        // Light emitter (left side)
        translate([-6.5, -7.5, 4]) {
            cylinder(h=3, r=2.8, center=true, $fn=32);
        }
        
        // Light detector (right side, center)
        translate([6.5, -0.5, 4]) {
            cylinder(h=3, r=1.9, center=true, $fn=32);
        }
        
        // Lens case (center front)
        translate([0, -7.5, 4.5]) {
            cylinder(h=4, r=3.8, center=true, $fn=32);
        }
        
        // Connector back (mounting side)
        translate([0, 10.5, -5.5]) {
            // Main connector body
            cube([16.3, 7.5, 3], center=true);
            
            // Connector pins area
            translate([0, -2, 0]) {
                cube([4.15, 2, 2.5], center=true);
            }
        }
        
        // PWB (circuit board)
        translate([0, 8, -4.5]) {
            cube([14.75, 18.1, 1.2], center=true);
        }
        
        // Mounting tabs/stamps
        translate([-8, 3.5, -1]) {
            cube([2, 3, 2], center=true);
        }
        translate([8, 3.5, -1]) {
            cube([2, 3, 2], center=true);
        }
        
        // Lens acrylic (front optical window)
        translate([0, -11.5, 5.5]) {
            sphere(r=3.2, $fn=32);
        }
    }
}

// Render the sensor
gp2y0a21yk0f();

// Optional: Add reference coordinate system
%translate([0, 0, 0]) {
    cylinder(h=20, r=0.5, center=true, $fn=16); // Z axis
}