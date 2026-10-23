---
name: 2d-character-animation
description: Use when rigging 2D stickmen, limbs, walk cycles in SVG.
---

# 2D Character Animation & Rigging (HTML/SVG/GSAP)

## Anatomical Hierarchy & Zero-Gap Anchoring (Anti-Floating Head & Limbs)
When designing stylized stick figures or 2D vector characters with clothing (aprons, uniforms, suits):
1. **Neck & Chin Alignment**:
   - The chin (head circle lowest point `cy + r`) must connect directly to the neck line (`y1 = cy + r`).
   - The neck line must feed flush into the garment collar (`y2`).
   - Never leave an unbridged vertical gap between the head and garment; an air gap between chin and collar results in a broken "floating balloon" head.
2. **Shoulder & Hip Anchoring**:
   - Upper limb joints (shoulders) must be anchored flush inside or directly at the top vertices of the torso polygon (e.g. `x = 175` and `x = 225` on an apron top width of 64px `168..232`), NOT floating in empty air outside the garment.
   - Hip joints must originate symmetrically beneath the bottom hemline (e.g., `x = 180` and `x = 220`), giving the appearance of legs supporting a pelvis.
3. **Neck Pivot for Head Tweens (CRITICAL: svgOrigin vs transformOrigin)**:
   - On SVG groups (`<g>`), NEVER use CSS `transformOrigin: "200px 207px"` in GSAP. Chromium computes CSS `transformOrigin` relative to the element's local `getBBox()`, which drifts during rotation and shifts the neck pivot by up to 50px, causing visible decapitation or a floating head gap.
   - ALWAYS use GSAP's native `svgOrigin: "x y"` (e.g., `svgOrigin: "200 207"`). This locks the pivot strictly in absolute SVG user coordinate space without any translation drift (`transformedChin` remains identical to 6 decimal places).
4. **Headwear Proportion & Fitting (Eliminating Skull Clipping & Double Strokes)**:
   - Headwear brim bands must span `>= 1.0 * (2 * r_head)` (e.g., pill band `width = 2 * r_head + 4px`, `rx = 10`, or `rx_brim >= r_head`). A brim narrower than `2 * r_head` leaves bare skull sticking out on both sides.
   - Use a clean solid-fill pill or rounded rectangle for the brim band spanning from `cy - r - 10` down to `cy - r + 8` (`fill="#ffffff"`). This cleanly covers the top arc of the skull circle without interior stroked curves cutting across the forehead or creating doubled horizontal stripes.

## Continuous Kinematics Walk Cycle in GSAP
- Never animate walking with loose keyframes or large-interval tweens returning to zero rotation; random frame extractions will capture characters frozen in static vertical or scissor poses.
- Use a continuous nested timeline walk cycle generator (~0.4s - 0.5s per stride):
  - **Phase 1 (Leading Left)**: `leg-l` swings forward (-26°), `shin-l` straightens (-4°), `leg-r` pushes back (+24°), `shin-r` knee bends (+38°), `torso` bobs down/up (10px), right arm counter-swings (+24°).
  - **Phase 2 (Leading Right)**: `leg-l` swings back (+24°), `shin-l` knee bends (+38°), `leg-r` swings forward (-26°), `shin-r` straightens (-4°), `torso` bobs down/up (10px), right arm counter-swings (-16°).
  - Reset rotations to 0 only when the walk duration completes.

## Ground Plane, Stance & Contact Shadows
- **Contrapposto (Natural Standing Stance)**:
  - Never leave a standing character's legs as rigid parallel vertical lines; parallel legs read as a primitive, lifeless stickman.
  - Apply natural contrapposto weight-shift: support leg straight (`leg: +3°`, `shin: 0°`), relaxed leg angled with slight knee flex (`leg: -6°`, `shin: +12°`). This immediately establishes organic weight and human posture.
- **Floor Baseline & Furniture Interaction**:
  - Standing or walking characters must have their shoe lowest coordinate touch the floor baseline exactly (`svg_bottom = screen_height - (floor_y - shoe_y_in_svg + svg_height)`).
  - When characters approach counters or desks, never translate them into the desk surface coordinates (`x, y`); translating onto furniture makes the character stand awkwardly atop countertops or clip props. Either keep them standing on the floor beside the counter or position them behind the counter with proper layer stacking (`counter z-index > character z-index`).
- **Contact Shadows**:
  - Always include an elliptical contact shadow (`<ellipse id="shadow" rx="38" ry="8" fill="rgba(0,0,0,0.5)">`) directly under the feet that pulses (`scaleX: 1.15`) with step cadence; without a contact shadow, 2D characters appear to float in mid-air.

## Volumetric Lighting & Spotlight Cones
- Avoid rectangular `<div>` elements with CSS radial gradients for directional lighting (pendant lamps, street lights); they produce harsh rectangular clipping edges against textured or dark walls.
- Use an SVG `<polygon>` cone (`points="lamp_x,lamp_y left_x,floor_y right_x,floor_y"`) with an SVG `<linearGradient>` fading from warm glow (35%–45% opacity) down to `transparent` at 85%–100%. This yields mathematically clean, feathered volumetric falloff without raster mask boundaries.
- **Persistent Lighting in Multi-Shot Scenes**: Never nest directional lamps, volumetric light cones, or floor baselines inside shot-specific sub-containers or environmental groups that fade out (`opacity: 0`). Keep floor planks, overhead lamps, and light cones in a persistent global scene layer (`z-index: 5` for floor, `z-index: 12..16` for light) so characters in later shots (e.g. kitchen or warehouse shifts) remain brightly illuminated instead of being cast into pitch darkness.

## Limb Contrast & Silhouette Separation Against Backdrops
- **Silhouette Negative Space**: When stick limbs share the stroke color of background elements (e.g. black stroke `#0f172a` on dark navy tiled walls or dark garment pockets), limbs held tightly across the torso vanish completely (0 contrast). Poses must project outward into negative space (e.g. pointing outward `arm-l: +50°..+75°`, reaching to props `arm-r: -50°..-65°`) where limbs silhouette clearly against bright spotlight cones.
- **Handheld Props for Pose Clarity**: Equip interacting hands with contrasting accessories (e.g. white/cream audit clipboards, smartphones with glowing colored borders, digital probes) to immediately anchor hand position and intent in visual QA from any viewing distance.

## Upper Limb Rotation Signs & Outward vs Inward Kinematics (GSAP/SVG)
In standard SVG/HTML coordinates (`+x` right, `+y` down):
- For bones resting straight down (`y+`), GSAP positive rotation (`+deg`) is clockwise:
  - **Right Arm (Character's Right / Screen Right)**:
    - Rotating `+deg` swings INWARD across the chest/torso (crossed-arms / defensive posture).
    - Rotating `-deg` swings OUTWARD to the right (reaching for props, smartphones, pointing outward).
  - **Left Arm (Character's Left / Screen Left)**:
    - Rotating `+deg` swings OUTWARD to the left (reaching, gesturing, balance beam).
    - Rotating `-deg` swings INWARD across the torso/chin (holding chin, clutching chest).
- **Nested Forearm Hierarchy**: Forearm rotation is cumulative with upper arm (`global_angle = arm + forearm`). If upper arm is rotated `+60°` outward (left), set forearm to `+110°` (total `+170°`) to bend the elbow UPWARD into a natural vertical cupped hand.

## Gestural Archetypes: Scales of Justice, Panic & Moral Dilemma
- Never use rigid straight horizontal lines for "weighing options" — they read as pointers or broken stickman geometry.
- **U-Shape Scales of Justice Silhouette**:
  - Both upper arms angle outward-downward (`arm-l: +60°`, `arm-r: -60°`).
  - Both forearms bend upward (`forearm-l: +110°`, `forearm-r: -110°`), cupping hands beneath hovering choices/avatars.
  - **Tilt Motion**: Asymmetric upper arm angles (e.g. `arm-l: +80°` raised vs `arm-r: -40°` depressed) instantly telegraph unequal moral weight.
- **Panic / Head-Clutching Silhouette (Holding Temples)**:
  - Do not use shallow arm rotations (e.g. 90°), which collapse the limbs across the throat or collar.
  - Flare upper arms wide upward and outward: `arm-l: +155°` and `arm-r: -155°` (pointing high and outward from shoulders).
  - Bend forearms backward toward the skull: `forearm-l: +40°` and `forearm-r: -40°`.
  - This lands the hands squarely against the left and right temples with wide, expressive elbows telegraphing intense panic.
- **Bow of Gratitude & Welcoming Outro Gesture (Concluding Presentation)**:
  - **Clasped Hands Gratitude**: Clasp hands at chest with symmetric inward rotations: `arm-l: -15°, forearm-l: +75°` and `arm-r: +15°, forearm-r: -75°`.
  - **Bow Timing**: Tilt torso and head forward in unison (`rotation: +10°` on `#body-core` around hip and `rotation: +15°` on `#head-unit` around `svgOrigin: "200 207"`).
  - **Welcoming Open-Arms Return**: Stand upright, return torso/head to 0°, and sweep arms wide outward (`arm-l: +65°, forearm-l: +25°` and `arm-r: -65°, forearm-r: -25°`) paired with crescent smile eyes (`M 172 148 Q 180 140 188 148`) to invite audience appreciation.

## Staging & Zero-Occlusion Separation
- **Stage Split**: Always divide layout into clean visual zones (e.g., UI dialogue cards at stage left `left: 100px`, character and interactable counters at center-right `left: 850px+`). Never allow UI cards to render in the same quadrant as character heads or upper bodies.
- **Companion Hover Clearance**: Small shoulder sprites (conscience angels/devils) must have an explicit offset (minimum 60px–85px clear of the character's head perimeter) to prevent wings, horns, or weapons from clipping character cheeks, eyes, or headwear.

