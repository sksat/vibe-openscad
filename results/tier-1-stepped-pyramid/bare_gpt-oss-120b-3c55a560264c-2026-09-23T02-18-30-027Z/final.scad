// 3段階のピラミッド
module step(size, z_center) {
    translate([0, 0, z_center])
        cube([size, size, 10], center = true);
}

// 底辺 60mm の段
step(60, 5);
// 中央の 40mm の段
step(40, 15);
// 上の 20mm の段
step(20, 25);