"""Zip the release web build for a Netlify "drag and drop" deploy.

Windows' Compress-Archive writes backslash separators, which Netlify stores as
literal file names -> every asset 404s. Python's zipfile always writes forward
slashes, so use this script instead of Compress-Archive.

Usage:
    python tool/zip_web.py
"""

from __future__ import annotations

import os
import shutil
import sys
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WEB = os.path.join(ROOT, "build", "web")
OUT = os.path.join(ROOT, "build", "moodmeal-web.zip")


def main() -> int:
    if not os.path.isfile(os.path.join(WEB, "index.html")):
        print("build/web/index.html is missing - run 'flutter build web' first.")
        return 1

    if os.path.exists(OUT):
        os.remove(OUT)

    # make_archive keeps paths relative to build/web and uses '/' separators.
    created = shutil.make_archive(os.path.splitext(OUT)[0], "zip", WEB)

    with zipfile.ZipFile(created) as archive:
        names = archive.namelist()
        bad = [n for n in names if "\\" in n]
        top = sorted({n.split("/")[0] for n in names})

    print(f"zip      : {created}")
    print(f"entries  : {len(names)}")
    print(f"size     : {os.path.getsize(created) / (1024 * 1024):.2f} MB")
    print(f"backslash: {len(bad)}")
    print(f"top level: {', '.join(top[:8])}{' ...' if len(top) > 8 else ''}")

    if bad:
        print("FAILED: the archive contains backslash paths.")
        return 1
    if "index.html" not in names or "main.dart.js" not in names:
        print("FAILED: index.html / main.dart.js missing from the archive.")
        return 1

    print("OK: upload this zip in Netlify > Deploys.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
