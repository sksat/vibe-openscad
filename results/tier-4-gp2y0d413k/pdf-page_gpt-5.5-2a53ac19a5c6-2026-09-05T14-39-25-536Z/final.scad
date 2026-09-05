/*
  Sharp GP2Y0D413K0F distance sensor - simplified mechanical model

  Coordinate system:
    Unit: mm
    Origin: center of the main lens case/body
    X: horizontal direction across emitter/detector
    Y: optical/front direction; lens face is +Y
    Z: vertical direction; PWB / connector mounting side is -Z

  Dimensions are modeled from the outline drawing.
  Unspecified small details are approximated for visual/CAD reference use.
*/

$fn = 64;

// -------------------- Main dimensions --------------------
body_w = 29.45;   // X, overall lens case width
body_d = 13.50;   // Y, case depth
body_h = 13.05;   // Z, lens case height

overall_h_ref = 18.90;              // including lower connector/PWB side, ref.
connector_drop = overall_h_ref - body_h;

emitter_x  = -body_w/2 + 4.5;       // *4.5 lens center from left edge
detector_x = emitter_x + 19.7;      // *19.7 lens center pitch
lens_z     = 0.0;

// Connector / PWB approximation
conn_w = 10.1;
conn_d = 6.3;
conn_h = connector_drop;

// -------------------- Colors --------------------
case_col      = [0.015, 0.015, 0.015, 1.0];
case_edge_col = [0.045, 0.045, 0.045, 1.0];
dark_col      = [0.0, 0.0, 0.0, 1.0];
lens_col      = [0.75, 0.90, 1.00, 0.45];
det_lens_col  = [0.08, 0.10, 0.12, 0.65];
pcb_col       = [0.42, 0.24, 0.08, 1.0];
conn_col      = [0.86, 0.84, 0.75, 1.0];
pin_col       = [1.00, 0.72, 0.20, 1.0];
stamp_col     = [0.85, 0.85, 0.82, 1.0];

// -------------------- Utility modules --------------------
module rounded_box_xy(size=[1,1,1], r=0.5) {
    // Rounded in X-Y plane, extruded in Z.
    linear_extrude(height=size[2], center=true)
        offset(r=r)
            square([size[0]-2*r, size[1]-2*r], center=true);
}

module cyl_y(d=1, h=1) {
    rotate([90, 0, 0])
        cylinder(d=d, h=h, center=true);
}

module front_rect(cx, cz, w, h, t=0.18, col=[0,0,0,1]) {
    color(col)
        translate([cx, body_d/2 + t/2 + 0.01, cz])
            cube([w, t, h], center=true);
}

module front_frame(cx, cz, w, h, border=0.55, t=0.35) {
    color(case_edge_col) {
        // top
        translate([cx, body_d/2 + t/2 + 0.03, cz + h/2 - border/2])
            cube([w, t, border], center=true);
        // bottom
        translate([cx, body_d/2 + t/2 + 0.03, cz - h/2 + border/2])
            cube([w, t, border], center=true);
        // left
        translate([cx - w/2 + border/2, body_d/2 + t/2 + 0.03, cz])
            cube([border, t, h], center=true);
        // right
        translate([cx + w/2 - border/2, body_d/2 + t/2 + 0.03, cz])
            cube([border, t, h], center=true);
    }
}

module top_stamp() {
    // Raised pale stamp on +Z top surface.
    translate([0, -1.2, body_h/2 + 0.035]) {
        color(stamp_col)
            translate([0, 0, 0])
                cube([11.5, 3.0, 0.05], center=true);

        color(dark_col) {
            translate([0, 0.55, 0.06])
                linear_extrude(height=0.04)
                    text("SHARP", size=1.35, halign="center", valign="center",
                         font="Liberation Sans:style=Bold");

            translate([0, -0.75, 0.06])
                linear_extrude(height=0.04)
                    text("0D413KF", size=1.10, halign="center", valign="center",
                         font="Liberation Sans:style=Bold");
        }
    }
}

module lens_assembly(x, z, glass_col=lens_col) {
    // Outer black boss / ring
    color([0.02, 0.02, 0.02, 1])
        translate([x, body_d/2 + 0.26, z])
            cyl_y(d=6.45, h=0.48);

    // Inner rim
    color([0.12, 0.12, 0.12, 1])
        translate([x, body_d/2 + 0.52, z])
            cyl_y(d=5.55, h=0.34);

    // Visible lens
    color(glass_col)
        translate([x, body_d/2 + 0.72, z])
            cyl_y(d=4.55, h=0.30);

    // Small highlight
    color([1, 1, 1, 0.35])
        translate([x - 1.15, body_d/2 + 0.90, z + 1.15])
            cyl_y(d=0.85, h=0.05);
}

module bottom_connector() {
    // Paper phenol PWB plate on the -Z side.
    color(pcb_col)
        translate([0, -1.0, -body_h/2 - 0.18])
            cube([12.6, 8.0, 0.36], center=true);

    // Connector housing protruding toward -Z.
    color(conn_col)
        translate([0, -1.0, -body_h/2 - conn_h/2])
            cube([conn_w, conn_d, conn_h], center=true);

    bottom_z = -body_h/2 - conn_h;

    // Connector socket opening on the lower mounting side.
    color(dark_col)
        translate([0, -1.0, bottom_z - 0.035])
            cube([conn_w - 1.3, conn_d - 1.2, 0.08], center=true);

    // Three contacts; terminal order as seen from the connector side.
    for (i = [-1, 0, 1]) {
        color(pin_col)
            translate([i * 2.54, -1.0, bottom_z - 0.13])
                cube([0.55, 2.7, 0.18], center=true);
    }

    // Plastic separators in the socket.
    for (i = [-0.5, 0.5]) {
        color(conn_col)
            translate([i * 2.54, -1.0, bottom_z - 0.11])
                cube([0.22, conn_d - 1.45, 0.16], center=true);
    }
}

module lower_case_lugs() {
    // Small black lower projections visible beside the connector in the outline.
    color(case_col) {
        translate([-9.9, -1.0, -body_h/2 - 0.65])
            cube([7.5, 5.7, 1.3], center=true);

        translate([9.7, -1.0, -body_h/2 - 0.65])
            cube([7.8, 5.7, 1.3], center=true);
    }
}

// -------------------- Model --------------------
union() {
    // Main carbonic ABS lens case
    color(case_col)
        rounded_box_xy([body_w, body_d, body_h], r=0.65);

    // Slight raised top/front lip and lower seam on the front face
    color(case_edge_col)
        translate([0, body_d/2 + 0.12, body_h/2 - 0.65])
            cube([body_w - 1.0, 0.24, 0.45], center=true);

    color(case_edge_col)
        translate([0, body_d/2 + 0.13, -3.95])
            cube([body_w - 1.0, 0.22, 0.28], center=true);

    // Front optical windows / frames
    front_rect(emitter_x, lens_z, 7.5, 7.2, 0.12, [0.03, 0.03, 0.03, 1]);
    front_frame(emitter_x, lens_z, 7.5, 7.2, border=0.55, t=0.34);

    right_panel_cx = body_w/2 - 0.35 - 16.3/2;
    front_rect(right_panel_cx, lens_z, 16.3, 7.2, 0.12, [0.03, 0.03, 0.03, 1]);
    front_frame(right_panel_cx, lens_z, 16.3, 7.2, border=0.55, t=0.34);

    // Light emitter and detector lenses
    lens_assembly(emitter_x,  lens_z, lens_col);
    lens_assembly(detector_x, lens_z, det_lens_col);

    // Small center rib/details between optical windows
    color(case_edge_col)
        translate([0.0, body_d/2 + 0.20, -0.15])
            cube([0.38, 0.34, 7.6], center=true);

    // Connector and PWB on the -Z mounting side
    lower_case_lugs();
    bottom_connector();

    // Top-side stamp
    top_stamp();

    // Pin numbers embossed near connector, facing -Z side.
    // These are shallow raised digits on the bottom connector face.
    bottom_z = -body_h/2 - conn_h;
    for (idx = [0:2]) {
        xnum = (idx - 1) * 2.54;
        color(dark_col)
            translate([xnum, 1.95, bottom_z - 0.22])
                rotate([180, 0, 0])
                    linear_extrude(height=0.04)
                        text(str(idx + 1), size=1.15, halign="center", valign="center",
                             font="Liberation Sans:style=Bold");
    }
}