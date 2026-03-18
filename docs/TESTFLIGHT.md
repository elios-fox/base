# TestFlight CI/CD Setup

Automatische TestFlight deploys via GitHub Actions + Fastlane Match.

## Vereisten

- Apple Developer account met Admin-rol
- App Store Connect app aangemaakt (Bundle ID: `nl.com.club.manager`)
- GitHub repo: `elios-fox/base`

## Setup stappen

### 1. Private Git repo voor Match certificates

Maak een **private** repo aan, bijv. `elios-fox/certificates`. Deze repo slaat je signing certificates en provisioning profiles versleuteld op.

### 2. Fastlane Match initialiseren

```bash
cd ios
bundle install
bundle exec fastlane match appstore
```

Dit vraagt om:
- De URL van je certificates repo (bijv. `https://github.com/elios-fox/certificates.git`)
- Een encryptie-wachtwoord (bewaar dit goed!)

Match genereert een distribution certificate + provisioning profile en slaat ze versleuteld op in de certificates repo.

### 3. App Store Connect API Key aanmaken

1. Ga naar [App Store Connect → Users and Access → Integrations → App Store Connect API](https://appstoreconnect.apple.com/access/integrations/api)
2. Klik op **Generate API Key**
3. Naam: bijv. `GitHub Actions`
4. Rol: **Admin**
5. Noteer de **Key ID** en **Issuer ID**
6. Download het `.p8` bestand (kan maar 1x!)

Base64-encode de `.p8` key:

```bash
base64 -i AuthKey_XXXXXXXXXX.p8 | tr -d '\n'
```

### 4. GitHub Secrets toevoegen

Ga naar `elios-fox/base` → Settings → Secrets and variables → Actions → New repository secret.

| Secret | Waarde |
|--------|--------|
| `MATCH_GIT_URL` | `https://github.com/elios-fox/certificates.git` |
| `MATCH_PASSWORD` | Het wachtwoord dat je bij stap 2 hebt gekozen |
| `MATCH_GIT_BASIC_AUTHORIZATION` | Base64 van `username:personal-access-token` * |
| `ASC_KEY_ID` | Key ID uit stap 3 |
| `ASC_ISSUER_ID` | Issuer ID uit stap 3 |
| `ASC_KEY_CONTENT` | Base64-encoded `.p8` content uit stap 3 |

\* Genereer een GitHub PAT met `repo` scope, en base64-encode het:

```bash
echo -n "username:ghp_xxxxxxxxxxxx" | base64
```

### 5. Deploy triggeren

Push naar de `develop` branch:

```bash
git push origin develop
```

De GitHub Action bouwt de app en uploadt naar TestFlight. Na ~15-20 minuten verschijnt de build in TestFlight.

## Troubleshooting

- **Match kan certificates repo niet clonen**: Controleer `MATCH_GIT_BASIC_AUTHORIZATION` — de PAT moet `repo` scope hebben.
- **Code signing error**: Controleer of het certificate niet verlopen is. Run `bundle exec fastlane match nuke appstore` en daarna opnieuw `match appstore`.
- **Upload mislukt**: Controleer of de API key Admin-rol heeft en of de app in App Store Connect bestaat.
