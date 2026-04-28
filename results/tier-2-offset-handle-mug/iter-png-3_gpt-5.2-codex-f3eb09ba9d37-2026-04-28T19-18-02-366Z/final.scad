$fn = 100;
eps = 0.1;

module d2(width, height){
    r = height/2;
    rect_w = width - r;
    union(){
        translate([0, -height/2]) square([rect_w, height]);
        translate([rect_w, 0]) circle(r=r);
    }
}

module handle(){
    outer_w = 35;
    outer_h = 40;
    inner_w = 25;
    inner_h = 30;
    depth = 12;
    difference(){
        rotate([90,0,0]) linear_extrude(height=depth, center=true) d2(outer_w, outer_h);
        rotate([90,0,0]) linear_extrude(height=depth+eps, center=true) d2(inner_w, inner_h);
    }
}

module mug(){
    difference(){
        cylinder(h=90, r=40);
        translate([0,0,6]) cylinder(h=84+eps, r=35);
    }
}

union(){
    mug();
    translate([40-0.5,0,45]) handle();
}