$fn = 60;

cup_od = 80;
cup_r = cup_od / 2;
cup_h = 100;
wall_t = 4;
bottom_t = 6;

handle_ring_r = 24;    // 取手のリング半径（外周から十分はみ出すサイズ）
handle_tube_r = 5;     // 取手の棒自体の半径

union() {
    // カップ本体
    difference() {
        cylinder(r = cup_r, h = cup_h);
        translate([0, 0, bottom_t])
            cylinder(r = cup_r - wall_t, h = cup_h - bottom_t + 1);
    }
    
    // 取手（側面に配置されたリング）
    translate([cup_r + handle_ring_r - 8, 0, cup_h / 2])
        rotate([90, 0, 0])
            rotate_extrude()
                translate([handle_ring_r, 0, 0])
                    circle(r = handle_tube_r);
}