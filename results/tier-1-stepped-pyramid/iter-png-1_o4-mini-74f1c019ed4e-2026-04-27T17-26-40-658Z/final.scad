// 3段の階段状ピラミッド
union() {
    // 底段
    cube([60, 60, 10], center = false);
    // 中段
    translate([(60-40)/2, (60-40)/2, 10])
        cube([40, 40, 10], center = false);
    // 上段
    translate([(60-20)/2, (60-20)/2, 20])
        cube([20, 20, 10], center = false);
}