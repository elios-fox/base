# ClubHub User Flows

## 1. Onboarding Flow
```
[Splash Screen] → [Welkom] → [Login/Registreer]
                                    ↓
                            [Keuze: Maak team / Join team]
                              ↓                    ↓
                    [Team Setup]           [Voer code in]
                    - Naam                  - Invite code
                    - Sport                 - Bevestiging
                    - Seizoen                    ↓
                         ↓                 [Dashboard]
                    [Leden uitnodigen]
                         ↓
                    [Dashboard]
```

## 2. Aanwezigheid Flow (Speler)
```
[Dashboard]
    ↓ tik op event card
[Event Detail]
    ↓
[Bekijk info: datum, tijd, locatie]
    ↓
[RSVP: Aanwezig / Onzeker / Afwezig]
    ↓ (bij afwezig)
[Reden opgeven (optioneel)]
    ↓
[Bevestiging snackbar]
    ↓
[Terug naar overzicht]
```

## 3. Aanwezigheid Flow (Coach)
```
[Dashboard]
    ↓
[Team selecteren]
    ↓
[Kalender met events]
    ↓ tik op event
[Event Detail]
    ├── Aanwezigheidslijst (wie reageert)
    ├── Stats: X aanwezig / Y afwezig / Z onzeker
    └── Nog niet gereageerd lijst
```

## 4. Team Beheer Flow
```
[Teams overzicht]
    ↓ tik op team
[Team Detail]
    ├── Leden lijst (met rollen)
    ├── Uitnodigingscode (kopieer/deel)
    ├── Team instellingen
    └── Statistieken
         ├── Aanwezigheidspercentage per speler
         └── Totaal per event
```

## 5. Event Aanmaken Flow
```
[Team Events] → FAB +
    ↓
[Type kiezen: Training / Wedstrijd]
    ↓
[Details invullen]
    - Titel
    - Datum (date picker)
    - Tijd (time picker)
    - Locatie
    - Notities
    ↓
[Herhaling? (optioneel)]
    - Wekelijks / 2-wekelijks
    - Tot datum
    ↓
[Opslaan]
    ↓
[Push notificatie → alle teamleden]
```

## 6. Notificaties Flow
```
[Bell icon met badge] → tik
    ↓
[Notificatie lijst]
    ├── "Nieuwe training: Training dinsdag"
    ├── "Pieter is afwezig bij Training"
    └── "Herinnering: Wedstrijd morgen!"
    ↓ tik op notificatie
[Navigeer naar relevant scherm]
```

## 7. Join Team Flow
```
[Teams overzicht] → "Join team" knop
    ↓
[Voer uitnodigingscode in]
    ↓
[Validatie]
    ├── Succes → "Welkom bij Heren 1!" → Team detail
    ├── Al lid → "Je bent al lid van dit team"
    └── Ongeldig → "Code niet gevonden"
```
