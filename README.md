# upload-file — malicious-upload test corpus

Reusable sample files for **authorized** file-upload security testing (bug bounty / pentest).
Organized one folder per bug class for fast access. Payloads use placeholders:
`ATTACKER-HOST` (your OOB/Collaborator host), `cmd` (command param), `169.254.169.254` (cloud metadata).

> Scope discipline (CLAUDE.md §2): only fire these at hosts listed in `state/scope.md`.
> Web shells / bombs are live payloads — treat accordingly.

## Folders

| Folder | Bug class | Key files |
|---|---|---|
| `web-shell/` | RCE via executable upload | `shell.php`, `.aspx`, `.asp`, `.jsp`, `.jspx`, `.cshtml`, php ext-variants (`phtml/php5/php7/pht/phar/phps/inc`), short-tag |
| `xss/` | Stored XSS via served HTML | `xss.html`, `.xhtml`, `.xml`, `.txt`, `.mhtml` (MIME-related), `.js` (served/`<script src>`), `.json` (MIME-sniff) |
| `svg/` | SVG XSS / XXE / SSRF / DoS | `svg-onload`, `svg-script`, `svg-foreignobject`, `svg-xxe`, `svg-ssrf`, `svg-billion-laughs`, `svg-animate-xss` (SMIL `<set>/<animate>`), `svg-use-xss` (`<use>`+data/href), `svgz-onload.svgz` (gzipped — bypasses `.svg`-only checks) |
| `pdf/` | PDF-JS XSS / SSRF + HTML→PDF | `pdf-openaction-xss.pdf` (Acrobat `/OpenAction /JS`), `pdf-uri-ssrf.pdf` (auto `/URI` + link OOB), `html-to-pdf-ssrf.html` / `html-to-pdf-lfi.html` (server-side HTML→PDF converters: iframe/img → metadata + `file://`) |
| `office/` | OOXML XML-external-entity | `docx-xxe-fileread.docx` (`file:///etc/passwd`), `xlsx-xxe-oob.xlsx` (OOB param-entity → `ATTACKER-HOST/evil.dtd`) — valid zips; XXE injected in `word/document.xml` / `xl/workbook.xml` |
| `image-metadata/` | XSS via reflected image metadata | `png-text-xss.png` (tEXt `Comment` chunk), `exif-comment-xss.jpg` (JPEG COM segment) — fire when the app echoes EXIF/PNG metadata unencoded |
| `xxe/` | XML external entity | file-read (nix/win), SSRF, OOB (+`evil.dtd`), billion-laughs |
| `ssrf/` | SSRF via media parsers | `ssrf.svg`, `ssrf.m3u8`, `ffmpeg-ssrf.avi` (FFmpeg HLS) |
| `content-type-bypass/` | Magic-byte valid image + payload | `png/gif/jpeg-php.*` (valid image header, PHP appended), `gif-xss.gif` |
| `polyglot/` | Dual-parse files | `pdf-xss.pdf`, `gif-html.html`, `js-gif-polyglot.gif` (valid GIF magic + valid JS → CSP `script-src 'self'` bypass via `<script src>`) |
| `filename-payloads/` | Malicious filenames (request-time) | `filenames.txt` — XSS / SQLi / SSTI / cmd-injection / traversal / unicode names to set in the multipart `filename=` field |
| `extension-bypass/` | Filter evasion by name | `shell.php.jpg`, `shell.jpg.php`, `shell.pHp`, `shell.php%00.jpg`, … |
| `config-override/` | Handler hijack | `.htaccess` (Apache→exec images as PHP), `web.config` (IIS ASP) |
| `csv-injection/` | CSV/formula injection | `formula.csv` |
| `eicar/` | AV pipeline test | `eicar.com.txt` (standard EICAR string, benign) |
| `image-tragick/` | ImageMagick RCE/SSRF | `.mvg` / `.svg` (CVE-2016-3714 family) |
| `dos/` | Resource exhaustion | `decompression-bomb.gz` (100MB inflate), `zip-bomb.zip`, `pixel-flood.png` (65535×65535) |
| `path-traversal/` | Path traversal / zip-slip | `zip-slip.zip`, url-encoded traversal filenames |
| `size-test/` | Upload size-limit test | 600KB / 50MB / 100MB JPEGs |

## Filename tricks NTFS can't store (send them at request time in the multipart `filename=` field)

NTFS strips trailing dots/spaces and is case-insensitive, so these must be set in the
raw HTTP request, not as on-disk files. Point your upload at any `web-shell/shell.php`
body and swap the filename to:

```
shell.php.            (trailing dot — Windows/IIS strips it → shell.php)
shell.php%20          (trailing space)
shell.php.....        (multiple trailing dots)
shell.php::$DATA      (NTFS Alternate Data Stream → shell.php)
shell.php:.jpg        (ADS extension confusion)
shell.asp;.jpg        (old IIS semicolon parse → shell.asp)
shell.php%00.jpg      (null-byte truncation — old PHP/CGI)
shell%E2%80%A Egpj.php (RTLO override display trick)
../../../shell.php    (path traversal in filename → escape upload dir)
```

## Quick usage

```bash
# content-type sniffing test — does the server serve it as HTML?
curl -s -o /dev/null -w '%{content_type}\n' https://TARGET/uploads/gif-xss.gif

# web-shell reachability after upload
curl -s "https://TARGET/uploads/shell.php?cmd=id"

# SSRF/XXE OOB — watch your Collaborator/interactsh for the ATTACKER-HOST hit

# PDF-JS: upload pdf-openaction-xss.pdf, then open the served copy in Acrobat/inline viewer
# HTML->PDF: submit pdf/html-to-pdf-*.html to a "generate PDF/invoice/report" feature, read the rendered PDF
# Office XXE: upload office/*.docx|xlsx to any DOCX/XLSX import; watch OOB for the evil.dtd fetch
# Metadata XSS: upload image-metadata/*, then load any page that echoes the file's EXIF/PNG metadata
```

> **Notes.** `exif-comment-xss.jpg` is a magic-valid minimal JPEG (SOI+COM+EOI) when Pillow
> isn't installed at generation time — it passes magic-byte checks but may not fully decode;
> install Pillow and re-run the generator for a fully-decodable 8×8 JPEG carrying the same COM
> payload. `xlsx-xxe-oob.xlsx` needs an `evil.dtd` on your `ATTACKER-HOST` (see `xxe/evil.dtd`).

Generated by `_gen_uploads.py` (idempotent; re-run to add new samples without clobbering).
