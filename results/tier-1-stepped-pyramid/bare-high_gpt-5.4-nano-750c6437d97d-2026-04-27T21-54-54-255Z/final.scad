// 3段の階段状ピラミッド（中心揃えで積み上げ）

$fn = 50;

base_size = 60;
mid_size  = 40;
top_size  = 20;

h = 10;

module plate(size, z) {
    cube([size, size, h], center = false);
    translate([0, 0, z]) children();
}

module step_stack() {
    // 底板（60x60x10）
    translate([-base_size/2, -base_size/2, 0])
        cube([base_size, base_size, h], center=false);

    // 中板（40x40x10）を底板の上へ（高さ +10）
    translate([-mid_size/2, -mid_size/2, h])
        cube([mid_size, mid_size, h], center=false);

    // 上板（20x20x10）を中板の上へ（高さ +20）
    translate([-top_size/2, -top_size/2, 2*h])
        cube([top_size, top_size, h], center=false);
}

step_stack();