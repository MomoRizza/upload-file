# upload-file — malicious-upload test corpus

Reusable sample files for **authorized** file-upload security testing (bug bounty / pentest).
Organized one folder per bug class for fast access. Payloads use placeholders:
`ATTACKER-HOST` (your OOB/Collaborator host), `cmd` (command param), `169.254.169.254` (cloud metadata).

> Scope discipline (CLAUDE.md §2): only fire these at hosts listed in `state/scope.md`.
> Web shells / bombs are live payloads — treat accordingly.

## Folders

| Folder | Bug class | Key files |
|---|---|---|
| `web-shell/` | RCE via executable upload | **PHP** `.php/.php3/.php4/.php5/.php7/.phtml/.phtm/.pht/.phar/.phps/.inc` + short-tag · **ASP/.NET** `.asp/.aspx/.ashx/.cshtml/.asa/.cer/.cdx` · **JSP** `.jsp/.jspx/.jspf` · **SSI** `.shtml/.shtm/.stm` · **Perl** `.pl/.cgi` · **Python** `.py` · **Ruby** `.rb/.erb/.rhtml` · **ColdFusion** `.cfm/.cfml` |
| `xss/` | Stored XSS via served content | `.html/.htm/.xhtml/.xht/.dhtml/.wml`, `.xml`, `.txt`, `.mhtml`, `.eml`, `.js` (`<script src>`), `.json` (MIME-sniff), `.xsl/.xslt` (XSLT+`document()`), `.vtt` (WebVTT), `.hta`, `.md/.markdown`, `.rss/.atom/.rdf` (feeds/CDATA) |
| `svg/` | SVG XSS / XXE / SSRF / DoS | `svg-onload/-script/-foreignobject/-xxe/-ssrf/-billion-laughs`, `svg-animate-xss` (SMIL), `svg-use-xss` (`<use>`+data/href), `svgz-onload.svgz` (gzipped — bypasses `.svg`-only checks) |
| `pdf/` | PDF-JS XSS / SSRF + HTML→PDF | `pdf-openaction-xss` (Acrobat `/OpenAction /JS`), `pdf-uri-ssrf`, `pdf-submitform-ssrf`, `pdf-gotor-ssrf`, `pdf-importdata-ssrf`, `pdf-launch-action` (all auto-action OOB); `html-to-pdf-ssrf.html`/`html-to-pdf-lfi.html` (server-side HTML→PDF: metadata + `file://`) |
| `office/` | OOXML XXE + template injection | `docx-xxe-fileread` / `docx-xxe-oob` / `xlsx-xxe-oob` / `xlsx-xxe-fileread` / `pptx-xxe` (XXE in the doc XML parts); `docx-remote-template.docx` (external `attachedTemplate` rel → SSRF/remote-template load) — all valid zips |
| `image-metadata/` | XSS via reflected media metadata | `exif-comment-xss.jpg` (JPEG COM), `jpeg-xmp-xss.jpg` (XMP packet), `png-text-xss.png` (tEXt), `png-itxt-xss.png` (iTXt), `gif-comment-xss.gif` (comment ext) — fire when the app echoes metadata unencoded |
| `xxe/` | XML external entity | file-read (nix/win), SSRF, OOB (`evil.dtd`/`xxe-error.dtd`), billion-laughs, `xxe-xinclude`, `xxe-php-filter`, `xxe-parameter-entity`, `xxe-utf16`, `xxe-svg-in-xml` |
| `ssrf/` | SSRF via parsers | `ssrf.svg`, `ssrf.m3u8`, `ffmpeg-ssrf.avi`, `ffmpeg-concat-ssrf.txt` (concat demuxer `file://`+http), `ssrf-jsonref[-file].json` (`$ref`), `ssrf.gpx`, `ssrf-import.css` (`@import`/`url()`) |
| `content-type-bypass/` | Valid magic bytes + payload | `png/gif/jpeg/bmp/webp/tiff/ico/pdf-php.*` (valid header + PHP appended), `gif-xss.gif`, `bmp-xss.bmp` |
| `polyglot/` | Dual-parse files | `pdf-xss.pdf`, `gif-html.html`, `js-gif-polyglot.gif` / `bmp-js-polyglot.bmp` / `html-js-polyglot.js` (image/HTML magic + valid JS → CSP `script-src 'self'` bypass), `phar-jpeg.jpg` (PHAR/JPEG object-injection stub) |
| `filename-payloads/` | Malicious filenames (request-time) | `filenames.txt` — XSS / SQLi / SSTI / cmd-injection / traversal / unicode names for the multipart `filename=` field (chars a filesystem can't store) |
| `extension-bypass/` | Filter evasion by name | full matrix: case (`shell.PHP…`), double/reversed (`shell.php.jpg`, `shell.jpg.php`, `shell.png.php`), backup (`.bak/.old/~/.save/.swp`), url-encoded (`%00/%0a/%0d/%09/%23/%3f/%2500/%20`), alt-engine (`shell.asp;.png`, `shell.phtml.jpg`, `shell.jsp.jpg`, …) |
| `config-override/` | Handler hijack | `.htaccess` (Apache→exec images as PHP), `web.config` (IIS), `.user.ini` (PHP-FPM `auto_prepend_file`), `htaccess-variants.txt` (AddType/AddHandler/SetHandler/php_value) |
| `csv-injection/` | Formula/CSV injection | `formula.csv`, `formula.tsv`, `formula.slk` (SYLK `EXEC`), `dde.csv` (DDE), `google-sheets-import.csv` (IMPORTXML/DATA/IMAGE exfil) |
| `eicar/` | AV pipeline test | `eicar.com.txt` (standard EICAR string, benign) |
| `image-tragick/` | ImageMagick RCE/SSRF | `.mvg` / `.svg` (CVE-2016-3714 family) |
| `dos/` | Resource exhaustion | `decompression-bomb.gz`, `zip-bomb.zip`, `nested-zip-bomb.zip`, `pixel-flood.png` (65535²), `xml-quadratic-blowup.xml`, `json-bomb.json` (deep nesting) |
| `path-traversal/` | Traversal / zip-slip / symlink | `zip-slip.zip`, `tar-slip.tar` (`../` + symlink), `symlink.zip` (symlink→`/etc/passwd`), url-encoded traversal filenames (single/double/overlong-UTF-8/backslash) |
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
