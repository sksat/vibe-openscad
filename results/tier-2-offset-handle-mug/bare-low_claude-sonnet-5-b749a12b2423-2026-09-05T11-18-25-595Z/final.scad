// マグカップ本体 + 取手

$fn = 100;

outer_d = 80;
inner_d = 70;
height = 90;
bottom_thickness = 6;

module mug_body() {
    difference() {
        cylinder(d=outer_d, h=height);
        translate([0, 0, bottom_thickness])
            cylinder(d=inner_d, h=height - bottom_thickness + 1);
    }
}

// 取手パラメータ
handle_inner_h = 30; // 内側空間の高さ
handle_inner_w = 25; // 内側空間の幅(本体からの突き出し方向)
handle_thickness = 8; // 取手の太さ(D字の厚み)
handle_center_z = height / 2;

module handle() {
    outer_r = outer_d / 2;
    // D字形状の取手を、Y-Z平面上に断面として描き、X方向に押し出す
    // 外側:半円、本体側:直線 のD字形状を2Dで作り、linear_extrudeでX方向に厚みを持たせる

    // 外形の半径(内側空間 + 厚み)
    total_w = handle_inner_w + handle_thickness * 2;
    total_h = handle_inner_h + handle_thickness * 2;

    module d_shape(w, h) {
        // D字:上下は半円、本体側は直線でつながる断面(Y-Z平面, 原点は中心)
        r = h / 2;
        union() {
            // 半円部分(外側)
            translate([w - r - (w/2 - r), 0])
                circle(r = r);
            // 直線部分(本体側の矩形)
            translate([-(w/2), -r])
                square([w/2, h]);
        }
    }

    // outer d-shape
    module outer_dshape() {
        translate([0,0,0])
        d_shape(total_w, total_h);
    }

    // inner d-shape (穴)
    module inner_dshape() {
        d_shape(handle_inner_w, handle_inner_h);
    }

    // 2D形状をX軸方向へ厚み分押し出す(取手の厚み方向はX軸)
    translate([outer_r - 1, 0, handle_center_z])
        rotate([0, 90, 0])
            linear_extrude(height = handle_thickness, center = false)
                difference() {
                    outer_dshape();
                    inner_dshape();
                }
}

module mug() {
    union() {
        mug_body();
        handle();
    }
}

mug();