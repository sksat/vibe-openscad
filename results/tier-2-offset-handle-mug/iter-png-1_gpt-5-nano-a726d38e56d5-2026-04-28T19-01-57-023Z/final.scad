$fn = 100;

// Main mug body: outer cylinder with hollow inner bottom (6 mm)
module mug_body() {
    outer = cylinder(h = 90, r = 40, $fn = $fn);
    inner = translate([0, 0, 6]) cylinder(h = 84, r = 35, $fn = $fn);
    difference() {
        outer;
        inner;
    }
}

// 2D cross-section for the D-shaped handle (in YZ plane), to be extruded along X
module handle_cross_section() {
    Th = 30;       // thickness into +X direction (cross-section width)
    Hh = 70;       // overall cross-section height
    hole_w = 25;   // inner hollow width
    hole_h = 30;   // inner hollow height
    hole_x = Th - hole_w; // inner hole left edge (keeps hole inside from the left boundary)
    hole_y = (Hh - hole_h) / 2;

    // Build D-shape: left straight boundary (x = 0), right semi-circular boundary
    pts = [];
    pts = concat(pts, [[0, 0]]);
    pts = concat(pts, [[Th, 0]]);
    for (a = [-90:5:90]) {
        ang = a * PI / 180;
        pts = concat(pts, [ [ Th + Th * cos(ang), Hh/2 + Th * sin(ang) ] ]);
    }
    pts = concat(pts, [[0, Hh]]);

    difference() {
        polygon(points = pts);
        translate([hole_x, hole_y]) square([hole_w, hole_h], center = false);
    }
}

// 3D handle by extruding the 2D cross-section along the X axis
module handle3d() {
    rotate([-90, 0, 0]) {
        linear_extrude(height = 18) {
            handle_cross_section();
        }
    }
}

// Assemble mug with handle on the +X side
union() {
    mug_body();

    // Position the handle near the outer surface on the +X side
    // Z offset centers the handle around the mug height
    translate([40, 0, 10]) handle3d();
}