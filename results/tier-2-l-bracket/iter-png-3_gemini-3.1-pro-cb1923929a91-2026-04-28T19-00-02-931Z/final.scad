$fn = 60;

module m4_countersunk_hole(t=3) {
    // 基準面(Z=0)を外側表面とし、+Z方向(内側)に貫通させる
    // 貫通穴
    translate([0, 0, -1]) 
        cylinder(h=t + 2, d=4.5);
        
    // 皿座面 (深さ2mmでテーパー)
    // Z=0(外側表面)で直径8mm、Z=2で直径4.5mm
    // 表面が確実に削れるようにマージン±0.1mmを考慮
    translate([0, 0, -0.1]) 
        cylinder(h=2.2, d1=8.175, d2=4.325);
}

difference() {
    union() {
        // 水平面
        // 内側コーナー(0,0,0)から +Y 方向に40mm伸びる
        translate([0, 0, -3]) 
            cube([50, 40, 3]);
            
        // 垂直面
        // 内側コーナー(0,0,0)から +Z 方向に40mm伸びる
        translate([0, -3, 0]) 
            cube([50, 3, 40]);
            
        // 外側コーナーの共有部分
        translate([0, -3, -3]) 
            cube([50, 3, 3]);
    }
    
    // 水平面の皿穴
    // Y方向の中心 (0から40の中心 = 20)
    // X方向の縁から10mm -> X=10, 40
    // 皿座面を下(-Z方向)に向ける
    translate([10, 20, -3]) 
        m4_countersunk_hole(3);
    translate([40, 20, -3]) 
        m4_countersunk_hole(3);
        
    // 垂直面の皿穴
    // Z方向の中心 (0から40の中心 = 20)
    // X方向の縁から10mm -> X=10, 40
    // 皿座面を裏(-Y方向)に向けるように -90度回転
    translate([10, -3, 20]) 
        rotate([-90, 0, 0]) 
        m4_countersunk_hole(3);
    translate([40, -3, 20]) 
        rotate([-90, 0, 0]) 
        m4_countersunk_hole(3);
}