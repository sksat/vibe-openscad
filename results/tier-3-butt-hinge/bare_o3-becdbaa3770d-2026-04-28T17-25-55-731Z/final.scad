// Butt hinge (opened 180°)
// Parameters
plate_len = 30;           // along Y
plate_w   = 25;           // along X (each leaf)
plate_t   = 2;            // thickness (Z)
kn_seg    = 6;            // single knuckle length
kn_count  = 5;            // total knuckle pieces
kn_od     = 8;            // knuckle outer Ø
kn_id     = 4.6;          // knuckle inner Ø (pin clearance)
pin_d     = 4;            // pin Ø
pin_len   = plate_len+2;  // 32 mm (30 + 1 + 1)

// Convenience
$fn = 64;

// ---------- Modules ----------
module cyl_y(h,r,center=false)
    rotate([90,0,0]) cylinder(h=h,r=r,center=center);

module knuckle_seg(len=kn_seg, od=kn_od/2, id=kn_id/2)
difference(){
    cyl_y(len, od);
    cyl_y(len+0.2, id);     // a bit longer for clean subtraction
}

module countersunk_hole()
union(){
    translate([0,0,-2]) cylinder(h=6,r=3.2/2,$fn=32);   // through M3.2
    translate([0,0,0])  cylinder(h=1,r=6/2,$fn=32);     // 6 mm Ø, 1 mm deep
}

module leaf(is_left=true){
    // X positions
    plate_x = is_left ? -(kn_od/2) - plate_w :  kn_od/2;
    hole_x  = is_left ? -(kn_od/2) - plate_w/2 : kn_od/2 + plate_w/2;

    difference(){
        // Solid parts
        union(){
            // plate
            translate([plate_x,0,-plate_t/2])
                cube([plate_w, plate_len, plate_t]);

            // knuckles
            if(is_left){
                for(i=[0,2,4])
                    translate([0,i*kn_seg,0]) knuckle_seg();
            }else{
                for(i=[1,3])
                    translate([0,i*kn_seg,0]) knuckle_seg();
            }
        }

        // screw holes (Y positions 6 mm, 14 mm, 22 mm from one end)
        for(y=[6,14,22])
            translate([hole_x,y,plate_t/2])
                countersunk_hole();
    }
}

module pin(){
    translate([0,-1,0]) cyl_y(pin_len, pin_d/2, false);
}

// ---------- Assembly ----------
union(){
    leaf(true);   // left leaf
    leaf(false);  // right leaf
    pin();        // hinge pin
}