#!/usr/bin/env python3
"""Generate the koi wallpaper from a reduced theme palette."""

import argparse
import math
import subprocess
import tempfile
from pathlib import Path

TEMPLATE = Path(__file__).with_name("template.svg")
WIDTH, HEIGHT = 3840, 2160


def hex_to_rgb(value):
    value = value.lstrip("#")
    return tuple(int(value[i : i + 2], 16) / 255 for i in (0, 2, 4))


def rgb_to_hex(rgb):
    return "#" + "".join(f"{round(min(max(c, 0), 1) * 255):02X}" for c in rgb)


def srgb_to_linear(c):
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def linear_to_srgb(c):
    return 12.92 * c if c <= 0.0031308 else 1.055 * c ** (1 / 2.4) - 0.055


def rgb_to_oklch(rgb):
    r, g, b = (srgb_to_linear(c) for c in rgb)
    l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
    m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
    s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b
    l, m, s = (math.copysign(abs(x) ** (1 / 3), x) for x in (l, m, s))
    L = 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s
    a = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s
    b = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
    return L, math.hypot(a, b), math.atan2(b, a)


def oklch_to_linear_rgb(L, C, H):
    a, b = C * math.cos(H), C * math.sin(H)
    l = (L + 0.3963377774 * a + 0.2158037573 * b) ** 3
    m = (L - 0.1055613458 * a - 0.0638541728 * b) ** 3
    s = (L - 0.0894841775 * a - 1.2914855480 * b) ** 3
    return (
        4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
        -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
        -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s,
    )


def in_gamut(rgb):
    return all(-1e-4 <= c <= 1 + 1e-4 for c in rgb)


def oklch_to_rgb(L, C, H):
    L = min(max(L, 0), 1)
    rgb = oklch_to_linear_rgb(L, C, H)
    if not in_gamut(rgb):
        lo, hi = 0.0, C
        for _ in range(30):
            mid = (lo + hi) / 2
            if in_gamut(oklch_to_linear_rgb(L, mid, H)):
                lo = mid
            else:
                hi = mid
        rgb = oklch_to_linear_rgb(L, lo, H)
    return tuple(linear_to_srgb(min(max(c, 0), 1)) for c in rgb)


def lighter(color):
    L, C, H = rgb_to_oklch(color)
    return oklch_to_rgb(L + (0.95 - L) * 0.45, C, H)


def darker(color, hue_shift=0.0):
    L, C, H = rgb_to_oklch(color)
    return oklch_to_rgb(L * 0.73, C, H + math.radians(hue_shift))


def luminance(color):
    return rgb_to_oklch(color)[0]


def derive(args):
    background = hex_to_rgb(args.background)
    blue = hex_to_rgb(args.blue)
    yellow = hex_to_rgb(args.yellow)
    pink = hex_to_rgb(args.pink)

    if luminance(background) >= 0.5:
        bright, dim = darker, lighter
    else:
        bright, dim = lighter, darker

    colors = {
        "BACKGROUND": background,
        "MANTLE": hex_to_rgb(args.mantle),
        "WHITE": hex_to_rgb(args.white),
        "YELLOW": yellow,
        "ORANGE": dim(yellow, hue_shift=-25),
        "BLUE_DARK": blue,
        "BLUE_LIGHT": bright(blue),
        "PINK_LIGHT": pink,
        "PINK_DARK": dim(pink),
    }
    return {name: rgb_to_hex(rgb) for name, rgb in colors.items()}


def render(svg_text, colors):
    for name, value in colors.items():
        svg_text = svg_text.replace("{{" + name + "}}", value)
    return svg_text


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for flag in ("background", "mantle", "white", "blue", "yellow", "pink"):
        parser.add_argument(f"--{flag}", required=True, help="hex color")
    parser.add_argument("--svg", type=Path, help="write the colored SVG here")
    parser.add_argument("--png", type=Path, help="write a 3840x2160 PNG here")
    args = parser.parse_args()

    if not args.svg and not args.png:
        parser.error("pass --svg, --png, or both")

    svg = render(TEMPLATE.read_text(encoding="utf-8"), derive(args))

    if args.svg:
        args.svg.write_text(svg, encoding="utf-8")

    if args.png:
        with tempfile.NamedTemporaryFile("w", suffix=".svg", encoding="utf-8") as tmp:
            tmp.write(svg)
            tmp.flush()
            subprocess.run(
                [
                    "rsvg-convert",
                    "-w", str(WIDTH),
                    "-h", str(HEIGHT),
                    "-f", "png",
                    "-o", str(args.png),
                    tmp.name,
                ],
                check=True,
            )


if __name__ == "__main__":
    main()
