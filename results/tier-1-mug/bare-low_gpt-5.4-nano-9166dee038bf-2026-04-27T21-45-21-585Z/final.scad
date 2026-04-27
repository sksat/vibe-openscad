// Mug with handle ring
// Outer diameter 80mm, height 100mm
// Wall thickness 4mm, bottom thickness 6mm
// Handle: semicircular ring sticking outward, radius 12mm, centered at mid-height

$fn = 128;

outer_d = 80;
outer_r = outer_d/2;

height = 100;

wall = 4;
bottom_th = 6;

inner_r = outer_r - wall;
inner_h = height - bottom_th;

handle_r = 12;                 // handle outer radius
handle_th = 8;                // handle thickness (ring cross-section thickness)
handle_gap = 2;              // clearance between ring and cup wall

// --- Main mug body (outer minus inner cavity) ---
module mug() {
  difference() {
    // Outer shell
    union() {
      cylinder(h=height, r=outer_r);
      // (No separate bottom; handled by cavity depth)
    }

    // Inner cavity
    translate([0,0,bottom_th])
      cylinder(h=inner_h, r=inner_r);
  }
}

// --- Handle: ring-like shape (implemented as a thick circular torus section),
// centered at cup mid-height and sticking out to the outside.
// Orientation: ring plane vertical (Y-Z plane), so it's accessible as a loop.
module handle() {
  // Place the handle so its center is offset outward from cup outer surface.
  // Want the handle to stick out with radius 12mm.
  // Torus center offset from cup center = outer_r + (handle_r - handle_th/2 + handle_gap)
  cx = outer_r + (handle_r - handle_th/2 + handle_gap);

  // Ring is a torus cut to an approximate "C" shape by using a half-box.
  // Then we union it with a cylindrical ear to ensure solid attachment at the desired height.
  translate([cx, 0, height/2]) rotate([0,90,0])
  difference() {
    // Outer torus section
    // Major radius = handle_r - handle_th/2 (approx), minor radius = handle_th/2
    // But we use "torus" as a full solid by rotating a circle around Y axis.
    rotate_extrude(angle=360)
      translate([handle_r - handle_th/2, 0, 0])
        circle(r=handle_th/2);

    // Remove inner part to make it ring-like (thin hole)
    // Increase inner subtraction circle radius slightly for clean ring.
    rotate_extrude(angle=360)
      translate([handle_r - handle_th/2, 0, 0])
        circle(r=max(0.01,(handle_th/2 - 1.5)));

    // Optional: cut a window to make it more "C" like (keep enough for finger through)
    // Remove one side of the torus by cutting with a cube.
    translate([-handle_r*2, -handle_r*2, -handle_r*2])
      cube([handle_r*4, handle_r*2, handle_r*4], center=false);
  }
}

// --- Compose mug + handle ---
difference() {
  union() {
    mug();
    handle();
  }

  // Ensure handle doesn't intersect internal cavity aggressively is optional.
  // Not applying extra boolean cuts inside the cup cavity (keeps it simple).
}