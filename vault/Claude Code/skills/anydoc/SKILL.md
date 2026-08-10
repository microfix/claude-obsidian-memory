---
name: anydoc
description: Convert documents (PDF, Word, Excel, PowerPoint, OpenDocument, RTF, EPUB, CSV) to clean Markdown so they can be read and analyzed. ALWAYS activate when a task requires the content of a .pdf, .doc, .docx, .xls, .xlsx, .ppt, .pptx, .odt, .ods, .odp, .rtf, .epub or .csv file — instead of reading the binary file directly. Also activates on "convert to markdown", "read this PDF", "what does the document say", "/anydoc". Also used for bulk-converting folders of documents into Obsidian.
---

# anydoc — documents to Markdown

Converts office documents and text-based PDFs to GitHub-Flavored Markdown in milliseconds per document. Requires the `anydoc` CLI on PATH (the install script offers to install it; see the repo README for the package name).

## Run it

```bash
anydoc report.docx                   # Markdown to stdout
anydoc slides.pptx -o slides.md      # write to file
anydoc - --format csv < data.csv     # read stdin
curl -s https://example.com/paper.pdf | anydoc -
```

If the binary isn't found, check your global npm bin directory is on PATH (`npm bin -g`).

## Rules

1. **NEVER read a binary document directly.** Run anydoc first, then read the markdown output.
2. **Large documents: write to a file with `-o` and read only the parts you need.** Don't pour 200 pages of markdown into context.
3. **Format is detected from file content, not the extension.** `--format <name>` is only needed for CSV from stdin or a missing/wrong extension.
4. **Exit codes:** 0 = ok, 1 = conversion failed, 2 = usage error. Errors go to stderr as a single line `anydoc: <message>`. Never prompts.
5. **Inside a Node/Python/Rust codebase the same engine exists as a library.** Prefer that over shelling out.

## Supported formats

| Format | Extensions |
| --- | --- |
| Word | `.doc`, `.docx`, `.docm` |
| PowerPoint | `.ppt`, `.pps`, `.pot`, `.pptx`, `.pptm`, `.ppsx`, `.ppsm` |
| Excel | `.xls`, `.xlsx`, `.xlsm`, `.xlsb` |
| OpenDocument | `.odt`, `.ods`, `.odp` |
| RTF | `.rtf` |
| EPUB | `.epub` |
| CSV | `.csv` |
| PDF | `.pdf` (text-based only) |

## Scanned PDFs

anydoc does not do OCR. An image-based PDF fails with:

```
anydoc: unsupported input: PDF has no extractable text (ImageBased, N pages): OCR is required
```

Fallback order:

1. **Claude's Read tool with the `pages` parameter** — reads PDF pages as images directly. Works for a few pages, needs no installation. This is the default route.
2. **`ocrmypdf` + tesseract** for batch OCR without an agent in the loop (`sudo apt install ocrmypdf tesseract-ocr`, plus a language pack like `tesseract-ocr-dan`).

Check whether a PDF has any text before guessing: `pdftotext file.pdf - | head`.

## Bulk conversion into Obsidian

Convert a folder of mixed documents into the vault as markdown:

```bash
mkdir -p "$TARGET"
for f in "$SOURCE"/*; do
  case "${f,,}" in
    *.pdf|*.doc|*.docx|*.docm|*.odt|*.rtf|*.epub|*.ppt|*.pptx|*.odp|*.xls|*.xlsx|*.xlsm|*.ods|*.csv)
      name=$(basename "$f"); name="${name%.*}"
      anydoc "$f" -o "$TARGET/$name.md" || echo "SKIPPED: $f"
      ;;
  esac
done
```

When writing into the vault, add Obsidian frontmatter afterwards. Raw dumps belong in `AI/raw/` and get processed with `/compile`.

## Quality in practice

- DOCX/PPTX/XLSX give the cleanest output — structure, tables, and formatting survive.
- PDF is worse because layout is guessed: multi-column pages become tables, and headers bleed into body text. **If you have both .docx and .pdf of the same document, convert the .docx.**
- Images become alt-text in markdown. The image bytes themselves are only available via the library API, not the CLI.
