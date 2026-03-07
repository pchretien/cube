// Soap Holder with Double Bottom
// Water drains through the inner base into a sealed channel,
// then flows out through an opening on the long side.

// Overall dimensions
length         = 100;  // mm - tray length (long axis = X)
width          =  70;  // mm - tray width  (short axis = Y)
height         =  25;  // mm - total height (inner soap cavity = 20 mm)
wall_thickness =   3;  // mm

// Double bottom
outer_base     =  2;   // mm - solid bottom plate
channel_height =  8;   // mm - water collection channel
inner_base     =  2;   // mm - perforated inner floor
total_base     = outer_base + channel_height + inner_base;  // = 12 mm
slope_height   =  3;   // mm - ramp rise from drain side to far side (< channel_height)

// Drain opening on the long side (y = 0 face, centered along length)
drain_w        = 90;   // mm - opening width along X
drain_h        = channel_height;  // mm - full channel height

// Drainage holes (through inner_base only)
hole_diameter  =   6;  // mm
hole_rows      =   3;  // rows along the width

// Ribs (keep soap elevated above inner floor)
rib_count      =   5;
rib_height     =   5;  // mm above inner floor
rib_width      =   2;  // mm

inner_length = length - wall_thickness * 2;
inner_width  = width  - wall_thickness * 2;

module tray() {
    difference() {
        // Outer shell
        cube([length, width, height]);

        // Water channel cavity (between outer_base and inner_base)
        translate([wall_thickness, wall_thickness, outer_base])
            cube([inner_length, inner_width, channel_height]);

        // Soap cavity (above inner_base)
        translate([wall_thickness, wall_thickness, total_base])
            cube([inner_length, inner_width, height]);

        // Drain opening through the long side wall (y = 0)
        translate([(length - drain_w) / 2, -1, outer_base])
            cube([drain_w, wall_thickness + 2, drain_h]);
    }
}

module drainage_holes() {
    // One column per gap between ribs; centered in each gap
    rib_spacing = inner_length / (rib_count + 1);
    y_spacing   = inner_width  / (hole_rows + 1);

    for (col = [1 : rib_count + 1]) {
        for (row = [1 : hole_rows]) {
            translate([
                wall_thickness + (col - 0.5) * rib_spacing,
                wall_thickness + row * y_spacing,
                total_base - inner_base - 1
            ])
                cylinder(h = inner_base + 2, r = hole_diameter / 2, $fn = 32);
        }
    }
}

// Wedge ramp on the channel floor: zero height at the drain side (y = wall_thickness),
// rising to slope_height at the far side (y = width - wall_thickness).
// Water that falls through the inner base is guided toward the y = 0 drain opening.
module channel_ramp() {
    hull() {
        // Far edge (high side)
        translate([wall_thickness, width - wall_thickness - 0.01, outer_base])
            cube([inner_length, 0.01, slope_height]);
        // Drain edge (low side) — infinitesimally thin
        translate([wall_thickness, wall_thickness, outer_base])
            cube([inner_length, 0.01, 0.01]);
    }
}

module ribs() {
    spacing = inner_length / (rib_count + 1);
    for (i = [1 : rib_count]) {
        translate([
            wall_thickness + i * spacing - rib_width / 2,
            wall_thickness,
            total_base
        ])
            cube([rib_width, inner_width, rib_height]);
    }
}

difference() {
    union() {
        tray();
        channel_ramp();
        ribs();
    }
    drainage_holes();
}
