"""Shot Oyunu uygulama ikonunu üretir: düz, tek bir shot bardağı silueti.

İki dosya üretilir:
- assets/icon/icon.png            → tam ikon (mor->pembe degrade arka plan +
  bardak), iOS ve eski Android ikonları için.
- assets/icon/icon_foreground.png → SADECE bardak, şeffaf arka plan, Android
  adaptive icon'un "safe zone"una (iç ~%66) sığacak şekilde küçültülmüş —
  Android bunu daire/kare gibi farklı maskelerle kırptığı için arka planın
  ayrı, düz renkli katman (adaptive_icon_background) olması gerekiyor.
"""
from PIL import Image, ImageDraw

SIZE = 1024


def draw_glass(draw, cx, glass_top_y, glass_bottom_y, top_half_w, bottom_half_w):
    glass = [
        (cx - top_half_w, glass_top_y),
        (cx + top_half_w, glass_top_y),
        (cx + bottom_half_w, glass_bottom_y),
        (cx - bottom_half_w, glass_bottom_y),
    ]
    draw.polygon(glass, fill=(255, 255, 255, 255))

    rim_h = 28
    draw.ellipse(
        [cx - top_half_w, glass_top_y - rim_h / 2, cx + top_half_w, glass_top_y + rim_h / 2],
        fill=(235, 235, 240, 255),
    )

    liquid_top_y = glass_top_y + (glass_bottom_y - glass_top_y) * 0.55
    t = (liquid_top_y - glass_top_y) / (glass_bottom_y - glass_top_y)
    liquid_half_w_top = top_half_w + (bottom_half_w - top_half_w) * t
    liquid = [
        (cx - liquid_half_w_top, liquid_top_y),
        (cx + liquid_half_w_top, liquid_top_y),
        (cx + bottom_half_w, glass_bottom_y),
        (cx - bottom_half_w, glass_bottom_y),
    ]
    draw.polygon(liquid, fill=(255, 209, 102, 255))  # #FFD166

    draw.line(
        [(cx - bottom_half_w, glass_bottom_y), (cx + bottom_half_w, glass_bottom_y)],
        fill=(230, 230, 230, 255),
        width=10,
    )

    highlight = [
        (cx - top_half_w + 35, glass_top_y + 15),
        (cx - top_half_w + 60, glass_top_y + 15),
        (cx - bottom_half_w + 40, glass_bottom_y - 15),
        (cx - bottom_half_w + 15, glass_bottom_y - 15),
    ]
    draw.polygon(highlight, fill=(214, 200, 230, 255))


# ── 1) Tam ikon: degrade arka plan + bardak ─────────────────────────────
full = Image.new("RGB", (SIZE, SIZE), "#000000")
draw = ImageDraw.Draw(full)

top_color = (114, 9, 183)     # #7209B7
bottom_color = (255, 0, 110)  # #FF006E
for y in range(SIZE):
    t = y / (SIZE - 1)
    r = round(top_color[0] + (bottom_color[0] - top_color[0]) * t)
    g = round(top_color[1] + (bottom_color[1] - top_color[1]) * t)
    b = round(top_color[2] + (bottom_color[2] - top_color[2]) * t)
    draw.line([(0, y), (SIZE, y)], fill=(r, g, b))

draw_glass(draw, SIZE / 2, 300, 760, 190, 140)
full.save("assets/icon/icon.png")
print("Wrote assets/icon/icon.png", full.size)

# ── 2) Sadece bardak, şeffaf arka plan, adaptive icon safe-zone'a göre
#      küçültülmüş (Android güvenli alanı ~%66 çap) ─────────────────────
fg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
fg_draw = ImageDraw.Draw(fg)
# Orijinal tasarım merkezi ~530 civarında, y 300-760 arası (460px yükseklik,
# tuvalin ~%45'i) — safe zone için biraz küçültüp ortalıyoruz.
scale = 0.66
cx = SIZE / 2
mid_y = (300 + 760) / 2
new_half_height = (760 - 300) / 2 * scale
draw_glass(
    fg_draw,
    cx,
    mid_y - new_half_height,
    mid_y + new_half_height,
    190 * scale,
    140 * scale,
)
fg.save("assets/icon/icon_foreground.png")
print("Wrote assets/icon/icon_foreground.png", fg.size)
