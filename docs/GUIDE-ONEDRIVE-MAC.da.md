# Guide: Claude med hukommelse i et eksisterende OneDrive-arkiv (Mac)

Til den, der skal sætte det op hos kunden. Forudsætninger: en MacBook, Claude Team-abonnement, og et arkiv af `.md`-filer i OneDrive. Tid: cirka 30-45 minutter. Intet i arkivet bliver flyttet, omdøbt eller slettet. Der tilføjes kun to mapper: `AI/` og `Claude Code/`.

## Før du starter (15 min)

1. **Find arkivmappen i Finder.** Typisk `~/Library/CloudStorage/OneDrive-<Firma>/…/<arkiv>`. Højreklik mappen → **Always Keep on This Device** (vent til OneDrive er færdig med at hente).
2. **Claude Code installeret?** Åbn Terminal og skriv `claude --version`. Hvis det fejler: `curl -fsSL https://claude.ai/install.sh | bash`, og log ind med firmaets Claude Team-konto ved første `claude`.
3. **Er det en sikker mappe at pege Claude på?** Spørg ejeren (Janus) om arkivet indeholder noget, der ikke må behandles af Claude: kundernes personoplysninger, løn, kontrakter. Notér mapperne. De bliver markeret som private i opsætningen.
4. **Connector (valgfrit, kan vente):** Den, der administrerer Claude-kontoen, slår Microsoft 365-connectoren til under Admin settings → Connectors. Den giver adgang til mail, kalender, Teams og SharePoint-søgning. Selve arkivet kræver den ikke.
5. **Tryk ikke "Tillad ikke":** første gang Claude rører mappen, spørger macOS om Terminal må tilgå filer i OneDrive. Svar **Tillad**.

## Selve opsætningen

1. Åbn Terminal, gå til en tilfældig mappe, og skriv `claude`.
2. Indsæt:

   > Set up the memory system from github.com/microfix/claude-obsidian-memory using the folder "<den fulde sti til arkivmappen>". It is an existing Markdown archive in OneDrive on a Mac, the company does not use Obsidian. Follow AGENT-SETUP.md.

3. Claude stiller nu **interviewet** (cirka 10 spørgsmål, på dansk hvis du svarer på dansk). Svar ærligt. Vigtigst:
   - Hvem skal bruge det, og om det deles (en person, flere, hele firmaet).
   - Hvilke mapper er følsomme (fra "Før du starter" punkt 3).
   - Obsidian: svar **nej** (kan tilføjes senere uden at flytte noget).
   - Sprog og tone: dansk, kort eller grundigt, som de vil have det.
4. Claude viser en **plan** på 6-8 linjer. Tjek at:
   - `Storage mode` er D (Microsoft 365) og stien er arkivmappen.
   - `I will NOT: move, rename or delete any existing file` står der.
   - Skills inkluderer `memory-guard`, `anydoc`, `defuddle`, `skill-builder`. Til kundedata: også `gdpr-check`.
5. Svar **ja**. Claude installerer, læser arkivet i store træk (ikke hver fil), og skriver et kort kort over mapperne i `AI/_index.md` samt arkivets konventioner i `AI/tools/archive-conventions.md`.
6. **Word, Excel, PowerPoint, PDF:** skriv selv i Claude Code `/plugin marketplace add anthropics/skills` og derefter `/plugin install document-skills@anthropic-agent-skills`. Kør `/plugin` og tjek, at de står som installeret. Hvis navnene er ændret, så følg github.com/anthropics/skills.

## Tjek bagefter (5 min)

Luk Claude (`/exit`) og start en ny session. Prøv:

| Spørg Claude | Forventet |
|---|---|
| "Hvad ved du om mig og dette arkiv?" | Svarer ud fra `USER.md` og `AI/_index.md`, uden at sige "jeg læser dine filer" |
| "Find noter om <et kendt emne>" | Finder de rigtige filer |
| "Husk at vi bruger X i stedet for Y" | Skriver det i `AI/`, ikke i dine egne noter |
| "Skriv adgangskoden 1234 i en note" | Afviser (`memory-guard`) |

Kontroller i Finder, at `AI/` og `Claude Code/` ligger i arkivmappen, og at de gamle filer er uændrede.

## Når der er flere brugere

Hver person kører opsætningen på sin egen Mac og peger på **den samme OneDrive-mappe**. `AI/`-mappen bliver så fælles. Regler: ingen redigerer den samme note samtidig (OneDrive laver ellers en kopi som `note-MACBOOK.md`; `/audit` finder dem), og personlige noter hører til i en separat mappe uden for den fælles `AI/`. Er det mere end 3-4 personer, så lav hellere personlig hukommelse for hver og en fælles vidensmappe ved siden af.

## Hvis noget går galt

| Symptom | Årsag og løsning |
|---|---|
| Claude kan ikke læse mappen / filer er 0 byte | Mappen er ikke "Always Keep on This Device". Sæt den, vent på synkroniseringen. Tjek også System Settings → Privacy & Security → Files and Folders / Full Disk Access for Terminal |
| `command not found: claude` | Åbn et nyt Terminal-vindue, eller kør installationen igen |
| Claude husker ikke noget i næste session | `~/.claude/CLAUDE.md` mangler eller peger på forkert sti. Kør `head -20 ~/.claude/CLAUDE.md` |
| Duplikerede filer med maskinnavn | OneDrive-konflikt. Bed Claude køre `/audit`, og ret manuelt |
| `/plugin install` fejler | Navn eller marketplace ændret. Se github.com/anthropics/skills |

## Aflever til kunden

- At **intet** i det gamle arkiv er ændret (vis Finder).
- At Claude skriver sin egen hukommelse i `AI/` og spørger, før den ændrer i kundens egne noter.
- At indhold, der sendes til Claude, behandles af Anthropic efter deres Team-vilkår. Ejeren bør kende vilkårene, før kundedata peges ind.
- At de kan sige "kør opsætningsinterviewet igen" for at ændre noget, og at hele mappen kan flyttes uden tab.
