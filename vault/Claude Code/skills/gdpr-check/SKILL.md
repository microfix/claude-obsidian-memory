---
name: gdpr-check
description: Audit software, kode, databehandlings-flows eller produkt-specifikationer for GDPR-compliance. Bruger konsolideret Regulation (EU) 2016/679 + Digital Omnibus 2026-ændringer. Aktiveres ved "tjek GDPR", "GDPR audit", "bryder det her GDPR", "compliance-tjek", "databeskyttelse", "er det her lovligt efter GDPR", "privacy review", "DPIA", "data protection review", eller når brugeren deler kode/features/flows og nævner personoplysninger, cookies, tracking, samtykke, brugerdata, login-systemer, eller tredjelandsoverførsler.
---

# GDPR Compliance Audit

Auditér software eller specifikationer mod GDPR (Regulation (EU) 2016/679) og kommende Digital Omnibus-ændringer. Giver struktureret rapport med artikel-referencer, sværhedsgrad og konkrete anbefalinger.

## Når skillen aktiveres

Kør dette workflow:

### 1. Forstå scope

Hvad er genstanden for audit? Et af disse:
- **Kode/codebase** — læs relevante filer (auth, DB-schema, API-endpoints, tracking, storage)
- **Feature/flow** — brugerens beskrivelse af hvad softwaren gør
- **Specifikation/produkt** — dokument, PRD, kravsliste
- **Tredjepart/leverandør** — er det her værktøj/API GDPR-sikkert at bruge

Hvis scope er uklart, stil ét spørgsmål og gå i gang. Ikke flere rundbordsdiskussioner.

### 2. Identificér persondata

Først: Hvilke personoplysninger behandles? Kig efter:
- Direkte identifikatorer: navn, email, telefon, CPR, IP-adresse, device-ID
- Indirekte/pseudonyme: user-ID, session-ID, cookie-ID
- Særlige kategorier (art. 9): helbred, etnicitet, religion, seksualitet, biometri, politisk overbevisning
- Børn under 16 (eller DK: under 13 efter databeskyttelsesloven § 6)
- Offentligt tilgængelige data er stadig persondata hvis de identificerer

Hvis ingen persondata → skillen er irrelevant, sig det og stop.

### 3. Kør checklisten

Load `references/checklist.md` og gennemgå hvert område systematisk. For hvert punkt, afgør:
- ✅ **OK** — opfylder kravet
- ⚠️ **Risiko** — delvist eller uklart, kræver dokumentation/review
- ❌ **Brud** — direkte i strid med GDPR

Hvis specifikke artikler er relevante, load `references/articles.md` for detaljer.

### 4. Tjek Digital Omnibus-ændringer (2026)

Load `references/omnibus-2026.md` for at tjekke om ændringerne påvirker vurderingen. Særligt relevant ved:
- Databrud-procedurer (timing, single-entry point)
- Records of processing (Art. 30)
- Børns samtykke

### 5. Producér rapport

Brug formatet i `references/report-template.md`. Gem den i `<vault>/AI/audits/gdpr/YYYY-MM-DD-<emne>.md` hvis det er en substantiel audit brugeren vil kunne finde senere. Skriv også et kort sammendrag direkte i chatten.

## Nøgleprincipper der ALTID skal tjekkes

Disse 7 er grundpillerne (art. 5). Hver feature/flow skal overholde alle:

1. **Lovlighed, rimelighed, gennemsigtighed** — Er der et lovligt grundlag (art. 6)? Er brugeren informeret (art. 13/14)?
2. **Formålsbegrænsning** — Bruges data kun til det formål det blev indsamlet for?
3. **Dataminimering** — Indsamles kun det der er strengt nødvendigt?
4. **Rigtighed** — Kan forkerte data rettes?
5. **Opbevaringsbegrænsning** — Er der en sletnings- eller anonymiseringspolitik?
6. **Integritet og fortrolighed** — Kryptering, adgangskontrol, logging?
7. **Ansvarlighed** — Kan compliance dokumenteres?

## Særligt farlige mønstre — se efter disse i kode

- `SELECT *` på user-tabeller uden filter → dataminimering-brud
- Emails/PII i logs → integritet-brud + risiko ved log-aggregation
- Cookies uden samtykke før deres sættes (undtagen strengt nødvendige) → ePrivacy-brud
- Google Analytics/Meta Pixel/Hotjar uden consent management → samtykke-brud + tredjelands-overførsel
- API-kald til US-baserede services med PII uden SCC/DPF → art. 44-49 brud
- `last_login`, `ip_address`, `user_agent` uden retention policy
- Delete-flows der kun "soft-deleter" → art. 17 brud hvis ikke dokumenteret
- Ingen `/api/me/data`-endpoint eller eksport → art. 15/20 problem
- Hardcoded admin-adgang til prod-databaser → art. 32 brud
- Manglende `Data Processing Agreement` (databehandleraftale) med leverandører

## Opdatering af referencer

Den konsoliderede GDPR-tekst opdateres periodisk på EUR-Lex. For at genhente nyeste version:

```bash
bash "$HOME/.claude/skills/gdpr-check/scripts/fetch-latest.sh"
```

Scriptet henter seneste konsoliderede tekst fra EUR-Lex (`https://eur-lex.europa.eu/eli/reg/2016/679/oj`) og opdaterer `references/gdpr-fulltext.md`. Kør det hvis du er i tvivl om en specifik artikel, eller hvis auditten er vigtig og sidst-hentet-dato er mere end 3 måneder gammel.

## Output-stil

- **Konkret, ikke akademisk** — "Du logger email i plain text på linje 42. Fix: hash det eller fjern feltet." slår "Overvej implikationerne af at logge persondata".
- **Sværhedsgrad markeret** — ❌ brud / ⚠️ risiko / ✅ ok
- **Artikel-reference** — altid "art. X, stk. Y" så brugeren kan slå op
- **Anbefaling per finding** — ikke bare "problem", men "fix"

## Rapport-format

Se `references/report-template.md` for fuldt skelet. Kort version:

```markdown
# GDPR Audit: <emne>
**Dato:** YYYY-MM-DD
**Auditor:** Claude (gdpr-check skill)
**Reference:** Regulation (EU) 2016/679 konsolideret + Omnibus 2026

## Executive summary
- X brud, Y risici, Z ok-punkter
- Samlet compliance-vurdering: [Høj/Middel/Lav risiko]
- Top 3 actions

## Findings
### ❌ Brud
### ⚠️ Risici
### ✅ OK

## Anbefalinger (prioriteret)
1. ...
```
