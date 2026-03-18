# Event Calendar

## Doel
Maandoverzicht van trainingen en wedstrijden per team.

## Layout
```
┌─────────────────────────┐
│ ← Heren 1               │
├─────────────────────────┤
│ ◀  Maart 2026       ▶  │
│ Ma Di Wo Do Vr Za Zo    │
│                    1     │
│  2  3  4  5  6  7  8    │
│  9 10 11 12 13 14 15    │
│ 16 17 18●19 20 21○22    │
│ 23 24 25●26 27 28 29    │
│ 30 31                    │
│                         │
│ ● = training (blauw)    │
│ ○ = wedstrijd (oranje)  │
│                         │
│ ─── 18 maart ────────── │
│ ┌──────────────────────┐│
│ │ 🏋 Training  19:00   ││
│ │ Sportpark Noord      ││
│ │ ✅ Aanwezig           ││
│ └──────────────────────┘│
│                    [+]  │
├─────────────────────────┤
│ 🏠 Home  👥 Teams  👤   │
└─────────────────────────┘
```

## Componenten
- Maand navigator: pijlen links/rechts, maand+jaar titel
- Kalender grid: 7 kolommen, stipjes op event-dagen
- Dag detail: events gefilterd op geselecteerde dag
- EventCard per event

## Interacties
- ◀ / ▶ → vorige/volgende maand (swipe ook)
- Tik op dag → filter events
- Tik op event → event detail
- Huidige dag: cirkel outline
- Geselecteerde dag: filled cirkel
