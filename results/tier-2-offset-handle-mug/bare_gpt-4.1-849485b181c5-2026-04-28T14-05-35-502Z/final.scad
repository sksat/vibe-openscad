// マグ本体パラメータ
mug_outer_diameter = 80;    // mm
mug_inner_diameter = 70;    // mm
mug_height = 90;            // mm
mug_wall_thickness = 5;     // mm
mug_bottom_thickness = 6;   // mm

// 取手パラメータ
handle_inner_height = 30;   // mm
handle_inner_width  = 25;   // mm
handle_thickness    = 12;   // mm (グリップの厚み)
handle_clearance    = 3;    // mm (マグと取手のすき間:0でぴったり)

// 共通計算
mug_radius = mug_outer_diameter / 2;
mug_inner_radius = mug_inner_diameter / 2;
handle_top = (mug_height + handle_inner_height) / 2;
handle_bottom = (mug_height - handle_inner_height) / 2;
handle_center_y = 0;
handle_center_z = mug_height / 2;

// マグのメインモジュール
module mug_body() {
    difference() {
        // 外側
        cylinder(h = mug_height, r = mug_radius, $fn = 128);
        // 内部空間(底厚分上げる)
        translate([0, 0, mug_bottom_thickness])
            cylinder(h = mug_height - mug_bottom_thickness, r = mug_inner_radius, $fn = 128);
    }
}

// D字ハンドル
module mug_handle() {
    // D字の中心半径: (内幅+厚み)/2
    handle_outer_radius = (handle_inner_width + handle_thickness) / 2;
    handle_inner_radius = handle_inner_width / 2;

    // 上下の位置
    z_pos = mug_height / 2 - handle_inner_height / 2;

    // ハンドル中心(x 座標: 本体外半径 + handle_thickness/2)
    translate([mug_radius + handle_thickness / 2 - handle_clearance, 0, handle_bottom]) {
        // D字全体
        difference() {
            // 外側D
            union() {
                // 半円部分
                rotate([90,0,0])
                    translate([0, 0, handle_inner_height/2])
                        cylinder(h = handle_thickness, r = handle_outer_radius, center=true, $fn=64, segment1=true);
                // 直線部分(上下のバー)
                for (sign=[-1,1])
                    translate([0, sign*(handle_inner_height/2), 0])
                        cube([handle_outer_radius, handle_thickness, handle_thickness], center = true);
            }
            // 内側カット
            union() {
                // 半円部分
                rotate([90,0,0])
                    translate([0, 0, handle_inner_height/2])
                        cylinder(h = handle_thickness+0.1, r = handle_inner_radius, center=true, $fn=64, segment1=true);
                // 直線部分
                for (sign=[-1,1])
                    translate([0, sign*(handle_inner_height/2), 0])
                        cube([handle_inner_radius+0.1, handle_thickness+0.1, handle_thickness+0.1], center = true);
            }
        }
    }
}

// マグとハンドルの合成
union() {
    mug_body();
    mug_handle();
}

// 円柱の半円(セグメント)を描画するための segment1=true 拡張
// OpenSCADの標準 cylinder では使えません。互換目的のヘルパー:
module cylinder(h, r, segment1=false, $fn=64, center=false) {
    if (!segment1)
        builtin_cylinder(h=h, r=r, $fn=$fn, center=center);
    else
        rotate([0,0,90])
            linear_extrude(height=h, center=center)
                offset(0)
                arc(r, 180);
}
module builtin_cylinder(h, r, $fn=64, center=false) {
    // シンプルな円
    if (!center)
        cylinder(h=h, r=r, $fn=$fn);
    else
        translate([0,0,-h/2]) cylinder(h=h, r=r, $fn=$fn);
}
module arc(r, angle) {
    polygon(
        concat(
            [[0,0]],
            [ for (a = [0:angle/($fn-1):angle]) [ r*cos(a), r*sin(a) ] ],
            [[0,0]]
        )
    );
}