# ClubHub Design System

## Kleurenpalet

### Primary Colors
| Naam | Hex | Gebruik |
|------|-----|---------|
| Primary | `#2E7D32` | Hoofdacties, navigatie, branding |
| Primary Container | `#A5D6A7` | Achtergrond van primaire elementen |
| On Primary | `#FFFFFF` | Tekst op primary |

### Secondary Colors
| Naam | Hex | Gebruik |
|------|-----|---------|
| Secondary | `#F57C00` | Wedstrijden, urgente acties |
| Secondary Container | `#FFE0B2` | Achtergrond wedstrijd-elementen |

### Tertiary Colors
| Naam | Hex | Gebruik |
|------|-----|---------|
| Tertiary | `#1565C0` | Trainingen, informatief |
| Tertiary Container | `#BBDEFB` | Achtergrond training-elementen |

### Semantic Colors
| Status | Kleur | Hex | Icoon |
|--------|-------|-----|-------|
| Aanwezig | Groen | `#4CAF50` | `check_circle` |
| Afwezig | Rood | `#F44336` | `cancel` |
| Onzeker | Oranje | `#FF9800` | `help` |

### Neutrals
| Naam | Hex | Gebruik |
|------|-----|---------|
| Surface | `#FFFFFF` | Kaarten, sheets |
| Surface Variant | `#F5F5F5` | Secundaire achtergrond |
| On Surface | `#1C1B1F` | Primaire tekst |
| On Surface Variant | `#757575` | Secundaire tekst |
| Outline | `#E0E0E0` | Borders, dividers |

## Typografie

| Stijl | Font | Grootte | Gewicht | Gebruik |
|-------|------|---------|---------|---------|
| Display Large | Poppins | 32 | Bold | Cijfers/stats groot |
| Headline Medium | Poppins | 24 | SemiBold | Schermtitels |
| Title Large | Poppins | 20 | SemiBold | Card titels |
| Title Medium | Roboto | 16 | Medium | Lijstitems |
| Body Large | Roboto | 16 | Regular | Body tekst |
| Body Medium | Roboto | 14 | Regular | Secundaire tekst |
| Label Large | Roboto | 14 | Medium | Buttons |
| Label Small | Roboto | 11 | Medium | Chips, badges |

## Iconografie
- **Stijl**: Material Symbols, filled variant
- **Grootte**: 24px (standaard), 20px (compact), 32px (feature)
- **Key icons**: `groups` (teams), `fitness_center` (training), `emoji_events` (wedstrijd), `event` (kalender), `person` (profiel)

## Spacing & Layout

### Grid
- Base unit: **8px**
- Screen padding: **16px**
- Card padding: **16px**
- Card gap: **8px**

### Spacing Scale
| Token | Waarde | Gebruik |
|-------|--------|---------|
| xs | 4px | Inline spacing |
| sm | 8px | Compact elementen |
| md | 12px | Standaard gap |
| lg | 16px | Sectie spacing |
| xl | 24px | Grote secties |
| xxl | 32px | Scherm secties |

## Componenten

### Buttons
- **Filled**: Primary acties (48px hoogte, 8px border radius)
- **Outlined**: Secundaire acties
- **Text**: Tertiaire acties
- **FAB**: Hoofdactie per scherm (56px)
- **SegmentedButton**: RSVP selectie

### Cards
- Elevation: 1 (subtle shadow)
- Border radius: 12px
- Padding: 16px

### Chips
- Status chips: filled met semantic kleur
- Filter chips: outlined

### Bottom Navigation
- 3 tabs: Home, Teams, Profiel
- Active: primary kleur
- Inactive: on-surface-variant

### Bottom Sheet
- Gebruikt voor: event aanmaken, team settings
- Border radius top: 16px
- Handle bar: 32px breed, 4px hoog

### Snackbar
- Feedback na acties (RSVP, team join)
- Duur: 3 seconden
- Positie: boven bottom nav
