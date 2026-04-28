$fn = 100;

// マグカップ全体
union() {
    // --- 1. 本体 (Body) ---
    difference() {
        // 外径 80mm (半径 40mm), 高さ 90mm
        cylinder(h=90, r=40);
        
        // 内側の中空化 (内径 70mm/半径 35mm, 底面の厚み 6mm)
        // 確実に上部を突き抜けるよう、高さは本体より少し高く設定
        translate([0, 0, 6])
            cylinder(h=85, r=35);
    }

    // --- 2. 取手 (Handle) ---
    // 本体外周(X=40)から+X方向に配置、高さ方向の中央(Z=45)に配置
    translate([39, 0, 45]) // 1mm本体にめり込ませて確実に結合(union)させる
    rotate([90, 0, 90])    // 2D図面を立ててX軸方向に向ける
    linear_extrude(height=12, center=true) // 取手自体の厚み(幅)は12mm
    difference() {
        // 取手の外形: D字形状 (外側が半径25mmの半円、本体側が直線)
        hull() {
            translate([0, -25]) square([1, 50]); // 本体側の平らな面
            translate([10, 0]) circle(r=25);     // 外側の膨らみ
        }
        
        // 取手の内側の空間: 指定された 30mm(高さ) × 25mm(幅)
        // 位置を調整して指が入るスペースを確保
        translate([0, -15]) square([25, 30]);
    }
}