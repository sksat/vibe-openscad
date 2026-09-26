// マグカップの設計パラメータ
mug_outer_r = 40;      // 外径 80mm -> 半径 40mm
mug_inner_r = 35;      // 内径 70mm -> 半径 35mm
mug_height = 90;       // 高さ 90mm
mug_bottom_t = 6;      // 底の厚み 6mm

handle_h = 30;         // 取っ手の高さ 30mm
handle_w = 30;         // 取っ手の幅 (Y方向) 30mm
handle_d = 40;         // 取っ手の奥行き (X方向) 40mm
handle_hole_w = 25;    // 取っ手の内側の空間の幅 25mm
handle_hole_h = 30;    // 取っ手の内側の空間の高さ 30mm

$fn = 100;

// 本体
difference() {
    // 外側の円筒
    cylinder(h = mug_height, r = mug_outer_r);
    
    // 内側の空洞（底面の厚みを考慮して上方向にずらす）
    translate([0, 0, mug_bottom_t])
        cylinder(h = mug_height, r = mug_inner_r);
}

// 取っ手 (Handle)
union() {
    translate([38, 0, 30]) { // x=38に配置することでマグ本体と確実に結合 (x=40の表面に食い込ませる)
        difference() {
            union() {
                // D字形状の構築
                // 前半部分：直線的なブロック (高さ30, 幅30, 奥行き25)
                cube([handle_d - 15, handle_w, handle_h]);
                
                // 後半部分：半円形の端 (半径15)
                // これにより「外側が半円、本体側が直線」のD字形状を実現
                translate([handle_d - 15, 0, 0])
                    rotate([0, 0, 90])
                    cylinder(h = handle_w, r = 15, center = true);
            }
            
            // 取っ手の内側の空間（指が入る穴）をくり抜く
            // 幅25mm、高さ30mmの空間を確保
            // 取っ手の中央付近に配置
            translate([10, -handle_hole_h/2, 0])
                cube([handle_hole_w, handle_hole_h, handle_hole_h]);
        }
    }
}