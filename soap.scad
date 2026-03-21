// =============================================================================
// Soap Holder with Bottle Compartment
// =============================================================================
// A two-section shower caddy:
//   - Front section: soap tray with a perforated double bottom for drainage
//   - Back section:  open compartment for small shampoo bottles
// Water drains through the inner base into a sealed channel with a sloped
// ramp, then flows out through a spout on the front side (y = 0).
// =============================================================================

// --- Overall dimensions (soap tray) -----------------------------------------
// The soap tray sits along the X axis (length) and Y axis (width).
// The bottle holder is attached to the back (high-Y side).
length         = 100;  // mm - tray length along X
width          =  80;  // mm - tray width along Y
height         =  18;  // mm - total tray wall height
wall_thickness =   3;  // mm - thickness of all outer walls

// --- Double bottom (tray module) ---------------------------------------------
// Three layers from bottom up: solid outer base, water channel, perforated inner base.
// Water falls through the inner base holes into the channel below.
outer_base     =  2;   // mm - solid bottom plate (waterproof floor)
channel_height =  4;   // mm - height of the water collection channel between bases
inner_base     =  2;   // mm - perforated floor the soap sits on (via ribs)
total_base     = outer_base + channel_height + inner_base;  // mm - combined base height

// --- Channel ramp (channel_ramp module) --------------------------------------
// A wedge inside the channel that slopes from the back (bottle holder side)
// down to the front (drain side), guiding water toward the drain opening.
// Must be less than channel_height to leave room for water flow.
slope_height   =  3;   // mm - total rise from drain side to far end of bottle holder

// --- Drain opening & spout (tray + drain_spout modules) ----------------------
// The drain is a rectangular opening in the front wall (y = 0), centered along X.
// The spout extends outward from this opening so water drips away from the holder.
drain_w        = 70;   // mm - width of the drain opening along X
drain_h        = channel_height;  // mm - height of the drain opening (full channel)
drain_spout    =  5;   // mm - how far the spout extends away from the front wall

// --- Drainage holes (drainage_holes module) ----------------------------------
// Grid of circular holes through the inner base that let water fall into the channel.
// Holes are evenly distributed between ribs.
hole_diameter  =   6;  // mm - diameter of each drainage hole
hole_rows      =   4;  // number of hole rows along the Y axis

// --- Ribs (ribs module) ------------------------------------------------------
// Raised bars on the inner base that keep the soap elevated above the perforated
// floor, improving airflow and drainage underneath the soap.
rib_count      =   5;  // number of ribs along the X axis
rib_height     =   5;  // mm - how high ribs rise above the inner base
rib_width      =   2;  // mm - thickness of each rib

// --- Bottle holder (bottle_holder module) ------------------------------------
// An open compartment attached to the back of the soap tray (high-Y side)
// for holding small shampoo bottles. Shares the back wall with the tray.
// Its floor sits on the same sloped ramp so water drains toward the front.
bottle_depth   =  50;  // mm - compartment depth along Y (~2 inches)
bottle_height  =  30;  // mm - wall height (tall enough for travel-size bottles)
channel_opening=  90;  // mm - width of the opening between bottle holder and tray channel

// --- Computed values ---------------------------------------------------------
inner_length = length - wall_thickness * 2;  // mm - usable interior length
inner_width  = width  - wall_thickness * 2;  // mm - usable interior width

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
