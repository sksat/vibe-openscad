// マグカップの設定
$fn = 100;

module mug() {
    union() {
        // 本体
        difference() {
            cylinder(d = 80, h = 90);
            translate([0, 0, 6])
                cylinder(d = 70, h = 85);
        }

        // 取手
        // 本体外径80mm (半径40mm) の +X 側に配置
        translate([40, 0, 45]) {
            rotate([0, 90, 0]) {
                difference() {
                    // 取手の外形 (D字形状)
                    union() {
                        cylinder(d = 40, h = 10);
                        translate([-20, 0, 0])
                            cube([20, 40, 10]);
                    }
                    // 取手の穴 (高さ30mm x 幅25mm)
                    translate([-20, 5, -1])
                        cube([25, 30, 12]);
                }
            }
        }
    }
}

mug();