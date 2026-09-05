$fn = 60;

// Dimensions
leaf_width = 25;
leaf_height = 30;
leaf_thickness = 2;

pin_diameter = 4;
pin_length = 32;

knuckle_od = 8;
knuckle_id = 4.6; // pin_diameter + 0.3mm clearance
knuckle_count = 5;
knuckle_height = leaf_height / knuckle_count; // 6mm

hole_x_offset = 15;
hole_pitch = 8;
hole_y_center = leaf_height / 2; // 15mm

// M3 Countersink Hole Module
module m3_countersink() {
    // Taper: top dia 6mm (r=3), depth 1mm, bottom dia 3.2mm (r=1.6)
    translate([0, 0, -1 + 0.01])
        cylinder(r1=1.6, r2=3.0, h=1, center=false);
    // Through hole: dia 3.2mm (r=1.6)
    translate([0, 0, -leaf_thickness - 1])
        cylinder(r=1.6, h=leaf_thickness + 2, center=false);
}

// Left Leaf Component (Knuckles 0, 2, 4)
module left_leaf() {
    difference() {
        union() {
            // Leaf plate (x < 0)
            translate([-leaf_width, 0, -leaf_thickness])
                cube([leaf_width, leaf_height, leaf_thickness]);
            
            // Knuckles (Outer 2 + Center 1)
            for (i = [0, 2, 4]) {
                translate([0, i * knuckle_height, 0])
                    rotate([-90, 0, 0])
                        cylinder(r=knuckle_od/2, h=knuckle_height);
            }
        }
        
        // Pin hole passing through knuckles
        translate([0, -1, 0])
            rotate([-90, 0, 0])
                cylinder(r=knuckle_id/2, h=leaf_height + 2);
        
        // 3 Countersink holes
        for (i = [-1, 0, 1]) {
            translate([-hole_x_offset, hole_y_center + i * hole_pitch, 0])
                m3_countersink();
        }
    }
}

// Right Leaf Component (Knuckles 1, 3)
module right_leaf() {
    difference() {
        union() {
            // Leaf plate (x > 0)
            translate([0, 0, -leaf_thickness])
                cube([leaf_width, leaf_height, leaf_thickness]);
            
            // Knuckles (Middle 2)
            for (i = [1, 3]) {
                translate([0, i * knuckle_height, 0])
                    rotate([-90, 0, 0])
                        cylinder(r=knuckle_od/2, h=knuckle_height);
            }
        }
        
        // Pin hole passing through knuckles
        translate([0, -1, 0])
            rotate([-90, 0, 0])
                cylinder(r=knuckle_id/2, h=leaf_height + 2);
        
        // 3 Countersink holes
        for (i = [-1, 0, 1]) {
            translate([hole_x_offset, hole_y_center + i * hole_pitch, 0])
                m3_countersink();
        }
    }
}

// Pin Axis Component
module pin() {
    translate([0, -1, 0])
        rotate([-90, 0, 0])
            cylinder(r=pin_diameter/2, h=pin_length);
}

// Assembly (180° Open Position)
left_leaf();
right_leaf();
pin();