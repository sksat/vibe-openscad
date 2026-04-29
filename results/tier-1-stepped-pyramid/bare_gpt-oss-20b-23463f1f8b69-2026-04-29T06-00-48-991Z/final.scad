$fn = 100;

// 底面（60mm × 60mm）
linear_extrude(height=10)
    square([60, 60], center=true);

// 中段（40mm × 40mm）
translate([0, 0, 10])
    linear_extrude(height=10)
        square([40, 40], center=true);

// 上段（20mm × 20mm）
translate([0, 0, 20])
    linear_extrude(height=10)
        square([20, 20], center=true);