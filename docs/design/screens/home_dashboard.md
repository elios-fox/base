# Home Dashboard

## Doel
Overzicht van aankomende events en snelle acties.

## Layout
```
┌─────────────────────────┐
│ ClubHub            🔔(3)│  ← AppBar met notificatie badge
├─────────────────────────┤
│                         │
│ Hallo, Jan! 👋          │  ← Greeting card
│                         │
│ ┌─ Aankomende events ─┐ │
│ │ 🏋 Training          │ │
│ │ Di 19 mrt · 19:00   │ │
│ │ [Aanwezig ✓]         │ │
│ ├──────────────────────┤ │
│ │ ⚽ vs. SV Rivaal     │ │
│ │ Za 22 mrt · 14:30   │ │
│ │ [Nog niet gereageerd]│ │
│ └──────────────────────┘ │
│                         │
│ ┌─ Mijn teams ────────┐ │
│ │ 👥 Heren 1    3/5 ✓ │ │
│ └──────────────────────┘ │
│                         │
├─────────────────────────┤
│ 🏠 Home  👥 Teams  👤   │  ← Bottom nav
└─────────────────────────┘
```

## Componenten
- AppBar: titel + notificatie bell icon met unread badge
- Greeting card: naam van de gebruiker
- Aankomende events: max 3, horizontaal scrollbaar of vertical list
- Mijn teams: compact overzicht met aanwezigheidstatus

## Edge Cases
- **Empty**: "Nog geen events. Join een team om te beginnen."
- **Loading**: Skeleton cards
- **Error**: ErrorView met retry

## Interacties
- Tik op event → Event detail
- Tik op team → Team events
- Tik op 🔔 → Notificaties
