$fn = 100;

// パラメータ定義
outer_d = 80;          // マグカップ外径
height = 100;          // マグカップ高さ
wall_thick = 4;        // 側面の肉厚
bottom_thick = 6;      // 底面の厚み

handle_r = 25;         // 取手全体の半径
handle_tube_r = 6;     // 取手の太さ(半径)

union() {
    // カップ本体
    difference() {
        // 外側の円筒
        cylinder(d = outer_d, h = height);
        
        // 内側のくり抜き
        translate([0, 0, bottom_thick])
            cylinder(d = outer_d - (wall_thick * 2), h = height - bottom_thick + 1);
    }
    
    // 取手（リング状）
    translate([outer_d/2 + handle_r - handle_tube_r, 0, height/2])
        rotate([90, 0, 0])
            rotate_extrude()
                translate([handle_r - handle_tube_r, 0, 0])
                    circle(r = handle_tube_r);
}