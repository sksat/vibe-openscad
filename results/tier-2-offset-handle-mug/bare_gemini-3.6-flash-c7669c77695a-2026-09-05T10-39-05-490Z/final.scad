$fn = 100;

// マグカップのサイズ情報
mug_height = 90;
outer_radius = 40; // 外径 80mm
inner_radius = 35; // 内径 70mm
bottom_thickness = 6;

// 取手のサイズ情報
handle_y_width = 12; // 取手のY方向の厚み

difference() {
    // 本体外観と取手を統合
    union() {
        // マグカップ外形本体
        cylinder(h = mug_height, r = outer_radius);

        // 取手 (+X 軸方向)
        rotate([90, 0, 0])
        linear_extrude(height = handle_y_width, center = true)
        difference() {
            // 取手外形 (D字型)
            hull() {
                translate([35, 20]) square([15, 50]);
                translate([50, 45]) circle(r = 25);
            }
            // 取手内側の穴 (高さ30mm × 幅25mm)
            hull() {
                translate([40, 30]) square([10, 30]);
                translate([50, 45]) circle(r = 15);
            }
        }
    }

    // マグカップ内側のくり抜き
    translate([0, 0, bottom_thickness])
        cylinder(h = mug_height - bottom_thickness + 1, r = inner_radius);
}