# Soap Holder Project — Complete Session History

**Project:** `/home/pchretien/OpenScad/cube` | **Branch:** `master`

---

## Session 1 — March 7, 2026

### 1. Create the Initial Soap Holder

**User request:** Create a soap holder in a new scad file called `soap.scad`.

**Context:** The project already contained `cube.scad` — a hollow cube with circular, square, and triangular holes. No prior memory file existed.

**`soap.scad` created with:**
- Tray shell: 100×70×20mm with 3mm walls and 3mm base
- Drainage holes: a 4×3 grid of 6mm holes through the base
- Raised ribs: 5 ribs along the length to elevate the soap

| Variable | Default | Purpose |
|---|---|---|
| `length` / `width` / `height` | 100 / 70 / 20 mm | Overall tray size |
| `wall_thickness` | 3 mm | Shell wall thickness |
| `hole_diameter` | 6 mm | Drainage hole size |
| `rib_count` / `rib_height` | 5 / 5 mm | Number and height of ribs |

---

### 2. Center Holes Between Ribs

**User request:** Make sure the holes on the bottom are centered between the ribs. Also put holes between the two end ribs and the walls.

**Changes made:**
- Removed the independent `hole_cols` parameter — column count is now derived from `rib_count`
- Rewrote `drainage_holes()` to use `rib_spacing = inner_length / (rib_count + 1)`, placing one hole column per gap centered at `(col - 0.5) * rib_spacing`
- This automatically covers both end gaps (wall↔rib) and all inter-rib gaps

---

### 3. Add a Double Bottom with Drain Channel

**User request:** Create a double bottom on the soap holder to catch the water and redirect it to the long side of the holder. Make an opening on the long side to let water flow out of the double bottom.

**Changes made — full rewrite of `soap.scad`:**

The base was redesigned as three layers totalling 12mm:

| Layer | Thickness | Role |
|---|---|---|
| `outer_base` | 2 mm | Sealed bottom plate |
| `channel_height` | 8 mm | Water collection channel |
| `inner_base` | 2 mm | Perforated inner floor |

Additional changes:
- Overall height increased to 32mm to preserve a 20mm soap cavity above the double bottom
- Added a drain opening: 90mm wide × 8mm tall, centered on the front long side (y = 0 face)
- Drainage holes now only pierce `inner_base` (2mm), not the outer bottom — water collects in the sealed channel and exits through the side opening
- Ribs repositioned to sit on `total_base` instead of `base_thickness`

---

### 4. Add Slope to the Channel Floor

**User request:** Give a slight inclination to the double bottom so that the water flows toward the drain channel.

**Changes made:**
- Added `slope_height = 4 mm` parameter
- Added a `channel_ramp()` module — a `hull()` wedge sitting on the outer base floor, zero height at the drain side (y = `wall_thickness`) rising to 4mm at the far side (y = `width - wall_thickness`), spanning the full inner length
- Added `channel_ramp()` to the main `union()`
- Water falling through drainage holes hits the sloped floor and flows toward the y=0 opening

**Final state of `soap.scad` at end of Session 1:**

| Parameter | Value |
|---|---|
| `length` | 100 mm |
| `width` | 70 mm |
| `height` | 32 mm |
| `wall_thickness` | 3 mm |
| `outer_base` | 2 mm |
| `channel_height` | 8 mm |
| `inner_base` | 2 mm |
| `slope_height` | 4 mm |
| `drain_w` | 90 mm |
| `hole_diameter` | 6 mm |
| `rib_count` | 5 |

---

## Session 2 — March 21, 2026

### 5. Add a Bottle Holder Compartment

**User request:** Add a ~2-inch wide placeholder on the opposite side from the drainage hole for small shampoo bottles.

**Changes made to `soap.scad`:**
- Added `bottle_depth = 51 mm` and `bottle_height = 60 mm` parameters
- Added a `bottle_holder()` module — an open-top box attached to the back wall (y = width side), full length of the tray
- Called `bottle_holder()` in the main `union()`

---

### 6. Connect Bottle Holder Floor to the Drainage Ramp

**User request:** The bottom of the bottle holder should match the height of the slope from the drainage double bottom so water can flow from one section to the other.

**Changes made:**
- The bottle holder's inner cavity floor was set to `outer_base + slope_height` (matching the high end of the ramp)
- Added an opening through the shared wall between the bottle holder and the drainage channel, controlled by the `channel_opening` parameter

---

### 7. Add `channel_opening` Parameter

**User request:** Add a parameter to adjust the width of the channel opening between the bottle holder and the soap holder double bottom.

**Changes made:**
- Added `channel_opening = 60 mm` parameter
- The opening is centered along the length of the shared wall
- Both the tray's back wall and the bottle holder's shared wall use this parameter

---

### 8. Fix the Gap — Shared Inclined Floor

**User request:** There is a gap between the bottle holder and the soap holder where the bottom drops. Both sections should have the same inclined bottom to allow drainage.

**Changes made:**
- Extended the `channel_ramp()` to span the full depth — from y = 0 (front wall) all the way to the far end of the bottle holder (`width - wall_thickness + bottle_depth`)
- Set the bottle holder cavity floor to `outer_base` so the ramp serves as the continuous floor for both sections

---

### 9. Add Opening Between Bottle Holder and Soap Holder

**User request:** Add an opening between the bottle holder and the soap holder to let water flow.

**Changes made:**
- Added an opening through the tray's back wall (y = width) matching the same `channel_opening` parameter
- This completes the connection so water can flow from the bottle holder through the shared wall into the drainage channel

---

### 10. Push to Origin

**User request:** Push the master branch to origin.

**Result:** Initial push was rejected (non-fast-forward). Resolved with `git pull --rebase origin master`, then pushed successfully: `db8f7bd..005bf1e master -> master`

---

### 11. Add a Drain Spout

**User request:** Extend the drain opening away from the soap holder by 10mm so that water flows away from the holder.

**Changes made:**
- Added `drain_spout = 10 mm` parameter
- Added a `drain_spout()` module with a sloped floor descending from `outer_base` at the holder wall to `wall_thickness` at the outer edge
- Added straight vertical side walls and triangular ramps on each side to guide water inward and prevent sideways flow
- Extended the `channel_ramp()` low edge to y = 0 to eliminate the gap between the ramp and the spout floor

---

### 12. Fix Spout Artifact & Add Side Ramps

**User request:** There is an artifact on top of the spout. Remove it and add two small ramps on each side to avoid water flowing sideways.

**Changes made:**
- Rewrote `drain_spout()` as an open-top channel (no lid artifact)
- Added straight vertical left and right side walls
- Added triangular wedge ramps on each inner side to guide water toward the center

---

### 13. Fix Spout Floor Gap

**User request:** The inclined bottom floor should extend to the outside of the soap holder wall to avoid a gap between the inclined floor and the spout.

**Changes made:**
- Extended the `channel_ramp()` low edge from `y = wall_thickness` to `y = 0`, seamlessly meeting the spout floor

---

### 14. Spout Refinements

**User request:** The spout walls should be straight verticals. The spout slope should end with a height equal to the wall thickness.

**Changes made:**
- Side walls confirmed as straight verticals
- Spout outer edge floor height changed from 0 to `wall_thickness` (3mm), creating a solid lip at the end of the spout

---

### 15. Clean Up Parameters Section

**User request:** Clean the parameters section of the code by grouping variables by modules and adding more detailed comments.

**Changes made:**
- Added a file-level banner comment describing the two-section design
- Grouped all parameters into labelled sections: Overall Dimensions, Double Bottom, Channel Ramp, Drain Opening & Spout, Drainage Holes, Ribs, Bottle Holder, and Computed Values
- Each section includes explanatory comments describing the geometry and design intent

---

## Final State of `soap.scad`

| Parameter | Value |
|---|---|
| `length` | 100 mm |
| `width` | 80 mm |
| `height` | 18 mm |
| `wall_thickness` | 3 mm |
| `channel_height` | 4 mm |
| `slope_height` | 3 mm |
| `drain_w` | 70 mm |
| `drain_spout` | 5 mm |
| `bottle_depth` | 50 mm |
| `bottle_height` | 30 mm |
| `channel_opening` | 90 mm |