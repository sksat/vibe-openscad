// =========================================
// OpenSCAD Mug Design (Specified Orientation)
// =========================================

// --- Global Dimensions ---
MUG_OD = 80;      // Outer Diameter of Mug (mm)
MUG_RD = MUG_OD / 2; // Outer Radius of Mug (mm)
MUG_ID = 70;      // Inner Diameter of Mug (mm)
MUG_RD_INNER = MUG_ID / 2; // Inner Radius of Mug (mm)

WALL_THICKNESS = MUG_RD - MUG_RD_INNER; // 5mm

TOTAL_HEIGHT = 90;   // Total height of the mug (mm)
BASE_THICKNESS = 6;  // Thickness of the base (mm)
WALL_HEIGHT = TOTAL_HEIGHT - BASE_THICKNESS; // Height of the cylindrical walls (84mm)


// --- Handle Dimensions ---
HANDLE_INNER_H = 30;     // Internal height of handle (Z)
HANDLE_INNER_W = 25;     // Internal width/depth of handle (Y)

// Estimate overall outer dimensions for D-shape based on internal size.
// We need a minimum structural thickness around the inner space.
HANDLE_OUTER_RADIUS = 37; // Outer radius estimate, must connect to R=40 mug wall
HANDLE_ATTACHMENT_THICKNESS = 15; // Thickness of the handle section connecting into the side wall


// =========================================
// 1. MUG BODY GENERATION
// =========================================

module generate_mug() {
    difference() {
        // A. Outer Shell (Solid Block)
        union() {
            // Base Plate: Solid disk at the bottom
            cylinder(h = BASE_THICKNESS, r = MUG_RD); 
            
            // Side Walls: Cylinder from base up to TOTAL_HEIGHT
            translate([0, 0, BASE_THICKNESS]) {
                difference() {
                    cylinder(h = WALL_HEIGHT, r = MUG_RD); // Outer cylinder segment
                    cylinder(h = WALL_HEIGHT + 1, r = MUG_RD_INNER); // Void cutout
                }
            }
        }

        // B. Internal Void Cutout (The liquid space)
        translate([0, 0, -1]) { // Offset slightly to ensure clean cut through the base/walls
             cylinder(h = TOTAL_HEIGHT + 2, r = MUG_RD_INNER);
        }
    }
}

// =========================================
// 2. HANDLE GENERATION AND PLACEMENT
// =========================================

module generate_handle() {
    // The handle will be placed on the side wall (e.g., +X direction).
    // We define a D-shape cross section that is extruded along the X-axis (depth of attachment).
    
    // Cross-section definition in YZ plane: 
    difference() {
        // Outer Shape (Semi-Circle based)
        circle(r = HANDLE_OUTER_RADIUS); // Defines a full circle for simplicity, we will use half later.

        translate([0, 0, 0]) {
            linear_extrude(height = HANDLE_ATTACHMENT_THICKNESS + 1) // Extrudes the D-shape along X axis (depth into wall)
            difference() {
                // Outer semi-circle shape (relative to the cup's surface at R=40)
                translate([HANDLE_OUTER_RADIUS, 0, 0]) circle(r = HANDLE_OUTER_RADIUS);

                // Inner Rectangular Cutout: This creates the D-shape.
                // We define the cutout centered relative to its own local origin.
                translate([- (HANDLE_INNER_W / 2), - (HANDLE_INNER_H / 2), 0])
                    cube([HANDLE_INNER_W + 1, HANDLE_INNER_H + 1, HANDLE_ATTACHMENT_THICKNESS]); 
            }
        }
    }
}

module attach_handle() {
    // Position the handle on the side corresponding to the positive X-axis.
    // We place its center at (40mm, 0, 90/2).
    translate([MUG_RD, 0, TOTAL_HEIGHT / 2]) {
        rotate([90, 0, 0]) // Rotate so that the attached flat face is perpendicular to X axis
        scale([1, -1, 1])   // Correcting orientation after rotation if needed (though usually unnecessary for translation)

        // We redefine the handle module placement logic here for correct mounting.
        // The handle's cross-section needs to be defined such that its straight side is flush with R=40.

        difference() {
             // Outer Shape: Semi-circle centered at (X_start, Y_start)
            translate([0, 0, 0]) 
                rotate([0, 90, 0]) // Rotate so the straight side is facing 'out' from X=40
                    cylinder(h = HANDLE_ATTACHMENT_THICKNESS + 1, r = HANDLE_OUTER_RADIUS);

            // Inner Cutout (The void space for fingers)
            translate([0, -HANDLE_INNER_W / 2, -(HANDLE_INNER_H / 2)]) // Centering the cutout relative to the handle's local frame
                cube([HANDLE_ATTACHMENT_THICKNESS + 1, HANDLE_INNER_W + 1, HANDLE_INNER_H + 1]);

            // Cutout of material that would intersect the mug body (Ensuring manifold connection)
             translate([0, -WALL_THICKNESS/2, -(HANDLE_INNER_H / 2)]) 
                cube([HANDLE_ATTACHMENT_THICKNESS + 1, WALL_THICKNESS * 2 , HANDLE_INNER_H + 1]); 

        }
    }
}


// =========================================
// 3. FINAL ASSEMBLY (UNION)
// =========================================

union() {
    generate_mug();
    attach_handle();
}