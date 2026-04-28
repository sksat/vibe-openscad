$fn = 100;

// マグカップ本体
difference() {
    // 外側の円筒
    cylinder(h = 90, d = 80);
    
    // 内側をくり抜く（上から）
    translate([0, 0, 6]) {
        cylinder(h = 85, d = 70);
    }
}

// 取手（+X軸方向）
translate([40, 0, 45]) {
    difference() {
        // 取手の外形（D字形状の外側部分）
        rotate([0, 90, 0]) {
            rotate_extrude(angle = 180) {
                translate([17.5, 0, 0]) {
                    circle(d = 8);
                }
            }
        }
        
        // 取手の内側をくり抜く
        translate([-5, -12.5, -15]) {
            cube([20, 25, 30]);
        }
    }
    
    // 取手の接続部分（上下）
    translate([0, -17.5, -15]) {
        cube([8, 8, 8]);
    }
    translate([0, -17.5, 15-8]) {
        cube([8, 8, 8]);
    }
    translate([0, 17.5-8, -15]) {
        cube([8, 8, 8]);
    }
    translate([0, 17.5-8, 15-8]) {
        cube([8, 8, 8]);
    }
}

// 取手と本体の接続を強化
translate([35, 0, 45]) {
    difference() {
        scale([1, 1, 2]) {
            rotate([0, 90, 0]) {
                cylinder(h = 10, d = 40);
            }
        }
        
        // 本体の内側部分を除去
        translate([-15, 0, 0]) {
            cylinder(h = 100, d = 70, center = true);
        }
        
        // 取手の穴を維持
        translate([5, -12.5, -15]) {
            cube([20, 25, 30]);
        }
    }
}