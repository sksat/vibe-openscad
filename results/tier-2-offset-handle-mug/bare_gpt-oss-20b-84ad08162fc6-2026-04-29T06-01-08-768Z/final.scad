// マグカップ本体
module body() {
    outer_radius = 40;   // 外径80mm / 2
    inner_radius = 35;   // 内径70mm / 2
    height      = 90;
    bottom_thick= 6;

    difference() {
        // 本体（底厚み含む）
        cylinder(r=outer_radius, h=height, $fn=100);

        // 内側を空洞化（底は残すためz=bottom_thickから抜く）
        translate([0,0,bottom_thick])
            cylinder(r=inner_radius, h=height-bottom_thick, $fn=100);
    }
}

// 取手
module handle() {
    // D字形状の2Dプロファイル（外側半円＋内側直線）
    // 半円半径15mm、内部空間高さ30mm、幅25mm
    outer_radius = 15;
    inner_h     = 30;
    inner_w     = 25;

    // 外側半円（左端をx=0に置く）
    outer_semi = offset(r=outer_radius)
                    circle(r=outer_radius, $fn=100);

    // 内部空間（矩形）→外側半円から差し引く
    inner_rect = square([inner_w, inner_h], center=true);
    translate([0, -inner_h/2 + outer_radius]) inner_rect;

    profile = difference() {
        outer_semi;
        inner_rect;
    };

    // 厚み10mmで押し出す
    linear_extrude(height=10, $fn=50) profile;
}

// 取手の配置（+X側に接続）
module positioned_handle() {
    handle_offset = body_radius + outer_radius; // 本体外周＋半円半径
    translate([handle_offset, 0, (90-30)/2]) rotate([0,0,-90])
        handle();
}

// マニフォールドを保つために union
module mug_with_handle() {
    union() {
        body();
        positioned_handle();
    }
}

mug_with_handle();