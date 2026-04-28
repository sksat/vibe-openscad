$fn = 100;

// マグ本体のパラメータ
outer_d = 80;
inner_d = 70;
height = 90;
bottom_thick = 6;

// 取手のパラメータ
handle_inner_h = 30;
handle_inner_w = 25;
handle_thick = 10;

// マグ本体の作成
module mug_body() {
    difference() {
        cylinder(d = outer_d, h = height);
        translate([0, 0, bottom_thick])
            cylinder(d = inner_d, h = height - bottom_thick + 0.1);
    }
}

// 取手の作成
module handle() {
    handle_outer_w = handle_inner_w + 2 * handle_thick;
    handle_total_h = handle_inner_h + 2 * handle_thick;
    
    translate([outer_d / 2 - 1, 0, height / 2]) {
        rotate([0, 90, 0]) {
            difference() {
                // 外側の形状 (D字の背にあたる半円と長方形)
                union() {
                    translate([0, 0, -handle_total_h / 2])
                        cylinder(d = handle_outer_w, h = handle_total_h);
                    translate([0, -handle_outer_w / 2, -handle_total_h / 2])
                        cube([handle_outer_w / 2, handle_outer_w, handle_total_h]);
                }
                // 内側の空間 (D字の穴)
                union() {
                    translate([0, 0, -handle_inner_h / 2])
                        cylinder(d = handle_inner_w, h = handle_inner_h);
                    translate([0, -handle_inner_w / 2, -handle_inner_h / 2])
                        cube([handle_inner_w / 2, handle_inner_w, handle_inner_h]);
                }
                // マグ本体との接続面をフラットにするための切り取り
                translate([-handle_outer_w, -handle_outer_w, -handle_total_h])
                    cube([handle_outer_w, handle_outer_w * 2, handle_total_h * 2]);
            }
        }
    }
}

union() {
    mug_body();
    handle();
}