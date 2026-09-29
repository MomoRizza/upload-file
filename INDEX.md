# INDEX — file → test map / engagement checklist

Walk this top-to-bottom against any upload / import / avatar / attachment / "generate document"
feature. Each row says **what the file proves** and the **pass signal** (what you observe if the
target is vulnerable). Tick a box only after you've fired it and recorded the result.

- Placeholders to replace before firing: `ATTACKER-HOST` (your OOB/Collaborator/interactsh),
  `cmd` (command param), `169.254.169.254` (cloud metadata).
- **Scope gate (CLAUDE.md §2):** only fire at hosts in `state/scope.md`. `dos/`, `web-shell/`,
  and the DoS-ish `xxe`/`svg` bombs are live payloads — DoS classes need explicit written approval.
- Full folder overview + install/usage: `README.md`. This file is the checklist; README is the map.

## 0. Pre-flight — decide these first (they select which sections matter)
- [ ] **Where does the stored file get served from?** same-origin vs a sandbox/CDN domain, and with what `Content-Type` / `Content-Disposition`? (decides XSS/polyglot viability)
- [ ] **Server stack?** Apache/Nginx/IIS, PHP/ASP.NET/Java/Ruby/Python/CF (decides `web-shell/` + `config-override/`)
- [ ] **What validates the upload?** extension allow/deny-list, magic-byte/`getimagesize`, MIME, re-encode, AV, archive scan (decides `extension-bypass/`, `content-type-bypass/`, `polyglot/`)
- [ ] **Is the file parsed?** image (metadata/ImageMagick), XML/Office (XXE), archive (zip/tar), HTML→PDF/image (SSRF/LFI)
- [ ] **Can you reach the stored file by URL?** (needed to prove `web-shell/` execution & served-XSS)

---

## web-shell/ — RCE via executable upload  (33 files)
- [ ] Upload each engine that matches the stack, then request the stored URL with `?cmd=id` (nix) / `?cmd=whoami` (win).
- **Pass signal:** command output in the response = RCE.

| Engine | Files | Notes |
|---|---|---|
| PHP | `shell.php` `.php3` `.php4` `.php5` `.php7` `.phtml` `.phtm` `.pht` `.phar` `.phps` `.inc` `shell-shorttag.php` | try every variant — deny-lists usually miss one; `.phps`/`.inc` need include/handler mapping |
| ASP / .NET | `shell.asp` `.aspx` `.ashx` `.cshtml` `.asa` `.cer` `.cdx` | `.asa/.cer/.cdx` are legacy IIS names historically mapped to `asp.dll` |
| Java | `shell.jsp` `.jspx` `.jspf` | needs a servlet container serving the upload dir |
| SSI | `shell.shtml` `.shtm` `.stm` | Apache/IIS server-side includes: `<!--#exec-->` runs on render |
| Perl | `shell.pl` `.cgi` | needs `cgi-bin`/ExecCGI on the upload dir |
| Python | `shell.py` | CGI handler |
| Ruby | `shell.rb` `.erb` `.rhtml` | ERB/rack context |
| ColdFusion | `shell.cfm` `.cfml` | `cfexecute` |

## xss/ — stored XSS via served content  (21 files)
- [ ] Upload, open the stored URL directly; watch for `alert(document.domain)`.
- **Pass signal:** script runs in the app's origin (or the file's serving origin).

| File(s) | Proves |
|---|---|
| `xss.html` `.htm` `.xhtml` `.xht` `.dhtml` `.wml` | server serves your HTML as `text/html` |
| `xss.xml` `.rss` `.atom` `.rdf` | XML/feed rendered → script/CDATA executes |
| `xss.txt` `.json` | **MIME-sniffing** XSS (served as text/json but sniffed to HTML) |
| `xss.js` | uploaded JS served/`<script src>`-includable → CSP `script-src 'self'` bypass |
| `xss.svg` (see `svg/`) | — |
| `xss.xsl` `.xslt` | XSLT injection: inline `<script>` + `document('http://ATTACKER-HOST')` SSRF |
| `xss.vtt` | WebVTT subtitle XSS in a video player |
| `xss.hta` | HTML Application (Windows) — script + WScript.Shell |
| `xss.eml` `.mhtml` | MIME/MHTML rendered as HTML |
| `xss.md` `.markdown` | server-side markdown render → raw HTML/`javascript:` link |

## svg/ — SVG XSS / XXE / SSRF / DoS  (10 files)
- [ ] Upload where an SVG is shown inline (avatar, logo, preview).
- **Pass signal:** `alert(document.domain)` (XSS) · OOB/file contents (XXE/SSRF) · hang (DoS).

| File | Proves |
|---|---|
| `svg-onload.svg` `svg-script.svg` `xss-original.svg` | inline `onload`/`<script>` execution |
| `svg-foreignobject.svg` | HTML-in-SVG via `<foreignObject>` (sanitizer bypass) |
| `svg-animate-xss.svg` | SMIL `<animate>`/`onbegin` execution (no `onload` attr) |
| `svg-use-xss.svg` | `<use>` + `data:`/external `href` payload |
| `svgz-onload.svgz` | **gzipped SVG** — bypasses handlers/sanitizers keyed only on `.svg` |
| `svg-xxe.svg` | XXE (`file://`) inside SVG XML |
| `svg-ssrf.svg` | SSRF via SVG external reference |
| `svg-billion-laughs.svg` | entity-expansion DoS ⚠ |

## pdf/ — PDF-JS XSS / SSRF + server-side HTML→PDF  (8 files)
- [ ] PDF-action files: upload then open the served copy in a reader / inline viewer.
- [ ] HTML→PDF files: submit to any "generate PDF/invoice/report/export" feature; read the output + watch OOB.
- **Pass signal:** reader runs JS · OOB hit from server IP · metadata/`file://` contents in the rendered PDF.

| File | Proves |
|---|---|
| `pdf-openaction-xss.pdf` | reader auto-runs `/OpenAction /JS` (Acrobat) |
| `pdf-uri-ssrf.pdf` | auto `/URI` + link annotation → OOB/phishing |
| `pdf-submitform-ssrf.pdf` `pdf-importdata-ssrf.pdf` | `/SubmitForm` `/ImportData` fetch attacker URL |
| `pdf-gotor-ssrf.pdf` | `/GoToR` remote-goto SSRF |
| `pdf-launch-action.pdf` | `/Launch` external-program action ⚠ |
| `html-to-pdf-ssrf.html` | HTML→PDF renderer fetches metadata/OOB (iframe/img/link/object/meta/fetch) |
| `html-to-pdf-lfi.html` | HTML→PDF reads `file:///etc/passwd`, `win.ini` |

## office/ — OOXML XXE + remote-template injection  (6 files)
- [ ] Upload to any DOCX/XLSX/PPTX import/preview/convert; watch OOB for the fetch.
- **Pass signal:** local file contents surface, or OOB hit (`evil.dtd`/`evil.dotm`) from server IP.

| File | Proves |
|---|---|
| `docx-xxe-fileread.docx` `xlsx-xxe-fileread.xlsx` | XXE local read (`file:///etc/passwd`) |
| `docx-xxe-oob.docx` `xlsx-xxe-oob.xlsx` `pptx-xxe.pptx` | blind XXE OOB via external parameter entity → `ATTACKER-HOST/evil.dtd` |
| `docx-remote-template.docx` | external `attachedTemplate` relationship → SSRF / remote-template load (`evil.dotm`) |

> Needs an `evil.dtd` (see `xxe/evil.dtd`) / `evil.dotm` on your `ATTACKER-HOST`.

## xxe/ — XML external entity (raw XML uploads)  (12 files)
- [ ] Upload where an XML body is parsed (SAML, sitemap, SVG, config import, SOAP, RSS).
- **Pass signal:** file contents reflected, or OOB hit for blind variants.

`xxe-file-read.xml` / `-win.xml` (local read) · `xxe-ssrf.xml` (SSRF) · `xxe-oob.xml` + `evil.dtd`
(OOB) · `xxe-parameter-entity.xml` (blind param-entity) · `xxe-error.dtd` (error-based exfil) ·
`xxe-php-filter.xml` (`php://filter` base64 read) · `xxe-xinclude.xml` (XInclude when DOCTYPE
blocked) · `xxe-utf16.xml` (encoding bypass) · `xxe-svg-in-xml.xml` (SVG-wrapped) ·
`xxe-billion-laughs.xml` (DoS ⚠).

## content-type-bypass/ — valid magic bytes + payload  (14 files)
- [ ] Upload where validation is magic-byte/`getimagesize` only; then reach the file to execute.
- **Pass signal:** file passes the image check AND the appended PHP runs / HTML renders.

`png/gif/jpeg/bmp/webp/tiff/ico/pdf-php.*` (valid header + `<?php … ?>` appended) ·
`bmp2-php.bmp2` (bare 2-byte magic) · `gif-xss.gif` `bmp-xss.bmp` (image magic + served-as-HTML XSS).

## extension-bypass/ — filename filter evasion (disk-storable)  (46 files)
- [ ] Feed each name against a deny/allow-list; confirm which the server accepts AND still executes.
- **Pass signal:** an accepted name resolves to an executable handler.
- **Groups:** double/reversed (`shell.php.jpg`, `shell.jpg.php`, `shell.png.php`, `.php.png/.gif/.jpeg`) ·
  strip/parse (`shell.p.phphp`, `shell%2ephp`, `shell.php..jpg`) · alt-engine (`shell.asp;.png`,
  `shell.aspx;.jpg`, `shell.php;.jpg`, `shell.phtml.jpg`, `shell.jsp/jspx/cfm/php5/php7/pht/phar.jpg`) ·
  url-encoded (`%00` null-byte on gif/jpg/png, `%0a`/`%0d`/`%09` control, `%23`/`%3f` query/frag,
  `%2500` double-encoded null, `%20`/`%20%20` trailing space) · backup/source-disclosure
  (`.bak/.old/~/.save/.swp/.orig/.txt`) · case (`shell.pHp`, `shell.pHtml`).
> Case-only and trailing-dot/space variants a filesystem can't store distinctly → `filename-payloads/filenames.txt` (fire at request time).

## filename-payloads/filenames.txt — request-time filename injection
- [ ] Keep the body benign; put the payload in the multipart `filename="…"`.
- **Pass signal:** XSS in a listing/error/JSON · SQLi timing/error · SSTI (`${7*7}`→49) · cmd-inj OOB · traversal write outside the dir.

## config-override/ — handler hijack  (5 files)
- [ ] Upload into a dir you can also serve from.
- **Pass signal:** afterwards a benign image/any file in that dir executes as code.

`.htaccess` (Apache: exec images as PHP) · `htaccess-variants.txt` (AddType/AddHandler/SetHandler/`auto_prepend_file`) ·
`.user.ini` (PHP-FPM `auto_prepend_file`) · `web.config` / `web.config-cscript` (IIS handler map).

## image-metadata/ — XSS via reflected media metadata  (5 files)
- [ ] Upload, then load any page that echoes the file's EXIF/PNG/GIF metadata unencoded.
- **Pass signal:** `alert(document.domain)` from the metadata field.

`exif-comment-xss.jpg` (JPEG COM) · `jpeg-xmp-xss.jpg` (XMP packet) · `png-text-xss.png` (tEXt) ·
`png-itxt-xss.png` (iTXt) · `gif-comment-xss.gif` (comment extension).

## image-tragick/ — ImageMagick RCE/SSRF (CVE-2016-3714)  (3 files)
- [ ] Upload where ImageMagick/GraphicsMagick processes the file.
- **Pass signal:** OOB / command execution. `imagetragick-rce.mvg` · `-ssrf.mvg` · `-ssrf.svg`.

## polyglot/ — dual-parse files  (6 files)
- [ ] Use where one parser validates and another executes.
- **Pass signal:** file is accepted as media AND runs as script/HTML.

`js-gif-polyglot.gif` `bmp-js-polyglot.bmp` `html-js-polyglot.js` (image/HTML magic + valid JS →
CSP `script-src 'self'` bypass via `<script src>`) · `gif-html.html` · `pdf-xss.pdf` ·
`phar-jpeg.jpg` (PHAR/JPEG object-injection **stub** — append a target-specific manifest+gadget).

## path-traversal/ — traversal / zip-slip / symlink  (12 files)
- [ ] Traversal filenames (many url-encodings incl. double/overlong-UTF-8/backslash) → escape the upload dir.
- [ ] Archive files where the server extracts uploads.
- **Pass signal:** file written outside the intended dir, or arbitrary read.

`zip-slip.zip` · `tar-slip.tar` (`../` + symlink) · `symlink.zip` (symlink→`/etc/passwd` on extract) ·
encoded-traversal names (`%2e%2e%2f…`, `%252e…` double, `%c0%af` overlong, `%5c`/`%255c` backslash).

## csv-injection/ — formula/CSV injection  (5 files)
- [ ] Upload to a feature that exports/renders your rows to a spreadsheet.
- **Pass signal:** formula executes on open (calc) or exfils via HYPERLINK/WEBSERVICE/IMPORT*.

`formula.csv` · `formula.tsv` · `formula.slk` (SYLK `EXEC`) · `dde.csv` (DDE) ·
`google-sheets-import.csv` (IMPORTXML/IMPORTDATA/IMAGE exfil).

## dos/ — resource exhaustion  ⚠ DoS auth required  (6 files)
- [ ] Only with explicit written DoS approval. `decompression-bomb.gz` · `zip-bomb.zip` ·
  `nested-zip-bomb.zip` · `pixel-flood.png` (65535²) · `xml-quadratic-blowup.xml` · `json-bomb.json`.
- **Pass signal:** CPU/memory spike, timeout, or crash on parse/extract.

## eicar/ · size-test/ — pipeline checks
- `eicar/eicar.com.txt` — [ ] does the AV pipeline catch the standard EICAR string?
- `size-test/600-kb.jpg` `50mb.jpg` `100-mb-example-jpg.jpg` (regen via `size-test/regen.py`) —
  [ ] where is the size limit? (50/100MB are gitignored; regenerate locally).
