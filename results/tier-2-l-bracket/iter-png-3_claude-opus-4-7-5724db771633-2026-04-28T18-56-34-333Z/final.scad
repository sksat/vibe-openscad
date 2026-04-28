// L-bracket with countersunk holes

$fn = 64;

// Parameters
width     = 50;   // X direction (幅)
depth     = 40;   // Y direction (水平面の奥行き)
height    = 40;   // Z direction (垂直面の高さ)
thickness = 3;    // 板厚

hole_dia    = 4.5;
csk_dia     = 8;
csk_depth   = 2;
edge_offset = 10;

eps = 0.05;

// 各面の「中心線」= 奥行き/高さ方向の中央線。
// その上に、幅方向で縁から 10mm 内側に左右対称な 2 点。
x_a = edge_offset;          // 10
x_b = width - edge_offset;  // 40

// 水平面: 中心線は y = depth/2
y_center = depth / 2;
// 垂直面: 中心線は z = height/2
z_center = height / 2;

module l_bracket() {
    difference() {
        union() {
            // 水平フランジ: 内側(上)面が z=0、+Y 方向に伸びる
            translate([0, 0, -thickness])
                cube([width, depth, thickness]);

            // 垂直フランジ: 内側面が y=0、+Z 方向に伸びる
            // コーナー部 (z: -thickness..0) も含めて一体化
            translate([0, -thickness, -thickness])
                cube([width, thickness, height + thickness]);
        }

        // --- 水平フランジの穴 (軸は Z 方向) ---
        // 外側(ボルト頭側)は -Z 面なので、そちらに皿座面
        for (x = [x_a, x_b]) {
            translate([x, y_center, 0]) {
                // 貫通穴
                translate([0, 0, -thickness - eps])
                    cylinder(d = hole_dia, h = thickness + 2*eps);
                // 皿座面 (外側 = -Z 面側)
                translate([0, 0, -thickness - eps])
                    cylinder(d = csk_dia, h = csk_depth + eps);
            }
        }

        // --- 垂直フランジの穴 (軸は Y 方向) ---
        // 外側は -Y 面なので、そちらに皿座面
        for (x = [x_a, x_b]) {
            translate([x, 0, z_center]) {
                // 貫通穴 (Y 方向)
                translate([0, eps, 0])
                    rotate([90, 0, 0])
                        cylinder(d = hole_dia, h = thickness + 2*eps);
                // 皿座面 (外側 = -Y 面側)
                translate([0, -thickness + csk_depth + eps, 0])
                    rotate([90, 0, 0])
                        cylinder(d = csk_dia, h = csk_depth + eps);
            }
        }
    }
}

l_bracket();