// ===== パラメータ =====
outer_d      = 80;   // カップ外径
outer_r      = outer_d / 2;
height       = 100;  // カップ高さ
wall         = 4;    // 側面肉厚
bottom       = 6;    // 底面厚み

inner_r      = outer_r - wall;      // 内径半径 = 36
inner_h      = height - bottom;     // 内側空洞の高さ = 94

// 取手(リング状)
handle_r     = 12;   // リングの半径(穴の中心線半径)
handle_t     = 5;    // リング断面の半径(太さ)
handle_z     = height / 2;          // 取手の高さ位置(中心高さ)
handle_off   = outer_r + handle_r - 6; // リング中心のX位置(カップに食い込ませる)

$fn = 96;

// ===== 本体 =====
module cup_body() {
    difference() {
        cylinder(h = height, r = outer_r);
        translate([0, 0, bottom])
            cylinder(h = inner_h + 1, r = inner_r);
    }
}

// ===== 取手 =====
module handle() {
    translate([handle_off, 0, handle_z])
        rotate([90, 0, 0])
            rotate_extrude(convexity = 10)
                translate([handle_r, 0, 0])
                    circle(r = handle_t);
}

// ===== 組み立て =====
module mug() {
    difference() {
        union() {
            cup_body();
            handle();
        }
        // 取手が内側空洞に突き出さないようにカット
        translate([0, 0, bottom])
            cylinder(h = inner_h + 1, r = inner_r);
    }
}

mug();