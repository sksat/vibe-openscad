$fn = 96;

outer_d   = 80;       // 外径
inner_d   = 70;       // 内径
height    = 90;       // 高さ
bottom_t  = 6;        // 底厚

// 取手パラメータ
h_inner_h = 30;       // 内側空間 高さ
h_inner_w = 25;       // 内側空間 幅
h_thick   = 8;        // 取手の太さ(断面)
h_width   = 12;       // 取手のY方向の幅(板厚)
h_center_z = height / 2;

module body() {
    difference() {
        // 外形
        cylinder(d = outer_d, h = height);
        // 内側の中空部(底厚を残す)
        translate([0, 0, bottom_t])
            cylinder(d = inner_d, h = height - bottom_t + 1);
    }
}

module handle() {
    // D字形:外側半円(楕円弧)、本体側は直線
    // XZ平面内のリングをY軸方向に厚みh_widthで作り、+X側半分のみ残す
    rz_in  = h_inner_h / 2;            // 内側 縦半径 15
    rx_in  = h_inner_w;                // 内側 横半径 25
    rz_out = rz_in + h_thick;          // 外側 縦半径
    rx_out = rx_in + h_thick;          // 外側 横半径

    attach_x = outer_d/2 - 2;          // 本体壁に2mm食い込ませて確実にunion

    translate([attach_x, 0, h_center_z])
        difference() {
            // リング(楕円断面)
            rotate([90, 0, 0])
                translate([0, 0, -h_width/2])
                    linear_extrude(height = h_width)
                        difference() {
                            scale([rx_out/rz_out, 1])
                                circle(r = rz_out);
                            scale([rx_in/rz_in, 1])
                                circle(r = rz_in);
                        }
            // -X側半分を切除(本体側は直線=D字)
            translate([-rx_out*2, -h_width, -rz_out*2])
                cube([rx_out*2, h_width*2, rz_out*4]);
        }
}

union() {
    body();
    handle();
}