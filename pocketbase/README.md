# PocketBase Backend — ClubHub

## Setup

### 1. Download PocketBase
Download de laatste versie van [pocketbase.io](https://pocketbase.io/docs/):

```bash
# macOS (Apple Silicon)
curl -L https://github.com/pocketbase/pocketbase/releases/latest/download/pocketbase_0.25.0_darwin_arm64.zip -o pocketbase.zip
unzip pocketbase.zip -d ./pocketbase
rm pocketbase.zip
```

### 2. Start PocketBase
```bash
cd pocketbase
./pocketbase serve --migrationsDir=../pb_migrations --hooksDir=../pb_hooks
```

Of gebruik de Makefile:
```bash
make serve
```

### 3. Admin Dashboard
Open http://127.0.0.1:8090/_/ en maak een admin account aan.

### 4. Seed Data
De seed migration (`1679000005_seed_data.js`) maakt automatisch testdata aan:
- **Coach**: coach@clubhub.test / testtest123
- **Speler 1**: speler1@clubhub.test / testtest123
- **Speler 2**: speler2@clubhub.test / testtest123
- **Team**: Heren 1 (inviteCode: HRN1-2026)
- **Events**: 5 trainingen/wedstrijden
- **Attendances**: diverse reacties

## Environment Variabelen

| Variabele | Default | Beschrijving |
|-----------|---------|-------------|
| `PB_DATA_DIR` | `./pb_data` | Data directory |
| `PB_HOOKS_DIR` | `../pb_hooks` | Hooks directory |
| `PB_MIGRATIONS_DIR` | `../pb_migrations` | Migrations directory |

## Collections

| Collection | Beschrijving |
|-----------|-------------|
| `users` | Auth collection (PocketBase built-in + custom fields) |
| `teams` | Teams met leden en uitnodigingscode |
| `events` | Trainingen en wedstrijden |
| `attendances` | Aanwezigheidsregistratie per event |
| `notifications` | In-app notificaties |

## Custom API Routes

| Method | Route | Beschrijving |
|--------|-------|-------------|
| POST | `/api/clubhub/teams/join` | Join team via inviteCode |

## Development Workflow

1. Start PocketBase: `make serve`
2. Start Flutter app: `flutter run`
3. Flutter app verbindt met `http://127.0.0.1:8090`
