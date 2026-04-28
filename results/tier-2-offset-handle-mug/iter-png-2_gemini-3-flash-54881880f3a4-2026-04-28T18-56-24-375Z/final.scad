$fn = 100;

// --- 寸法定義 ---
mug_outer_r = 80 / 2;   // 外径 80mm -> 半径 40mm
mug_inner_r = 70 / 2;   // 内径 70mm -> 半径 35mm (肉厚 5mm)
mug_height = 90;
mug_bottom_thick = 6;

handle_inner_w = 25;    // 取っ手内側の空間 幅 25mm
handle_inner_h = 30;    // 取っ手内側の空間 高さ 30mm
handle_thickness = 8;   // 取っ手自体の肉厚
handle_breadth = 15;    // 取っ手の厚み（正面から見た時の幅）

union() {
    // 1. 本体 (Body)
    difference() {
        // 外側の円筒
        cylinder(h=mug_height, r=mug_outer_r);
        
        // 内側の中空化 (底面 6mm を残す)
        translate([0, 0, mug_bottom_thick])
            cylinder(h=mug_height, r=mug_inner_r);
    }

    // 2. 取っ手 (Handle)
    // マグの +X 軸方向の側面 (x=40) に設置。高さ方向の中央に配置。
    // 確実に union されるよう、本体へ 1mm めり込ませる
    translate([mug_outer_r - 1, 0, mug_height / 2])
    rotate([90, 0, 90]) // 2D 形状を YZ 平面に立てて X 軸方向に押し出す準備
    linear_extrude(height=handle_breadth, center=true) {
        difference() {
            // 外形: D字形状 (本体側が直線、外側が半径 R の半円)
            // 外側先端を (内側幅 25 + 肉厚 8 = 33mm) にするため
            // 半径 R = (内側高/2 + 肉厚) = 23mm の中心を x = 10 に配置
            hull() {
                // 本体側の直線接合部
                translate([0, -(handle_inner_h/2 + handle_thickness)])
                    square([1, handle_inner_h + handle_thickness * 2]);
                
                // 外側の半円
                translate([handle_inner_w + handle_thickness - (handle_inner_h/2 + handle_thickness), 0])
                    circle(r = handle_inner_h/2 + handle_thickness);
            }
            
            // 内側の空間 (高さ 30mm × 幅 25mm)
            translate([0, -handle_inner_h/2])
                square([handle_inner_w, handle_inner_h]);
        }
    }
}