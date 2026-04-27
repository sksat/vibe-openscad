$fn = 100;

difference() {
    union() {
        cylinder(h = 100, r = 40);
        
        translate([52, 0, 50])
        rotate([90, 0, 0])
        rotate_extrude()
        translate([12, 0, 0])
        circle(r = 4);
    }
    
    translate([0, 0, 6])
    cylinder(h = 100, r = 36);
}