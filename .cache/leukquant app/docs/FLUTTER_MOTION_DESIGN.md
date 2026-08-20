# LeukQuant Mobile: Motion Design System

## 1. Design Philosophy
LeukQuant Mobile adheres to a **calm enterprise aesthetic**. Animations and transitions are designed to provide spatial continuity, confirm user actions, and present incoming telemetry without distraction or sensationalism.

No cyberpunk neon, flashing sirens, hacker terminals, or fake live counters are permitted.

---

## 2. Animation Token Catalog

### 2.1 Staggered Content Entrances
- **Package**: `flutter_animate`
- **Curves**: `Curves.easeOutCubic` / `Curves.easeOutQuad`
- **Duration**: `300ms – 400ms`
- **Stagger**: `35ms – 70ms` between adjacent cards
- **Translation**: Vertical translation from `+0.05` to `0.0` (gentle 10–15px lift)

```dart
MetricCard(...)
  .animate()
  .fadeIn(duration: 350.ms, delay: 50.ms)
  .slideY(begin: 0.05, end: 0, duration: 350.ms);
```

### 2.2 Screen Navigation Transitions
- **Style**: Fade-through navigation between primary shell tabs.
- **Duration**: `200ms – 250ms`.
- **State Preservation**: Page scroll offsets and filter criteria are preserved across tab switches.

### 2.3 Real-Time WebSocket Telemetry Entrance
- **Behavior**: When a new live telemetry event arrives over WebSocket, it is inserted at the top of the event stream.
- **Motion**: `fadeIn(duration: 300.ms)` with subtle `slideY(begin: -0.05, end: 0)`.
- **Constraint**: Old historical events do not replay animations upon list pull-to-refresh.

### 2.4 Chart Rendering Motion
- **Line & Bar Charts**: FlChart render animation triggers once upon verified data arrival (`duration: 500ms`).
- **Empty States**: Static clean placeholder (`ChartEmptyState`). No fake continuous wave oscillation or oscillating demo curves.

### 2.5 Modal Bottom Sheet (Event Details)
- **Curve**: `Curves.easeOutCubic` (smooth deceleration, no exaggerated spring rebound).
- **Duration**: `300ms`.
- **Scrim**: Soft ambient backdrop darkening (`Colors.black54`).

### 2.6 Accessibility & Reduced Motion
The application honors the user's OS-level reduced motion accessibility settings. When `MediaQuery.disableAnimations` is enabled, transition durations drop to zero and motion effects are bypassed.
