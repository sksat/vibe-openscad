// 3段の階段状ピラミッド
// 各段は中心を揃えて積み上げる

// 1段目: 60 x 60 x 10
translate([0, 0, 0])
    cube([60, 60, 10], center=true);

// 2段目: 40 x 40 x 10
translate([0, 0, 10])
    cube([40, 40, 10], center=true);

// 3段目: 20 x 20 x 10
translate([0, 0, 20])
    cube([20, 20, 10], center=true);