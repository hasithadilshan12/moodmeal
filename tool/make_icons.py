"""Draw the MoodMeal app icon and write every size the app needs.

Run from the project root:

    python tool/make_icons.py

It renders one master artwork (a cream bowl with three curls of steam on a warm
orange gradient), then writes the PWA icons, the favicon, and the Android
launcher icons (including an adaptive icon). Pillow is the only dependency:

    pip install pillow
"""

from __future__ import annotations

import math
import os

from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MASTER = 1024
SS = 3  # supersampling factor, keeps the curves smooth

CREAM = (255, 250, 243)
CREAM_SHADE = (238, 223, 206)
FOOD = (255, 198, 128)
FOOD_DEEP = (247, 150, 62)
SEED = (255, 248, 236)
ORANGE_TOP = (255, 190, 137)
ORANGE_BOTTOM = (242, 106, 10)


def _gradient(size: int) -> Image.Image:
    image = Image.new("RGB", (1, size))
    pixels = image.load()
    for y in range(size):
        t = y / (size - 1)
        pixels[0, y] = tuple(
            round(ORANGE_TOP[i] + (ORANGE_BOTTOM[i] - ORANGE_TOP[i]) * t)
            for i in range(3)
        )
    return image.resize((size, size), Image.BICUBIC).convert("RGBA")


def _mix(color, other, amount: float):
    return tuple(round(color[i] + (other[i] - color[i]) * amount) for i in range(3))


def _steam(draw: ImageDraw.ImageDraw, x: float, y0: float, y1: float,
           width: float, amp: float, phase: float) -> None:
    points = []
    steps = 80
    for i in range(steps + 1):
        t = i / steps
        y = y0 + (y1 - y0) * t
        x2 = x + math.sin(t * math.pi * 1.7 + phase) * amp * (1 - 0.35 * t)
        points.append((x2, y))
    draw.line(points, fill=(255, 255, 255), width=int(width), joint="curve")
    r = width / 2
    for px, py in (points[0], points[-1]):
        draw.ellipse((px - r, py - r, px + r, py + r), fill=(255, 255, 255))


def _artwork(size: int, maskable: bool = False, transparent: bool = False) -> Image.Image:
    s = size * SS
    image = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    if not transparent:
        image.alpha_composite(_gradient(s))

    draw = ImageDraw.Draw(image)
    # Maskable icons must keep the artwork inside the central safe zone.
    scale = 0.74 if maskable else 1.0
    if transparent:
        scale = 0.86

    def S(v: float) -> float:
        return s * (0.5 + (v - 0.5) * scale)

    def box(cx: float, cy: float, w: float, h: float):
        return (S(cx - w / 2), S(cy - h / 2), S(cx + w / 2), S(cy + h / 2))

    # Soft shadow under the bowl (opaque, so it blends with the gradient).
    if not transparent:
        draw.ellipse(
            box(0.5, 0.845, 0.46 * scale, 0.048 * scale),
            fill=(*_mix(ORANGE_BOTTOM, (60, 25, 0), 0.18), 255),
        )

    # Steam: three curls, the middle one slightly taller.
    for dx, top, amp in ((-0.115, 0.285, 0.026), (0.0, 0.225, 0.020), (0.115, 0.285, 0.026)):
        _steam(
            draw,
            S(0.5 + dx),
            S(top),
            S(0.495),
            s * 0.025 * scale,
            s * amp * scale,
            0.9 if dx > 0 else (-0.9 if dx < 0 else 0.0),
        )

    # Bowl body: lower half of an ellipse. Same width as the rim, so the two
    # silhouettes meet without a step.
    draw.pieslice(box(0.5, 0.60, 0.62, 0.50), 0, 180, fill=CREAM)

    # Rim ring.
    draw.ellipse(box(0.5, 0.60, 0.62, 0.13), fill=CREAM)
    # Food in the middle of the ring.
    draw.ellipse(box(0.5, 0.601, 0.50, 0.094), fill=FOOD)
    draw.ellipse(box(0.5, 0.606, 0.40, 0.066), fill=FOOD_DEEP)

    # Sesame seeds, small enough to read as texture rather than clutter.
    for dx, dy in ((-0.10, 0.598), (0.00, 0.592), (0.10, 0.600)):
        draw.ellipse(box(0.5 + dx, dy, 0.022, 0.012), fill=SEED)

    return image.resize((size, size), Image.LANCZOS)


def _save(image: Image.Image, path: str) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    image.save(path, "PNG", optimize=True)
    print("wrote", os.path.relpath(path, ROOT))


def main() -> None:
    master = _artwork(MASTER)
    _save(master, os.path.join(ROOT, "assets", "branding", "app_icon.png"))

    for size in (192, 512):
        _save(master.resize((size, size), Image.LANCZOS),
              os.path.join(ROOT, "web", "icons", f"Icon-{size}.png"))

    maskable = _artwork(MASTER, maskable=True)
    for size in (192, 512):
        _save(maskable.resize((size, size), Image.LANCZOS),
              os.path.join(ROOT, "web", "icons", f"Icon-maskable-{size}.png"))

    _save(master.resize((64, 64), Image.LANCZOS),
          os.path.join(ROOT, "web", "favicon.png"))

    res = os.path.join(ROOT, "android", "app", "src", "main", "res")
    legacy = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
    for density, size in legacy.items():
        _save(master.resize((size, size), Image.LANCZOS),
              os.path.join(res, f"mipmap-{density}", "ic_launcher.png"))

    # Adaptive icon: 108 dp canvas, artwork in the safe zone, transparent.
    foreground = _artwork(MASTER * 2, transparent=True)
    adaptive = {"mdpi": 108, "hdpi": 162, "xhdpi": 216,
                "xxhdpi": 324, "xxxhdpi": 432}
    for density, size in adaptive.items():
        _save(foreground.resize((size, size), Image.LANCZOS),
              os.path.join(res, f"mipmap-{density}", "ic_launcher_foreground.png"))

    anydpi = os.path.join(res, "mipmap-anydpi-v26")
    os.makedirs(anydpi, exist_ok=True)
    with open(os.path.join(anydpi, "ic_launcher.xml"), "w", encoding="utf-8") as fh:
        fh.write(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
            '    <background android:drawable="@color/ic_launcher_background"/>\n'
            '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
            '</adaptive-icon>\n'
        )
    print("wrote", os.path.relpath(os.path.join(anydpi, "ic_launcher.xml"), ROOT))

    values = os.path.join(res, "values")
    os.makedirs(values, exist_ok=True)
    with open(os.path.join(values, "ic_launcher_background.xml"), "w",
              encoding="utf-8") as fh:
        fh.write(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            '<resources>\n'
            '    <color name="ic_launcher_background">#F9751A</color>\n'
            '</resources>\n'
        )
    print("wrote", os.path.relpath(
        os.path.join(values, "ic_launcher_background.xml"), ROOT))


if __name__ == "__main__":
    main()
