// OpenSCAD Mug with Handle
// Main Body:
//   Outer Diameter: 80mm (Radius 40mm)
//   Inner Diameter: 70mm (Radius 35mm)
//   Height: 90mm
//   Bottom Thickness: 6mm
// Handle:
//   Attached to +X side
//   D-shape (Outer semicircle, Body side straight line)
//   Inner Space: 30mm height, 25mm width
//   Position: Near vertical center (Z=45)

module mug() {
    // Outer Cylinder
    difference() {
        cylinder(h=90, r=40, center=false);
        
        // Inner Void (Liquid Capacity)
        // Inner Diameter 70mm -> Radius 35mm
        // Bottom Thickness 6mm -> Void starts at Z=6
        cylinder(h=84, r=35, center=false);
    }
}

module handle() {
    // Handle Geometry
    // Position: Center X=40 (Mug Surface), Center Z=45 (Mug Vertical Center)
    // Handle Material Thickness: 15mm (X=40 to 55)
    // Inner Space Width: 25mm (X=55 to 80)
    // Inner Space Height: 30mm (Z=37.5 to 52.5)
    // Outer Handle Height: 35mm (Z=36.25 to 53.75)
    // Handle Width (Y): 20mm (Y=-10 to 10)
    
    // 1. Create Solid Handle Block
    // This block is attached to the mug surface (X=40)
    difference() {
        // Main solid block
        cube([40, 20, 35], center=[40, 0, 45]);
        
        // Inner Void (Finger Space)
        // Width 25mm, Height 30mm
        // Starts at X=55 (after material thickness 15mm)
        // Centered at Z=45
        difference() {
            // Void block
            cube([25, 25, 30], center=[62.5, 0, 45]);
            
            // Rounded corners for D-shape profile (Outer side semicircle)
            // Subtract small cylinders at the top and bottom corners to round the outer edge
            // Radius 5mm, Height 30mm (covering the handle height)
            // Position at the outer edge (X=80, Y=10) and (X=80, Y=-10)
            translate([80, 10, 45]) {
                cylinder(h=30, r=5, center=false);
            }
            translate([80, -10, 45]) {
                cylinder(h=30, r=5, center=false);
            }
        }
    }
}

union() {
    mug();
    translate([40, 0, 0]) {
        handle();
    }
}