/*
  Sharp GP2Y0A21YK0F
  簡略外形モデル（単位: mm）

  座標系:
    原点 : レンズケース本体の中心
    +X   : 正面から見て右
    +Y   : 上
    +Z   : 光学面側
    -Z   : PWB / コネクタ側

  主なデータシート寸法:
    レンズケース幅       29.5
    レンズケース高さ     13
    レンズケース奥行      6.3
    取付穴ピッチ          37
    取付穴径               3.2
    取付耳外周半径         3.75
    レンズ中心間隔        20
    左レンズ中心位置       4.5（ケース左端から）
    コネクタ幅            10.1
    全高                  18.9
    全奥行（参考）        13.5
*/

$fn = 72;

eps = 0.02;

// 基準寸法
case_w = 29.5;
case_h = 13.0;
case_d = 6.3;

case_front_z =  case_d / 2;
case_rear_z  = -case_d / 2;

hole_pitch = 37.0;
hole_d     = 3.2;
ear_r      = 3.75;

emitter_x  = -case_w / 2 + 4.5;
detector_x = emitter_x + 20.0;

connector_w = 10.1;
connector_h = 18.9 - case_h;
connector_y = -case_h / 2 - connector_h / 2;

overall_depth = 13.5;
connector_rear_z = case_front_z - overall_depth;


// XY面で角を丸めた直方体
module rounded_box_xy(size=[10,10,10], radius=1, center=true)
{
    w = size[0];
    h = size[1];
    d = size[2];

    translate(center ? [0,0,-d/2] : [w/2,h/2,0])
        linear_extrude(height=d)
            offset(r=radius)
                square([w-2*radius, h-2*radius], center=true);
}


// 取付耳を含む背面プレート形状
module mounting_profile_2d()
{
    difference() {
        union() {
            square([case_w, case_h], center=true);

            // 左右の取付耳
            for (x = [-hole_pitch/2, hole_pitch/2])
                translate([x,0])
                    circle(r=ear_r);

            // ケースと取付耳の接続部
            polygon([
                [-case_w/2 + 0.3, -3.0],
                [-hole_pitch/2,   -ear_r],
                [-hole_pitch/2,    ear_r],
                [-case_w/2 + 0.3,  3.0]
            ]);

            polygon([
                [ case_w/2 - 0.3, -3.0],
                [ hole_pitch/2,   -ear_r],
                [ hole_pitch/2,    ear_r],
                [ case_w/2 - 0.3,  3.0]
            ]);
        }

        // 取付穴
        for (x = [-hole_pitch/2, hole_pitch/2])
            translate([x,0])
                circle(d=hole_d);
    }
}


// PWB
module pwb()
{
    pwb_t = 1.2;

    color([0.25, 0.18, 0.08])
        translate([0,0,case_rear_z - pwb_t/2 + 0.5])
            linear_extrude(height=pwb_t, center=true)
                mounting_profile_2d();

    // 背面の小さなランド
    color([0.72, 0.58, 0.24])
        for (x = [-2.5, 0, 2.5])
            translate([
                x,
                connector_y + connector_h/2 - 0.8,
                case_rear_z - pwb_t + 0.48
            ])
                cylinder(d=1.0, h=0.05);
}


// 取付耳を支える樹脂フランジ
module rear_flange()
{
    flange_t = 1.0;

    color([0.055, 0.055, 0.06])
        translate([0,0,case_rear_z + 1.0])
            linear_extrude(height=flange_t, center=true)
                mounting_profile_2d();
}


// レンズケース
module lens_case()
{
    // 主ケース
    color([0.045, 0.045, 0.05])
        translate([0,0,-0.225])
            rounded_box_xy(
                [case_w, case_h, case_d - 0.45],
                radius=0.45,
                center=true
            );

    // 上下の成形リブ
    color([0.035, 0.035, 0.04]) {
        translate([0, case_h/2 - 0.65, 0])
            cube([case_w, 1.3, case_d], center=true);

        translate([0,-case_h/2 + 0.65, 0])
            cube([case_w, 1.3, case_d], center=true);
    }

    // 正面外枠
    color([0.035, 0.035, 0.04])
        translate([0,0,case_front_z - 0.22])
            rounded_box_xy([27.7, 9.4, 0.48], 0.45, true);

    // レンズ間の凹面
    color([0.10, 0.10, 0.105])
        translate([0,0,case_front_z + 0.035])
            rounded_box_xy([25.9, 7.7, 0.18], 0.25, true);

    // 中央の仕切り
    color([0.035, 0.035, 0.04])
        translate([-0.25,0,case_front_z + 0.18])
            cube([1.0, 7.8, 0.55], center=true);
}


// 光学レンズ1個分
module optical_lens(xpos, lens_d=6.7)
{
    // レンズ保持リング
    color([0.025, 0.025, 0.028])
        translate([xpos,0,case_front_z - 0.05])
            difference() {
                cylinder(d=lens_d + 1.35, h=0.58);
                translate([0,0,-eps])
                    cylinder(d=lens_d, h=0.58 + 2*eps);
            }

    // レンズ外周の薄い縁
    color([0.35, 0.37, 0.35])
        translate([xpos,0,case_front_z + 0.02])
            difference() {
                cylinder(d=lens_d, h=0.20);
                translate([0,0,-eps])
                    cylinder(d=lens_d - 0.45, h=0.20 + 2*eps);
            }

    // 凸レンズ
    color([0.72, 0.78, 0.76, 0.55])
        translate([xpos,0,case_front_z + 0.02])
            scale([1,1,0.20])
                sphere(d=lens_d - 0.25);
}


// 3ピンコネクタ
module connector()
{
    outer_d = abs(connector_rear_z -
                  (case_rear_z - 0.60));

    front_z = case_rear_z - 0.60;
    rear_z  = connector_rear_z;
    center_z = (front_z + rear_z) / 2;

    wall = 1.0;
    cavity_w = connector_w - 2*wall;
    cavity_h = connector_h - 2*wall;

    // コネクタハウジング
    color([0.88, 0.86, 0.77])
        difference() {
            translate([0,connector_y,center_z])
                cube([connector_w, connector_h, outer_d],
                     center=true);

            // -Z側に開いた差込口
            translate([
                0,
                connector_y,
                rear_z + (outer_d-wall)/2 - eps
            ])
                cube([
                    cavity_w,
                    cavity_h,
                    outer_d-wall + 2*eps
                ], center=true);
        }

    // 開口内部
    color([0.12, 0.12, 0.105])
        translate([
            0,
            connector_y,
            rear_z + (outer_d-wall)/2 - 0.05
        ])
            cube([
                cavity_w,
                cavity_h,
                outer_d-wall
            ], center=true);

    // 3本の端子
    color([0.72, 0.72, 0.67])
        for (x = [-2.5, 0, 2.5])
            translate([
                x,
                connector_y,
                (rear_z + front_z)/2 - 0.25
            ])
                cube([0.52, 0.52, outer_d-1.8], center=true);

    // コネクタ上部の保持部
    color([0.91, 0.89, 0.80])
        translate([
            0,
            connector_y + connector_h/2 - 0.7,
            front_z - 0.8
        ])
            cube([connector_w-2.0, 1.4, 1.6], center=true);
}


// ケース背面の補強部
module rear_support()
{
    color([0.045, 0.045, 0.05]) {
        // コネクタ基部
        translate([
            0,
            connector_y + 0.7,
            case_rear_z - 0.25
        ])
            rounded_box_xy(
                [connector_w + 1.0, connector_h - 1.4, 1.5],
                0.35,
                true
            );

        // 左右の三角状補強を角柱で近似
        hull() {
            translate([-case_w/2 + 1.0, -case_h/2 + 0.8,
                       case_rear_z + 0.4])
                cube([2.0, 1.6, 1.0], center=true);

            translate([-connector_w/2 - 0.5,
                       connector_y + connector_h/2 - 0.5,
                       case_rear_z - 0.2])
                cube([1.0, 1.0, 1.0], center=true);
        }

        hull() {
            translate([case_w/2 - 1.0, -case_h/2 + 0.8,
                       case_rear_z + 0.4])
                cube([2.0, 1.6, 1.0], center=true);

            translate([connector_w/2 + 0.5,
                       connector_y + connector_h/2 - 0.5,
                       case_rear_z - 0.2])
                cube([1.0, 1.0, 1.0], center=true);
        }
    }
}


// 完成モデル
module GP2Y0A21YK0F()
{
    rear_flange();
    pwb();
    lens_case();
    rear_support();
    connector();

    optical_lens(emitter_x,  6.8);
    optical_lens(detector_x, 7.1);
}

GP2Y0A21YK0F();