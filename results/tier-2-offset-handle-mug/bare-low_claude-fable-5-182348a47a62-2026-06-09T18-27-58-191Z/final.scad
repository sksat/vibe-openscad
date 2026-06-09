$fn = 120;

// パラメータ
outer_d  = 80;
inner_d  = 70;
height   = 90;
bottom_t = 6;

handle_h = 30;   // 取手内側の高さ
handle_w = 25;   // 取手内側の幅
handle_t = 8;    // 取手の太さ
embed    = 5;    // 本体への食い込み量

// マグ本体
module body() {
    difference() {
        cylinder(d = outer_d, h = height);
        translate([0, 0, bottom_t])
            cylinder(d = inner_d, h = height);
    }
}

// D字形 2D 断面(x=0 が本体外壁位置、+x が外側)
module handle_2d() {
    difference() {
        // 外形 D
        hull() {
            translate([-embed, -(handle_h/2 + handle_t)])
                square([0.1, handle_h + 2*handle_t]);
            translate([handle_w - handle_h/2, 0])
                circle(r = handle_h/2 + handle_t);
        }
        // 内側の空間(壁側まで貫通)
        hull() {
            translate([-embed - 1, -handle_h/2])
                square([0.1, handle_h]);
            translate([handle_w - handle_h/2, 0])
                circle(r = handle_h/2);
        }
    }
}

// 取手(+X 側、高さ中央)
module handle() {
    translate([outer_d/2, 0, height/2])
        rotate([90, 0, 0])
            linear_extrude(height = handle_t, center = true)
                handle_2d();
}

// 組み立て
union() {
    body();
    handle();
}