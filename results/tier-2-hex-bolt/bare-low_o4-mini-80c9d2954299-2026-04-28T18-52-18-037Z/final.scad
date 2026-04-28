d_hex = 26/sqrt(3);
h_head = 5.3;
d_shaft = 8;
l_shaft = 30;

union() {
    cylinder(d = d_hex, h = h_head, $fn = 6);
    translate([0, 0, -l_shaft])
        cylinder(d = d_shaft, h = l_shaft);
}