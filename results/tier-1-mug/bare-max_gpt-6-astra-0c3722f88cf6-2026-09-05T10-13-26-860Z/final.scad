$fn = 128;

outer_diameter = 80;
cup_height = 100;
wall_thickness = 4;
bottom_thickness = 6;

handle_radius = 12;       // リングの中心線半径
handle_tube_radius = 2;   // 断面半径：指穴の直径は20mm

outer_radius = outer_diameter / 2;
inner_radius = outer_radius - wall_thickness;
epsilon = 0.01;

difference() {
    union() {
        cylinder(r = outer_radius, h = cup_height);

        // カップ側面へ2mm食い込ませて接合し、指穴を外周より外に配置
        translate([outer_radius + handle_radius, 0, cup_height / 2])
            rotate([90, 0, 0])
                rotate_extrude(convexity = 10)
                    translate([handle_radius, 0, 0])
                        circle(r = handle_tube_radius);
    }

    // 底を6mm残し、上端まで内側をくり抜く
    translate([0, 0, bottom_thickness])
        cylinder(
            r = inner_radius,
            h = cup_height - bottom_thickness + epsilon
        );
}