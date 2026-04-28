$fn = 60;

module m4_countersunk_hole(t=3) {
    // 基準面(Z=0)を外側表面とし、+Z方向(内側)に穴をあける
    // 貫通穴
    translate([0, 0, -1]) 
        cylinder(h=t + 2, d=4.5);
        
    // 皿座面 (深さ2mmでテーパー)
    // Z=0(外側表面)で直径8mm、Z=2で直径4.5mm
    // 表面が確実に削れるようにマージン±0.1mmを考慮 (1.75 * 0.1 = 0.175)
    translate([0, 0, -0.1]) 
        cylinder(h=2.2, d1=8.175, d2=4.325);
}

difference() {
    union() {
        // 水平面 (外寸 50x40、厚み3)
        // 内側コーナー(0,0,0)を基準とし、外側コーナーは(-3,-3)
        translate([0, -3, -3]) 
            cube([50, 40, 3]);
            
        // 垂直面 (外寸 50x40、厚み3)
        translate([0, -3, -3]) 
            cube([50, 3, 40]);
    }
    
    // 水平面の皿穴
    // Y方向の中心は外寸40の半分=20mm (外端Y=-3から20mm -> Y=17)
    // X方向の縁から10mm -> X=10, 40
    translate([10, 17, -3]) 
        m4_countersunk_hole(3);
    translate([40, 17, -3]) 
        m4_countersunk_hole(3);
        
    // 垂直面の皿穴
    // Z方向の中心は外寸40の半分=20mm (外端Z=-3から20mm -> Z=17)
    // 皿座面が外側(Y=-3)を向くようにX軸を中心に-90度回転
    translate([10, -3, 17]) 
        rotate([-90, 0, 0]) 
        m4_countersunk_hole(3);
    translate([40, -3, 17]) 
        rotate([-90, 0, 0]) 
        m4_countersunk_hole(3);
}