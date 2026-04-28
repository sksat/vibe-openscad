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
handle_clearance    = 0;    // mm (マグと取手のすき間:0でぴったり)

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
    // D字グリップの円弧半径
    handle_outer_radius = (handle_inner_width + handle_thickness) / 2;
    handle_inner_radius = handle_outer_radius - handle_thickness;

    // ハンドル中心の x 方向座標（マグ外縁+取っ手外半径、隙間なし）
    handle_center_x = mug_radius + handle_outer_radius;

    // ハンドルの中心高さ
    handle_center_z = mug_height / 2;

    // D字部分（半円部分＋上下の直線バー）
    translate([handle_center_x, 0, handle_center_z]) {
        difference() {
            // 外側（D字: 半円弧+直線）
            union() {
                // 半円弧
                rotate([0,90,0])
                    rotate([0,0,90])
                        linear_extrude(height=handle_thickness, center=true)
                            offset(0)
                                arc_points(handle_outer_radius, 180);
                // 上下の直線バー
                for (sign=[-1,1])
                    translate([0, sign*handle_inner_height/2, 0])
                        cube([handle_outer_radius, handle_thickness, handle_thickness], center = true);
            }
            // 内側カット
            union() {
                // 半円弧
                rotate([0,90,0])
                    rotate([0,0,90])
                        linear_extrude(height=handle_thickness+0.2, center=true)
                            offset(0)
                                arc_points(handle_inner_radius, 180);
                // 上下の直線バー
                for (sign=[-1,1])
                    translate([0, sign*handle_inner_height/2, 0])
                        cube([handle_inner_radius+0.2, handle_thickness+0.2, handle_thickness+0.2], center = true);
            }
        }
    }
}

// 2D半円弧のポリゴン（中心始点+極座標）
function arc_points(r, deg=180, steps=64) =
    concat([[0,0]], [for (a = [0 : deg/(steps-1) : deg]) [r*cos(a), r*sin(a)]]);

// マグとハンドルの合成
union() {
    mug_body();
    mug_handle();
}