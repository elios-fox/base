# ClubHub Animaties & Micro-interacties

## Page Transitions
- **Forward navigation**: Slide in from right (300ms, easeOutCubic)
- **Back navigation**: Slide out to right (250ms, easeInCubic)
- **Bottom nav switch**: Fade + slight vertical slide (200ms)
- **Modal/sheet**: Slide up from bottom (350ms, easeOutQuint)

## RSVP Button
- Selectie: kleur morph van neutraal → status-kleur (200ms)
- Icoon: scale bounce (0.8 → 1.1 → 1.0, 300ms)
- Haptic feedback: light impact bij selectie

## Kalender
- Maand wisselen: horizontal slide (250ms)
- Dag selecteren: cirkel scale-in (150ms, easeOut)
- Event stipjes: fade in bij maand load (staggered, 50ms interval)

## Event Cards
- Lijst laden: staggered fade + slide up (50ms interval per card)
- Swipe to delete: slide out + height collapse

## Pull-to-Refresh
- Custom indicator met ClubHub logo
- Rotation animatie tijdens laden

## Skeleton Loading
- Shimmer effect op placeholder cards
- Richting: links → rechts, 1.5s cycle

## FAB
- Standaard: enkele FAB
- Long press: expand naar mini-FABs (training + wedstrijd)
- Expansion: scale + fade in (200ms, staggered)

## Speciale momenten
- **Iedereen aanwezig**: Confetti regen (2 seconden) + "Compleet team!" tekst
- **Eerste team join**: Welkomst animatie met team naam
- **Milestone**: Badge animatie bij 10e event
