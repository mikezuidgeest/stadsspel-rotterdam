#!/usr/bin/env python3
"""
Stadsspel Rotterdam — volledige archief-export.

Trekt ALLES uit Supabase naar een lokale map, zodat het spel bewaard blijft
los van het domein (jorikhethaasje.nl), GitHub Pages en het Supabase-project
zelf. Draait op kale Python 3 — geen pip install nodig.

Wat het bewaart:
  1. Alle tabellen  -> JSON (volledig) + CSV (per tabel, makkelijk te openen)
  2. Alle media     -> echte .jpg/.mp4/.mov bestanden in media/
                       - bestanden uit de Supabase Storage-bucket 'media'
                       - EN foto's die als inline base64 in de rij staan
                         (de fallback-route uit V41.11) worden uitgepakt
  3. manifest.json  -> wat er is opgehaald, hoeveel, en wat er misging

Gebruik:
    python3 archief/export-archief.py
    python3 archief/export-archief.py --out ~/Dropbox/stadsspel-archief

Let op: draai dit ZOLANG het Supabase-project nog actief is. Een gepauzeerd
project (Supabase free tier pauzeert na inactiviteit) moet eerst weer
'resumed' worden via app.supabase.com.
"""

import argparse
import base64
import csv
import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timezone

# Zelfde waarden als in index.html (anon key — publiek, staat al in de app).
SUPABASE_URL = "https://kybcndicweuxjxkfzxud.supabase.co"
SUPABASE_KEY = (
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9."
    "eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt5YmNuZGljd2V1eGp4a2Z6eHVkIiwicm9sZSI6ImFub24i"
    "LCJpYXQiOjE3NzYxMDM3ODYsImV4cCI6MjA5MTY3OTc4Nn0."
    "utTzURErYUiGgOpvlq1goKToUl8i4CavVicEFp-MrDk"
)
STORAGE_BUCKET = "media"

# Elke tabel die de app aanraakt (grep op from('...') in index.html).
TABLES = [
    "teams",
    "team_members",
    "game_state",
    "activity_feed",
    "completed_challenges",
    "photo_reviews",
    "feed_reactions",
    "challenge_first_finder",
]

PAGE_SIZE = 1000
DATA_URL_RE = re.compile(r"^data:([\w.+-]+/[\w.+-]+);base64,", re.I)

MIME_EXT = {
    "image/jpeg": "jpg", "image/jpg": "jpg", "image/png": "png",
    "image/webp": "webp", "image/heic": "heic", "image/gif": "gif",
    "video/mp4": "mp4", "video/quicktime": "mov", "video/webm": "webm",
}

errors = []


def log(msg):
    print(msg, flush=True)


def request(url, method="GET", body=None, extra_headers=None, timeout=120):
    headers = {
        "apikey": SUPABASE_KEY,
        "Authorization": f"Bearer {SUPABASE_KEY}",
    }
    if extra_headers:
        headers.update(extra_headers)
    data = None
    if body is not None:
        data = json.dumps(body).encode()
        headers["Content-Type"] = "application/json"
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return resp.read(), dict(resp.headers)


def fetch_table(name):
    """Haalt een tabel volledig op, gepagineerd via Range-headers."""
    rows, offset = [], 0
    while True:
        url = f"{SUPABASE_URL}/rest/v1/{name}?select=*"
        headers = {"Range": f"{offset}-{offset + PAGE_SIZE - 1}", "Prefer": "count=exact"}
        try:
            raw, _ = request(url, extra_headers=headers)
        except urllib.error.HTTPError as e:
            detail = e.read().decode("utf-8", "replace")[:300]
            errors.append(f"tabel {name}: HTTP {e.code} {detail}")
            log(f"  !! {name}: HTTP {e.code} — {detail}")
            return rows
        except Exception as e:  # netwerk, DNS, timeout
            errors.append(f"tabel {name}: {e}")
            log(f"  !! {name}: {e}")
            return rows
        batch = json.loads(raw.decode("utf-8"))
        rows.extend(batch)
        if len(batch) < PAGE_SIZE:
            break
        offset += PAGE_SIZE
    return rows


def write_table(out_dir, name, rows):
    json_path = os.path.join(out_dir, "tabellen", f"{name}.json")
    with open(json_path, "w", encoding="utf-8") as fh:
        json.dump(rows, fh, ensure_ascii=False, indent=2)

    # CSV voor menselijke ogen. Inline base64 wordt afgekapt — die staat al
    # volledig in de JSON en wordt bovendien als los bestand weggeschreven.
    if rows:
        cols = []
        for row in rows:
            for key in row:
                if key not in cols:
                    cols.append(key)
        csv_path = os.path.join(out_dir, "tabellen", f"{name}.csv")
        with open(csv_path, "w", encoding="utf-8", newline="") as fh:
            writer = csv.DictWriter(fh, fieldnames=cols, extrasaction="ignore")
            writer.writeheader()
            for row in rows:
                flat = {}
                for key, val in row.items():
                    if isinstance(val, str) and val.startswith("data:"):
                        flat[key] = f"<inline media, {len(val)} bytes — zie media/>"
                    elif isinstance(val, (dict, list)):
                        flat[key] = json.dumps(val, ensure_ascii=False)
                    else:
                        flat[key] = val
                writer.writerow(flat)


def walk_strings(node, path=""):
    """Loopt recursief door een rij en levert (pad, string) op."""
    if isinstance(node, str):
        yield path, node
    elif isinstance(node, dict):
        for key, val in node.items():
            yield from walk_strings(val, f"{path}.{key}" if path else key)
    elif isinstance(node, list):
        for idx, val in enumerate(node):
            yield from walk_strings(val, f"{path}[{idx}]")


def safe_name(text, limit=90):
    return re.sub(r"[^A-Za-z0-9._-]", "_", text)[:limit] or "media"


# ── Het echte bestandstype uit de eerste bytes lezen ────────────────────────
# Nodig omdat de uploadcode van 6 juni de extensie afleidde met .slice(0,8):
# "video/quicktime" werd ".quicktim", en daar opent geen enkel besturingssysteem
# iets mee. De bytes zijn prima; alleen de naam klopt niet. We vertrouwen daarom
# niet op de naam in de bucket maar op wat er werkelijk in het bestand staat.
ISO_BRANDS = {
    b"qt  ": "mov",
    b"heic": "heic", b"heix": "heic", b"heim": "heic", b"heis": "heic",
    b"hevc": "heic", b"hevx": "heic", b"hevm": "heic", b"hevs": "heic",
    b"mif1": "heic", b"msf1": "heic",
    b"M4V ": "m4v", b"M4A ": "m4a", b"M4P ": "m4p",
}


def sniff_ext(head):
    """Geeft de extensie die bij de inhoud hoort, of None als niets past."""
    if len(head) < 12:
        return None
    if head[:3] == b"\xff\xd8\xff":
        return "jpg"
    if head[:8] == b"\x89PNG\r\n\x1a\n":
        return "png"
    if head[:3] == b"GIF":
        return "gif"
    if head[:4] == b"RIFF":
        sub = head[8:12]
        if sub == b"WEBP":
            return "webp"
        if sub == b"AVI ":
            return "avi"
        if sub == b"WAVE":
            return "wav"
    if head[:4] == b"\x1aE\xdf\xa3":
        return "webm"
    if head[4:8] == b"ftyp":
        brand = head[8:12]
        if brand in ISO_BRANDS:
            return ISO_BRANDS[brand]
        if brand[:2] == b"3g":
            return "3gp"
        return "mp4"
    if head[:4] == b"OggS":
        return "ogv"
    if head[:4] == b"%PDF":
        return "pdf"
    return None


def correct_name(name, head):
    """(nieuwe naam, gewijzigd?, herkend type) op basis van de eerste bytes."""
    real = sniff_ext(head)
    if not real:
        return name, False, None
    stem, _, cur = name.rpartition(".")
    if not stem:
        stem, cur = name, ""
    if cur.lower() == real or (real == "jpg" and cur.lower() == "jpeg"):
        return name, False, real
    return f"{stem}.{real}", True, real


def file_name_from_url(url):
    """
    In een platte bucket is de bestandsnaam de identiteit, niet de URL. De
    bucket-listing bouwt zijn URL zelf op (met quote()) terwijl de tabelrij de
    opgeslagen URL draagt; wijkt de codering ook maar een teken af, dan zou
    ontdubbelen op URL hetzelfde bestand twee keer binnenhalen.
    """
    last = url.split("/")[-1].split("?")[0].split("#")[0]
    return urllib.parse.unquote(last)


def collect_media(all_rows):
    """
    Vindt alle media in de tabelrijen. Twee soorten, want de app schrijft
    beide (Storage-URL bij succes, inline base64 als fallback):
      - remote: https://<project>.supabase.co/storage/v1/object/public/media/...
      - inline: data:image/jpeg;base64,...

    remote is gesleuteld op bestandsnaam -> {"url": ..., "refs": [...]}.
    """
    remote, inline = {}, []
    for table, rows in all_rows.items():
        for idx, row in enumerate(rows):
            row_id = row.get("id", idx)
            for field, val in walk_strings(row):
                if val.startswith("data:") and DATA_URL_RE.match(val):
                    inline.append((table, row_id, field, val))
                elif "/storage/v1/object/" in val and val.startswith("http"):
                    key = file_name_from_url(val)
                    entry = remote.setdefault(key, {"url": val, "refs": []})
                    entry["refs"].append(f"{table}#{row_id}.{field}")
    return remote, inline


def list_bucket():
    """Probeert de bucket zelf uit te lezen — vangt media die in geen enkele
    rij meer voorkomt (verwijderde inzendingen, weesbestanden)."""
    names, offset = [], 0
    while True:
        url = f"{SUPABASE_URL}/storage/v1/object/list/{STORAGE_BUCKET}"
        body = {"prefix": "", "limit": PAGE_SIZE, "offset": offset,
                "sortBy": {"column": "name", "order": "asc"}}
        try:
            raw, _ = request(url, method="POST", body=body)
        except Exception as e:
            log(f"  -- bucket-listing niet beschikbaar ({e}); val terug op de "
                f"URL's uit de tabellen")
            return None
        batch = json.loads(raw.decode("utf-8"))
        names.extend(o["name"] for o in batch if o.get("name"))
        if len(batch) < PAGE_SIZE:
            break
        offset += PAGE_SIZE
    return names


def download(url, media_dir, filename):
    """
    Haalt het bestand op en slaat het op onder de extensie die bij de INHOUD
    hoort, niet onder de naam die in de bucket staat.
    Geeft (gelukt, opgeslagen naam, opmerking) terug.
    """
    try:
        raw, _headers = request(url)
    except Exception as e:
        return False, None, str(e)
    if not raw:
        return False, None, "leeg bestand (0 bytes)"

    final, changed, real = correct_name(filename, raw[:16])
    dest = os.path.join(media_dir, final)
    if os.path.exists(dest) and os.path.getsize(dest) == len(raw):
        return True, final, "overgeslagen (bestond al)"
    tmp = dest + ".part"
    with open(tmp, "wb") as fh:
        fh.write(raw)
    os.replace(tmp, dest)
    if changed:
        log(f"  ~ {filename}  ->  {final}")
    elif real is None:
        log(f"  ? {filename}: type niet herkend")
    return True, final, (real or "type onbekend")


def main():
    ap = argparse.ArgumentParser(description="Exporteer het volledige Stadsspel-archief.")
    ap.add_argument("--out", default=None, help="doelmap (standaard: archief/export-<datum>)")
    args = ap.parse_args()

    stamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    here = os.path.dirname(os.path.abspath(__file__))
    out_dir = os.path.abspath(args.out or os.path.join(here, f"export-{stamp}"))
    os.makedirs(os.path.join(out_dir, "tabellen"), exist_ok=True)
    os.makedirs(os.path.join(out_dir, "media"), exist_ok=True)

    log(f"Archief -> {out_dir}\n")

    # 1. Tabellen
    log("1/3  Tabellen ophalen")
    all_rows, counts = {}, {}
    for table in TABLES:
        rows = fetch_table(table)
        all_rows[table] = rows
        counts[table] = len(rows)
        write_table(out_dir, table, rows)
        log(f"  ok {table}: {len(rows)} rijen")

    # 2. Media uit de rijen
    log("\n2/3  Media ophalen")
    remote, inline = collect_media(all_rows)

    bucket_files = list_bucket()
    if bucket_files is not None:
        base = f"{SUPABASE_URL}/storage/v1/object/public/{STORAGE_BUCKET}/"
        for name in bucket_files:
            if name in remote:
                # Al bekend uit een tabelrij — alleen de herkomst aanvullen.
                remote[name]["refs"].append("bucket-listing")
            else:
                remote[name] = {"url": base + urllib.parse.quote(name),
                                "refs": ["bucket-listing"]}
        log(f"  bucket '{STORAGE_BUCKET}': {len(bucket_files)} bestanden")

    media_index, ok_count, renamed, unknown = [], 0, 0, 0
    media_dir = os.path.join(out_dir, "media")
    for key, entry in sorted(remote.items()):
        filename = safe_name(key)
        good, final, note = download(entry["url"], media_dir, filename)
        if good:
            ok_count += 1
            if final != filename:
                renamed += 1
            if note == "type onbekend":
                unknown += 1
        else:
            errors.append(f"download {entry['url']}: {note}")
            log(f"  !! {filename}: {note}")
        media_index.append({"bron": "storage", "url": entry["url"],
                            "bestand": f"media/{final}" if good else None,
                            "bucket_naam": filename, "hernoemd": bool(good and final != filename),
                            "gebruikt_in": entry["refs"], "ok": good, "opmerking": note})
    log(f"  ok storage-bestanden: {ok_count}/{len(remote)} binnen")
    if renamed:
        log(f"  {renamed} bestand(en) hernoemd naar de juiste extensie "
            f'(de upload van 6 juni gaf o.a. ".quicktim" i.p.v. ".mov")')
    if unknown:
        log(f"  {unknown} bestand(en) met onherkenbare inhoud — "
            f"die zijn waarschijnlijk beschadigd")
    # Wezen: in de bucket, maar door geen enkele tabelrij genoemd. Dat is media
    # waarvan de upload slaagde maar de bijbehorende rij niet is weggeschreven.
    # In de app was dit onzichtbaar — hier komt het wel mee.
    orphans = sum(1 for e in remote.values() if e["refs"] == ["bucket-listing"])
    if orphans:
        log(f"  {orphans} bestand(en) stonden alleen in de bucket, bij geen enkele "
            f"opdracht — teruggevonden materiaal dat de app nooit toonde")

    inline_ok = 0
    for table, row_id, field, data_url in inline:
        match = DATA_URL_RE.match(data_url)
        mime = match.group(1).lower()
        ext = MIME_EXT.get(mime, (mime.split("/")[-1] or "bin"))
        filename = safe_name(f"inline_{table}_{row_id}_{field}.{ext}")
        dest = os.path.join(out_dir, "media", filename)
        try:
            payload = data_url.split(",", 1)[1]
            with open(dest, "wb") as fh:
                fh.write(base64.b64decode(payload))
            inline_ok += 1
            media_index.append({"bron": "inline-base64", "url": None,
                                "bestand": f"media/{filename}",
                                "gebruikt_in": [f"{table}#{row_id}.{field}"],
                                "ok": True, "opmerking": mime})
        except Exception as e:
            errors.append(f"inline {table}#{row_id}.{field}: {e}")
            log(f"  !! inline {table}#{row_id}: {e}")
    log(f"  ok inline base64 uitgepakt: {inline_ok}/{len(inline)}")

    # 3. Manifest
    log("\n3/3  Manifest schrijven")
    manifest = {
        "gemaakt_op": datetime.now(timezone.utc).isoformat(),
        "supabase_url": SUPABASE_URL,
        "storage_bucket": STORAGE_BUCKET,
        "bucket_listing_gelukt": bucket_files is not None,
        "rijen_per_tabel": counts,
        "media_totaal": len(media_index),
        "media_hernoemd": renamed,
        "media_onherkenbaar": unknown,
        "media_alleen_in_bucket": orphans,
        "media_uit_storage": len(remote),
        "media_inline": len(inline),
        "fouten": errors,
        "media": media_index,
    }
    with open(os.path.join(out_dir, "manifest.json"), "w", encoding="utf-8") as fh:
        json.dump(manifest, fh, ensure_ascii=False, indent=2)

    total_rows = sum(counts.values())
    log(f"\nKlaar. {total_rows} rijen, {len(media_index)} mediabestanden.")
    log(f"Map: {out_dir}")
    if errors:
        log(f"\nLET OP: {len(errors)} fout(en) — zie manifest.json -> fouten.")
        log("Controleer of het Supabase-project actief is (niet gepauzeerd) "
            "voordat je hier conclusies uit trekt.")
        return 1
    log("Geen fouten. Zet deze map op een plek die losstaat van GitHub en Supabase.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
