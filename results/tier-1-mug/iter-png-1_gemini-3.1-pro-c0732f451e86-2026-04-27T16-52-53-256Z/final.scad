$fn = 100;

difference() {
    union() {
        // カップ外側 (外径80mm -> 半径40mm、高さ100mm)
        cylinder(h = 100, r = 40);
        
        // 取手 (高さ中心 Z=50に配置)
        // 外周から十分にはみ出させるため X=50 へオフセット
        translate([50, 0, 50])
        rotate([90, 0, 0])
        rotate_extrude()
        // 半径12mmのリング状の取手 (断面半径は肉厚に合わせた4mm)
        translate([12, 0, 0])
        circle(r = 4);
    }
    
    // カップ内側 (肉厚4mm -> 内径 半径36mm)
    // 底面の厚み6mmを残して上まで確実にくり抜く
    translate([0, 0, 6])
    cylinder(h = 100, r = 36);
}