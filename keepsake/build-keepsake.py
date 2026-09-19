#!/usr/bin/env python3
"""
Bouwt een offline aandenken uit een archief-export.

De speel-app zelf is hiervoor ongeschikt: die haalt React, Leaflet en Supabase
van externe CDN's en praat live met de database. Over vijf jaar opent dat niets
meer. Dit script maakt er één map van die het wél doet — dubbelklik index.html,
geen internet, geen server, geen afhankelijkheden.

Gebruik:
    python3 archief/export-archief.py                     # eerst de data ophalen
    python3 keepsake/build-keepsake.py                    # nieuwste export pakken
    python3 keepsake/build-keepsake.py --export <map> --out <map>

Resultaat:
    <out>/index.html     alles in één bestand, data inline (file:// blokkeert fetch)
    <out>/media/...      de foto's en video's, als gewone bestanden ernaast

Zet die map op een USB-stick, in Dropbox, of brand 'm op een schijf. Hij is
volledig zelfstandig.
"""

import argparse
import html
import json
import os
import re
import shutil
import sys
from datetime import datetime, timezone

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)

TABLES = ["teams", "activity_feed", "photo_reviews", "completed_challenges",
          "team_members", "game_state", "feed_reactions", "challenge_first_finder"]

# Ook de kapotte extensies uit de bucket van 6 juni (.quicktim enz.).
VIDEO_EXT = re.compile(r"\.(mp4|m4v|mov|qt|webm|ogv|quicktim\w*|xm4v|3gpp?|mpeg4?)$", re.I)


def newest_export():
    root = os.path.join(HERE, "..", "archief")
    if not os.path.isdir(root):
        return None
    cands = sorted(
        (os.path.join(root, d) for d in os.listdir(root) if d.startswith("export-")),
        reverse=True,
    )
    return cands[0] if cands else None


def load_table(export_dir, name):
    path = os.path.join(export_dir, "tabellen", f"{name}.json")
    if not os.path.exists(path):
        return []
    try:
        with open(path, encoding="utf-8") as fh:
            rows = json.load(fh)
        return rows if isinstance(rows, list) else []
    except Exception as e:
        print(f"  !! {name}.json onleesbaar: {e}")
        return []


def build_media_map(export_dir):
    """Remote URL (en inline-herkomst) -> lokaal bestandspad uit manifest.json."""
    mapping = {}
    manifest_path = os.path.join(export_dir, "manifest.json")
    if not os.path.exists(manifest_path):
        return mapping, {}
    with open(manifest_path, encoding="utf-8") as fh:
        manifest = json.load(fh)
    by_ref = {}
    for item in manifest.get("media", []):
        if not item.get("ok"):
            continue
        local = item.get("bestand")
        if not local:
            continue
        if item.get("url"):
            mapping[item["url"]] = local
        for ref in item.get("gebruikt_in", []):
            by_ref[ref] = local
    return mapping, by_ref


def resolve_media(value, table, row_id, field, url_map, ref_map):
    """Zet een photo_url / photo-waarde om naar een pad binnen de keepsake-map."""
    if not value or not isinstance(value, str):
        return None
    if value in url_map:
        return url_map[value]
    ref = f"{table}#{row_id}.{field}"
    if ref in ref_map:
        return ref_map[ref]
    if value.startswith("data:"):
        return None  # de export schreef deze als inline_*; zonder manifest niet te koppelen
    return None


def main():
    ap = argparse.ArgumentParser(description="Bouw een offline aandenken uit een archief-export.")
    ap.add_argument("--export", default=None, help="exportmap (standaard: de nieuwste in archief/)")
    ap.add_argument("--out", default=None, help="doelmap (standaard: keepsake/stadsspel-aandenken)")
    ap.add_argument("--titel", default="Stadsspel Rotterdam")
    ap.add_argument("--ondertitel", default="Jorik's Bachelor Party · 6 juni 2026")
    args = ap.parse_args()

    export_dir = os.path.abspath(args.export or (newest_export() or ""))
    if not export_dir or not os.path.isdir(export_dir):
        print("Geen exportmap gevonden. Draai eerst:\n    python3 archief/export-archief.py")
        return 1

    out_dir = os.path.abspath(args.out or os.path.join(HERE, "stadsspel-aandenken"))
    os.makedirs(out_dir, exist_ok=True)

    print(f"Export : {export_dir}")
    print(f"Doel   : {out_dir}\n")

    url_map, ref_map = build_media_map(export_dir)
    data = {name: load_table(export_dir, name) for name in TABLES}
    for name in TABLES:
        print(f"  {name}: {len(data[name])} rijen")

    # Media meekopiëren.
    src_media = os.path.join(export_dir, "media")
    dst_media = os.path.join(out_dir, "media")
    copied = 0
    if os.path.isdir(src_media):
        os.makedirs(dst_media, exist_ok=True)
        for fn in os.listdir(src_media):
            src = os.path.join(src_media, fn)
            if not os.path.isfile(src):
                continue
            dst = os.path.join(dst_media, fn)
            if not os.path.exists(dst) or os.path.getsize(dst) != os.path.getsize(src):
                shutil.copy2(src, dst)
            copied += 1
    print(f"  media: {copied} bestanden gekopieerd")

    # Teams + eindstand.
    teams = []
    for t in data["teams"]:
        if t.get("spectator"):
            continue
        teams.append({
            "id": t.get("id"),
            "name": t.get("name") or "Naamloos team",
            "emoji": t.get("emoji") or "🎯",
            "color": t.get("color") or "#e4b25c",
            "score": t.get("score") or 0,
        })
    teams.sort(key=lambda t: (-(t["score"] or 0), str(t["name"])))

    # Feed, nieuwste eerst in de data; we tonen chronologisch.
    feed = []
    for row in data["activity_feed"]:
        local = resolve_media(row.get("photo"), "activity_feed", row.get("id"), "photo", url_map, ref_map)
        feed.append({
            "id": row.get("id"),
            "message": row.get("message") or "",
            "points": row.get("points") or 0,
            "at": row.get("created_at"),
            "team": row.get("team_name"),
            "emoji": row.get("team_emoji"),
            "color": row.get("team_color") or "#e4b25c",
            "media": local,
        })
    feed.sort(key=lambda e: str(e["at"] or ""))

    # Inzendingen — de eigenlijke fotogalerij.
    shots = []
    missing = 0
    for row in data["photo_reviews"]:
        local = resolve_media(row.get("photo_url"), "photo_reviews", row.get("id"), "photo_url", url_map, ref_map)
        if not local:
            missing += 1
        shots.append({
            "id": row.get("id"),
            "team": row.get("team_name"),
            "emoji": row.get("team_emoji"),
            "color": row.get("team_color") or "#e4b25c",
            "location": row.get("location_name") or "",
            "title": row.get("challenge_title") or "",
            "type": row.get("challenge_type") or "",
            "points": row.get("points_awarded") or 0,
            "at": row.get("created_at"),
            "media": local,
        })
    shots.sort(key=lambda s: str(s["at"] or ""))

    payload = {
        "titel": args.titel,
        "ondertitel": args.ondertitel,
        "gebouwdOp": datetime.now(timezone.utc).isoformat(),
        "teams": teams,
        "feed": feed,
        "shots": shots,
        "stats": {
            "teams": len(teams),
            "feed": len(feed),
            "shots": len(shots),
            "media": sum(1 for s in shots if s["media"]),
            "zonderMedia": missing,
        },
    }

    template_path = os.path.join(HERE, "template.html")
    with open(template_path, encoding="utf-8") as fh:
        template = fh.read()

    # </script> in de JSON zou het script-blok voortijdig sluiten.
    blob = json.dumps(payload, ensure_ascii=False).replace("</", "<\\/")
    page = template.replace("__TITEL__", html.escape(args.titel))
    page = page.replace("__ONDERTITEL__", html.escape(args.ondertitel))
    page = page.replace('"__DATA__"', blob)

    with open(os.path.join(out_dir, "index.html"), "w", encoding="utf-8") as fh:
        fh.write(page)

    print(f"\nKlaar. Open: {os.path.join(out_dir, 'index.html')}")
    print(f"  {len(teams)} teams · {len(shots)} inzendingen · {payload['stats']['media']} met media")
    if missing:
        print(f"  {missing} inzendingen zonder media — dat is wat op de speeldag is gesneuveld")
        print("  (zie MEDIA-FIX-V57.md; de originelen staan nog in de camerarol van de spelers)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
