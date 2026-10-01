# GDPR Compliance Checklist

Systematisk checkliste til audit af software mod Regulation (EU) 2016/679. Hvert punkt refererer til artiklen. Inkluderer Digital Omnibus 2026-ændringer hvor relevant.

---

## 1. Lovligt grundlag (art. 6)

- [ ] Er der identificeret mindst ét lovligt grundlag for hver type behandling?
  - (a) Samtykke
  - (b) Kontrakt-opfyldelse
  - (c) Retlig forpligtelse
  - (d) Vitale interesser
  - (e) Samfundets interesse
  - (f) Legitim interesse (kræver balance-test)
- [ ] Hvis samtykke: er det frivilligt, specifikt, informeret, utvetydigt? (art. 4(11), art. 7)
- [ ] Hvis legitim interesse: er LIA (Legitimate Interest Assessment) dokumenteret?
- [ ] Hvis kontrakt: er behandlingen *nødvendig* for kontrakten, ikke bare "nice to have"?

## 2. Særlige kategorier (art. 9)

- [ ] Behandles data om helbred, etnicitet, religion, politisk overbevisning, seksualitet, biometri, genetik, fagforening?
- [ ] Hvis ja: er ét af undtagelserne i art. 9(2) opfyldt? (eksplicit samtykke, arbejdsret, vitale interesser, offentlig interesse m.fl.)
- [ ] Straffedomme/lovovertrædelser → kræver art. 10 grundlag

## 3. Samtykke (art. 7) — hvis relevant

- [ ] Kan samtykket trækkes tilbage lige så nemt som det blev givet?
- [ ] Er samtykket dokumenteret (hvem, hvornår, hvad, hvordan)?
- [ ] Er der separate samtykker for separate formål?
- [ ] Ingen pre-ticked checkboxes, ingen tvungne samtykker (cookie-walls er problematiske)
- [ ] Børns samtykke: under 16 (DK: 13) kræver forældremyndighed (art. 8)

## 4. Information til brugeren (art. 13 & 14)

Hvis data indsamles direkte (art. 13):
- [ ] Identitet og kontakt på dataansvarlig + evt. DPO
- [ ] Formål og lovligt grundlag
- [ ] Modtagere/kategorier af modtagere
- [ ] Tredjelandsoverførsler + garantier
- [ ] Opbevaringsperiode (eller kriterier)
- [ ] Rettigheder (adgang, berigtigelse, sletning, portabilitet, indsigelse)
- [ ] Ret til at klage til Datatilsynet
- [ ] Automatiserede afgørelser inkl. profilering

Hvis data indsamles fra tredjepart (art. 14):
- [ ] Alt ovenstående + kilden til data

## 5. Registreredes rettigheder (art. 15-22)

- [ ] **Art. 15 — Indsigt:** Kan bruger få kopi af sine data? Endpoint/flow eksisterer?
- [ ] **Art. 16 — Berigtigelse:** Kan bruger rette forkerte data?
- [ ] **Art. 17 — Sletning (ret til at blive glemt):** Kan data slettes komplet? Inkl. backups, cache, logs?
- [ ] **Art. 18 — Begrænsning:** Kan behandling pauses mens tvist løses?
- [ ] **Art. 20 — Dataportabilitet:** Kan bruger eksportere data i maskinlæsbart format (JSON/CSV)?
- [ ] **Art. 21 — Indsigelse:** Kan bruger gøre indsigelse mod behandling (særligt direkte markedsføring)?
- [ ] **Art. 22 — Automatiserede afgørelser:** Er der automatiseret profilering med juridisk virkning? Menneskelig review mulig?

**Svartid:** Anmodninger skal besvares inden 1 måned (art. 12(3)), kan forlænges med 2 måneder.

## 6. Privacy by Design og Default (art. 25)

- [ ] Er privacy indbygget fra start af designet, ikke bolted on?
- [ ] Er default-indstillinger de mest privatlivsvenlige? (f.eks. profil private by default)
- [ ] Minimum data indsamlet som default, ikke maximum

## 7. Sikkerhed (art. 32)

- [ ] Kryptering af persondata i transit (TLS) og at rest
- [ ] Pseudonymisering hvor muligt
- [ ] Adgangskontrol: role-based, least privilege, MFA på admin-konti
- [ ] Logging af adgang til persondata
- [ ] Regelmæssig test af sikkerhed (penetration tests, code review)
- [ ] Backup og disaster recovery
- [ ] Incident response plan

## 8. Databehandlere (art. 28)

- [ ] Er der databehandleraftale (DPA) med alle leverandører der behandler persondata?
  - Cloud (AWS, GCP, Azure, Hetzner)
  - Email (SendGrid, Mailchimp, Postmark)
  - Analytics (GA, Mixpanel, PostHog)
  - Payment (Stripe, Klarna)
  - Support (Intercom, Zendesk)
  - SMS/telefon (Twilio)
- [ ] Sub-databehandlere godkendt og listet?
- [ ] DPA'en inkluderer alle krav fra art. 28(3)?

## 9. Tredjelandsoverførsler (kap. V, art. 44-49)

- [ ] Bruges US-baserede services? (Google, Meta, Microsoft, AWS us-regions, OpenAI, Anthropic)
- [ ] Hvis ja: er der gyldigt overførselsgrundlag?
  - EU-US Data Privacy Framework (DPF) — tjek at leverandøren er certificeret
  - Standard Contractual Clauses (SCC) — 2021-version
  - Binding Corporate Rules (BCR)
- [ ] TIA (Transfer Impact Assessment) gennemført for risikable overførsler (Schrems II)?
- [ ] Overførsler til andre tredjelande uden tilstrækkelighedsafgørelse?

## 10. Records of Processing (art. 30)

- [ ] Er der en fortegnelse over behandlingsaktiviteter?
- [ ] Inkluderer den: formål, kategorier af data, modtagere, overførsler, sletningsfrister, sikkerhedsforanstaltninger?
- [ ] **Omnibus 2026:** Kravet foreslås lempet for SMV'er under visse betingelser — tjek status.

## 11. Databrud (art. 33 & 34)

- [ ] Er der en incident response plan?
- [ ] Kan et brud opdages og vurderes inden 72 timer?
- [ ] **Omnibus 2026:** Frist muligvis udvidet til 96 timer + single-entry point for anmeldelse.
- [ ] Kan påvirkede brugere informeres hurtigt hvis høj risiko?
- [ ] Er der en intern log over alle brud (selv dem der ikke anmeldes)?

## 12. DPIA — Konsekvensanalyse (art. 35)

Kræves ved høj risiko. Tjek om ét af disse gælder:
- [ ] Systematisk og omfattende profilering med juridiske virkninger
- [ ] Storskala behandling af særlige kategorier
- [ ] Systematisk overvågning af offentligt tilgængelige områder
- [ ] Datatilsynets egen liste (DK har offentliggjort en)

Hvis ja: er DPIA gennemført og dokumenteret?

## 13. DPO — Databeskyttelsesrådgiver (art. 37)

Kræves hvis:
- [ ] Offentlig myndighed
- [ ] Kerneaktivitet = systematisk overvågning i stor målestok
- [ ] Kerneaktivitet = storskala behandling af særlige kategorier

Hvis ja: er DPO udpeget og kontaktoplysninger tilgængelige?

## 14. Børn (art. 8)

- [ ] Henvender tjenesten sig til børn?
- [ ] Samtykke fra forældremyndighed hvis under 16 (DK: 13)?
- [ ] Alders-verifikation på plads?
- [ ] Information skrevet i børnevenligt sprog?

## 15. Markedsføring og cookies

**Bemærk: cookies reguleres primært af ePrivacy-direktivet (DK: Cookiebekendtgørelsen), ikke GDPR direkte, men de er tæt forbundne.**

- [ ] Cookie-banner vises før ikke-nødvendige cookies sættes?
- [ ] Lige så nemt at afvise som acceptere? (ingen "Accept all" uden tilsvarende "Reject all")
- [ ] Granulært samtykke per kategori?
- [ ] Dokumentation af samtykke (Consent Mode v2, CMP-log)?
- [ ] Newsletter: double opt-in? Nem afmelding?

## 16. Logging og telemetri — often overlooked

- [ ] Logger I persondata (emails, IPs, user-IDs) i plaintext?
- [ ] Retention på logs — automatisk sletning efter X dage?
- [ ] Adgang til logs begrænset?
- [ ] Aggregates I logs til tredjepart (Sentry, Datadog, LogRocket) — DPA + tredjelands-tjek?

## 17. AI og automatiseret behandling

- [ ] Bruges LLM/AI med brugerdata som input?
- [ ] Hvis data sendes til OpenAI/Anthropic/Google: DPA + tredjelandsgrundlag?
- [ ] Retention på prompts/completions hos AI-leverandør?
- [ ] Oplyses brugeren om AI-behandling?
- [ ] Menneskelig review af AI-beslutninger med juridisk virkning? (art. 22)
- [ ] Overlap med EU AI Act — tjek om brugen falder under high-risk kategori.

## 18. Dokumentation

- [ ] Privacy Policy offentligt tilgængelig og opdateret?
- [ ] Cookie Policy?
- [ ] Intern dokumentation: RoPA, DPIA'er, LIA'er, TIA'er?
- [ ] Uddannelse af personale i databeskyttelse?
- [ ] Klar procedure for indsigelse og klage?
