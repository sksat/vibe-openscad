$fn = 64;

// GP2Y0D413K0F simplified exterior model
// Coordinate system:
// origin = center of main body case
// +Z = up
// +Y = front (lens side)
// units = mm

// -------------------- Main dimensions from datasheet --------------------
body_w = 29.45;      // X
body_d = 7.1;        // Y
body_h = 13.5;       // Z

lenscase_w = 29.45;  // front view suggests full width face piece
lenscase_d = 2.0;    // side view
lenscase_h = 8.4;    // side view front protrusion height envelope

// Lens center reference dimensions (* in datasheet)
emit_cx_from_left = 4.5;
recv_cx_from_left = 19.7;

// Front lower reference
front_lower_step_z = 3.75;   // from bottom to lower front ledge

// Receiver window approximate dimensions read from drawing
recv_win_w = 12.4;
recv_win_h = 5.6;

// Emitter lens approximate visible diameter from drawing
emit_lens_d = 5.0;

// PCB / connector
pwb_t = 1.2;
pwb_w = 10.1;
pwb_d = 3.3;

conn_w = 10.1;
conn_d = 6.2;
conn_h = 7.0;

pin_w = 0.6;
pin_d = 0.6;
pin_h = 3.0;
pin_pitch = 2.54;

// -------------------- Derived positions --------------------
body_xmin = -body_w/2;
body_xmax =  body_w/2;
body_ymin = -body_d/2;
body_ymax =  body_d/2;
body_zmin = -body_h/2;
body_zmax =  body_h/2;

front_face_y = body_ymax;
lenscase_center_y = front_face_y + lenscase_d/2;

emit_cx = body_xmin + emit_cx_from_left;
recv_cx = body_xmin + recv_cx_from_left;

// Lens centers taken approximately at mid-height of front optical section
lens_cz = 0;

// -------------------- Modules --------------------
module main_case() {
    color([0.12,0.12,0.12])
    cube([body_w, body_d, body_h], center=true);
}

module front_lens_case() {
    color([0.18,0.18,0.18])
    translate([0, lenscase_center_y, lens_cz])
        cube([lenscase_w, lenscase_d, lenscase_h], center=true);
}

module front_windows() {
    // subtract shallow recesses to indicate the two front optical windows
    difference() {
        union() {
            // left emitter bezel block
            translate([emit_cx, front_face_y + lenscase_d/2 + 0.01, lens_cz])
                cube([7.6, lenscase_d + 0.02, 6.2], center=true);

            // right receiver bezel block
            translate([recv_cx, front_face_y + lenscase_d/2 + 0.01, lens_cz])
                cube([14.0, lenscase_d + 0.02, 6.2], center=true);
        }

        // circular emitter lens recess
        translate([emit_cx, front_face_y + lenscase_d/2, lens_cz])
            rotate([90,0,0])
                cylinder(h=lenscase_d + 0.2, d=emit_lens_d, center=true);

        // receiver rectangular window recess
        translate([recv_cx, front_face_y + lenscase_d/2, lens_cz])
            cube([recv_win_w, lenscase_d + 0.2, recv_win_h], center=true);
    }
}

module pwb() {
    color([0.82,0.72,0.45])
    translate([0, 0, body_zmin - pwb_t/2])
        cube([pwb_w, pwb_d, pwb_t], center=true);
}

module connector_body() {
    color([0.92,0.92,0.92])
    translate([0, 0, body_zmin - pwb_t - conn_h/2])
        cube([conn_w, conn_d, conn_h], center=true);
}

module connector_pins() {
    color([0.75,0.75,0.75])
    for (x = [-pin_pitch, 0, pin_pitch])
        translate([x, 0, body_zmin - pwb_t - conn_h - pin_h/2])
            cube([pin_w, pin_d, pin_h], center=true);
}

module sensor_model() {
    union() {
        main_case();
        front_lens_case();
        front_windows();
        pwb();
        connector_body();
        connector_pins();
    }
}

sensor_model();