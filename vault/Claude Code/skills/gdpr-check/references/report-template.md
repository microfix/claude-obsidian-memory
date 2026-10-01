# GDPR Audit Report Template

Brug dette skelet til alle audit-rapporter. Gem som `<vault>/AI/audits/gdpr/YYYY-MM-DD-<emne>.md`.

---

```markdown
---
tags: [gdpr, audit, compliance]
dato: YYYY-MM-DD
emne: <kort beskrivelse>
status: [draft|final]
---

# GDPR Audit: <emne>

**Dato:** YYYY-MM-DD
**Auditor:** Claude (gdpr-check skill)
**Scope:** <hvad blev auditeret — kode/feature/spec/leverandør>
**Reference:** Regulation (EU) 2016/679 konsolideret + Digital Omnibus 2026

## Executive Summary

- **Brud identificeret:** X
- **Risici:** Y
- **OK-punkter:** Z
- **Samlet risiko-vurdering:** [Høj / Middel / Lav]
- **Anbefalet handling:** [Øjeblikkelig / Planlagt / Monitor]

### Top 3 actions
1. <kritisk action>
2. <kritisk action>
3. <kritisk action>

## Persondata behandlet

| Type | Kategori | Kilde | Formål | Lovligt grundlag |
|------|----------|-------|--------|------------------|
| Email | Direkte | Registrering | Login | Kontrakt (art. 6(1)(b)) |
| IP | Indirekte | Server-log | Sikkerhed | Legitim interesse (art. 6(1)(f)) |
| ... | ... | ... | ... | ... |

## Findings

### ❌ Brud

#### 1. <kort titel>
- **Artikel:** Art. X, stk. Y
- **Beskrivelse:** <præcis hvad problemet er>
- **Bevis:** `<filepath:linje>` eller citat fra spec
- **Risiko:** <hvad kan gå galt — bøde, brugertab, omdømme>
- **Anbefaling:** <konkret fix, helst med kode-eksempel>

### ⚠️ Risici

#### 1. <kort titel>
- **Artikel:** Art. X
- **Beskrivelse:** <hvorfor det er uklart eller delvist>
- **Mitigation:** <hvad der skal gøres for at afklare>

### ✅ OK

- Art. 32 — TLS 1.3 på alle endpoints, adgangskontrol via OAuth2
- Art. 17 — Delete-flow dokumenteret i `/api/users/delete`
- ...

## Tredjepart / leverandører

| Leverandør | Data | DPA | Tredjelands-grundlag | Status |
|-----------|------|-----|----------------------|--------|
| SendGrid | Email | ✅ | DPF | OK |
| Hotjar | Session-replay | ❌ | SCC | ❌ Mangler DPA |
| ... | ... | ... | ... | ... |

## Anbefalinger (prioriteret)

### Umiddelbart (denne uge)
1. **[❌]** <action med fil-referencer>
2. **[❌]** <action>

### Kortsigtet (denne måned)
1. **[⚠️]** <action>
2. **[⚠️]** <action>

### Langsigtet
1. **[📋]** <dokumentation/proces-forbedring>

## Digital Omnibus 2026 — relevans

<Beskrivelse af om/hvordan kommende ændringer påvirker dette system, særligt:>
- Databrud-procedurer
- RoPA-krav
- AI-behandling

## Næste audit

**Anbefalet:** <dato, f.eks. om 6 måneder eller ved næste major release>

---

*Genereret af `gdpr-check` skill. Konsulter en jurist for bindende rådgivning.*
```
