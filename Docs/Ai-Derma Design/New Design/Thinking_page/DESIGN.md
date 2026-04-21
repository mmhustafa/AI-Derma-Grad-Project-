# Design System Specification: Clinical Serenity

## 1. Overview & Creative North Star
This design system is built upon the Creative North Star of **"The Clinical Sanctuary."** In the high-stakes environment of skin health assessment, the interface must transcend basic utility to become a calming, authoritative presence. We move away from the rigid, boxy layouts of traditional medical software in favor of an "Editorial Wellness" aesthetic.

By utilizing high-contrast typography (mixing the structural strength of Manrope with the clarity of Inter), generous whitespace, and tonal layering, we create an experience that feels like a premium digital clinic. The design breaks the "template" look by using subtle gradients to provide visual soul and glassmorphism to suggest transparency and modern precision.

---

### 2. Colors & Surface Philosophy
Color is used as a functional signifier and a psychological anchor. Our palette balances the clinical authority of deep blues with the approachable energy of bright teals.

- **Primary & Signature:** `primary` (#00658d) serves as our voice of authority, while `primary_container` (#00aeef) provides the energetic spark for main actions.
- **The "No-Line" Rule:** To maintain a high-end feel, **do not use 1px solid borders to define sections.** Hierarchy must be established through background color shifts. For instance, a `surface_container_lowest` card should sit atop a `surface_container_low` background.
- **Surface Hierarchy:** Treat the UI as physical layers. 
    - `surface`: The base canvas.
    - `surface_container_low`: Primary content grouping.
    - `surface_container_lowest`: Interactive cards and floating elements (pure white).
- **The Glass & Gradient Rule:** For hero sections (e.g., the "Start Diagnosis" card), utilize a soft gradient transition from `primary_container` to a `secondary_container` teal. For floating headers or overlays, apply **Glassmorphism**: `surface_container_lowest` at 80% opacity with a 16px backdrop-blur.

---

### 3. Typography
We use a dual-font strategy to balance character with readability.
- **Display & Headlines (Manrope):** Chosen for its geometric precision and modern medical feel. Use `display-lg` for impactful welcome states and `headline-md` for clear section markers.
- **Body & Labels (Inter):** The workhorse of the system. Chosen for its exceptional legibility in dense symptom descriptions or clinical results.
- **Hierarchy as Identity:** Wide tracking (letter-spacing) on `label-sm` in all-caps should be used for secondary metadata (e.g., "OCTOBER 26, 2023") to provide an editorial, organized feel.

---

### 4. Elevation & Depth
Depth in this design system is "Ambient," not "Structural."

- **The Layering Principle:** Instead of shadows, stack `surface_container` tiers. A `surface_container_lowest` element on a `surface` background creates a natural, soft lift.
- **Ambient Shadows:** When a card requires true elevation (e.g., a critical result), use an extra-diffused shadow: `offset-y: 8px`, `blur: 24px`, `color: rgba(0, 62, 88, 0.06)`. Note the use of a blue-tinted shadow rather than grey to maintain tonal harmony.
- **The "Ghost Border" Fallback:** If accessibility requires a stroke (e.g., unselected input states), use the `outline_variant` token at 20% opacity. Never use 100% opaque outlines.

---

### 5. Components

#### Buttons
- **Primary:** Rounded (`rounded-full`), using a linear gradient of `primary` to `primary_container`. White text.
- **Secondary:** `surface_container_lowest` background with a `primary` ghost border (20% opacity) and `primary` text.
- **Destructive:** `error` (#ba1a1a) background, reserved strictly for "Delete" or "Stop" actions.

#### Cards & Lists
- **Rule:** Forbid the use of divider lines. 
- Use `spacing-6` (1.5rem) as the default vertical gap between list items. 
- Cards must use `rounded-xl` (1.5rem) to maintain the "Soft Minimalist" aesthetic.
- Inside cards, use `tertiary` (#006e1c) for positive status indicators ("High Confidence") and `error` for alerts.

#### Selection Controls (Radio/Check)
- Use `secondary` (#006874) for active states. Selected items should feature a subtle `secondary_container` background fill to highlight the entire row, not just the icon.

#### Input Fields
- Avoid "box" inputs. Use a `surface_container_high` background with a bottom-only `outline_variant` for an elegant, editorial look.

---

### 6. Do's and Don'ts

- **DO** use asymmetry in layout. Place imagery (like skin scans) off-center or with overlapping caption cards to break the "grid" feel.
- **DO** use the `spacing-8` and `spacing-12` tokens for section headers. Breathing room is a luxury signal.
- **DON'T** use pure black (#000000) for text. Always use `on_surface` (#171c20) to maintain a soft, professional contrast.
- **DON'T** use standard Material shadows. They are too heavy for a healthcare context. Stick to tonal layering and high-blur ambient shadows.
- **DO** ensure that "Confidence Scores" are always the most legible element in an assessment card, using `headline-sm` in the appropriate status color.