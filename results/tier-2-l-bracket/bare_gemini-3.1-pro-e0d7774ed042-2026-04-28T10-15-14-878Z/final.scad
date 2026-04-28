$fn = 60;

module countersunk_hole() {
    // 貫通穴 (マージンを含めて少し長く配置)
    translate([0, 0, -4]) 
        cylinder(h=6, d=4.5);
        
    // 皿座面 (Z=-3が外側表面、深さ2mmでZ=-1までテーパー)
    // 表面が確実に削れるよう外側に0.1mmマージンを持たせるため、d1を計算して拡張
    translate([0, 0, -3.1]) 
        cylinder(h=2.1, d1=8 + (8 - 4.5) * (0.1 / 2), d2=4.5);
}

difference() {
    union() {
        // 水平面 (内側コーナーから+Y方向に40mm、コーナー部の厚み3mm分を含む)
        translate([0, -3, -3]) 
            cube([50, 43, 3]);
            
        // 垂直面 (内側コーナーから+Z方向に40mm)
        translate([0, -3, 0]) 
            cube([50, 3, 40]);
    }
    
    // 水平面の皿穴 (Y方向の中心20mm、X方向の縁から10mm)
    translate([10, 20, 0]) 
        countersunk_hole();
    translate([40, 20, 0]) 
        countersunk_hole();
        
    // 垂直面の皿穴 (Z方向の中心20mm、X方向の縁から10mm)
    // 皿座面が外側(Y=-3)を向くようにX軸を中心に-90度回転
    translate([10, 0, 20]) 
        rotate([-90, 0, 0]) 
        countersunk_hole();
    translate([40, 0, 20]) 
        rotate([-90, 0, 0]) 
        countersunk_hole();
}