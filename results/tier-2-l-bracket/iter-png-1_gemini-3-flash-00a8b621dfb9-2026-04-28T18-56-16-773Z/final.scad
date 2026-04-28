$fn = 64;

// 基本寸法
width = 50;     // 幅 (X方向)
depth = 40;     // 奥行き (Y方向)
height = 40;    // 高さ (Z方向)
thickness = 3;  // 板厚

// 皿穴の寸法 (M4ねじ用)
hole_d = 4.5;   // 貫通穴径
sink_d = 8.0;   // 皿座面最大径
sink_h = 2.0;   // 皿座面深さ

// 配置設定
edge_offset = 10; // 左右の縁からの距離

// 皿穴モジュール (ローカル原点表面から内部に向かって穴を開ける)
module countersunk_hole() {
    // 貫通穴 (中心をずらして確実に貫通させる)
    translate([0, 0, -thickness])
        cylinder(d = hole_d, h = thickness * 3);
    
    // 皿座面 (テーパー部分)
    // 外側から内側へ向かって細くなる円錐
    translate([0, 0, -0.01]) // 表面のチラつき防止
        cylinder(d1 = sink_d, d2 = hole_d, h = sink_h);
}

difference() {
    // L字金具の本体
    union() {
        // 水平面: 内側コーナーが原点、+Y方向に伸びる
        // 板厚分は下に下げる (表面が Z=0)
        translate([0, 0, -thickness])
            cube([width, depth, thickness]);
        
        // 垂直面: 内側コーナーが原点、+Z方向に伸びる
        // 板厚分は奥に下げる (表面が Y=0)
        translate([0, -thickness, 0])
            cube([width, thickness, height]);
    }

    // 水平面の皿穴 (2個)
    // 面の中心線は Y = depth / 2
    for (x = [edge_offset, width - edge_offset]) {
        translate([x, depth / 2, -thickness]) {
            // 0度回転で、Z-3(外側)からZ-1(内側)へ向けて穴が開く
            countersunk_hole();
        }
    }

    // 垂直面の皿穴 (2個)
    // 面の中心線は Z = height / 2
    for (x = [edge_offset, width - edge_offset]) {
        translate([x, -thickness, height / 2]) {
            // X軸周りに-90度回転させ、Y-3(外側)からY-1(内側)へ向けて穴を開ける
            rotate([-90, 0, 0])
                countersunk_hole();
        }
    }
}