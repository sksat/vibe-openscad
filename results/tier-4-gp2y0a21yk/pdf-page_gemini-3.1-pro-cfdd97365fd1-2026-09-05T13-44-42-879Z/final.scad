$fn = 64;

module GP2Y0A21YK0F() {
    // 1. ベースプレート (メインケースと取付耳)
    // 原点(0,0,0)を中心に配置。Z軸は上(レンズ方向)、Y軸は前方(Stamp側)
    difference() {
        union() {
            // メインケース (幅29.5, 奥行13, 厚さ7.2)
            cube([29.5, 13, 7.2], center=true);
            
            // 取付耳 左
            translate([-14.75, 0, 0])
                cylinder(r=3.75, h=7.2, center=true);
            
            // 取付耳 右
            translate([14.75, 0, 0])
                cylinder(r=3.75, h=7.2, center=true);
        }
        
        // 取付穴 左 (φ3.2)
        translate([-14.75, 0, 0])
            cylinder(d=3.2, h=8, center=true);
            
        // 取付穴 右 (φ3.2)
        translate([14.75, 0, 0])
            cylinder(d=3.2, h=8, center=true);
    }

    // 2. レンズ部本体ケース
    difference() {
        union() {
            // 土台部 (高さ1.2)
            translate([0, 0, 3.6 + 0.6])
                cube([26.5, 11, 1.2], center=true);
            
            // レンズケース下段 (高さ2.0)
            translate([-0.25, 0, 4.8 + 1.0])
                cube([25.5, 9.5, 2.0], center=true);

            // レンズケース上段 (高さ4.3)
            translate([-0.25, 0, 6.8 + 2.15])
                cube([24.5, 8.5, 4.3], center=true);
        }
        
        // レンズ窓の窪み
        // 発光側(左) - 矩形 (中心距離 *4.5)
        translate([-10.25, 0, 11.1 - 0.5])
            cube([4.5, 5.5, 1.1], center=true);
            
        // 受光側(右) - 円形 (左レンズからの中心距離 *20)
        translate([9.75, 0, 11.1 - 0.5])
            cylinder(d=6.5, h=1.1, center=true);
    }
    
    // 内部レンズのダミー (窪みの奥)
    translate([-10.25, 0, 11.1 - 1.0])
        cube([3.5, 4.5, 1], center=true);
    translate([9.75, 0, 11.1 - 1.0])
        cylinder(d=5.5, h=1, center=true);

    // 3. ケーブル取り出し部 (PWB / コネクタ)
    difference() {
        union() {
            // PWB (基板)
            translate([0, -9.45, -3.0])
                cube([10.1, 5.9, 1.2], center=true);
            
            // コネクタ本体
            translate([0, -9.45, -1.35])
                cube([10.1, 5.9, 2.1], center=true);
        }
        
        // ケーブル取り出しの切欠き
        translate([0, -11.5, -1.35])
            cube([7.0, 5.0, 2.2], center=true);
    }

    // 4. ケーブル (丸棒で簡易表現)
    for (i = [-1, 0, 1]) {
        translate([i * 2.0, -11.0, -1.8])
            rotate([90, 0, 0])
            cylinder(d=1.2, h=20);
    }
}

GP2Y0A21YK0F();