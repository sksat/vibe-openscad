$fn = 100;

// --- 寸法定義 ---
mug_outer_diam = 80;
mug_inner_diam = 70; // 肉厚 5mm
mug_height = 90;
mug_bottom_thick = 6;

handle_inner_w = 25;    // 取手内側の空間 幅
handle_inner_h = 30;    // 取手内側の空間 高さ
handle_thickness = 8;   // 取手の構造材の厚み
handle_breadth = 15;    // 取手の横幅(Y軸方向の厚み)

// 外側の高さ = 内側高さ + 上下の肉厚
handle_outer_h = handle_inner_h + (handle_thickness * 2);
// 外側の半径 = 外側高さの半分
handle_outer_r = handle_outer_h / 2;

union() {
    // 1. マグカップ本体
    difference() {
        // 外郭
        cylinder(h=mug_height, d=mug_outer_diam);
        
        // 内側の中空化
        translate([0, 0, mug_bottom_thick])
            cylinder(h=mug_height, d=mug_inner_diam);
    }

    // 2. 取手 (Handle) - +X軸方向に配置
    // 本体外周(x = 40)に接続。確実に結合させるため1mm食い込ませる。
    translate([(mug_outer_diam / 2) - 1, 0, mug_height / 2])
    rotate([90, 0, 90]) // 2D形状を垂直に立ててX軸方向に押し出し
    linear_extrude(height=handle_breadth, center=true) {
        difference() {
            // 取手の外形: D字形状 (本体側が直線、外側が半円)
            hull() {
                // 本体側の接合面
                translate([0, -handle_outer_h / 2])
                    square([1, handle_outer_h]);
                
                // 外側の半円部分
                // 全体の幅が (内側幅 + 肉厚) になるように配置
                translate([(handle_inner_w + handle_thickness) - handle_outer_r, 0])
                    circle(r = handle_outer_r);
            }
            
            // 取手の内側の穴 (高さ 30mm × 幅 25mm)
            translate([0, -handle_inner_h / 2])
                square([handle_inner_w, handle_inner_h]);
        }
    }
}