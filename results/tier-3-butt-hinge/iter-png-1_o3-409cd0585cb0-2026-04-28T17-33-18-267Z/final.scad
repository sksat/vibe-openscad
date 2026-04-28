// Butt hinge (opened 180°)

// ---------- Parameters ----------
plate_len = 30;          // Y-length of each leaf
plate_w   = 25;          // X-width  of each leaf
plate_t   = 2;           // thickness (Z)
kn_seg    = 6;           // single knuckle length
kn_count  = 5;           // total knuckles
kn_od     = 8;           // knuckle outer Ø
kn_id     = 4.6;         // knuckle inner Ø (pin clearance)
pin_d     = 4;           // pin Ø
pin_len   = plate_len+2; // 32 mm  (1 mm overhang each end)

// ---------- Rendering quality ----------
$fn = 64;

// ---------- Helper : cylinder along Y ----------
module cyl_y(h,r,center=false)
    rotate([90,0,0]) cylinder(h=h,r=r,center=center);

// ---------- Knuckle segment ----------
module knuckle_seg()
difference(){
    cyl_y(kn_seg, kn_od/2);
    cyl_y(kn_seg+0.2, kn_id/2);   // slightly longer for clean cut
}

// ---------- Countersunk M3 hole ----------
module countersunk_hole()
union(){
    // Through hole (3.2 mm) – centred, long enough to pass the plate
    cylinder(h=plate_t+4, r=3.2/2, center=true, $fn=32);
    // 6 mm Ø, 1 mm deep countersink from top face
    translate([0,0, plate_t/2 - 1])
        cylinder(h=1, r=6/2, center=false, $fn=32);
}

// ---------- Leaf (left / right) ----------
module leaf(is_left=true){
    // X-positions
    plate_x = is_left ? -(kn_od/2) - plate_w : kn_od/2;
    hole_x  = is_left ? -(kn_od/2) - plate_w/2 : kn_od/2 + plate_w/2;

    difference(){
        // Solid geometry
        union(){
            // Plate
            translate([plate_x, 0, -plate_t/2])
                cube([plate_w, plate_len, plate_t]);

            // Knuckles (0-based index of 5 segments)
            if(is_left){
                for(i=[0,2,4])
                    translate([0, i*kn_seg, 0]) knuckle_seg();
            } else {
                for(i=[1,3])
                    translate([0, i*kn_seg, 0]) knuckle_seg();
            }
        }

        // Screw holes – Y positions 7 mm, 15 mm, 23 mm (8 mm pitch)
        for(y=[7,15,23])
            translate([hole_x, y, 0]) countersunk_hole();
    }
}

// ---------- Pin ----------
module pin(){
    // Shift –1 mm so it projects 1 mm beyond each end of the 30 mm knuckle stack
    translate([0,-1,0]) cyl_y(pin_len, pin_d/2, false);
}

// ---------- Assembly ----------
union(){
    leaf(true);   // left leaf
    leaf(false);  // right leaf
    pin();        // central pin
}