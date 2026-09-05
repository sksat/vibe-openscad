// 単位: mm
// ピン中心線: X=0, Z=0（+Y方向）
// 180°開いたとき、両板の表面は Z=-2、裏面は Z=-4。
$fn = 128;

leaf_length    = 30;
leaf_width     = 25;
leaf_thickness = 2;

pin_diameter = 4;
pin_length   = 32;

knuckle_od       = 8;
radial_clearance = 0.3;
knuckle_id       = pin_diameter + 2 * radial_clearance; // 4.6
knuckle_count    = 5;
knuckle_pitch    = leaf_length / knuckle_count;        // 6

// 6mm区画の内側境界に可動用の隙間を設ける。
// 最外端は Y=0,30 に保ち、ピンの突出量を両端1mmにする。
axial_gap = 0.10;

screw_hole_diameter = 3.2;
countersink_diameter = 6;
countersink_depth    = 1;
screw_pitch          = 8;
screw_edge_inset     = 5;

eps = 0.01;

knuckle_radius = knuckle_od / 2;
leaf_inner_x   = knuckle_radius;
leaf_bottom_z  = -knuckle_radius;
leaf_top_z     = leaf_bottom_z + leaf_thickness;


// +Y方向の円柱
module cylinder_y(diameter, length, y_start = 0) {
    translate([0, y_start, 0])
        rotate([-90, 0, 0])
            cylinder(d = diameter, h = length);
}


// +Z側の表面から加工する皿穴
module countersunk_hole() {
    translate([0, 0, leaf_bottom_z - eps])
        cylinder(
            d = screw_hole_diameter,
            h = leaf_thickness + 2 * eps
        );

    // 表面で直径6mm、深さ1mmで直径3.2mmとなるテーパ。
    // 上端のみ延長し、表面位置での指定径を維持する。
    translate([0, 0, leaf_top_z - countersink_depth])
        cylinder(
            h  = countersink_depth + eps,
            d1 = screw_hole_diameter,
            d2 = countersink_diameter
               + (countersink_diameter - screw_hole_diameter)
               * eps / countersink_depth
        );
}


// 筒部と、その筒部を板につなぐ一体のウェブ
module knuckle_with_web(index, side) {
    y0 = index * knuckle_pitch
       + (index == 0 ? 0 : axial_gap / 2);

    y1 = (index + 1) * knuckle_pitch
       - (index == knuckle_count - 1 ? 0 : axial_gap / 2);

    web_x = side < 0 ? -leaf_inner_x - eps : 0;

    union() {
        cylinder_y(
            diameter = knuckle_od,
            length   = y1 - y0,
            y_start  = y0
        );

        translate([web_x, y0, leaf_bottom_z])
            cube([
                leaf_inner_x + eps,
                y1 - y0,
                leaf_thickness
            ]);
    }
}


// side=-1: 左板（区画0,2,4）
// side=+1: 右板（区画1,3）
module leaf(side) {
    body_x = side < 0
           ? -leaf_inner_x - leaf_width
           :  leaf_inner_x;

    screw_x = side
            * (leaf_inner_x + leaf_width - screw_edge_inset);

    difference() {
        union() {
            // 25×30×2の平板本体。
            // 筒部の外側に置き、相手側の筒部との干渉を防ぐ。
            translate([body_x, 0, leaf_bottom_z])
                cube([leaf_width, leaf_length, leaf_thickness]);

            for (i = [0 : knuckle_count - 1])
                if (i % 2 == (side < 0 ? 0 : 1))
                    knuckle_with_web(i, side);
        }

        // ウェブを含めて貫通させ、軸穴を完全に開ける。
        cylinder_y(
            diameter = knuckle_id,
            length   = leaf_length + 2 * eps,
            y_start  = -eps
        );

        // Y=7,15,23、8mmピッチ
        for (n = [-1 : 1])
            translate([
                screw_x,
                leaf_length / 2 + n * screw_pitch,
                0
            ])
                countersunk_hole();
    }
}


module pin() {
    cylinder_y(
        diameter = pin_diameter,
        length   = pin_length,
        y_start  = -(pin_length - leaf_length) / 2
    );
}


// 0°で閉、180°で開。回転中心は共通のY軸。
module hinge(open_angle = 180) {
    color([0.62, 0.65, 0.68])
        leaf(-1);

    color([0.72, 0.75, 0.78])
        rotate([0, open_angle - 180, 0])
            leaf(1);

    color([0.42, 0.45, 0.48])
        pin();
}


hinge(open_angle = 180);