# Digital Omnibus 2026 — ændringer til GDPR

Europa-Kommissionens Digital Omnibus-pakke (foreslået 2025, forventet adoption medio 2026) ændrer flere procedurale aspekter af GDPR. Kerneprincipperne er uændrede — ændringerne er primært lempelser for SMV'er og harmonisering af databrud-procedurer.

## Status per april 2026

- **Forslag vedtaget:** I gang i Parlamentet og Rådet
- **Artikel 4(2)(b) og (3):** Gælder fra **5. marts 2026**
- **Fuld pakke:** Forventet adoption medio 2026
- **Kilde:** https://commission.europa.eu/document/download/7fd9c846-b894-4f9f-b164-3b926d1b264b_en

## Konkrete ændringer der kan påvirke compliance-vurdering

### 1. Databrud-anmeldelse (art. 33)

**Nu:** 72 timer til at anmelde til Datatilsynet efter opdagelse.

**Omnibus:** Foreslået udvidet til **96 timer**. Herudover introduceres et **single-entry point** (ét samlet anmeldelsessystem på tværs af EU) så virksomheder ikke skal anmelde separat i hvert land de opererer i.

**Standardiseret skabelon:** Fælles EU-skabelon for databrud-anmeldelser.

### 2. Records of Processing (art. 30)

**Nu:** Alle virksomheder med >250 ansatte SKAL føre fortegnelse. Under 250 også, hvis behandlingen er risiko- eller systematisk.

**Omnibus:** Lempelser for SMV'er — reducerede krav når risikoen er lav. Præcis afgrænsning forventes i implementeringsakter.

### 3. Artikel 4 — Definitioner

Ændringer til punkt 2(b) og 3 træder i kraft 5. marts 2026. Handler primært om præcisering af:
- Hvad der tæller som "behandling" (art. 4(2)(b))
- Definition af pseudonymisering ift. AI-træning (art. 4(3))

**Konkret effekt:** AI-træning på pseudonymiserede data får klarere retsvilkår. Relevant hvis auditten involverer AI/ML.

### 4. Børns samtykke

Diskussioner om at harmonisere alders-grænsen på tværs af EU (pt. varierer fra 13-16). Ikke endelig endnu.

### 5. Samspil med AI Act

Omnibus justerer overlap mellem GDPR og AI Act, særligt:
- Automatiserede afgørelser (GDPR art. 22) vs. high-risk AI systems (AI Act)
- DPIA kan potentielt kombineres med AI-konsekvensanalyse

## Hvad der IKKE ændres

Følgende er stadig i fuld kraft og upåvirket:
- De 7 principper (art. 5)
- Lovligt grundlag (art. 6)
- Registreredes rettigheder (art. 15-22)
- Bødeniveauer (art. 83) — fortsat op til 20M EUR eller 4% af global omsætning
- Privacy by Design (art. 25)
- Sikkerhedskrav (art. 32)
- Tredjelandsoverførsler (kap. V)

## Implikationer for audit

Når Omnibus er adopteret fuldt, justér audit-tilgang således:
1. Databrud-procedurer kan tillade 96-timers vindue, men best practice er stadig hurtigst muligt.
2. Small business exemptions til RoPA — tjek om klienten kvalificerer.
3. Nye skabeloner kan erstatte ældre incident-response dokumentation.

Indtil adoption: Behandl nuværende GDPR (72 timer etc.) som gældende ret.

## Hold dig opdateret

- **EUR-Lex konsolideret version:** https://eur-lex.europa.eu/eli/reg/2016/679/oj/dan
- **EDPB retningslinjer:** https://edpb.europa.eu/
- **Datatilsynet (DK):** https://www.datatilsynet.dk/
- Kør `scripts/fetch-latest.sh` for at opdatere lokalt.
