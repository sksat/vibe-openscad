// Parameters
mug_outer_radius = 40;   // 80mm diameter
wall_thickness   = 4;
bottom_thickness = 6;
mug_height       = 100;

inner_radius     = mug_outer_radius - wall_thickness;          // 36mm
inner_height     = mug_height - bottom_thickness;              // 94mm

handle_major_radius = 12;   // distance from torus center to tube center
handle_tube_radius  = 4;    // thickness of the handle tube

// Mug
module mug(){
    difference(){
        cylinder(h = mug_height, r = mug_outer_radius, $fn = 128);
        translate([0,0,bottom_thickness])
            cylinder(h = inner_height, r = inner_radius, $fn = 128);
    }
}

// Torus (handle)
module torus(R, r){
    rotate_extrude(convexity = 10, $fn = 128)
        translate([R,0,0])
            circle(r = r, $fn = 64);
}

// Handle positioned on the side
module handle(){
    translate([mug_outer_radius + handle_major_radius - 2, 0, mug_height/2])
        rotate([0,90,0])       // axis along X
            torus(handle_major_radius, handle_tube_radius);
}

// Assemble
union(){
    mug();
    handle();
}