$fn = 80;

outer_r = 40;
inner_r = 35;
height = 90;
bottom = 6;

// Body
difference() {
    cylinder(r=outer_r, h=height);
    translate([0, 0, bottom])
        cylinder(r=inner_r, h=height);
}

// Handle on +X side
handle_h = 30;
handle_w = 25;
handle_thick = 8;
handle_z = (height - handle_h) / 2;

translate([outer_r, 0, handle_z])
difference() {
    scale([handle_w / handle_h, 1, 1])
        rotate([-90, 0, 0])
        rotate([0, 90, 0])
        linear_extrude(height = handle_thick, center = true)
        resize([handle_h + handle_thick * 2, handle_w + handle_thick * 2])
        circle(d = 1);
    scale([handle_w / handle_h, 1, 1])
        rotate([-90, 0, 0])
        rotate([0, 90, 0])
        linear_extrude(height = handle_thick + 2, center = true)
        resize([handle_h, handle_w])
        circle(d = 1);
    // Cut inner half (toward mug body)
    translate([-(handle_w + handle_thick * 2) / 2 - 1, 0, 0])
        cube([handle_w + handle_thick * 2 + 2, handle_w + handle_thick * 2 + 2, handle_h + handle_thick * 2 + 2], center = true);
}