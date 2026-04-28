// L字金具のパラメータ
horizontal_width = 50;
horizontal_depth = 40;
vertical_width = 50;
vertical_height = 40;
thickness = 3;

// 皿穴のパラメータ
through_hole_dia = 4.5;
countersink_dia = 8;
countersink_depth = 2;
hole_offset = 10;

module countersunk_hole() {
    // 貫通穴
    cylinder(h = thickness + 0.1, d = through_hole_dia, center = false, $fn = 32);
    // 皿座面
    cylinder(h = countersink_depth, d = countersink_dia, center = false, $fn = 32);
}

difference() {
    union() {
        // 水平面
        translate([0, 0, 0])
            cube([horizontal_width, horizontal_depth, thickness]);
        
        // 垂直面
        translate([0, 0, 0])
            cube([vertical_width, thickness, vertical_height]);
    }
    
    // 水平面の皿穴（下から上に向けて穴あけ、皿座面は下側）
    translate([horizontal_width/2 - (horizontal_width/2 - hole_offset), horizontal_depth - hole_offset, -0.05])
        countersunk_hole();
    translate([horizontal_width/2 + (horizontal_width/2 - hole_offset), horizontal_depth - hole_offset, -0.05])
        countersunk_hole();
    
    // 垂直面の皿穴（前から後ろに向けて穴あけ、皿座面は前側）
    translate([vertical_width/2 - (vertical_width/2 - hole_offset), thickness + 0.05, vertical_height - hole_offset])
        rotate([90, 0, 0])
            countersunk_hole();
    translate([vertical_width/2 + (vertical_width/2 - hole_offset), thickness + 0.05, vertical_height - hole_offset])
        rotate([90, 0, 0])
            countersunk_hole();
}