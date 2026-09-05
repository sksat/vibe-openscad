// Sharp GP2Y0D413K0F Distance Sensor Modeling
// Coordinate System: Origin at center of the body. -Z points towards the mounting surface (PWB/Connector side).
// Dimensions are based on the provided outline dimensions in mm.

// --- Parameters based on Outline Dimensions ---
L = 29.45; // Length (mm)
W = 10.1;  // Width (mm)
H = 3.75;  // Thickness/Height (derived from drawing, representing the dimension between mounting features)

// --- Module Definitions ---

// Main Sensor Body
module sensor_body() {
    // The body is centered at the origin (0, 0, 0).
    // Since -Z points to the mounting surface, the body extends in the positive Z direction.
    cube([L, W, H], center = true);
}

// Optional: Representing a simplified connection area or mounting feature if required, 
// but focusing primarily on the main geometry defined by the outline.

// --- Model Execution ---
sensor_body();

// Note: The block diagram features (LED emitter, Output circuit, etc.) are functional representations
// and are not explicitly modeled as physical external features unless specific dimensions for their placement are provided.