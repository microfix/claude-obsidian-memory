# Guide: Din personlige Claude og virksomhedens fælles arkiv

Til alle i virksomheden. Arkivet (den fælles Obsidian-mappe i OneDrive) er virksomhedens **eneste sandhed**. Din personlige `CLAUDE.md` fortæller Claude, **hvem du er**, hvad din rolle er, og **hvad du lægger ind og henter ud**. De fælles regler ligger i arkivet og gælder for alle.

## Sådan hænger det sammen

| Lag | Hvor | Hvem | Indhold |
|---|---|---|---|
| Fælles regler | `CLAUDE.md` i arkivets rod | Alle (vedligeholdes af bibliotekaren) | Virksomhederne, hvor ting findes, hvordan man skriver, hvad der aldrig må ind |
| Skill `vault-keeper` | Installeres hos alle | Alle | Den præcise håndtering: filing, kilder, ingen konflikter |
| Din personlige `CLAUDE.md` | `~/.claude/` på din Mac | Kun dig | Navn, titel, rolle, data ind og ud, systemer, dine vaner |
| Din profil | `People/<dit-navn>.md` i arkivet | Alle kan se den | Arbejdsinfo: titel, rolle, hvad du arbejder med |

## Del 1: Til bibliotekaren (én gang)

Forudsætning: Arkivet er organiseret (se `GUIDE-ONEDRIVE-MAC.da.md`), og `vault-keeper` er installeret.

1. **Udfyld `AI/company/ROLES.md`:** Hvilke roller findes (én række pr. rolle, ikke pr. person), hvad hver normalt skriver til, læser, lægger ind og henter ud. Claude hjælper dig med et spørgsmål ad gangen.
2. **Udfyld `AI/company/SYSTEMS.md`:** Hvilket system ejer hvilke data (sager, timer, fakturaer, regnskab, tegninger). Arkivet kopierer ikke de data, det peger på systemet.
3. **Opret den fælles `CLAUDE.md`** i arkivets rod ud fra `AI/company/COMPANY-CLAUDE-TEMPLATE.md`. Claude gør det, når I kører omorganiseringen (trin 9 i `vault-organizer`).
4. **Beslut det følsomme.** I har valgt, at **alle læser alt**. Så må følgende **ikke** ligge i arkivet: løn, HR-sager, sundhedsoplysninger, CPR-numre, private adresser og telefonnumre, bankoplysninger, adgangskoder. Lad det blive uden for den delte mappe. Claude afviser at gemme det, og `vault.py check` lister notes, der ligner det, ikke. Tjek derfor selv, at intet sådant lå i det gamle arkiv.
5. **Giv kollegerne to ting:** denne guide og beskeden under "Del 2".

**Løbende:** Hver uge (10 min) kører du `/audit` og går de noter igennem, der stadig står som `unverified`. Ret eller sæt `status: verified`. Konfliktkopier afgør de to involverede.

## Del 2: Til dig (cirka 15 minutter)

Du skal bruge: en Mac, Claude-appen med firmaets Team-login, og arkivmappen synkroniseret på din Mac (**Always Keep on This Device**).

1. Åbn **Code** i Claude-appen, start en **ny session**, og vælg **arkivmappen**. Tillad adgang, hvis macOS spørger.
2. Skriv:

   > Læs AI/company/PERSON-SETUP.md i denne mappe og sæt min personlige Claude op.

3. Claude stiller dig ni korte spørgsmål, ét ad gangen:
   - dit navn og din titel,
   - hvilken virksomhed (eller flere) du arbejder for,
   - din rolle (du vælger den, der passer bedst),
   - hvad du laver i en almindelig uge,
   - **hvad du lægger ind** (mødenoter, tilbud, billeder, kundeopkald …) og hvor,
   - **hvad du henter ud eller laver til andre** (status, tilbud, overblik, rapporter),
   - hvilke systemer du bruger,
   - hvordan Claude skal opføre sig over for dig (sprog, kort eller grundigt),
   - en bekræftelse: din titel og rolle bliver synlige for alle i `People/`.
4. Claude installerer fælles skills fra arkivet, skriver din personlige `CLAUDE.md`, og opretter din profil. Hvis du allerede har en `CLAUDE.md`, beholder den dine egne vaner, flytter fakta om virksomheden ind i arkivet og gemmer den gamle som `CLAUDE.md.bak-<dato>`. Den viser dig forskellen, før noget overskrives.
5. **Test** i en ny session på arkivmappen:

   | Skriv | Forventet |
   |---|---|
   | "Hvem er jeg?" | Dit navn, din titel og rolle |
   | "Hvad ved vi om <en kunde>?" | Svar fra arkivet med henvisning til noter |
   | "Gem dette: <en kort oplysning>" | En ny note det rigtige sted med forfatter, kilde og `unverified` |
   | "Gem min løn" | Claude afviser og siger, hvor det hører hjemme |

## Hvad du skal vide om arkivet

- **Alle kan læse og skrive det samme.** Din rolle bestemmer, hvad Claude viser dig først og hvor den normalt lægger dit. Det er ikke en lås.
- **Nyt = ny note.** Claude lægger ny viden i en ny, dateret note med dit navn, en kilde og `status: unverified`. Den retter kun små ting i andres noter og sletter aldrig noget.
- **Én skriver pr. fil.** Redigér ikke den samme note som en kollega samtidig. Opstår der en kopi som `note-MACBOOK.md`, så lad Claude vise den, og tal med din kollega om, hvilken der gælder.
- **Kilder.** Claude skriver ikke et "faktum" ind uden en kilde. Står der ingenting i arkivet, siger den det i stedet for at gætte.
- **Dine egne noter og din egen log** ligger i `People/<dit-navn>/`. Kun du skriver der.
- **Sager, timer, fakturaer og regnskab** ligger i systemerne. Claude peger dertil og opfinder ikke tal.

## Hvis noget går galt

| Symptom | Løsning |
|---|---|
| Claude kender ikke dig i en ny session | Åbn sessionen i arkivmappen, eller bed Claude vise `~/.claude/CLAUDE.md` og tjek, at stien til arkivet er rigtig |
| "Kan ikke finde arkivet" / filer er tomme | Mappen er ikke sat til **Always Keep on This Device**. Sæt den, og vent på OneDrive |
| Claude gemmer noget det forkerte sted | Sig det, så flytter den det til `Inbox/` eller det rigtige sted og retter indexet |
| Du ser en `note-MACBOOK.md`-kopi | OneDrive-konflikt. Bed Claude køre `/audit` og lad bibliotekaren afgøre |
| Du vil ændre rolle eller vaner | Sig "kør den personlige opsætning igen" |
