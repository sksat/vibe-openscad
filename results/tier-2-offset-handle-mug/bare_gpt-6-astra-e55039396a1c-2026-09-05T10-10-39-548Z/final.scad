$fn = 180;

// 本体寸法（mm）
outer_diameter = 80;
inner_diameter = 70;
mug_height = 90;
bottom_thickness = 6;

// 取手寸法（mm）
handle_opening_height = 30;
handle_opening_width = 25;
handle_depth = 10;
handle_tip_thickness = 4;

outer_radius = outer_diameter / 2;
inner_radius = inner_diameter / 2;

// 本体外周へ 2 mm 食い込ませ、面接触ではなく体積で接続する。
handle_base_x = outer_radius - 2;
handle_opening_x = outer_radius + 1;
handle_center_z = mug_height / 2;

opening_offset = handle_opening_x - handle_base_x;
handle_outer_radius =
    opening_offset + handle_opening_width + handle_tip_thickness;

epsilon = 0.1;

// 直線辺が x=0、半円が +X 側にある D 字。
module half_disk(radius) {
    intersection() {
        circle(r = radius);
        translate([0, -radius])
            square([radius, 2 * radius]);
    }
}

module mug_body() {
    difference() {
        cylinder(h = mug_height, r = outer_radius);

        translate([0, 0, bottom_thickness])
            cylinder(
                h = mug_height - bottom_thickness + epsilon,
                r = inner_radius
            );
    }
}

module handle_profile() {
    difference() {
        // 外側は真円の半円、本体側は直線。
        half_disk(handle_outer_radius);

        // 内側の開口：X 方向 25 mm、高さ方向 30 mm。
        translate([opening_offset, 0])
            scale([
                handle_opening_width,
                handle_opening_height / 2
            ])
                half_disk(1);
    }
}

module handle() {
    // 2D の Y を高さ Z に写し、厚みを Y 方向へ付ける。
    // 取手全体を本体の +X 側だけに配置する。
    translate([handle_base_x, 0, handle_center_z])
        rotate([90, 0, 0])
            linear_extrude(
                height = handle_depth,
                center = true,
                convexity = 10
            )
                handle_profile();
}

render(convexity = 10)
    union() {
        mug_body();
        handle();
    }