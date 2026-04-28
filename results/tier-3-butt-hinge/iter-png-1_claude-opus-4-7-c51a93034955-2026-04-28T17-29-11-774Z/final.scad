// Small butt hinge - 180° open state
// Pin axis along Y, leaves on Z=0 plane
// Left leaf: x<0, knuckles at segments 0,2,4 (outer + middle)
// Right leaf: x>0, knuckles at segments 1,3 (between)

$fn = 64;

// Parameters
leaf_w = 25;       // leaf width (X direction from hinge axis)
leaf_h = 30;       // leaf height (along Y, hinge axis)
leaf_t = 2;        // leaf thickness
knuckle_od = 8;    // knuckle outer diameter
knuckle_id = 4.6;  // knuckle inner diameter (pin + 0.3 clearance per side overall 0.6? spec says +0.3)
pin_d = 4;         // pin diameter
pin_len = 32;      // pin length (1mm overhang each side)
seg = 6;           // each knuckle segment length (30/5)

// Screw hole parameters
screw_through_d = 3.2;
screw_csk_d = 6;
screw_csk_depth = 1;
screw_pitch = 8;

// ---------- Leaf with knuckles ----------
// The leaf's flat plate ends tangent to the knuckle (so the plate doesn't
// extend across the hinge axis). The knuckle is centered at x=0, and the
// plate's inner edge is at x = ±knuckle_od/2 (so that when opened 180°,
// both plates lie in the same Z plane and clear each other).
module leaf(side="left") {
    sign = (side=="left") ? -1 : 1;
    knuckle_segs = (side=="left") ? [0,2,4] : [1,3];
    
    // Plate inner edge is tangent to knuckle outer cylinder
    plate_inner = sign * knuckle_od/2;
    plate_outer = sign * leaf_w; // total leaf width measured from axis... 
    // Spec: leaf is 25mm wide. Interpreting "25mm" as plate width from
    // knuckle edge outward, but typical hinge "leaf width" includes the
    // knuckle. Here we keep flat plate part = leaf_w from axis tangent
    // (so the visible flat is 25 mm wide as seen in top view, excluding knuckle).
    
    difference() {
        union() {
            // Flat plate
            if (side=="left") {
                translate([-leaf_w - knuckle_od/2, 0, -leaf_t/2])
                    cube([leaf_w, leaf_h, leaf_t]);
            } else {
                translate([knuckle_od/2, 0, -leaf_t/2])
                    cube([leaf_w, leaf_h, leaf_t]);
            }
            
            // Knuckles
            for (i = knuckle_segs) {
                translate([0, i*seg, 0])
                    rotate([-90,0,0])
                        cylinder(d=knuckle_od, h=seg);
            }
            
            // Small fillet bridge from plate edge to knuckle (optional, small triangular block)
            // Connect plate flush to knuckle: thin bridge along Y for each knuckle of THIS leaf
            for (i = knuckle_segs) {
                translate([sign*knuckle_od/2 - (side=="left" ? 0 : 0), i*seg, -leaf_t/2])
                    if (side=="left")
                        translate([-0.01,0,0]) cube([0.02, seg, leaf_t]);
                    else
                        translate([-0.01,0,0]) cube([0.02, seg, leaf_t]);
            }
        }
        
        // Pin hole through knuckles
        translate([0, -1, 0])
            rotate([-90,0,0])
                cylinder(d=knuckle_id, h=leaf_h+2);
        
        // Screw holes - 3 holes along Y, centered, on the leaf
        hole_x = sign * (knuckle_od/2 + leaf_w - 5);  // 5mm from outer edge
        y_center = leaf_h/2;
        for (i = [-1,0,1]) {
            y = y_center + i*screw_pitch;
            // Through hole
            translate([hole_x, y, -leaf_t/2 - 0.1])
                cylinder(d=screw_through_d, h=leaf_t + 0.2);
            // Countersink (taper) on top surface (+Z side)
            translate([hole_x, y, leaf_t/2 - screw_csk_depth])
                cylinder(d1=screw_through_d, d2=screw_csk_d, h=screw_csk_depth + 0.01);
        }
    }
}

// ---------- Pin ----------
// Pin length 32mm, knuckle stack length 30mm, so 1mm overhang each side
module pin() {
    translate([0, -1, 0])
        rotate([-90,0,0])
            cylinder(d=pin_d, h=pin_len);
}

// ---------- Assembly (180° open) ----------
leaf(side="left");
leaf(side="right");
color("gold") pin();