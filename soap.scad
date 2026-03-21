// Soap Holder with Double Bottom
// Water drains through the inner base into a sealed channel,
// then flows out through an opening on the long side.

// Overall dimensions
length         = 100;  // mm - tray length (long axis = X)
width          =  80;  // mm - tray width  (short axis = Y)
height         =  18;  // mm - total height (inner soap cavity = 20 mm)
wall_thickness =   3;  // mm

// Double bottom
outer_base     =  2;   // mm - solid bottom plate
channel_height =  4;   // mm - water collection channel
inner_base     =  2;   // mm - perforated inner floor
total_base     = outer_base + channel_height + inner_base;  // = 12 mm
slope_height   =  3;   // mm - ramp rise from drain side to far side (< channel_height)

// Drain opening on the long side (y = 0 face, centered along length)
drain_w        = 70;   // mm - opening width along X
drain_h        = channel_height;  // mm - full channel height
drain_spout    = 5;   // mm - spout extension away from the holder

// Drainage holes (through inner_base only)
hole_diameter  =   6;  // mm
hole_rows      =   4;  // rows along the width

// Ribs (keep soap elevated above inner floor)
rib_count      =   5;
rib_height     =   5;  // mm above inner floor
rib_width      =   2;  // mm

// Bottle holder (opposite side from drain, along Y)
bottle_depth   =  50;  // mm (~2 inches) - depth of the bottle compartment
bottle_height  =  30;  // mm - tall enough for small shampoo bottles
channel_opening=  90;  // mm - width of the opening between bottle holder and drainage

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

        // Opening through the back wall (y = width) to connect with bottle holder
        translate([(length - channel_opening) / 2, width - wall_thickness - 1, outer_base])
            cube([channel_opening, wall_thickness + 2, channel_height]);
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

// Wedge ramp spanning both soap tray and bottle holder:
// zero height at the drain side (y = wall_thickness),
// rising to slope_height at the far end of the bottle holder.
// Water is guided toward the y = 0 drain opening from both sections.
module channel_ramp() {
    far_y = width - wall_thickness + bottle_depth;  // inner far wall of bottle holder
    hull() {
        // Far edge (high side) — at the back of the bottle holder
        translate([wall_thickness, far_y - 0.01, outer_base])
            cube([inner_length, 0.01, slope_height]);
        // Drain edge (low side) — extends to outer wall face (y = 0) to meet the spout
        translate([wall_thickness, 0, outer_base])
            cube([inner_length, 0.01, 0.01]);
    }
}

module bottle_holder() {
    // Positioned at the back of the soap holder (y = width side), sharing the back wall
    translate([0, width - wall_thickness, 0])
        difference() {
            cube([length, bottle_depth + wall_thickness, bottle_height]);

            // Inner cavity — floor at outer_base so the ramp serves as the continuous floor
            translate([wall_thickness, wall_thickness, outer_base])
                cube([inner_length, bottle_depth - wall_thickness, bottle_height]);

            // Opening through shared wall so water flows into the drainage channel
            translate([(length - channel_opening) / 2, -1, outer_base])
                cube([channel_opening, wall_thickness + 2, channel_height]);
        }
}

// Spout extending outward from the drain opening so water flows away
module drain_spout() {
    spout_x = (length - drain_w) / 2;

    // Sloped floor — from outer_base at the holder down to wall_thickness at the outer edge
    translate([spout_x, -drain_spout, 0])
        hull() {
            // Inner edge (at holder wall)
            translate([0, drain_spout - 0.01, 0])
                cube([drain_w, 0.01, outer_base]);
            // Outer edge — ends at wall_thickness height
            translate([0, 0, 0])
                cube([drain_w, 0.01, wall_thickness]);
        }

    // Left side wall — straight vertical
    translate([spout_x, -drain_spout, 0])
        cube([wall_thickness, drain_spout, outer_base + drain_h]);

    // Right side wall — straight vertical
    translate([spout_x + drain_w - wall_thickness, -drain_spout, 0])
        cube([wall_thickness, drain_spout, outer_base + drain_h]);

    // Left ramp — triangular wedge to guide water inward
    translate([spout_x + wall_thickness, -drain_spout, 0])
        hull() {
            cube([0.01, drain_spout, outer_base + drain_h]);
            cube([drain_h, drain_spout, 0.01]);
        }

    // Right ramp — triangular wedge to guide water inward
    translate([spout_x + drain_w - wall_thickness, -drain_spout, 0])
        hull() {
            translate([-0.01, 0, 0])
                cube([0.01, drain_spout, outer_base + drain_h]);
            translate([-drain_h, 0, 0])
                cube([drain_h, drain_spout, 0.01]);
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
        bottle_holder();
        drain_spout();
    }
    drainage_holes();
}
