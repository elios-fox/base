# Team Detail

## Doel
Team info, ledenlijst en beheer.

## Layout
```
┌─────────────────────────┐
│ ← Heren 1         ⚙️    │
├─────────────────────────┤
│                         │
│ ┌─ Team Info ──────────┐│
│ │ Sport: Voetbal       ││
│ │ Seizoen: 2025/2026   ││
│ │ Code: HRN1-2026 [📋] ││
│ └──────────────────────┘│
│                         │
│ Leden (12)              │
│ ┌──────────────────────┐│
│ │ 👤 Jan de Vries      ││
│ │    Coach         [×] ││
│ ├──────────────────────┤│
│ │ 👤 Pieter Bakker     ││
│ │    Speler        [×] ││
│ ├──────────────────────┤│
│ │ 👤 Klaas Jansen      ││
│ │    Speler        [×] ││
│ └──────────────────────┘│
│                         │
│ [Deel uitnodigingslink] │
│                         │
├─────────────────────────┤
│ 🏠 Home  👥 Teams  👤   │
└─────────────────────────┘
```

## Componenten
- Team info card: sport, seizoen, invite code met kopieer-knop
- Ledenlijst: avatar, naam, rol, verwijder (alleen voor coach)
- Deel-knop: share invite link via native share sheet

## Interacties
- [📋] → kopieer code naar clipboard + snackbar "Code gekopieerd"
- [×] → bevestigingsdialog "Weet je zeker dat je X wilt verwijderen?"
- ⚙️ → team instellingen (naam, sport wijzigen)
