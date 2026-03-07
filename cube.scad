// Hollow Cube - 20mm outer size
// Adjust wall_thickness to change shell thickness

outer_size    = 20;   // mm
wall_thickness = 2;   // mm
inner_size    = outer_size - (wall_thickness * 2);

hole_diameter   = 10;  // mm - circular hole (top to bottom)
square_hole_size = 5;  // mm - square hole side (right to left)
triangle_side   = 10;  // mm - equilateral triangle hole side (front to back)

difference() {
    // Outer cube
    cube(outer_size, center = true);

    // Inner cube (hollow cavity)
    cube(inner_size, center = true);

    // Vertical circular hole through top to bottom
    cylinder(h = outer_size + 1, r = hole_diameter / 2, center = true, $fn = 64);

    // Square hole from right to left (along X axis)
    cube([outer_size + 1, square_hole_size, square_hole_size], center = true);

    // Equilateral triangle hole from front to back (along Y axis)
    rotate([90, 0, 0])
        linear_extrude(height = outer_size + 1, center = true)
            polygon([
                [-triangle_side/2, -triangle_side*sqrt(3)/6],
                [ triangle_side/2, -triangle_side*sqrt(3)/6],
                [0,                 triangle_side*sqrt(3)/3]
            ]);
}