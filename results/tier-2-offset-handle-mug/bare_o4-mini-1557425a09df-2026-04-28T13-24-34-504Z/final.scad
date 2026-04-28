$fn = 100;

module mug() {
    difference() {
        // 外筒
        cylinder(d = 80, h = 90);
        // 飲み口内側
        translate([0, 0, 6])
            cylinder(d = 70, h = 84);
    }
}

module handle() {
    // 取手断面を2Dポリゴンで作成し、Y方向に押し出す
    linear_extrude(height = 10, center = true) {
        polygon(points = [
            for (i = [-90 : 3 : 90])
                [ 40 + 25 * cos(i * PI/180), 45 + 15 * sin(i * PI/180) ]
        ]);
    }
}

union() {
    mug();
    handle();
}