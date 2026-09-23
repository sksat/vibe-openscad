$fn = 64;

// Mug body
module mug() {
    outer = cylinder(r = 40, h = 90);
    inner = translate([0, 0, 6]) cylinder(r = 35, h = 84);
    difference() {
        outer;
        inner;
    }
}

// D‑shaped handle (+X side)
module handle() {
    wall      = 5;   // material thickness
    inner_w   = 25;  // inner width (X direction)
    inner_h   = 30;  // inner height (Z direction)

    // 2D cross‑section (X–Y plane)
    cross_section = difference() {
        // outer shape: rectangle + outer half‑circle
        union() {
            square([inner_w + wall, inner_h]);                     // rectangle part
            translate([inner_w + wall, inner_h/2])
                circle(r = inner_h/2 + wall);                     // outer half‑circle
        }
        // inner cavity (rectangular)
        translate([wall, 0]) square([inner_w, inner_h]);
    }

    // Extrude to give depth (Y direction) and position
    translate([40, 0, 45 - inner_h/2])          // attach to +X side, center vertically
        rotate([90, 0, 0])                     // extrude along Y
            linear_extrude(height = wall)      // handle thickness
                cross_section;
}

// Assemble
union() {
    mug();
    handle();
}