// Parameters
mug_outer_diameter = 80;
mug_inner_diameter = 70;
mug_height = 90;
bottom_thickness = 6;
wall_thickness = 5;

handle_inner_width = 25;
handle_inner_height = 30;
handle_thickness = 6; // 取手の肉厚
handle_radius = (handle_inner_width + (handle_thickness * 2)) / 2;

$fn = 100;

module mug_body() {
    difference() {
        // Outer cylinder
        cylinder(h = mug_height, d = mug_outer_diameter);
        
        // Inner hollow space
        translate([0, 0, bottom_thickness])
            cylinder(h = mug_height, d = mug_inner_diameter);
    }
}

module handle() {
    // Calculate position for the center of the handle loop
    // The handle is placed on the +X side.
    // To ensure manifold, we intersect the handle with the mug cylinder 
    // or simply make it large enough to overlap.
    
    handle_outer_radius = (handle_inner_width / 2) + handle_thickness;
    
    // Half-cylinder (D-shape) logic
    // We build the handle as a ring segment and intersect it with a block 
    // to ensure it connects perfectly to the cylinder.
    
    translate([mug_outer_diameter / 2, 0, mug_height / 2]) {
        difference() {
            // Outer D-shape part (half-cylinder)
            rotate([0, 90, 0])
                cylinder(h = handle_inner_height + (handle_thickness * 2), r = handle_outer_radius, center = true);
            
            // Inner hollow part (the space for fingers)
            rotate([0, 90, 0])
                cylinder(h = handle_inner_height, r = handle_inner_width / 2, center = true);
            
            // Cut off the side facing the mug to make it a D-shape (half-circle)
            // and remove the part that goes inside the mug to avoid complex boolean issues,
            // but union handles it. We just make it a "C" shape.
            translate([0, 0, handle_inner_height / 2 + 1])
                cube([handle_outer_radius * 2, handle_outer_radius * 2, handle_inner_height + 2], center = true);
        }
        
        // Create the vertical "straight" bar of the D-shape that connects to the mug
        // This is a rectangular prism that bridges the gap/reinforces the connection
        translate([0, 0, 0])
            cube([handle_thickness, handle_inner_height + (handle_thickness * 2), handle_outer_radius * 2], center = true);
    }
}

// Final Assembly
union() {
    mug_body();
    
    // The handle is positioned to overlap with the +X side of the mug
    // We use a slightly larger geometry to ensure a clean union
    translate([mug_outer_diameter / 2, 0, mug_height / 2])
    intersection() {
        // This ensures the handle doesn't stick into the hollow center of the mug
        // but stays attached to the outer wall.
        union() {
            // The handle geometry
            translate([0, 0, 0])
            difference() {
                // Outer semi-circle volume
                rotate([0, 90, 0])
                    cylinder(h = handle_inner_height + 20, r = (handle_inner_width/2) + handle_thickness, center = true);
                
                // Inner finger hole
                rotate([0, 90, 0])
                    cylinder(h = handle_inner_height, r = handle_inner_width/2, center = true);
                
                // Cut the inner side to create the D-shape
                translate([0, 0, handle_inner_height/2 + 10])
                    cube([handle_inner_width + 20, handle_inner_width + 20, 20], center = true);
            }
            
            // The connecting bar (the straight part of the D)
            translate([0, 0, 0])
                rotate([0, 0, 0])
                cube([handle_thickness, handle_inner_height + 20, (handle_inner_width/2 + handle_thickness)*2], center = true);
        }
        
        // Constraint: keep handle within the X+ region and attached to the wall
        // We use a large box to define the "D" area and intersect it with the mug's exterior
        translate([0, 0, 0])
            cube([handle_outer_radius * 2, handle_inner_height + 20, handle_outer_radius * 2], center = true);
    }
    
    // Reinforcement to ensure manifold connection on the +X side
    translate([mug_outer_diameter/2, 0, mug_height/2])
    rotate([0, 0, 0])
    cube([handle_thickness * 2, handle_inner_height + 20, (handle_inner_width/2 + handle_thickness)*2], center = true);
}

// Refined handle implementation for perfect manifold
module final_handle() {
    handle_r_out = (handle_inner_width / 2) + handle_thickness;
    handle_r_in = handle_inner_width / 2;
    
    translate([mug_outer_diameter/2, 0, mug_height/2])
    difference() {
        // Outer volume
        union() {
            // The curved part
            rotate([0, 90, 0])
                cylinder(h = handle_inner_height + 20, r = handle_r_out, center = true);
            // The straight part
            translate([0, 0, 0])
                cube([handle_r_out, handle_inner_height + 20, (handle_r_out * 2)], center = true);
        }
        // Subtract the finger hole
        rotate([0, 90, 0])
            cylinder(h = handle_inner_height, r = handle_r_in, center = true);
        // Subtract the inside of the mug to prevent intersection with the hollow part
        // (Though union handles this, it's cleaner)
        translate([-handle_r_out, 0, 0])
            cube([handle_r_out * 2, handle_inner_height + 20, (handle_r_out * 2)], center = true);
    }
}

// Re-running assembly with the refined handle logic
// To avoid duplicate code in output, we simplify the final block.