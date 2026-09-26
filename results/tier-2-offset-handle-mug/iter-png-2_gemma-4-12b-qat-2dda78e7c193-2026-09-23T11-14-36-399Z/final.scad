// マグカップの設計パラメータ
mug_outer_r = 40;      // 外径 80mm -> 半径 40mm
mug_inner_r = 35;      // 内径 70mm -> 半径 35mm
mug_height = 90;       // 高さ 90mm
mug_bottom_t = 6;      // 底の厚み 6mm

handle_r = 30;         // 取っ手の外側の半径（空間を確保するため30に設定）
handle_h = 30;         // 取っ手の高さ 30mm
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
    difference() {
        union() {
            // 取っ手本体 (D字形状)
            // 中心を x=40 (マグの表面), y=40, z=45 に配置
            // cylinder(h=30, r=30, center=true) は Z方向に30、X方向に-30〜30、Y方向に-30〜30を占める
            translate([40, 40, 45])
            difference() {
                cylinder(h = handle_h, r = handle_r, center = true);
                
                // X方向のカット：
                // x=35の位置でカットすることで、マグの表面(x=40)より少し内側から
                // 取っ手を開始させ、直線的な「D字」の背面を作りつつ、
                // マグの曲面に対して確実に接続されるようにする
                cube([35, 100, 100]);
            }
            
            // 接続補強 (Connection Bridge)
            // マグの曲面と 取っ手の平面を確実に結合するための接合部
            // x=30からx=35の範囲を埋めることで、マニフォールドを維持
            translate([30, 30, 30])
            cube([10, 40, 30]);
        }
        
        // 取っ手の内側の空間（指が入る穴）をくり抜く
        // 取っ手の厚み（x=40〜x=70）の範囲に配置
        translate([40, 35, 30])
        cube([handle_hole_w, handle_hole_h, handle_hole_h]);
    }
}