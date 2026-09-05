// L字金具
$fn = 60;

width = 50;
depth = 40;
height = 40;
thickness = 3;

hole_d = 4.5;
csk_d = 8;
csk_depth = 2;
edge_offset = 10;
hole_x_offset = width/2 - edge_offset;

module countersunk_hole(depth_total) {
    union() {
        translate([0,0,-1])
            cylinder(d=hole_d, h=depth_total+2);
        translate([0,0,depth_total-csk_depth])
            cylinder(d1=hole_d, d2=csk_d, h=csk_depth+0.01);
    }
}

module horizontal_flange() {
    difference() {
        translate([-width/2, 0, 0])
            cube([width, depth, thickness]);
        
        // 皿穴は上面(外側、+Z側)から見て皿座面が上(外側)
        for (x = [-hole_x_offset, hole_x_offset]) {
            translate([x, depth - edge_offset, 0])
                translate([0,0,thickness - csk_depth])
                countersunk_hole(thickness);
        }
    }
}

module vertical_flange() {
    difference() {
        translate([-width/2, 0, 0])
            cube([width, thickness, height]);
        
        // 皿穴は外側(+Y側)に皿座面
        for (x = [-hole_x_offset, hole_x_offset]) {
            translate([x, thickness, height - edge_offset])
                rotate([90,0,0])
                translate([0,0,-(thickness)])
                countersunk_hole(thickness);
        }
    }
}

// 組み立て
horizontal_flange();
vertical_flange();