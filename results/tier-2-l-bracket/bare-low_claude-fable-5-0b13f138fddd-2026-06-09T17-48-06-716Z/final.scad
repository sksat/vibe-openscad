$fn = 64;

width = 50;       // X 方向の幅
depth = 40;       // 水平面の奥行き (Y)
height = 40;      // 垂直面の高さ (Z)
t = 3;            // 板厚

hole_d = 4.5;     // M4 貫通穴
cs_d = 8;         // 皿座面径
cs_depth = 2;     // 皿座面深さ
edge = 10;        // 縁からのオフセット

module countersunk_hole() {
    // Z+ 方向に貫通、Z=0 側(外側)に皿座面
    translate([0, 0, -0.5])
        cylinder(d = hole_d, h = t + 1);
    translate([0, 0, -0.01])
        cylinder(d1 = cs_d, d2 = hole_d, h = cs_depth);
}

difference() {
    union() {
        // 水平フランジ(内側コーナー上面 z=0、下に板厚)
        translate([-width/2, 0, -t])
            cube([width, depth, t]);
        // 垂直フランジ(内側コーナー面 y=0、後ろに板厚)
        translate([-width/2, -t, -t])
            cube([width, t, height + t]);
    }

    // 水平面の穴(皿座面は下=外側)
    for (x = [-(width/2 - edge), width/2 - edge])
        translate([x, depth/2, -t])
            countersunk_hole();

    // 垂直面の穴(皿座面は後ろ=外側)
    for (x = [-(width/2 - edge), width/2 - edge])
        translate([x, -t, height/2])
            rotate([-90, 0, 0])
                countersunk_hole();
}