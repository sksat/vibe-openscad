$fn = 64;

module knuckle_segment(y0, len){
    difference(){
        translate([0, y0, 1]) rotate([-90,0,0]) cylinder(h=len, d=8);
        translate([0, y0-0.1, 1]) rotate([-90,0,0]) cylinder(h=len+0.2, d=4.6);
    }
}

module countersink_hole(x, y){
    // through hole
    translate([x, y, -0.1]) cylinder(h=2.2, d=3.2);
    // countersink from top surface (z=2) down 1mm
    translate([x, y, 1]) cylinder(h=1, d1=6, d2=3.2);
}

module leaf(side=1){
    x0 = (side==1) ? 4 : -29;
    difference(){
        union(){
            translate([x0, 0, 0]) cube([25,30,2]);
            for(y0 = (side==1) ? [6,18] : [0,12,24])
                knuckle_segment(y0,6);
        }
        for(y=[7,15,23])
            countersink_hole(side*20, y);
    }
}

module pin(){
    translate([0,-1,1]) rotate([-90,0,0]) cylinder(h=32, d=4);
}

// Assembly
leaf(-1);
leaf(1);
pin();