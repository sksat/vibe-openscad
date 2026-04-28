// L字ブラケット(L-bracket) OpenSCAD コード

// パラメータ
width = 50;   // フランジ幅 [mm]
depth = 40;   // 水平フランジ奥行 or 垂直フランジ高さ [mm]
thickness = 3; // 板厚 [mm]

hole_d = 4.5;    // M4用穴径 [mm]
csk_d = 8;       // 皿座面径 [mm]
csk_depth = 2;   // 皿座面深さ [mm]
edge_offset = 10; // フランジ縁から皿穴中心までの距離 [mm]

// 皿穴位置: フランジ中心線上で左右対称
hole_y = [edge_offset, depth - edge_offset];
hole_x = width / 2;

// モジュール：M4用皿穴（外側から掘る）
module countersunk_hole() {
    // 皿座面
    translate([0,0,-csk_depth])
        cylinder(h=csk_depth, d=csk_d, $fn=50);
    // 貫通穴
    cylinder(h=thickness+0.1, d=hole_d, $fn=30);
}

// モジュール: 水平面
module horizontal_flange() {
    difference() {
        // 基本板
        cube([width, depth, thickness]);
        // 皿穴: Y方向(奥行き)の2箇所
        for (y_pos = hole_y)
            translate([hole_x, y_pos, thickness])
                // 水平方向の面は上から(外側)に座掘り
                rotate([180,0,0])
                    countersunk_hole();
    }
}

// モジュール: 垂直面
module vertical_flange() {
    difference() {
        // 基本板
        cube([width, thickness, depth]);
        // 皿穴: Z方向(高さ)の2箇所
        for (z_pos = hole_y)
            translate([hole_x, thickness, z_pos])
                // 垂直面の外側はY+方向
                rotate([90,0,0])
                    countersunk_hole();
    }
}

// 組み立て: 原点が内側コーナー
horizontal_flange();
// 垂直面は Z方向へ、Y方向に厚み分だけずらす
translate([0, thickness, 0])
    rotate([-90,0,0])
        vertical_flange();