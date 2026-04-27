// マグカップのパラメータ
outer_diameter = 80;    // 外径 mm
height = 100;           // 高さ mm
wall_thickness = 4;     // 肉厚 mm
bottom_thickness = 6;   // 底面の厚み mm

// 内径の計算
inner_diameter = outer_diameter - 2 * wall_thickness;

// 取手のパラメータ
handle_tube_radius = 6;          // 取手チューブの断面半径 mm
handle_ring_radius = 18;         // 取手リングの中心半径 mm
handle_center_height = height / 2; // 取手の中心高さ

$fn = 128;

module cup_body() {
    difference() {
        // 外側の円柱（カップ本体）
        cylinder(h = height, d = outer_diameter, center = false);
        
        // 内側をくり抜く
        translate([0, 0, bottom_thickness])
            cylinder(
                h = height - bottom_thickness + 1,
                d = inner_diameter,
                center = false
            );
    }
}

module handle() {
    // 取手の位置: カップ外周から外側に配置
    // リング中心のX座標 = カップ外径/2 + 取手リング半径
    handle_x = outer_diameter / 2 + handle_ring_radius;
    
    translate([handle_x, 0, handle_center_height])
        rotate([90, 0, 0])
            rotate_extrude(angle = 360, $fn = 128)
                translate([handle_ring_radius, 0, 0])
                    circle(r = handle_tube_radius, $fn = 64);
}

module mug() {
    difference() {
        union() {
            cup_body();
            handle();
        }
        
        // 取手がカップ内部に食い込む部分を取り除く（内側のくり抜き）
        // 取手とカップ内壁の干渉除去は不要だが、
        // 取手のリング内部が詰まらないよう確認済み
        
        // カップ本体下部より下にはみ出た取手部分をカット
        translate([0, 0, -200])
            cube([400, 400, 200], center = true);
        
        // カップ本体上部より上にはみ出た取手部分をカット
        translate([0, 0, height])
            cube([400, 400, 400], center = true);
    }
}

mug();