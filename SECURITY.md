# Security notice & authorized-use disclaimer

This repository is a **file-upload security test corpus** — a collection of sample
payloads used to test how web applications handle uploaded files (content-type
handling, extension filtering, parser safety, size limits, archive extraction).

## What's in here

The corpus intentionally contains **live, working payloads**, including:

- **Web shells** (`web-shell/`) — command-execution scripts (PHP/ASP/ASPX/JSP/etc.).
- **XSS / SVG / polyglot** files that execute script when served with a renderable content-type.
- **XXE / SSRF** payloads that attempt file reads, cloud-metadata access, and out-of-band callbacks.
- **ImageMagick** RCE/SSRF payloads (`image-tragick/`, CVE-2016-3714 family).
- **Denial-of-service** samples (`dos/`) — decompression/zip bombs and a pixel-flood image.
- **EICAR** (`eicar/eicar.com.txt`) — the standard, benign anti-virus test string.

Antivirus and platform scanners (including GitHub's) may flag or quarantine these files.
That is expected — they are recognized testing artifacts, not concealed malware.

## Authorized use only

These files are provided **solely for authorized security testing, education, and
defensive research** — for example: your own systems, deliberately vulnerable labs,
CTF challenges, and bug-bounty / penetration-testing engagements that you have
**explicit written permission** to test.

**Do not** use anything in this repository against systems you do not own or are not
explicitly authorized to test. Unauthorized access, denial of service, or data
exfiltration is illegal in most jurisdictions. You are responsible for how you use
these files; the author accepts no liability for misuse or resulting damage.

## Placeholders

Payloads use placeholders you must replace for your own authorized target:

- `ATTACKER-HOST` — your out-of-band / Collaborator / interactsh host.
- `cmd` — the command parameter read by the web shells.
- `169.254.169.254` — cloud instance-metadata endpoint (SSRF probes).

## Reporting

This repo is a payload collection, not a service — there is no runtime to report a
vulnerability in. For issues with the samples themselves, open a GitHub issue.
