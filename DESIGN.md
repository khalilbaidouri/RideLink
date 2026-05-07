---
name: Eco-Professionalism
colors:
  surface: '#f7faf3'
  surface-dim: '#d7dbd4'
  surface-bright: '#f7faf3'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f1f5ed'
  surface-container: '#ebefe8'
  surface-container-high: '#e6e9e2'
  surface-container-highest: '#e0e4dd'
  on-surface: '#181d18'
  on-surface-variant: '#404940'
  inverse-surface: '#2d322d'
  inverse-on-surface: '#eef2eb'
  outline: '#707a6f'
  outline-variant: '#bfc9bd'
  surface-tint: '#1c6c3b'
  primary: '#005127'
  on-primary: '#ffffff'
  primary-container: '#1b6b3a'
  on-primary-container: '#9ae9ab'
  inverse-primary: '#8ad89c'
  secondary: '#835500'
  on-secondary: '#ffffff'
  secondary-container: '#feae2c'
  on-secondary-container: '#6b4500'
  tertiary: '#394565'
  on-tertiary: '#ffffff'
  tertiary-container: '#515d7e'
  on-tertiary-container: '#cbd7fd'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#a5f4b6'
  primary-fixed-dim: '#8ad89c'
  on-primary-fixed: '#00210c'
  on-primary-fixed-variant: '#005227'
  secondary-fixed: '#ffddb4'
  secondary-fixed-dim: '#ffb955'
  on-secondary-fixed: '#291800'
  on-secondary-fixed-variant: '#633f00'
  tertiary-fixed: '#dae2ff'
  tertiary-fixed-dim: '#bac6ec'
  on-tertiary-fixed: '#0d1a38'
  on-tertiary-fixed-variant: '#3a4666'
  background: '#f7faf3'
  on-background: '#181d18'
  surface-variant: '#e0e4dd'
typography:
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  margin-mobile: 20px
  gutter: 16px
---

## Brand & Style

This design system is built to bridge the gap between community-driven carpooling and high-end ride-sharing services. The brand personality is **reliable, conscious, and neighborly**. It targets professionals and frequent travelers who value sustainability without sacrificing a seamless, "it just works" technology experience.

The design style is **Corporate / Modern** with a human touch. It utilizes generous whitespace and a restricted color palette to maintain a clean, high-end feel while employing soft shapes to remain approachable. The interface avoids aggressive tech-industrial aesthetics in favor of a polished, trustworthy atmosphere that encourages the social contract of shared travel.

## Colors

The palette is anchored by **Deep Green**, chosen to evoke both environmental responsibility and financial stability. **Soft Orange** serves as a high-visibility accent for critical actions, providing a warm contrast that feels helpful rather than urgent. 

- **Primary (Deep Green):** Used for branding, active states, and primary navigation elements.
- **Secondary (Soft Orange):** Reserved strictly for CTAs, notifications, and interactive highlights to guide the user's eye.
- **Neutral (Slate & Light Gray):** A foundation of light grays for backgrounds prevents screen fatigue, while dark slate is used for text to ensure maximum legibility and professional contrast.

## Typography

The design system utilizes **Plus Jakarta Sans** to satisfy the requirement for a rounded, modern sans-serif. This typeface provides the perfect balance between the geometric efficiency of Inter and the friendly curves of Poppins.

- **Headlines:** Set with tighter letter-spacing and heavier weights to establish a strong information hierarchy.
- **Body Text:** Standard weight with generous line heights to ensure readability during travel or on-the-go viewing.
- **Labels:** Used for metadata (e.g., car models, departure times), employing medium and semi-bold weights at smaller scales to maintain clarity.

## Layout & Spacing

The layout follows a **fluid grid** model optimized for mobile-first usage. A standard 4px baseline grid ensures vertical rhythm across all components.

- **Margins:** 20px side margins on mobile devices to provide "breathing room" and prevent accidental edge-taps.
- **Gutters:** 16px fixed gutters between cards in list views.
- **Padding:** Internal card padding is set to 20px to accommodate the 16px corner radius harmoniously.

## Elevation & Depth

Hierarchy is established through **Ambient Shadows** and tonal layering. This design system avoids harsh borders in favor of soft depth cues that make the UI feel tactile and organized.

- **Base Layer:** The light gray background (#F7F8FA) acts as the canvas.
- **Surface Layer:** Cards and interactive containers use pure white (#FFFFFF).
- **Shadow Profile:** Shadows should be highly diffused with low opacity (approx. 4-8%) and a slight Y-axis offset. Use a subtle tint of the primary color in the shadow for a more organic, integrated look rather than pure black.
- **Interaction:** When a card is pressed, it should subtly "lift" by increasing the shadow spread, or "sink" by reducing it, providing immediate physical feedback.

## Shapes

The shape language is consistently rounded to project friendliness and safety. By using varying radii for different scales of components, we maintain visual balance.

- **Cards:** Use a 16px radius. This larger radius softens the overall layout and distinguishes content blocks.
- **Action Elements:** Buttons and input fields use a 12px radius. This slightly "sharper" curve makes them feel more precise and functional than the layout containers.
- **Avatars:** Always circular (full-round) to emphasize the human element of carpooling.

## Components

https://forui.dev/docs/llms.txt
