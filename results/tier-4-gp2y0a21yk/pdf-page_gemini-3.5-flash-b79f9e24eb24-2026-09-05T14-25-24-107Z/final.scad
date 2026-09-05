// Sharp GP2Y0A21YK0F Distance Measuring Sensor 3D Model
// Units: mm
// Origin: XY Center of the main body, Z=0 at the mounting flange surface (PWB side faces -Z)

$fn = 50;

// Color Definitions
color_body = "#2C2C2C";      // Carbonic ABS (Dark Gray)
color_lens = "#200305";      // Acrylic resin (Visible light cut-off - Dark Crimson Black)
color_pwb  = "#8B5A2B";      // Paper phenol PWB (Brown)
color_conn = "#E5E0D8";      // Connector (Off-White)

module gp2y0a21yk0f() {
    difference() {
        union() {
            // --- Main Body (Plastic Case) ---
            color(color_body) {
                // Central housing block
                translate([-11, -6.5, 0]) 
                    cube([22, 13, 7.2]);
                
                // Left flange base connection
                translate([-14.75, -3.75, 0]) 
                    cube([3.75, 7.5, 1.5]);
                // Left flange circular end
                translate([-14.75, 0, 0]) 
                    cylinder(h=1.5, r=3.75);
                // Left slope rib
                hull() {
                    translate([-14.75, -3.75, 0]) cube([0.1, 7.5, 1.5]);
                    translate([-11, -3.75, 0]) cube([0.1, 7.5, 7.2]);
                }

                // Right flange base connection
                translate([11, -3.75, 0]) 
                    cube([3.75, 7.5, 1.5]);
                // Right flange circular end
                translate([14.75, 0, 0]) 
                    cylinder(h=1.5, r=3.75);
                // Right slope rib
                hull() {
                    translate([14.75, -3.75, 0]) cube([0.1, 7.5, 1.5]);
                    translate([11, -3.75, 0]) cube([0.1, 7.5, 7.2]);
                }
            }
            
            // --- Lens Cases (Dark Red Acrylic) ---
            color(color_lens) {
                // Light Emitter (Left - Circular)
                translate([-6.5, 0, 7.2]) {
                    cylinder(h=6.3, r=4.2);
                    // Dome lens surface
                    translate([0, 0, 6.3]) 
                        scale([1, 1, 0.3]) sphere(r=4.2);
                }
                
                // Light Detector (Right - Oval/Long)
                translate([0, 0, 7.2]) {
                    hull() {
                        translate([4.2, 0, 0]) cylinder(h=6.3, r=4.2);
                        translate([13.5, 0, 0]) cylinder(h=6.3, r=4.2);
                    }
                    // Dome lens surface (Oval)
                    hull() {
                        translate([4.2, 0, 6.3]) scale([1, 1, 0.3]) sphere(r=4.2);
                        translate([13.5, 0, 6.3]) scale([1, 1, 0.3]) sphere(r=4.2);
                    }
                }
            }
            
            // --- PWB (Printed Wiring Board) ---
            color(color_pwb) {
                translate([-11, -6.5, -3.3]) 
                    cube([22, 13, 1.2]);
            }
            
            // --- Connector ---
            color(color_conn) {
                // Connector housing body
                translate([-6.85, -8.5, -8.3]) 
                    cube([10.1, 7.0, 5.0]);
            }
        }
        
        // --- Screw Holes (Subtraction) ---
        color(color_body) {
            // Left Screw Hole (phi 3.2)
            translate([-14.75, 0, -1]) 
                cylinder(h=4, r=1.6);
            
            // Right Screw Hole (phi 3.2)
            translate([14.75, 0, -1]) 
                cylinder(h=4, r=1.6);
        }
    }
}

// Render the model
gp2y0a21yk0f();