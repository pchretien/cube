// Soap Holder
// A tray with drainage holes and raised ribs to hold a bar of soap

// Dimensions
length         = 100;  // mm - tray length
width          =  70;  // mm - tray width
height         =  20;  // mm - tray height
wall_thickness =   3;  // mm
base_thickness =   3;  // mm

// Drainage holes
hole_diameter  =   6;  // mm
hole_rows      =   3;  // rows along the width

// Ribs (keep soap elevated for drainage)
rib_count      =   5;
rib_height     =   5;  // mm above base interior
rib_width      =   3;  // mm

inner_length = length - wall_thickness * 2;
inner_width  = width  - wall_thickness * 2;

module tray() {
    difference() {
        // Outer shell
        cube([length, width, height]);

        // Inner cavity
        translate([wall_thickness, wall_thickness, base_thickness])
            cube([inner_length, inner_width, height]);
    }
}

module drainage_holes() {
    // One column of holes per gap between ribs (and between end ribs and walls)
    // rib_spacing divides inner_length into (rib_count + 1) equal gaps
    // Each hole column is centered in its gap: offset = (col - 0.5) * rib_spacing
    rib_spacing = inner_length / (rib_count + 1);
    y_spacing   = inner_width  / (hole_rows + 1);

    for (col = [1 : rib_count + 1]) {
        for (row = [1 : hole_rows]) {
            translate([
                wall_thickness + (col - 0.5) * rib_spacing,
                wall_thickness + row * y_spacing,
                -1
            ])
                cylinder(h = base_thickness + 2, r = hole_diameter / 2, $fn = 32);
        }
    }
}

module ribs() {
    spacing = inner_length / (rib_count + 1);
    for (i = [1 : rib_count]) {
        translate([
            wall_thickness + i * spacing - rib_width / 2,
            wall_thickness,
            base_thickness
        ])
            cube([rib_width, inner_width, rib_height]);
    }
}

difference() {
    union() {
        tray();
        ribs();
    }
    drainage_holes();
}
