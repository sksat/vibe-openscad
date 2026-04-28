// マグカップの本体
module mug_body() {
    // 外側の円筒
    cylinder(h = 90, r = 40, center = false);
}

// マグカップの空洞(取手との干渉を避けるため)
module mug_hollow() {
    // 内側の空洞(高さ84mm分)
    translate([0, 0, 6]) {
        cylinder(h = 84, r = 35, center = false);
    }
}

// D字形の取手
module handle() {
    // 取手の寸法
    handle_inner_height = 30;  // 指が入る高さ
    handle_inner_width = 25;   // 指が入る幅(内側)
    
    // 取手の外側半径(本体外周から延びる)
    handle_outer_radius = 50;  // マグ外径40mm + 取手の厚さで約50mm
    
    // 取手の開始高さ(マグの高さ方向中央付近)
    handle_z_start = 30;  // 高さ30mmから開始
    
    // 取手を X > 0 の側面に配置
    // 外側が半円、本体側が直線のD字形
    
    difference() {
        // 外側の半円柱と本体接続部分
        union() {
            // 外側の半円部分
            translate([0, 0, handle_z_start]) {
                difference() {
                    // 大きな円筒の一部
                    cylinder(h = handle_inner_height, r = handle_outer_radius, center = false);
                    // マグ本体の外径より内側を削除
                    cylinder(h = handle_inner_height, r = 40, center = false);
                    // X < 0 の部分を削除(+X方向のみに取手を配置)
                    translate([-100, -100, -1]) {
                        cube([100, 200, handle_inner_height + 2]);
                    }
                }
            }
            // マグ本体と取手の接続部分
            translate([0, 0, handle_z_start]) {
                // X軸方向の厚みを持つ接続ブロック
                translate([0, -5, 0]) {
                    cube([handle_outer_radius - 40, 10, handle_inner_height]);
                }
            }
        }
        
        // 取手の内側をくり抜く(D字形の直線部分)
        translate([40, -handle_inner_width/2, handle_z_start]) {
            cube([handle_outer_radius - 40 + 1, handle_inner_width, handle_inner_height]);
        }
    }
}

// メイン処理
difference() {
    union() {
        // マグカップ本体
        mug_body();
        // 取手
        handle();
    }
    // マグカップの空洞
    mug_hollow();
}