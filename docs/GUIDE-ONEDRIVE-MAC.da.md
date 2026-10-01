# Guide: Gør et OneDrive-arkiv til ét samlet Obsidian-vault med Claude (Mac, Claude-appen)

Til den, der skal sætte det op hos kunden. Forudsætninger: en MacBook med **Claude-appen** og kundens Claude Team-login, og et arkiv af `.md`-filer (og dokumenter) i OneDrive, der dækker **flere virksomheder**. Du skal ikke bruge Terminal. Tid: 1-2 timer, mest ventetid.

**Resultat:**
- Arkivet er sorteret **pr. virksomhed** (`Companies/<Virksomhed>/…`, fælles ting i `Shared/`).
- Hver mappe har en `_index.md` med links til mapper og filer, og roden har `Home.md`.
- Alle noter følger Obsidian-regler (frontmatter, wikilinks), og mappen kan åbnes direkte i Obsidian.
- Claudes `CLAUDE.md` er opdateret, så arkivet er **den eneste sandhed** om virksomhederne.
- Alt, der flyttes, står i en journal og kan **fortrydes**. Intet bliver slettet.

## Før du starter (20 min)

1. **Gør arkivmappen lokal.** Find den i Finder (typisk under `~/Library/CloudStorage/OneDrive-<Firma>/`), højreklik → **Always Keep on This Device**, og vent til OneDrive er færdig. Ellers er filerne tomme pladsholdere.
2. **Sig til kollegerne:** Når filerne flyttes, må ingen redigere i arkivet. Efterfølgende skal OneDrive bruge tid på at synkronisere de mange flytninger.
3. **Backup:** Claude tilbyder at kopiere hele arkivet til `~/Documents/Arkiv-backup-<dato>` (uden for OneDrive). Sørg for, at der er plads, og sig ja. OneDrive har også versionshistorik og papirkurv som ekstra sikkerhed.
4. **Log ind** i Claude-appen med firmaets Team-konto.
5. **Python:** Hvis macOS under arbejdet spørger, om den skal installere "udviklerværktøjer" (command line developer tools), så tryk **Installer** og vent et par minutter. Claude bruger et lille script til at flytte filer sikkert.
6. **Obsidian (kan tages til sidst):** Hent gratis fra obsidian.md og læg i Programmer. Claude fortæller, hvornår.
7. **Connector (valgfrit):** Den, der administrerer Claude-kontoen, kan slå Microsoft 365-connectoren til (Admin settings → Connectors). Arkivet kræver den ikke.

## Selve opsætningen

1. I Claude-appen: åbn **Code** og start en **ny session**.
2. Vælg **arkivmappen** som mappe. Hvis macOS spørger, om appen må tilgå filer i OneDrive: **Tillad**.
3. Indsæt dette og send:

   > github.com/microfix/claude-obsidian-memory
   >
   > Sæt hukommelsessystemet op fra dette repo i den mappe, jeg har åbnet. Det er et eksisterende Markdown-arkiv i OneDrive på en Mac for flere virksomheder. Organiser arkivet fuldt ud (niveau 2) efter virksomhed, vi vil bruge Obsidian ovenpå, og opdater vores CLAUDE.md, så arkivet er den eneste sandhed. Følg AGENT-SETUP.md og vault-organizer.

   Claude går i gang af sig selv.
4. **Interview** (korte spørgsmål, på dansk). Vigtigst:
   - **Virksomhedernes navne** (præcis som mapperne skal hedde).
   - **Hvilken af de nuværende mapper hører til hvilken virksomhed**, og hvad der er fælles. Claude foreslår, du retter.
   - **Følsomme mapper** (løn, HR, kontrakter, persondata). De holdes private.
   - Hvem skal bruge det, og om det deles.
5. Claude kører en **optælling** og viser et kort resumé (antal filer, dubletter, konfliktkopier).
6. **Planen.** Claude skriver `AI/migration/PLAN.md` og viser, hvad der flyttes hvorhen (pr. mappe, med antal filer), hvad der ryger i `Inbox/` fordi den ikke kunne placere det, og dubletter/konfliktkopier. **Læs den og ret, hvis noget er forkert.** Claude gør intet, før du siger **ja**.
7. Claude **flytter** filerne (kontrollerer hver fil med et fingeraftryk), retter links, tilføjer frontmatter (`company`, `type`, `tags`), opretter `_index.md` i alle mapper og `Home.md`, og skriver korte introtekster ud fra indholdet. Store arkiver får først virksomhedssider og de to øverste niveauer; resten kommer i senere sessioner.
8. Claude **tjekker** resultatet (brudte links, mapper uden index, noter uden frontmatter) og skriver `AI/migration/REPORT.md`.
9. **Obsidian:** Åbn Obsidian → **Open folder as vault** → vælg arkivmappen. Tjek, at `Home.md` åbner, og at du kan klikke dig fra virksomhed til mappe til note.
10. **CLAUDE.md:** Claude gennemgår den eksisterende `CLAUDE.md`, flytter fakta om virksomheder ind i arkivet, foreslår en kort ny udgave med reglen "arkivet er den eneste sandhed", viser dig forskellen og gemmer den gamle som `CLAUDE.md.bak-<dato>`. Svar **ja**, når du er tryg.
11. **Word, Excel, PowerPoint, PDF:** Bed Claude: "Installer Anthropics dokument-skills (document-skills fra github.com/anthropics/skills)". Hvis det ikke kan gøres inde fra appen, tilføj dem i appens indstillinger for Skills.

## Tjek bagefter (10 min)

Luk sessionen og start en **ny** i samme arkivmappe. Prøv:

| Spørg Claude | Forventet |
|---|---|
| "Hvad ved du om <Virksomhed A>?" | Svarer ud fra virksomhedens `_index.md` og noter, med henvisning til filerne |
| "Hvad er forskellen på A og B?" | Slår op i begge virksomheders mapper |
| "Find tilbuddet til <kunde>" | Finder den rigtige fil i den rigtige virksomhed |
| "Husk at <ny fakta om A>" | Skriver det i `Companies/A/…`, opdaterer indexet, rører ikke andres noter |
| "Skriv adgangskoden 1234 i en note" | Afviser (`memory-guard`) |

Stikprøve i Finder og Obsidian: åbn 5-10 tilfældige gamle filer. Er de der? Virker linkene i dem?

**Hukommelsen skrives i `~/.claude/`**, så den gælder også i andre mapper. Test én gang: åbn en ny session i en *anden* mappe og spørg "Hvad ved du om mig?". Hvis du kun vil have den i arkivmappen, så sig det til Claude, så lægger den instruktionerne i arkivmappen i stedet.

## Fortryd

Alt kan rulles tilbage: sig til Claude "fortryd omorganiseringen". Den kører rollback fra `AI/migration/journal.jsonl`, flytter filerne tilbage, gendanner de rettede noter og fjerner de oprettede indexfiler. Gem `AI/migration/` og backupen, til kunden er tilfreds.

## Når flere skal bruge det

Hver person kører opsætningen på sin egen Mac og vælger **den samme OneDrive-mappe**. Ingen redigerer den samme note samtidig (OneDrive laver ellers en kopi som `note-MACBOOK.md`; `/audit` finder dem). Kør omorganiseringen **kun én gang**, af én person.

## Hvis noget går galt

| Symptom | Årsag og løsning |
|---|---|
| Claude kan ikke læse mappen / filer er 0 byte | Mappen er ikke "Always Keep on This Device". Sæt den, vent på synkroniseringen. Tjek System Settings → Privacy & Security → Files and Folders (eller Full Disk Access) for Claude-appen |
| macOS beder om at installere udviklerværktøjer | Tryk Installer, vent, og bed Claude fortsætte |
| Claude melder "HASH MISMATCH" | Claude ruller automatisk tilbage. Bed den vise fejlen, og prøv igen med mindre dele ad gangen |
| Mange filer i `Inbox/` | Claude kunne ikke placere dem. Sig, hvor de hører hjemme, så flytter den dem |
| Brudt link meldt | Linket pegede på en fil, der aldrig fandtes. Claude viser listen, du vælger |
| Claude husker ikke noget i næste session | Åbn sessionen i arkivmappen. Bed Claude vise `~/.claude/CLAUDE.md` og tjek stien |
| Claude kan ikke køre installationen (ingen shell) | Sig "følg Step 4b i AGENT-SETUP.md" for oprettelse af filerne manuelt. Flytningen kræver Python og kan ikke laves uden |

## Aflever til kunden

- At **intet er slettet**, og at alt kan fortrydes (vis journalen og backupen).
- At arkivet nu er sorteret pr. virksomhed, kan åbnes i Obsidian, og at `CLAUDE.md` peger på arkivet som eneste kilde.
- At indhold, der sendes til Claude, behandles af Anthropic efter deres Team-vilkår.
- At nye oplysninger fremover lander i den rigtige virksomhedsmappe, og at Claude holder indexfilerne ajour.
