mug = cylinder(
    radius: 35,
    height: 90,
    center: [120, 60, 40]
)

bottom_layer = circle(radius: 70/2, thickness: 6)
union(mug, bottom_layer)

handle = cylinder(
    radius: 35,
    height: 30,
    center: [120, 60, 90 - 30]
)

union(handle, mug)