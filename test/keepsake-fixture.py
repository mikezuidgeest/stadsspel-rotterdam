#!/usr/bin/env python3
"""
Maakt een nep-export met dezelfde vorm als archief/export-archief.py oplevert.

Waarvoor: keepsake/build-keepsake.py testen — en de keepsake zelf bekijken —
zonder dat er een draaiend Supabase-project nodig is.

    python3 test/keepsake-fixture.py --out /tmp/demo-export
    python3 keepsake/build-keepsake.py --export /tmp/demo-export --out /tmp/demo-keepsake
"""
import argparse, json, os, struct, sys, zlib
from datetime import datetime, timedelta, timezone

def png(w, h, rgb):
    """Kleine geldige PNG, zonder externe libraries."""
    raw = b"".join(b"\x00" + bytes(rgb) * w for _ in range(h))
    def chunk(tag, data):
        c = tag + data
        return struct.pack(">I", len(data)) + c + struct.pack(">I", zlib.crc32(c) & 0xFFFFFFFF)
    return (b"\x89PNG\r\n\x1a\n"
            + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(raw, 9))
            + chunk(b"IEND", b""))

TEAMS = [
    (1, "De Kraanvogels", "🏗️", "#e4b25c", 385),
    (2, "Team Kubuswoning", "🟨", "#6ea3ff", 340),
    (3, "Havenhoofden",    "⚓", "#ff6b6b", 295),
    (4, "De Watertaxi's",  "🚤", "#7ddf9a", 260),
]
SPOTS = [
    (1,  "Erasmusbrug",     "Bouw de brug na met z'n allen", "photo"),
    (10, "Laurenskerk",     "Gregoriaans in de kerkbank",     "video"),
    (12, "Stadhuis",        "Officiële toespraak op de trap",  "video"),
    (20, "Oude Haven",      "Kubuswoning-selfie",              "photo"),
    (5,  "Markthal",        "Proef iets wat je niet kent",     "photo"),
]

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="/tmp/demo-export")
    args = ap.parse_args()
    out = os.path.abspath(args.out)
    os.makedirs(os.path.join(out, "tabellen"), exist_ok=True)
    os.makedirs(os.path.join(out, "media"), exist_ok=True)

    t0 = datetime(2026, 6, 6, 14, 0, tzinfo=timezone.utc)
    base = "https://kybcndicweuxjxkfzxud.supabase.co/storage/v1/object/public/media/"

    teams = [{"id": i, "name": n, "emoji": e, "color": c, "score": s,
              "spectator": False, "created_at": t0.isoformat()}
             for i, n, e, c, s in TEAMS]
    teams.append({"id": 99, "name": "Game Master", "emoji": "👁️", "color": "#888",
                  "score": 0, "spectator": True, "created_at": t0.isoformat()})

    shots, feed, media_index = [], [], []
    rid = fid = 0
    for ti, (tid, tname, temoji, tcolor, _) in enumerate(TEAMS):
        for si, (lid, lname, title, ctype) in enumerate(SPOTS):
            rid += 1
            at = t0 + timedelta(minutes=17 * rid)
            # Eén inzending bewust zonder media — dat is de faalmodus van V57
            # en de keepsake hoort 'm eerlijk te tonen, niet te verbergen.
            drop = (rid == 7)
            ext = "mp4" if ctype == "video" else "png"
            fname = f"t{tid}_l{lid}_c0_{1770000000 + rid}_{rid:06d}.{ext}"
            url = None if drop else base + fname
            if not drop:
                path = os.path.join(out, "media", fname)
                if ext == "png":
                    shade = [(228, 178, 92), (110, 163, 255), (255, 107, 107), (125, 223, 154)][ti]
                    open(path, "wb").write(png(160 + si * 8, 160, shade))
                else:
                    # Geen echte video — genoeg om de tegel en de ▶-badge te testen.
                    open(path, "wb").write(b"\x00\x00\x00\x18ftypmp42" + b"\x00" * 2048)
                media_index.append({"bron": "storage", "url": url, "bestand": f"media/{fname}",
                                    "gebruikt_in": [f"photo_reviews#{rid}.photo_url"],
                                    "ok": True, "opmerking": ""})
            shots.append({
                "id": rid, "team_id": tid, "team_name": tname, "team_emoji": temoji,
                "team_color": tcolor, "location_id": lid, "location_name": lname,
                "challenge_idx": 0, "challenge_title": title, "challenge_type": ctype,
                "gps_distance": 12 + si, "points_awarded": 20 + si * 5,
                "photo_url": url, "status": "approved", "created_at": at.isoformat(),
            })
            fid += 1
            feed.append({
                "id": fid, "team_id": tid, "team_name": tname, "team_emoji": temoji,
                "team_color": tcolor, "message": f"{temoji} {lname} · {title} · +{20 + si * 5} pts",
                "points": 20 + si * 5, "photo": url, "loc_id": lid,
                "created_at": at.isoformat(),
            })

    fid += 1
    feed.append({"id": fid, "team_id": 1, "team_name": "De Kraanvogels", "team_emoji": "🏗️",
                 "team_color": "#e4b25c", "message": "🍻 Barpauze bij De Pelgrim!",
                 "points": 25, "photo": None, "loc_id": None,
                 "created_at": (t0 + timedelta(hours=3)).isoformat()})

    tables = {
        "teams": teams, "photo_reviews": shots, "activity_feed": feed,
        "completed_challenges": [], "team_members": [], "game_state": [],
        "feed_reactions": [], "challenge_first_finder": [],
    }
    for name, rows in tables.items():
        with open(os.path.join(out, "tabellen", f"{name}.json"), "w", encoding="utf-8") as fh:
            json.dump(rows, fh, ensure_ascii=False, indent=2)

    with open(os.path.join(out, "manifest.json"), "w", encoding="utf-8") as fh:
        json.dump({
            "gemaakt_op": datetime.now(timezone.utc).isoformat(),
            "supabase_url": "https://kybcndicweuxjxkfzxud.supabase.co",
            "storage_bucket": "media", "bucket_listing_gelukt": True,
            "rijen_per_tabel": {k: len(v) for k, v in tables.items()},
            "media_totaal": len(media_index), "media_uit_storage": len(media_index),
            "media_inline": 0, "fouten": [], "media": media_index,
        }, fh, ensure_ascii=False, indent=2)

    print(f"Nep-export klaar: {out}")
    print(f"  {len(teams)} teams · {len(shots)} inzendingen · {len(media_index)} mediabestanden")
    print(f"  1 inzending bewust zonder media (de V57-faalmodus)")
    return 0

if __name__ == "__main__":
    sys.exit(main())
