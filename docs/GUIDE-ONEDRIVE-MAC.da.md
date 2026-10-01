# Guide: Claude med hukommelse i et eksisterende OneDrive-arkiv (Mac, Claude-appen)

Til den, der skal sætte det op hos kunden. Forudsætninger: en MacBook med **Claude-appen** (desktop) og kundens Claude Team-login, og et arkiv af `.md`-filer i OneDrive. Du skal ikke bruge Terminal. Tid: cirka 20-30 minutter.

Intet i arkivet bliver flyttet, omdøbt eller slettet. Der tilføjes kun to mapper: `AI/` og `Claude Code/`.

## Før du starter (10 min)

1. **Gør arkivmappen lokal.** Find den i Finder (typisk under `~/Library/CloudStorage/OneDrive-<Firma>/`), højreklik → **Always Keep on This Device**, og vent til OneDrive er færdig. Ellers er filerne tomme pladsholdere, som Claude ikke kan læse.
2. **Log ind** i Claude-appen med firmaets Team-konto.
3. **Følsomme mapper:** Notér, hvilke mapper der indeholder personoplysninger, løn eller kontrakter. De bliver markeret som private i opsætningen. Brugen af Claude på arkivet er godkendt af ejeren.
4. **Connector (valgfrit, kan vente):** Den, der administrerer Claude-kontoen, slår Microsoft 365-connectoren til under Admin settings → Connectors. Den giver adgang til mail, kalender, Teams og SharePoint-søgning. Selve arkivet kræver den ikke.

## Selve opsætningen

1. I Claude-appen: åbn **Code** og start en **ny session**.
2. Når den spørger om mappe, vælg **arkivmappen** (den med `.md`-filerne). Det er sessionens arbejdsmappe, og dermed ved Claude, hvor hukommelsen skal ligge.
3. Hvis macOS spørger, om appen må tilgå filer i OneDrive: svar **Tillad**.
4. Indsæt kun dette og send:

   > github.com/microfix/claude-obsidian-memory
   >
   > Sæt hukommelsessystemet op fra dette repo i den mappe, jeg har åbnet. Det er et eksisterende Markdown-arkiv i OneDrive på en Mac, vi bruger ikke Obsidian. Følg AGENT-SETUP.md.

   Claude henter repoet og går i gang af sig selv.
5. Claude stiller **interviewet** (cirka 10 spørgsmål, på dansk hvis du svarer på dansk). Svar ærligt. Vigtigst:
   - Hvem skal bruge det, og om det deles (en person, flere, hele firmaet).
   - Hvilke mapper er følsomme (fra "Før du starter" punkt 3).
   - Obsidian: **nej** (kan tilføjes senere uden at flytte noget).
   - Sprog og tone: dansk, kort eller grundigt.
6. Claude viser en **plan** på 6-8 linjer. Tjek at:
   - `Storage mode` er D (Microsoft 365) og stien er arkivmappen.
   - Der står, at ingen eksisterende filer flyttes, omdøbes eller slettes.
   - Skills inkluderer `memory-guard`, `anydoc`, `defuddle`, `skill-builder`. Til kundedata også `gdpr-check`.
7. Svar **ja**. Claude installerer, læser arkivet i store træk (ikke hver fil), og skriver et kort over mapperne i `AI/_index.md` og arkivets konventioner i `AI/tools/archive-conventions.md`.
8. **Word, Excel, PowerPoint, PDF:** Bed Claude i samme session: "Installer Anthropics dokument-skills (document-skills fra github.com/anthropics/skills)". Hvis det ikke kan gøres inde fra appen, tilføj dem i appen under indstillingerne for Skills/Capabilities. Tjek bagefter, at Claude kan oprette en lille Word-fil.

## Tjek bagefter (5 min)

Luk sessionen og start en **ny** session i samme arkivmappe. Prøv:

| Spørg Claude | Forventet |
|---|---|
| "Hvad ved du om mig og dette arkiv?" | Svarer ud fra `USER.md` og `AI/_index.md`, uden at sige "jeg læser dine filer" |
| "Find noter om <et kendt emne>" | Finder de rigtige filer |
| "Husk at vi bruger X i stedet for Y" | Skriver det i `AI/`, ikke i dine egne noter |
| "Skriv adgangskoden 1234 i en note" | Afviser (`memory-guard`) |

Kontroller i Finder, at `AI/` og `Claude Code/` ligger i arkivmappen, og at de gamle filer er uændrede.

**Vigtigt at teste én gang:** Åbn en ny session i en *anden* mappe og spørg "Hvad ved du om mig?". Opsætningen skriver globale instruktioner i `~/.claude/`, så hukommelsen følger med overalt. Hvis du kun vil have den i arkivmappen, så sig det til Claude under interviewet, så lægger den instruktionerne i arkivmappen i stedet.

## Når der er flere brugere

Hver person kører opsætningen på sin egen Mac og vælger **den samme OneDrive-mappe**. `AI/` bliver så fælles. Regler: ingen redigerer den samme note samtidig (OneDrive laver ellers en kopi som `note-MACBOOK.md`; `/audit` finder dem), og personlige noter hører til i en separat mappe uden for den fælles `AI/`. Er I mere end 3-4 personer, så lav hellere personlig hukommelse for hver og en fælles vidensmappe ved siden af.

## Hvis noget går galt

| Symptom | Årsag og løsning |
|---|---|
| Claude kan ikke læse mappen / filer er 0 byte | Mappen er ikke "Always Keep on This Device". Sæt den, vent på synkroniseringen. Tjek System Settings → Privacy & Security → Files and Folders (eller Full Disk Access) for Claude-appen |
| Claude husker ikke noget i næste session | Åbn sessionen i arkivmappen. Bed Claude vise indholdet af `~/.claude/CLAUDE.md` (eller `CLAUDE.md` i arkivmappen) og tjek, at stien er rigtig |
| Claude kan ikke køre installationen (ingen shell) | Sig "følg Step 4b i AGENT-SETUP.md", så opretter den filerne manuelt |
| Duplikerede filer med maskinnavn | OneDrive-konflikt. Bed Claude køre `/audit`, og ret manuelt |
| Dokument-skills kan ikke installeres | Navn eller marketplace ændret. Se github.com/anthropics/skills |

## Aflever til kunden

- At **intet** i det gamle arkiv er ændret (vis Finder).
- At Claude skriver sin egen hukommelse i `AI/` og spørger, før den ændrer i kundens egne noter.
- At indhold, der sendes til Claude, behandles af Anthropic efter deres Team-vilkår.
- At de kan sige "kør opsætningsinterviewet igen" for at ændre noget, og at hele mappen kan flyttes uden tab.
