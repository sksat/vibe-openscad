$fn = 100;

outer_d       = 80;
height        = 100;
wall_thick    = 4;
bottom_thick  = 6;
outer_r       = outer_d/2;
inner_r       = outer_r - wall_thick;
handle_r      = 12;

module mug() {
    difference() {
        // 外胴
        cylinder(h = height, r = outer_r);
        // 内胴（底面厚みを残して上部をくり抜く）
        translate([0, 0, bottom_thick])
            cylinder(h = height - bottom_thick, r = inner_r);
    }
}

module handle() {
    // リング状の取手を torus で作成（マグ外周に面一接触）
    rotate([90, 0, 0])
        rotate_extrude()
            translate([outer_r + handle_r, 0])
                circle(r = handle_r);
}

union() {
    mug();
    // 取手はカップの中心高さに配置
    translate([0, 0, height/2])
        handle();
}