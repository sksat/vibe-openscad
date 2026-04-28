// マグカップ
module mug() {
    // 外径80mm = 半径40mm
    // 内径70mm = 半径35mm
    // 肉厚 5mm
    // 高さ 90mm
    // 底面厚み 6mm
    
    difference() {
        // 外側円筒
        cylinder(h = 90, r = 40, center = false);
        
        // 内側の空洞(底面6mm分は残す)
        translate([0, 0, 6]) {
            cylinder(h = 84, r = 35, center = false);
        }
    }
}

// D字形取手
module handle() {
    // 取手の内側寸法
    handle_inner_height = 30;  // 高さ30mm
    handle_inner_width = 25;   // 幅25mm
    
    // 取手開始高さ(中央付近: 90/2 - 30/2 = 30)
    handle_z = 30;
    
    // 取手は本体外径(40mm)から延びる
    // 外側半円部分の半径を定義
    handle_depth = 20;  // 本体から延びる距離
    
    union() {
        // 取手の本体側ブロック(直線部分)
        translate([35, -handle_inner_width/2, handle_z]) {
            cube([10, handle_inner_width, handle_inner_height]);
        }
        
        // 取手の外側半円部分
        // X >= 40 の部分の円形部分
        difference() {
            // 取手用円筒セクション
            translate([0, 0, handle_z]) {
                difference() {
                    // 外側半径 = 40 + 20 = 60mm
                    cylinder(h = handle_inner_height, r = 40 + handle_depth, center = false);
                    // 内側を削除(内径との干渉を避ける)
                    cylinder(h = handle_inner_height, r = 40, center = false);
                    // X < 40 の部分を削除(+X側のみ)
                    translate([-100, -100, -1]) {
                        cube([100, 200, handle_inner_height + 2]);
                    }
                }
            }
            // 取手内側をくり抜く
            translate([40, -handle_inner_width/2, handle_z - 1]) {
                cube([handle_depth + 1, handle_inner_width, handle_inner_height + 2]);
            }
        }
    }
}

// メイン構造
union() {
    mug();
    handle();
}