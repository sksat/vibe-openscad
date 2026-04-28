$fn = 100;

// マグカップ本体と取手の結合
union() {
    // --- 本体 (Body) ---
    difference() {
        // 外径 80mm, 高さ 90mm の円柱
        cylinder(h=90, d=80);
        
        // 内側の中空部分 (内径 70mm, 底の厚み 6mm)
        translate([0, 0, 6])
            cylinder(h=85, d=70);
    }

    // --- 取手 (Handle) ---
    // 本体外周(X=40)から+X方向に配置、高さ中央(Z=45)に合わせる
    translate([40 - 1, 0, 45]) // 確実に接続するため1mm本体にめり込ませる
    rotate([90, 0, 90])         // X軸方向に向くよう回転
    linear_extrude(height=15, center=true) // 取手自体の厚み(幅)は15mm
    difference() {
        // 取手の外形 (D字の曲線部分)
        // 底辺から25mmの位置を円の中心とし、外側を半円にする
        hull() {
            translate([0, -25]) square([1, 50]); // 本体側の直線
            translate([25, 0]) circle(d=50);     // 外側の半円
        }
        
        // 取手の内側の空間 (高さ 30mm × 幅 25mm)
        translate([0, -15]) square([25, 30]);
    }
}