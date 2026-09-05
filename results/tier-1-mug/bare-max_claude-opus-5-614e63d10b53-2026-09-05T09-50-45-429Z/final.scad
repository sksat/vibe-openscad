// ===== マグカップ =====
// 外径 80mm / 高さ 100mm / 肉厚 4mm / 底厚 6mm
// 取手: リング状(トーラス)、リング半径 12mm

$fn = 128;

outer_d      = 80;    // カップ外径
outer_r      = outer_d / 2;
cup_h        = 100;   // カップ全高
wall         = 4;     // 側面肉厚
bottom_t     = 6;     // 底面厚み
inner_r      = outer_r - wall;   // 内径半径 36mm

// 取手パラメータ
handle_ring_r  = 12;   // リング(穴)の半径 = 指を通す穴の半径
handle_tube_r  = 5;    // 取手の断面(パイプ)半径
handle_z       = cup_h / 2;                       // 中心高さに配置
handle_x       = outer_r + handle_ring_r - 4;     // 外周に少し食い込ませて接合

module cup_body() {
    difference() {
        // 外形
        cylinder(h = cup_h, r = outer_r);
        // 内側くり抜き(底厚 6mm を残す)
        translate([0, 0, bottom_t])
            cylinder(h = cup_h - bottom_t + 1, r = inner_r);
    }
}

module handle() {
    // Y軸まわりに立てたトーラス(カップ側面から水平に飛び出すリング)
    translate([handle_x, 0, handle_z])
        rotate([90, 0, 0])
            rotate_extrude(angle = 360)
                translate([handle_ring_r, 0, 0])
                    circle(r = handle_tube_r);
}

module mug() {
    union() {
        cup_body();
        // 取手はカップ内部に貫通しないようにカット
        difference() {
            handle();
            // 内側の空洞に飛び出した分を除去
            translate([0, 0, -1])
                cylinder(h = cup_h + 2, r = inner_r);
        }
    }
}

mug();