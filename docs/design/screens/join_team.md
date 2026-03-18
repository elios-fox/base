# Join Team

## Layout
```
┌─────────────────────────┐
│ ← Team joinen           │
├─────────────────────────┤
│                         │
│        👥               │
│                         │
│  Voer de uitnodigings-  │
│  code in die je van je  │
│  coach hebt ontvangen.  │
│                         │
│ ┌──────────────────────┐│
│ │ HRN1-2026            ││  ← TextField, auto-caps
│ └──────────────────────┘│
│                         │
│ [    Deelnemen    ]     │  ← FilledButton
│                         │
│ ┌─ Succes ─────────────┐│
│ │ ✅ Welkom bij Heren 1!││  ← Succes state
│ │ [Bekijk team →]       ││
│ └──────────────────────┘│
│                         │
└─────────────────────────┘
```

## States
- **Idle**: tekstveld + knop
- **Loading**: knop met spinner
- **Succes**: groene bevestiging + link naar team
- **Error**: rode tekst onder veld ("Code niet gevonden" / "Je bent al lid")
