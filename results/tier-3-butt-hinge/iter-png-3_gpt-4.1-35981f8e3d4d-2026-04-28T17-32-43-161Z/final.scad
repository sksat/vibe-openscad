// ==== パラメータ ====
knuckle_count = 5;
knuckle_length = 6;          // 各 knuckle の長さ (30mm/5)
knuckle_total = knuckle_count * knuckle_length; // =30mm
knuckle_outer_d = 8;
knuckle_clearance = 0.3;
pin_d = 4;
pin_l = knuckle_total + 2;   // 両端1mmずつ出す
knuckle_inner_d = pin_d + knuckle_clearance; // =4.3mm
plate_w = 25;
plate_h = 30;
plate_t = 2;
hole_d = 3.2;        // M3
csink_d = 6;         // 皿穴径
csink_depth = 1;     // 皿穴深さ
hole_count = 3;
hole_pitch = 8;      // 縦方向ピッチ
hole_margin_y = (plate_h - hole_pitch * (hole_count - 1)) / 2; // 上下余白

module countersunk_hole(z=0) {
    // 皿穴＋貫通穴
    translate([0,0,z])
    {
        // 皿部
        cylinder(h=csink_depth, d1=csink_d, d2=hole_d, $fn=32);
        // 貫通部
        translate([0,0,csink_depth])
            cylinder(h=plate_t-csink_depth+1, d=hole_d, $fn=24);
    }
}

// ==== knuckle配置 ====
left_knuckle_pos = [0, 2, 4];
right_knuckle_pos = [1, 3];

module hinge_knuckle() {
    difference() {
        rotate([90,0,0])
            cylinder(h=knuckle_length, d=knuckle_outer_d, center=true, $fn=64);
        rotate([90,0,0])
            cylinder(h=knuckle_length+0.2, d=knuckle_inner_d, center=true, $fn=48);
    }
}

// 板とknuckleの組合せ
module hinge_plate(side = "left") {
    kn_pos = side == "left" ? left_knuckle_pos : right_knuckle_pos;
    // y=0中心に ±plate_h/2 で配置
    x0 = side == "left" ? -plate_w : 0;
    y0 = -plate_h/2;
    // 板本体
    difference() {
        // 板
        translate([x0, y0, -plate_t/2])
            cube([plate_w, plate_h, plate_t]);
        // 皿穴
        for(i = [0:hole_count-1]) {
            y_pos = y0 + hole_margin_y + i*hole_pitch;
            translate([x0 + plate_w/2, y_pos, plate_t/2])
                rotate([90,0,0])
                    countersunk_hole(z=0);
        }
        // knuckle めりこみ
        for (j = kn_pos) {
            // knuckle の中心位置 y
            yj = -knuckle_total/2 + j*knuckle_length + knuckle_length/2;
            translate([0, yj, 0])
                rotate([90,0,0])
                    cylinder(h=plate_t+0.2, d=knuckle_outer_d+0.2, center=true, $fn=64);
        }
    }
    // knuckle 本体
    for (j = kn_pos) {
        yj = -knuckle_total/2 + j*knuckle_length + knuckle_length/2;
        translate([0, yj, 0])
            hinge_knuckle();
    }
}

// ピン軸
module hinge_pin() {
    // Y=0 中心に、±(knuckle_total+2)/2
    rotate([90,0,0])
        cylinder(h=knuckle_total+2, d=pin_d, center=true, $fn=64);
}

// メイン配置
$fn=48;
hinge_plate("left");
hinge_plate("right");
hinge_pin();