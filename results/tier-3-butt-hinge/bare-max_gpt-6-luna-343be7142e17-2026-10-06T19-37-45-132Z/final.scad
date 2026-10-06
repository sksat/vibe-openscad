$fn = 96;

// 基本寸法
HINGE_LENGTH = 30;
LEAF_WIDTH = 25;
LEAF_THICKNESS = 2;

PIN_DIAMETER = 4;
PIN_END_PROTRUSION = 1;
PIN_LENGTH = HINGE_LENGTH + 2 * PIN_END_PROTRUSION;

BARREL_OUTER_DIAMETER = 8;
BARREL_INNER_DIAMETER = 4.6;

NUM_SEGMENTS = 5;
SEGMENT_LENGTH = HINGE_LENGTH / NUM_SEGMENTS;

THROUGH_HOLE_DIAMETER = 3.2;
COUNTERSINK_DIAMETER = 6;
COUNTERSINK_DEPTH = 1;
SCREW_PITCH = 8;
SCREW_Y_POSITIONS = [
    HINGE_LENGTH / 2 - SCREW_PITCH,
    HINGE_LENGTH / 2,
    HINGE_LENGTH / 2 + SCREW_PITCH
];

// 穴は板の自由端から5mm内側に配置
SCREW_EDGE_MARGIN = 5;
SCREW_X_FROM_AXIS =
    BARREL_OUTER_DIAMETER / 2 + LEAF_WIDTH - SCREW_EDGE_MARGIN;

// 板と各 knuckle を接続する小さな重なり
WEB_OVERLAP = 0.5;
WEB_WIDTH = 1;
BORE_EPSILON = 0.02;

// 円柱の軸を +Y 方向に向ける。中心線は X=0, Z=0。
module cylinder_along_y(y_start, length, radius) {
    translate([0, y_start, 0])
        rotate([-90, 0, 0])
            cylinder(h=length, r=radius, center=false);
}

// 中空 knuckle
module knuckle_segment(y_start) {
    difference() {
        cylinder_along_y(
            y_start,
            SEGMENT_LENGTH,
            BARREL_OUTER_DIAMETER / 2
        );

        // 穴を両端よりわずかに延長し、端面の膜を残さない
        cylinder_along_y(
            y_start - BORE_EPSILON,
            SEGMENT_LENGTH + 2 * BORE_EPSILON,
            BARREL_INNER_DIAMETER / 2
        );
    }
}

// side=-1 が左板、side=+1 が右板
module hinge_leaf(side) {
    difference() {
        union() {
            // 板本体。厚さ方向は Z、両板とも Z=0 を中心に配置。
            if (side < 0) {
                translate([
                    -BARREL_OUTER_DIAMETER / 2 - LEAF_WIDTH,
                    0,
                    -LEAF_THICKNESS / 2
                ])
                    cube([LEAF_WIDTH, HINGE_LENGTH, LEAF_THICKNESS]);
            } else {
                translate([
                    BARREL_OUTER_DIAMETER / 2,
                    0,
                    -LEAF_THICKNESS / 2
                ])
                    cube([LEAF_WIDTH, HINGE_LENGTH, LEAF_THICKNESS]);
            }

            // 左板は区画0,2,4、右板は区画1,3を受け持つ
            for (segment = [0 : NUM_SEGMENTS - 1]) {
                if (
                    (side < 0 && (segment % 2) == 0) ||
                    (side > 0 && (segment % 2) == 1)
                ) {
                    knuckle_segment(segment * SEGMENT_LENGTH);

                    // 対応する knuckle にだけ接続 web を付ける
                    translate([
                        side * BARREL_OUTER_DIAMETER / 2 - WEB_OVERLAP,
                        segment * SEGMENT_LENGTH,
                        -LEAF_THICKNESS / 2
                    ])
                        cube([
                            WEB_WIDTH,
                            SEGMENT_LENGTH,
                            LEAF_THICKNESS
                        ]);
                }
            }
        }

        // M3 貫通穴と、+Z 側表面の皿穴
        for (hole_y = SCREW_Y_POSITIONS) {
            translate([side * SCREW_X_FROM_AXIS, hole_y, 0])
                cylinder(
                    h=LEAF_THICKNESS + 0.2,
                    d=THROUGH_HOLE_DIAMETER,
                    center=true
                );

            translate([
                side * SCREW_X_FROM_AXIS,
                hole_y,
                LEAF_THICKNESS / 2 - COUNTERSINK_DEPTH
            ])
                cylinder(
                    h=COUNTERSINK_DEPTH,
                    r1=THROUGH_HOLE_DIAMETER / 2,
                    r2=COUNTERSINK_DIAMETER / 2,
                    center=false
                );
        }
    }
}

// 組み立て状態：両板を180°開き、ピンを共有
color([0.72, 0.74, 0.77])
    hinge_leaf(-1);

color([0.80, 0.81, 0.83])
    hinge_leaf(1);

color([0.55, 0.57, 0.60])
    cylinder_along_y(
        -PIN_END_PROTRUSION,
        PIN_LENGTH,
        PIN_DIAMETER / 2
    );