// 3段の階段状ピラミッド（底面が z=0 に接するように配置）
translate([0, 0, 5])  cube([60, 60, 10], center=true);
translate([0, 0, 15]) cube([40, 40, 10], center=true);
translate([0, 0, 25]) cube([20, 20, 10], center=true);