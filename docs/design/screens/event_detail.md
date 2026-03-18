# Event Detail

## Doel
Event info bekijken en RSVP geven.

## Layout
```
┌─────────────────────────┐
│ ← Training        📤 🗑 │
├─────────────────────────┤
│                         │
│ ┌─ Info ───────────────┐│
│ │ 🏋 Training          ││
│ │ 📅 Dinsdag 19 mrt    ││
│ │ 🕐 19:00 - 20:30     ││
│ │ 📍 Sportpark Noord   ││
│ └──────────────────────┘│
│                         │
│ ┌─ Jouw beschikbaarheid┐│
│ │                       ││
│ │ [Aanwezig|Onzeker|Af] ││
│ │    ✓ selected         ││
│ │                       ││
│ └──────────────────────┘│
│                         │
│ ┌─ Overzicht ──────────┐│
│ │   8        2       1  ││
│ │ Aanwezig Onzeker Afw  ││
│ └──────────────────────┘│
│                         │
│ Reacties (11)           │
│ ┌──────────────────────┐│
│ │ ✅ Jan de Vries       ││
│ │ ✅ Pieter Bakker      ││
│ │ ❌ Klaas Jansen       ││
│ │    "Blessure"         ││
│ │ ❓ Lisa de Groot      ││
│ └──────────────────────┘│
│                         │
├─────────────────────────┤
│ 🏠 Home  👥 Teams  👤   │
└─────────────────────────┘
```

## Componenten
- Info card: type icon, datum, tijd, locatie
- RSVP SegmentedButton: 3 opties met iconen
- Stats row: 3 kolommen (aanwezig/onzeker/afwezig) met grote cijfers
- Reactie lijst: AttendanceTile per persoon

## Interacties
- SegmentedButton → submit attendance direct
- Bij "Afwezig" → optioneel reden-veld verschijnt
- 📤 → deel event via share sheet
- 🗑 → verwijder event (alleen coach, met bevestiging)
- Pull-to-refresh voor updates
