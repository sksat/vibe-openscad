// M8 六角ボルト（ねじ山省略）
// 頭部底面が z=0、シャンクは z<0 側へ伸びる
r = 13 / sqrt(3); // 六角形の外接円半径（対辺距離13mm に対応）
head_height = 5.3;
shank_d = 8;
shank_h = 30;

union() {
    // 六角頭部（底面 z=0 -> 天面 z=head_height）
    linear_extrude(height = head_height)
        circle(r = r, $fn = 6);

    // シャンク（上面 z=0、下面 z=-shank_h）
    translate([0, 0, -shank_h])
        cylinder(h = shank_h, r = shank_d / 2, $fn = 64);
}