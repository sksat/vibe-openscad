// Butt hinge (opened 180°)  ---------------------------
// Parameters
leaf_w   = 25;     // width (X direction)
leaf_h   = 30;     // height (Y direction)
leaf_t   = 2;      // thickness (Z)
kn_d_out = 8;      // knuckle outer diameter
kn_d_in  = 4.6;    // knuckle inner diameter  (= pin Ø + 0.3)
kn_len   = 6;      // each knuckle length
pin_d    = 4;      // pin diameter
pin_len  = 32;     // pin total length (30 + 1 + 1)
hole_d   = 3.2;    // through-hole diameter
cs_d     = 6;      // countersink top diameter
cs_depth = 1;      // countersink depth
hole_off = 20;     // X position of holes from origin (±)
hole_pitch = 8;    // Y spacing between holes

$fn = 64;

// Main assembly
module hinge()
{
    // pin
    rotate([90,0,0])
        translate([0,0,-pin_len/2])
            cylinder(d=pin_d, h=pin_len);

    // leaves
    leaf(side = -1);   // left leaf (x < 0)
    leaf(side =  1);   // right leaf (x > 0)
}

// Leaf with knuckles and holes
// side = -1 (left), +1 (right)
module leaf(side = -1)
{
    // Base plate
    translate([side*(leaf_w * -0.5 - kn_d_out/2), -leaf_h/2, 0])
        difference()
        {
            // plate
            cube([leaf_w, leaf_h, leaf_t]);

            // countersunk holes
            for(i=[-1,0,1])          // three holes
            {
                y_pos = leaf_h/2 + i*hole_pitch;   // convert i index to Y
                translate([side*hole_off, y_pos, 0])
                    countersunk_hole();
            }
        }

    // Knuckles
    for(idx=[0:4])
    {
        // decide if this knuckle belongs to this leaf
        knuckle_to_side = (idx % 2 == 0) ? -1 : 1;   // even -> left, odd -> right
        if(knuckle_to_side == side)
        {
            y_center = -leaf_h/2 + kn_len/2 + idx*kn_len;
            // Solid cylinder knuckle (outer)
            translate([0, y_center, 0])
                rotate([90,0,0])
                    cylinder(d=kn_d_out, h=kn_len);

            // Bore for pin clearance
            translate([0, y_center, 0])
                rotate([90,0,0])
                    #cylinder(d=kn_d_in, h=kn_len);   // use "#" for preview of hole
        }
    }
}

// Countersunk hole (subtractive)
module countersunk_hole()
{
    union()
    {
        // through hole
        translate([0,0,-1])   // extend a bit below plate for clean subtraction
            cylinder(d=hole_d, h=leaf_t+2);

        // countersink (straight-walled approximation)
        translate([0,0,leaf_t-cs_depth])
            cylinder(d=cs_d, h=cs_depth+0.01); // slight overlap
    }
}

// --- Render ---
hinge();