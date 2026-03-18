# Team List

## Doel
Overzicht van alle teams waar de gebruiker lid van is.

## Layout
```
┌─────────────────────────┐
│ Teams                   │
├─────────────────────────┤
│                         │
│ ┌──────────────────────┐│
│ │ 👥 Heren 1           ││
│ │ Voetbal · 2025/2026  ││
│ │ 12 leden         >   ││
│ └──────────────────────┘│
│ ┌──────────────────────┐│
│ │ 👥 Dames 2           ││
│ │ Hockey · 2025/2026   ││
│ │ 8 leden          >   ││
│ └──────────────────────┘│
│                         │
│         [Join team]     │  ← Outlined button
│                         │
│                    [+]  │  ← FAB: nieuw team
├─────────────────────────┤
│ 🏠 Home  👥 Teams  👤   │
└─────────────────────────┘
```

## Componenten
- TeamCard: avatar, naam, sport, seizoen, ledenaantal, chevron
- "Join team" button: outlined, midden scherm
- FAB: nieuw team aanmaken

## Edge Cases
- **Empty**: Icon + "Nog geen teams" + "Maak een team aan of join via uitnodigingscode"
- **Loading**: Skeleton cards
