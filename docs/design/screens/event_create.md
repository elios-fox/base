# Event Aanmaken

## Doel
Nieuwe training of wedstrijd toevoegen.

## Layout
```
┌─────────────────────────┐
│ ← Nieuw evenement       │
├─────────────────────────┤
│                         │
│ [Training] [Wedstrijd]  │  ← SegmentedButton
│                         │
│ Titel                   │
│ ┌──────────────────────┐│
│ │ bijv. Training       ││
│ └──────────────────────┘│
│                         │
│ 📅 Datum                │
│ ┌──────────────────────┐│
│ │ Di 19 mrt 2026       ││
│ └──────────────────────┘│
│                         │
│ 🕐 Tijd                 │
│ ┌──────────────────────┐│
│ │ 19:00                ││
│ └──────────────────────┘│
│                         │
│ 📍 Locatie (optioneel)  │
│ ┌──────────────────────┐│
│ │ Sportpark Noord      ││
│ └──────────────────────┘│
│                         │
│ 🔁 Herhaling            │
│ ┌──────────────────────┐│
│ │ Geen / Wekelijks /   ││
│ │ 2-wekelijks          ││
│ └──────────────────────┘│
│                         │
│ 📝 Notities (optioneel) │
│ ┌──────────────────────┐│
│ │                      ││
│ └──────────────────────┘│
│                         │
│ [    Toevoegen    ]     │  ← FilledButton
│                         │
└─────────────────────────┘
```

## Validatie
- Titel: verplicht
- Datum: verplicht, moet in de toekomst
- Tijd: verplicht
