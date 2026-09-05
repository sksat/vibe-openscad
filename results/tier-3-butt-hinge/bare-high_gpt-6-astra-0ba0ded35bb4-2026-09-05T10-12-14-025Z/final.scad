// 小型バット蝶番：180°開いた組立状態
// 単位：mm。ピン中心線はY軸、左板は-X側、右板は+X側。
$fn = 96;

leaf_length    = 30;
leaf_width     = 25;
leaf_thickness = 2;

pin_diameter = 4;
pin_length   = 32;

knuckle_outer_diameter = 8;
pin_radial_clearance   = 0.3;
knuckle_inner_diameter = pin_diameter + 2 * pin_radial_clearance;

knuckle_count = 5;
knuckle_pitch = leaf_length / knuckle_count;

// 各6mm区画の内部境界に設ける回転用の軸方向すきま。
// 最外端はY=0、Y=30を維持する。
axial_clearance = 0.10;

// 板本体と、相手側の筒部との接触を避けるすきま。
leaf_barrel_clearance = 0.20;

screw_diameter       = 3.2;
countersink_diameter = 6;
countersink_depth    = 1;
screw_pitch          = 8;
screw_edge_distance  = 5;

outer_radius = knuckle_outer_diameter / 2;
leaf_inner_x = outer_radius + leaf_barrel_clearance;

// 両板の裏面を筒部下面に合わせ、閉じる方向の回転を可能にする。
leaf_bottom_z = -outer_radius;
leaf_top_z    = leaf_bottom_z + leaf_thickness;

eps = 0.02;
neck_overlap = 0.25;

function section_start(i) =
    i * knuckle_pitch
    + (i == 0 ? 0 : axial_clearance / 2);

function section_end(i) =
    (i + 1) * knuckle_pitch
    - (i == knuckle_count - 1 ? 0 : axial_clearance / 2);

// ローカルの+Z方向を、組立座標の+Y方向へ向ける。
module cylinder_y(diameter, length, y_start) {
    translate([0, y_start, 0])
        rotate([-90, 0, 0])
            cylinder(d = diameter, h = length);
}

module plate_body(side) {
    x_start = side < 0
        ? -leaf_inner_x - leaf_width
        :  leaf_inner_x;

    translate([x_start, 0, leaf_bottom_z])
        cube([leaf_width, leaf_length, leaf_thickness]);
}

// 筒部と板本体を、体積のあるネックで一体化する。
module knuckle_and_neck(side, index) {
    y_start = section_start(index);
    length  = section_end(index) - y_start;
    neck_width = leaf_inner_x + neck_overlap;

    union() {
        cylinder_y(knuckle_outer_diameter, length, y_start);

        translate([
            side < 0 ? -neck_width : 0,
            y_start,
            leaf_bottom_z
        ])
            cube([neck_width, length, leaf_thickness]);
    }
}

// 皿穴は+Z側の板表面から深さ1mm。
// 板表面で直径6mm、テーパ底で直径3.2mm。
module countersunk_hole(x, y) {
    translate([x, y, leaf_bottom_z - eps])
        cylinder(
            d = screw_diameter,
            h = leaf_thickness + 2 * eps
        );

    translate([x, y, leaf_top_z - countersink_depth])
        cylinder(
            h  = countersink_depth + eps,
            d1 = screw_diameter,
            d2 = countersink_diameter
                 + (countersink_diameter - screw_diameter)
                   * eps / countersink_depth
        );
}

module hinge_leaf(side, indices) {
    hole_x = side * (
        leaf_inner_x + leaf_width - screw_edge_distance
    );

    difference() {
        union() {
            plate_body(side);

            for (i = indices)
                knuckle_and_neck(side, i);
        }

        // ネックを含めて直径4.6mmの軸穴を通す。
        cylinder_y(
            knuckle_inner_diameter,
            leaf_length + 2 * eps,
            -eps
        );

        // Y=7,15,23：縦方向8mmピッチ。
        for (offset = [-1, 0, 1])
            countersunk_hole(
                hole_x,
                leaf_length / 2 + offset * screw_pitch
            );
    }
}

module left_leaf() {
    hinge_leaf(-1, [0, 2, 4]);
}

module right_leaf() {
    hinge_leaf(1, [1, 3]);
}

module hinge_pin() {
    // Y=-1～31：筒部の両端から各1mm突出。
    cylinder_y(
        pin_diameter,
        pin_length,
        -(pin_length - leaf_length) / 2
    );
}

// 3パーツを共有軸上に組み立て、180°開いた状態で配置。
color([0.60, 0.63, 0.67])
    left_leaf();

color([0.70, 0.73, 0.77])
    right_leaf();

color([0.82, 0.84, 0.87])
    hinge_pin();