// パラメータ設定
outer_dia = 80;
inner_dia = 70;
height = 90;
bottom_thickness = 6;
wall_thickness = (outer_dia - inner_dia) / 2;

handle_width_inner = 25;
handle_height_inner = 30;
handle_thickness = 5;

$fn = 100;

union() {
    // --- 本体 ---
    difference() {
        // 外殻
        cylinder(d = outer_dia, h = height);
        
        // 内側の中空部分 (底面の厚みを考慮して上にずらす)
        translate([0, 0, bottom_thickness])
            cylinder(d = inner_dia, h = height);
    }

    // --- 取手 (+X軸方向) ---
    // 取手を高さ中央に配置
    translate([outer_dia/2, 0, height/2 - handle_height_inner/2]) {
        difference() {
            // 取手の外形 (D字形状)
            hull() {
                // 本体接続部の矩形
                translate([-1, -handle_height_inner/2 - handle_thickness, 0])
                    cube([1, handle_height_inner + handle_thickness * 2, handle_thickness]);
                
                // 外側の半円部分を形成するための円柱
                translate([handle_width_inner/2 + handle_thickness, 0, 0])
                    rotate([0, 90, 0])
                    cylinder(d = handle_height_inner + handle_thickness * 2, h = handle_thickness, center = true);
            }

            // 取手の内側空間 (指が入る部分)
            translate([0, 0, -1])
                cube([handle_width_inner + 1, handle_height_inner, handle_thickness + 2]);
            
            // D字の形状を整えるため、本体側へ突き抜けた部分をカット
            translate([-10, -handle_height_inner/2 - handle_thickness, -1])
                cube([10, handle_height_inner + handle_thickness * 2, handle_thickness + 2]);
        }
        
        // 取っ手の接続を確実にするための補強ブロック
        translate([-2, -handle_height_inner/2 - handle_thickness, 0])
            cube([2, handle_height_inner + handle_thickness * 2, handle_thickness]);
    }
}