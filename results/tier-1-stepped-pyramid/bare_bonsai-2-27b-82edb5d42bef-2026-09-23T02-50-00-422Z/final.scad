module slab(w) {
    cube([w, w, 10], center=[true, true, false]);
}

slab(60);
translate([0, 0, 10]) slab(40);
translate([0, 0, 20]) slab(20);