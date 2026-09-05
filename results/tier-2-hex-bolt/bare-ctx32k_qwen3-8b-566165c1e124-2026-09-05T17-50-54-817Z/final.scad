r = 13 / sqrt(3);
head_height = 5.3;
shaft_radius = 4; // diameter 8mm
shaft_length = 30;

union() {
    linear_extrude(height=head_height, $fn=6)
        polygon(points=[
            [r, 0],
            [r * cos(60), r * sin(60)],
            [-r * cos(60), r * sin(60)],
            [-r, 0],
            [-r * cos(60), -r * sin(60)],
            [r * cos(60), -r * sin(60)]
        ]);
    translate([0, 0, -15])
        cylinder(r=shaft_radius, h=shaft_length, $fn=20);
}