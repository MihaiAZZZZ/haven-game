import os
import math

OUTPUT_DIRS = [
    r"d:\haven-gaem\exported_svgs",
    r"d:\haven-gaem\assets\svgs"
]

for d in OUTPUT_DIRS:
    os.makedirs(d, exist_ok=True)

def save_svg(name, svg_content):
    for d in OUTPUT_DIRS:
        path = os.path.join(d, name)
        with open(path, "w", encoding="utf-8") as f:
            f.write(svg_content.strip())
    print(f"Generated {name}")

# Helper for SVG XML
def svg_wrap(width, height, content, viewBox=None):
    if not viewBox:
        viewBox = f"0 0 {width} {height}"
    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="{viewBox}" shape-rendering="crispEdges">
{content}
</svg>"""

# -------------------------------------------------------------
# 1. Corin Ghost (Normal)
# -------------------------------------------------------------
def make_corin_normal():
    w, h = 64, 72
    p = 4
    # 16x18 pixel grid mapped to 64x72
    ink = "#1c1426"
    fill = "#faf5ea"
    shad = "#ded4c7"
    blush = "#f28d94"
    eye = "#1c1426"
    
    hem = [1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0]
    
    rects = []
    for y in range(18):
        for x in range(16):
            c = None
            if y == 0:
                if 4 <= x <= 11: c = ink
            elif y == 1:
                if x in (2, 3, 12, 13): c = ink
                elif 4 <= x <= 11: c = fill
            elif y == 2:
                if x in (1, 14): c = ink
                elif 2 <= x <= 13: c = fill
            elif 3 <= y <= 14:
                if x in (0, 15): c = ink
                elif 1 <= x <= 14:
                    if x >= 12 or y >= 13: c = shad
                    else: c = fill
            elif y == 15:
                if x in (0, 15): c = ink
                elif hem[x] == 1: c = ink
                else: c = shad
            elif y == 16:
                if hem[x] == 1 and 1 <= x <= 14: c = ink
                
            if c:
                rects.append(f'<rect x="{x*p}" y="{y*p}" width="{p}" height="{p}" fill="{c}"/>')
                
    # Eyes
    eye_y = 5 * p
    # Left eye (2x3 px)
    rects.append(f'<rect x="{4*p}" y="{eye_y}" width="{2*p}" height="{3*p}" fill="#ffffff"/>')
    rects.append(f'<rect x="{4*p}" y="{eye_y + p}" width="{p}" height="{p}" fill="{eye}"/>')
    rects.append(f'<rect x="{4*p}" y="{eye_y}" width="{p}" height="{p}" fill="#ffffff"/>')
    # Right eye
    rects.append(f'<rect x="{10*p}" y="{eye_y}" width="{2*p}" height="{3*p}" fill="#ffffff"/>')
    rects.append(f'<rect x="{10*p}" y="{eye_y + p}" width="{p}" height="{p}" fill="{eye}"/>')
    rects.append(f'<rect x="{10*p}" y="{eye_y}" width="{p}" height="{p}" fill="#ffffff"/>')
    
    # Blush (2x1)
    rects.append(f'<rect x="{2*p}" y="{8*p}" width="{2*p}" height="{p}" fill="{blush}"/>')
    rects.append(f'<rect x="{12*p}" y="{8*p}" width="{2*p}" height="{p}" fill="{blush}"/>')
    # Mouth (2x1)
    rects.append(f'<rect x="{7*p}" y="{9*p}" width="{2*p}" height="{p}" fill="{ink}"/>')
    
    return svg_wrap(w, h, "\n".join(rects))

# -------------------------------------------------------------
# 2. Corin Ghost (Phased / Ghost Mode)
# -------------------------------------------------------------
def make_corin_phased():
    w, h = 80, 88
    p = 4
    ox, oy = 8, 8
    ink = "#594785"
    fill = "#d9ccfa"
    shad = "#b8a6e0"
    
    rects = []
    # Ethereal aura backing
    rects.append(f'<circle cx="{40}" cy="{40}" r="34" fill="rgba(160, 130, 240, 0.25)"/>')
    rects.append(f'<circle cx="{40}" cy="{40}" r="22" fill="rgba(190, 170, 255, 0.35)"/>')
    
    hem = [0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0]
    for y in range(18):
        for x in range(16):
            c = None
            if y == 0:
                if 4 <= x <= 11: c = ink
            elif y == 1:
                if x in (2, 3, 12, 13): c = ink
                elif 4 <= x <= 11: c = fill
            elif y == 2:
                if x in (1, 14): c = ink
                elif 2 <= x <= 13: c = fill
            elif 3 <= y <= 14:
                if x in (0, 15): c = ink
                elif 1 <= x <= 14: c = fill
            elif y == 15:
                if x in (0, 15): c = ink
                elif hem[x] == 1: c = ink
                else: c = shad
            elif y == 16:
                if hem[x] == 1 and 1 <= x <= 14: c = ink
                
            if c:
                rects.append(f'<rect x="{ox + x*p}" y="{oy + y*p}" width="{p}" height="{p}" fill="{c}"/>')
                
    # Glowing eyes
    eye_y = oy + 5 * p
    rects.append(f'<rect x="{ox + 4*p}" y="{eye_y}" width="{2*p}" height="{3*p}" fill="#ffffff"/>')
    rects.append(f'<rect x="{ox + 4*p}" y="{eye_y + p}" width="{p}" height="{p}" fill="{ink}"/>')
    rects.append(f'<rect x="{ox + 10*p}" y="{eye_y}" width="{2*p}" height="{3*p}" fill="#ffffff"/>')
    rects.append(f'<rect x="{ox + 10*p}" y="{eye_y + p}" width="{p}" height="{p}" fill="{ink}"/>')
    
    # Sparkling aura motes
    sparks = [(ox - 4, oy + 20), (ox + 64, oy + 12), (ox - 2, oy + 50), (ox + 66, oy + 44), (ox + 30, oy - 4)]
    for sx, sy in sparks:
        rects.append(f'<rect x="{sx}" y="{sy}" width="4" height="4" fill="#ffffff"/>')
        rects.append(f'<rect x="{sx+1}" y="{sy+1}" width="2" height="2" fill="#c4b5fd"/>')
        
    return svg_wrap(w, h, "\n".join(rects))

# -------------------------------------------------------------
# 3. Corin Ascended (With Halo & Wings)
# -------------------------------------------------------------
def make_corin_ascended():
    w, h = 96, 96
    ink = "#241a29"
    gold = "#fbbf24"
    rects = []
    
    # Celestial rays & aura
    rects.append('<circle cx="48" cy="48" r="44" fill="rgba(254, 240, 138, 0.25)"/>')
    rects.append('<circle cx="48" cy="48" r="30" fill="rgba(253, 224, 71, 0.3)"/>')
    
    # Golden Halo
    rects.append(f'<rect x="34" y="8" width="28" height="8" fill="{ink}"/>')
    rects.append(f'<rect x="36" y="10" width="24" height="4" fill="{gold}"/>')
    rects.append('<rect x="40" y="11" width="16" height="2" fill="#ffffff"/>')
    
    # Wings (Left & Right)
    rects.append(f'<rect x="10" y="32" width="26" height="16" fill="{ink}"/>')
    rects.append('<rect x="12" y="34" width="22" height="12" fill="#fef9c3"/>')
    rects.append(f'<rect x="60" y="32" width="26" height="16" fill="{ink}"/>')
    rects.append('<rect x="62" y="34" width="22" height="12" fill="#fef9c3"/>')
    
    # Body
    rects.append(f'<rect x="30" y="28" width="36" height="38" fill="{ink}"/>')
    rects.append('<rect x="33" y="31" width="30" height="32" fill="#fef08a"/>')
    
    # Happy closed eyes ^^
    rects.append(f'<rect x="39" y="42" width="5" height="3" fill="{ink}"/>')
    rects.append(f'<rect x="52" y="42" width="5" height="3" fill="{ink}"/>')
    # Cheeks
    rects.append('<rect x="36" y="48" width="5" height="2" fill="#f87171"/>')
    rects.append('<rect x="55" y="48" width="5" height="2" fill="#f87171"/>')
    # Happy mouth
    rects.append(f'<rect x="46" y="49" width="4" height="2" fill="{ink}"/>')
    
    return svg_wrap(w, h, "\n".join(rects))

# -------------------------------------------------------------
# 4. Ghost Mother (Maria)
# -------------------------------------------------------------
def make_ghost_mother():
    w, h = 80, 96
    ink = "#1f1729"
    rects = []
    
    # Loving emerald/gold spirit aura
    rects.append('<circle cx="40" cy="46" r="36" fill="rgba(110, 231, 183, 0.22)"/>')
    rects.append('<circle cx="40" cy="46" r="26" fill="rgba(253, 230, 138, 0.25)"/>')
    
    # Mother Hair / Bun
    rects.append(f'<rect x="30" y="10" width="20" height="12" fill="{ink}"/>')
    rects.append('<rect x="32" y="12" width="16" height="8" fill="#d8b4e2"/>')
    # Golden hair clip / flower
    rects.append('<rect x="44" y="12" width="6" height="6" fill="#fbbf24"/>')
    rects.append('<rect x="46" y="14" width="2" height="2" fill="#ffffff"/>')
    
    # Head
    rects.append(f'<rect x="28" y="22" width="24" height="20" fill="{ink}"/>')
    rects.append('<rect x="30" y="24" width="20" height="16" fill="#faf5ff"/>')
    
    # Gentle motherly eyes
    rects.append(f'<rect x="34" y="30" width="3" height="4" fill="{ink}"/>')
    rects.append(f'<rect x="43" y="30" width="3" height="4" fill="{ink}"/>')
    rects.append('<rect x="35" y="31" width="1" height="1" fill="#ffffff"/>')
    rects.append('<rect x="44" y="31" width="1" height="1" fill="#ffffff"/>')
    
    # Rosy blush
    rects.append('<rect x="32" y="36" width="3" height="2" fill="#f472b6"/>')
    rects.append('<rect x="45" y="36" width="3" height="2" fill="#f472b6"/>')
    
    # Cameo Necklace at throat
    rects.append(f'<rect x="37" y="42" width="6" height="5" fill="{ink}"/>')
    rects.append('<rect x="38" y="43" width="4" height="3" fill="#fbbf24"/>')
    rects.append('<rect x="39" y="44" width="2" height="1" fill="#34d399"/>')
    
    # Flowing Gown & Shawl
    rects.append(f'<rect x="24" y="44" width="32" height="32" fill="{ink}"/>')
    rects.append('<rect x="26" y="46" width="28" height="28" fill="#f3e8ff"/>')
    # Soft emerald embroidery ribbon
    rects.append('<rect x="34" y="46" width="12" height="28" fill="#a7f3d0"/>')
    
    # Wavy dress hem
    for i in range(5):
        rects.append(f'<rect x="{26 + i*6}" y="{74 + (i%2)*2}" width="4" height="6" fill="{ink}"/>')
        rects.append(f'<rect x="{27 + i*6}" y="{75 + (i%2)*2}" width="2" height="4" fill="#faf5ff"/>')
        
    return svg_wrap(w, h, "\n".join(rects))

# -------------------------------------------------------------
# 5. Ghost Grandmother (Elena)
# -------------------------------------------------------------
def make_ghost_grandmother():
    w, h = 80, 96
    ink = "#1f1729"
    rects = []
    
    # Soft ruby/rose aura
    rects.append('<circle cx="40" cy="46" r="36" fill="rgba(244, 114, 182, 0.22)"/>')
    rects.append('<circle cx="40" cy="46" r="26" fill="rgba(251, 146, 60, 0.2)"/>')
    
    # Braided crown hairstyle
    rects.append(f'<rect x="28" y="12" width="24" height="12" fill="{ink}"/>')
    rects.append('<rect x="30" y="14" width="20" height="8" fill="#cbd5e1"/>')
    
    # Head
    rects.append(f'<rect x="28" y="24" width="24" height="20" fill="{ink}"/>')
    rects.append('<rect x="30" y="26" width="20" height="16" fill="#f8fafc"/>')
    
    # Watchful, protective eyes
    rects.append(f'<rect x="34" y="32" width="4" height="4" fill="{ink}"/>')
    rects.append(f'<rect x="42" y="32" width="4" height="4" fill="{ink}"/>')
    rects.append('<rect x="35" y="33" width="1" height="1" fill="#ffffff"/>')
    rects.append('<rect x="43" y="33" width="1" height="1" fill="#ffffff"/>')
    
    # Ruby Brooch at collar
    rects.append(f'<rect x="36" y="44" width="8" height="6" fill="{ink}"/>')
    rects.append('<rect x="37" y="45" width="6" height="4" fill="#fbbf24"/>')
    rects.append('<rect x="38" y="46" width="4" height="2" fill="#e11d48"/>')
    
    # Wool knitted shawl & Victorian apron
    rects.append(f'<rect x="22" y="46" width="36" height="32" fill="{ink}"/>')
    rects.append('<rect x="24" y="48" width="32" height="28" fill="#e2e8f0"/>')
    rects.append('<rect x="30" y="48" width="20" height="28" fill="#fecdd3"/>')
    
    # Scalloped hem
    for i in range(5):
        rects.append(f'<rect x="{24 + i*7}" y="{76 + (i%2)*2}" width="5" height="5" fill="{ink}"/>')
        rects.append(f'<rect x="{25 + i*7}" y="{77 + (i%2)*2}" width="3" height="3" fill="#f8fafc"/>')
        
    return svg_wrap(w, h, "\n".join(rects))

# -------------------------------------------------------------
# 6. Ghost Matriarch Victoria (Străbunica - Posesorul Originar)
# -------------------------------------------------------------
def make_ghost_victoria():
    w, h = 88, 104
    ink = "#1f1729"
    rects = []
    
    # Regal ancestral violet-gold aura
    rects.append('<circle cx="44" cy="50" r="42" fill="rgba(192, 132, 252, 0.25)"/>')
    rects.append('<circle cx="44" cy="50" r="28" fill="rgba(251, 191, 36, 0.28)"/>')
    
    # High Victorian crown bun
    rects.append(f'<rect x="34" y="6" width="20" height="14" fill="{ink}"/>')
    rects.append('<rect x="36" y="8" width="16" height="10" fill="#e2e8f0"/>')
    # Ornate golden hairpin comb
    rects.append('<rect x="38" y="4" width="12" height="4" fill="#fbbf24"/>')
    rects.append('<rect x="42" y="2" width="4" height="2" fill="#ffffff"/>')
    
    # Head & Face
    rects.append(f'<rect x="30" y="20" width="28" height="24" fill="{ink}"/>')
    rects.append('<rect x="32" y="22" width="24" height="20" fill="#fdf4ff"/>')
    
    # Wise, compassionate grandmotherly eyes
    rects.append(f'<rect x="36" y="28" width="4" height="5" fill="{ink}"/>')
    rects.append(f'<rect x="48" y="28" width="4" height="5" fill="{ink}"/>')
    rects.append('<rect x="37" y="29" width="2" height="2" fill="#ffffff"/>')
    rects.append('<rect x="49" y="29" width="2" height="2" fill="#ffffff"/>')
    
    # Soft blush
    rects.append('<rect x="34" y="36" width="4" height="2" fill="#f472b6"/>')
    rects.append('<rect x="50" y="36" width="4" height="2" fill="#f472b6"/>')
    
    # Ornate Cameo Brooch with ruby heart
    rects.append(f'<rect x="40" y="44" width="8" height="7" fill="{ink}"/>')
    rects.append('<rect x="41" y="45" width="6" height="5" fill="#fbbf24"/>')
    rects.append('<rect x="43" y="46" width="2" height="3" fill="#e11d48"/>')
    
    # Victorian Gown with flowing lace shawl
    rects.append(f'<rect x="24" y="48" width="40" height="36" fill="{ink}"/>')
    rects.append('<rect x="26" y="50" width="36" height="32" fill="#f5d0fe"/>')
    rects.append('<rect x="34" y="50" width="20" height="32" fill="#fae8ff"/>')
    
    # Wavy lace embroidery hem
    for i in range(6):
        rects.append(f'<rect x="{26 + i*6}" y="{82 + (i%2)*2}" width="4" height="6" fill="{ink}"/>')
        rects.append(f'<rect x="{27 + i*6}" y="{83 + (i%2)*2}" width="2" height="4" fill="#ffffff"/>')
        
    return svg_wrap(w, h, "\n".join(rects))

# -------------------------------------------------------------
# 7. WW2 Patrol Soldier (Normal)
# -------------------------------------------------------------
def make_ww2_soldier(alerted=False):
    w, h = 140, 72
    p = 2
    ink = "#1a141f"
    rects = []
    
    # Flashlight beam
    beam_col = "rgba(239, 68, 68, 0.45)" if alerted else "rgba(254, 240, 138, 0.25)"
    beam_core = "rgba(248, 113, 113, 0.7)" if alerted else "rgba(255, 255, 255, 0.45)"
    rects.append(f'<polygon points="40,36 130,22 136,68" fill="{beam_col}"/>')
    rects.append(f'<line x1="40" y1="36" x2="133" y2="45" stroke="{beam_core}" stroke-width="2"/>')
    
    # Boots
    rects.append('<rect x="20" y="52" width="8" height="18" fill="#1e1b24"/>')
    rects.append('<rect x="32" y="52" width="8" height="18" fill="#1e1b24"/>')
    
    # Feldgrau Greatcoat
    rects.append(f'<rect x="18" y="24" width="26" height="30" fill="{ink}"/>')
    rects.append('<rect x="19" y="25" width="24" height="28" fill="#3d4742"/>')
    rects.append('<rect x="19" y="44" width="24" height="8" fill="#29302c"/>')
    
    # Ammo belt & buckle
    rects.append('<rect x="19" y="38" width="24" height="4" fill="#3d261a"/>')
    rects.append('<rect x="30" y="38" width="4" height="4" fill="#d97706"/>')
    
    # Face
    rects.append('<rect x="25" y="16" width="14" height="8" fill="#fbcfe8"/>')
    rects.append(f'<rect x="34" y="18" width="3" height="3" fill="{ink}"/>')
    
    # Stahlhelm Helmet
    rects.append(f'<rect x="20" y="8" width="24" height="10" fill="{ink}"/>')
    rects.append('<rect x="22" y="9" width="20" height="8" fill="#475569"/>')
    rects.append('<rect x="24" y="8" width="16" height="3" fill="#64748b"/>')
    # Helmet rim / neckguard
    rects.append('<rect x="18" y="14" width="28" height="3" fill="#334155"/>')
    
    # Hand & Flashlight
    rects.append('<rect x="32" y="32" width="6" height="10" fill="#3d4742"/>')
    rects.append('<rect x="36" y="34" width="8" height="6" fill="#1e1b24"/>')
    bulb_col = "#ef4444" if alerted else "#fef08a"
    rects.append(f'<rect x="42" y="33" width="4" height="8" fill="{bulb_col}"/>')
    
    # Panic alert box if alerted
    if alerted:
        rects.append(f'<rect x="26" y="0" width="12" height="14" fill="#dc2626" stroke="{ink}" stroke-width="1"/>')
        rects.append('<rect x="31" y="2" width="2" height="6" fill="#ffffff"/>')
        rects.append('<rect x="31" y="10" width="2" height="2" fill="#ffffff"/>')
        
    return svg_wrap(w, h, "\n".join(rects))

# -------------------------------------------------------------
# 8. Necklace Piece 1: Baza cu Lanț (Corin)
# -------------------------------------------------------------
def make_necklace_piece_1():
    w, h = 64, 64
    ink = "#1c1426"
    gold = "#fbbf24"
    gold_dark = "#d97706"
    rects = []
    
    # Golden glow
    rects.append('<circle cx="32" cy="36" r="26" fill="rgba(251, 191, 36, 0.25)"/>')
    
    # Draped chain links
    chain_pts = [(16, 14), (20, 20), (26, 26), (38, 26), (44, 20), (48, 14)]
    for cx, cy in chain_pts:
        rects.append(f'<rect x="{cx-2}" y="{cy-2}" width="6" height="6" fill="{ink}"/>')
        rects.append(f'<rect x="{cx-1}" y="{cy-1}" width="4" height="4" fill="{gold}"/>')
        rects.append(f'<rect x="{cx}" y="{cy}" width="2" height="2" fill="#ffffff"/>')
        
    # Center Bail Connector
    rects.append(f'<rect x="28" y="26" width="8" height="6" fill="{ink}"/>')
    rects.append(f'<rect x="30" y="27" width="4" height="4" fill="{gold_dark}"/>')
    
    # Filigree mounting base
    rects.append(f'<rect x="22" y="32" width="20" height="20" fill="{ink}"/>')
    rects.append(f'<rect x="24" y="34" width="16" height="16" fill="{gold}"/>')
    rects.append(f'<rect x="28" y="38" width="8" height="8" fill="{gold_dark}"/>')
    rects.append('<rect x="30" y="40" width="4" height="4" fill="#ffffff"/>')
    
    # Sparkles
    rects.append('<rect x="46" y="28" width="4" height="4" fill="#ffffff"/>')
    rects.append('<rect x="14" y="40" width="4" height="4" fill="#ffffff"/>')
    
    return svg_wrap(w, h, "\n".join(rects))

# -------------------------------------------------------------
# 9. Necklace Piece 2: Amuleta Mamei (Maria)
# -------------------------------------------------------------
def make_necklace_piece_2():
    w, h = 64, 64
    ink = "#1c1426"
    gold = "#fbbf24"
    cameo = "#34d399"
    rects = []
    
    # Emerald-gold glow
    rects.append('<circle cx="32" cy="36" r="26" fill="rgba(52, 211, 153, 0.28)"/>')
    
    # Chain links
    chain_pts = [(16, 14), (20, 20), (26, 26), (38, 26), (44, 20), (48, 14)]
    for cx, cy in chain_pts:
        rects.append(f'<rect x="{cx-2}" y="{cy-2}" width="6" height="6" fill="{ink}"/>')
        rects.append(f'<rect x="{cx-1}" y="{cy-1}" width="4" height="4" fill="{gold}"/>')
        
    # Bail
    rects.append(f'<rect x="28" y="26" width="8" height="6" fill="{ink}"/>')
    rects.append(f'<rect x="30" y="28" width="4" height="3" fill="{gold}"/>')
    
    # Golden Filigree Oval Cameo Frame
    rects.append(f'<rect x="20" y="32" width="24" height="26" fill="{ink}"/>')
    rects.append(f'<rect x="22" y="34" width="20" height="22" fill="{gold}"/>')
    
    # Inner Jade / Mother-of-Pearl Silhouette
    rects.append(f'<rect x="26" y="38" width="12" height="14" fill="{ink}"/>')
    rects.append(f'<rect x="27" y="39" width="10" height="12" fill="{cameo}"/>')
    rects.append('<rect x="30" y="42" width="4" height="4" fill="#ffffff"/>')
    
    return svg_wrap(w, h, "\n".join(rects))

# -------------------------------------------------------------
# 10. Necklace Piece 3: Medalionul cu Rubin (Elena)
# -------------------------------------------------------------
def make_necklace_piece_3():
    w, h = 64, 64
    ink = "#1c1426"
    gold = "#fbbf24"
    ruby = "#e11d48"
    ruby_dark = "#9f1239"
    rects = []
    
    # Ruby glow
    rects.append('<circle cx="32" cy="36" r="26" fill="rgba(225, 29, 72, 0.3)"/>')
    
    # Chain links
    chain_pts = [(16, 14), (20, 20), (26, 26), (38, 26), (44, 20), (48, 14)]
    for cx, cy in chain_pts:
        rects.append(f'<rect x="{cx-2}" y="{cy-2}" width="6" height="6" fill="{ink}"/>')
        rects.append(f'<rect x="{cx-1}" y="{cy-1}" width="4" height="4" fill="{gold}"/>')
        
    # Bail
    rects.append(f'<rect x="28" y="26" width="8" height="6" fill="{ink}"/>')
    rects.append(f'<rect x="30" y="28" width="4" height="3" fill="#b45309"/>')
    
    # Ornate setting
    rects.append(f'<rect x="18" y="32" width="28" height="28" fill="{ink}"/>')
    rects.append(f'<rect x="20" y="34" width="24" height="24" fill="{gold}"/>')
    
    # Faceted Ruby
    rects.append(f'<rect x="24" y="38" width="16" height="16" fill="{ink}"/>')
    rects.append(f'<rect x="25" y="39" width="14" height="14" fill="{ruby}"/>')
    rects.append(f'<rect x="25" y="46" width="14" height="7" fill="{ruby_dark}"/>')
    rects.append('<rect x="27" y="41" width="5" height="5" fill="#fecdd3"/>')
    
    return svg_wrap(w, h, "\n".join(rects))

# -------------------------------------------------------------
# 11. Complete Unified Ancestral Necklace
# -------------------------------------------------------------
def make_complete_necklace():
    w, h = 96, 96
    ink = "#1c1426"
    gold = "#fbbf24"
    ruby = "#e11d48"
    cameo = "#34d399"
    rects = []
    
    # Brilliant radiant golden halo
    rects.append('<circle cx="48" cy="52" r="42" fill="rgba(251, 191, 36, 0.3)"/>')
    rects.append('<circle cx="48" cy="52" r="28" fill="rgba(254, 240, 138, 0.5)"/>')
    
    # Draped multi-strand golden chain
    for offset_y, links in [(0, range(-5, 6)), (4, range(-4, 5))]:
        for i in links:
            cx = 48 + i * 7
            cy = 24 + abs(i) * 3 + offset_y
            rects.append(f'<rect x="{cx-2}" y="{cy-2}" width="5" height="5" fill="{ink}"/>')
            rects.append(f'<rect x="{cx-1}" y="{cy-1}" width="3" height="3" fill="{gold}"/>')
            
    # Central Cameo Casing (Mama)
    rects.append(f'<rect x="36" y="40" width="24" height="20" fill="{ink}"/>')
    rects.append(f'<rect x="38" y="42" width="20" height="16" fill="{gold}"/>')
    rects.append(f'<rect x="42" y="45" width="12" height="10" fill="{cameo}"/>')
    
    # Ornate Ruby Medallion Hanging Below (Elena)
    rects.append(f'<rect x="38" y="58" width="20" height="24" fill="{ink}"/>')
    rects.append(f'<rect x="40" y="60" width="16" height="20" fill="{gold}"/>')
    rects.append(f'<rect x="42" y="64" width="12" height="14" fill="{ruby}"/>')
    rects.append('<rect x="44" y="66" width="4" height="4" fill="#ffffff"/>')
    
    # Starlight glints
    glints = [(22, 38), (74, 38), (48, 16), (28, 70), (68, 70)]
    for gx, gy in glints:
        rects.append(f'<rect x="{gx-2}" y="{gy-2}" width="5" height="5" fill="#ffffff"/>')
        rects.append(f'<rect x="{gx-1}" y="{gy-1}" width="3" height="3" fill="{gold}"/>')
        
    return svg_wrap(w, h, "\n".join(rects))

# -------------------------------------------------------------
# 12. Brass Key (Cheia de Alamă)
# -------------------------------------------------------------
def make_brass_key():
    w, h = 64, 64
    ink = "#1c1426"
    gold = "#fbbf24"
    bright = "#fef08a"
    rects = []
    
    # Sparkle halo
    rects.append('<circle cx="32" cy="32" r="24" fill="rgba(251, 191, 36, 0.28)"/>')
    
    # Key Bow (Top loop)
    rects.append(f'<rect x="22" y="10" width="20" height="16" fill="{ink}"/>')
    rects.append(f'<rect x="24" y="12" width="16" height="12" fill="{gold}"/>')
    rects.append(f'<rect x="28" y="15" width="8" height="6" fill="{ink}"/>')
    rects.append('<rect x="29" y="16" width="6" height="4" fill="#2d1f3d"/>')
    rects.append(f'<rect x="25" y="13" width="3" height="2" fill="{bright}"/>')
    
    # Stem
    rects.append(f'<rect x="29" y="26" width="6" height="26" fill="{ink}"/>')
    rects.append(f'<rect x="30" y="26" width="4" height="25" fill="{gold}"/>')
    rects.append(f'<rect x="31" y="26" width="2" height="24" fill="{bright}"/>')
    
    # Bits / Teeth
    rects.append(f'<rect x="35" y="38" width="9" height="5" fill="{ink}"/>')
    rects.append(f'<rect x="35" y="39" width="8" height="3" fill="{gold}"/>')
    rects.append(f'<rect x="35" y="46" width="12" height="6" fill="{ink}"/>')
    rects.append(f'<rect x="35" y="47" width="11" height="4" fill="{gold}"/>')
    
    # Floating star glints
    for sx, sy in [(14, 20), (50, 16), (16, 44), (48, 52)]:
        rects.append(f'<rect x="{sx}" y="{sy}" width="4" height="4" fill="#ffffff"/>')
        rects.append(f'<rect x="{sx+1}" y="{sy+1}" width="2" height="2" fill="{gold}"/>')
        
    return svg_wrap(w, h, "\n".join(rects))

# -------------------------------------------------------------
# 13. Other Relics (Pocket Watch, Flame, Canary, Portal)
# -------------------------------------------------------------
def make_pocket_watch():
    w, h = 64, 64
    ink = "#1c1426"
    gold = "#fbbf24"
    rects = []
    rects.append('<circle cx="32" cy="34" r="24" fill="rgba(251, 191, 36, 0.25)"/>')
    rects.append(f'<rect x="28" y="4" width="8" height="6" fill="{ink}"/>')
    rects.append(f'<rect x="30" y="5" width="4" height="4" fill="{gold}"/>')
    rects.append(f'<rect x="18" y="18" width="28" height="28" fill="{ink}"/>')
    rects.append(f'<rect x="20" y="20" width="24" height="24" fill="{gold}"/>')
    rects.append('<rect x="24" y="24" width="16" height="16" fill="#fef9c3"/>')
    # Hands
    rects.append(f'<rect x="31" y="26" width="2" height="7" fill="{ink}"/>')
    rects.append(f'<rect x="31" y="32" width="6" height="2" fill="{ink}"/>')
    return svg_wrap(w, h, "\n".join(rects))

def make_lighthouse_flame():
    w, h = 64, 64
    ink = "#1c1426"
    rects = []
    rects.append('<circle cx="32" cy="32" r="26" fill="rgba(249, 115, 22, 0.3)"/>')
    rects.append(f'<rect x="24" y="16" width="16" height="34" fill="{ink}"/>')
    rects.append('<rect x="26" y="18" width="12" height="30" fill="#f97316"/>')
    rects.append('<rect x="29" y="24" width="6" height="20" fill="#facc15"/>')
    rects.append('<rect x="31" y="28" width="2" height="12" fill="#ffffff"/>')
    return svg_wrap(w, h, "\n".join(rects))

def make_golden_canary():
    w, h = 64, 64
    ink = "#1c1426"
    gold = "#fbbf24"
    rects = []
    rects.append('<circle cx="32" cy="32" r="24" fill="rgba(251, 191, 36, 0.28)"/>')
    rects.append(f'<rect x="20" y="26" width="20" height="16" fill="{ink}"/>')
    rects.append(f'<rect x="22" y="28" width="16" height="12" fill="{gold}"/>')
    rects.append(f'<rect x="36" y="20" width="12" height="12" fill="{ink}"/>')
    rects.append(f'<rect x="38" y="22" width="8" height="8" fill="{gold}"/>')
    rects.append('<rect x="46" y="24" width="5" height="4" fill="#ea580c"/>') # Beak
    rects.append(f'<rect x="41" y="23" width="2" height="2" fill="{ink}"/>') # Eye
    rects.append(f'<rect x="24" y="25" width="12" height="6" fill="#d97706"/>') # Wing
    return svg_wrap(w, h, "\n".join(rects))

# -------------------------------------------------------------
# 14. Ancestral Altar (Altarul Originii)
# -------------------------------------------------------------
def make_ancestral_altar():
    w, h = 180, 90
    ink = "#1c1426"
    stone = "#474354"
    stone_dark = "#2b2836"
    gold = "#fbbf24"
    rects = []
    
    # Base altar slab
    rects.append(f'<rect x="10" y="45" width="160" height="40" fill="{ink}"/>')
    rects.append(f'<rect x="12" y="47" width="156" height="36" fill="{stone_dark}"/>')
    rects.append(f'<rect x="16" y="50" width="148" height="30" fill="{stone}"/>')
    rects.append(f'<rect x="18" y="50" width="144" height="4" fill="#6d687d"/>')
    
    # Glowing Runic Engravings
    for rx in [35, 75, 115, 145]:
        rects.append(f'<rect x="{rx}" y="62" width="6" height="12" fill="{gold}"/>')
        rects.append(f'<rect x="{rx-3}" y="66" width="12" height="3" fill="{gold}"/>')
        
    # 3 Pedestal Sockets on top
    sockets = [(35, "#fbbf24"), (90, "#34d399"), (145, "#e11d48")]
    for sx, col in sockets:
        rects.append(f'<rect x="{sx-14}" y="36" width="28" height="12" fill="{ink}"/>')
        rects.append(f'<rect x="{sx-12}" y="38" width="24" height="8" fill="{stone}"/>')
        rects.append(f'<circle cx="{sx}" cy="30" r="14" fill="{col}" opacity="0.3"/>')
        rects.append(f'<rect x="{sx-8}" y="24" width="16" height="12" fill="{col}"/>')
        rects.append(f'<rect x="{sx-2}" y="26" width="4" height="4" fill="#ffffff"/>')
        
    return svg_wrap(w, h, "\n".join(rects))

# -------------------------------------------------------------
# 15. Platforms (Brass, Wood, Steel, Crystal, Cloud)
# -------------------------------------------------------------
def make_platform_brass():
    w, h = 160, 32
    ink = "#1c1426"
    gold = "#b48b36"
    rects = []
    rects.append(f'<rect x="0" y="0" width="{w}" height="{h}" fill="{ink}"/>')
    rects.append(f'<rect x="2" y="2" width="{w-4}" height="{h-4}" fill="{gold}"/>')
    rects.append(f'<rect x="2" y="2" width="{w-4}" height="4" fill="#fef08a"/>')
    rects.append(f'<rect x="2" y="{h-6}" width="{w-4}" height="4" fill="#785317"/>')
    for x in range(32, w - 10, 32):
        rects.append(f'<rect x="{x}" y="4" width="2" height="{h-8}" fill="{ink}"/>')
        rects.append(f'<rect x="{x+2}" y="4" width="2" height="{h-8}" fill="#fde047"/>')
        # Diamond rivets
        rects.append(f'<rect x="{x-8}" y="8" width="4" height="4" fill="{ink}"/>')
        rects.append(f'<rect x="{x-7}" y="9" width="2" height="2" fill="#fde047"/>')
    return svg_wrap(w, h, "\n".join(rects))

def make_platform_steel():
    w, h = 160, 32
    ink = "#1c1426"
    steel = "#3d424b"
    rects = []
    rects.append(f'<rect x="0" y="0" width="{w}" height="{h}" fill="{ink}"/>')
    rects.append(f'<rect x="2" y="2" width="{w-4}" height="{h-4}" fill="{steel}"/>')
    rects.append(f'<rect x="2" y="2" width="{w-4}" height="4" fill="#7c8594"/>')
    rects.append(f'<rect x="2" y="{h-6}" width="{w-4}" height="4" fill="#1e2126"/>')
    for x in range(32, w - 10, 32):
        rects.append(f'<rect x="{x}" y="4" width="2" height="{h-8}" fill="{ink}"/>')
        rects.append(f'<rect x="{x+2}" y="4" width="2" height="{h-8}" fill="#94a3b8"/>')
        # Dual rivets
        rects.append(f'<rect x="{x-6}" y="6" width="4" height="4" fill="{ink}"/>')
        rects.append(f'<rect x="{x-6}" y="{h-10}" width="4" height="4" fill="{ink}"/>')
    return svg_wrap(w, h, "\n".join(rects))

def make_platform_wood():
    w, h = 160, 32
    ink = "#1c1426"
    wood = "#3b5266"
    rects = []
    rects.append(f'<rect x="0" y="0" width="{w}" height="{h}" fill="{ink}"/>')
    rects.append(f'<rect x="2" y="2" width="{w-4}" height="{h-4}" fill="{wood}"/>')
    rects.append(f'<rect x="2" y="2" width="{w-4}" height="4" fill="#7099b8"/>')
    rects.append(f'<rect x="2" y="{h-6}" width="{w-4}" height="4" fill="#202e3b"/>')
    for x in range(24, w - 10, 24):
        rects.append(f'<rect x="{x}" y="4" width="2" height="{h-8}" fill="{ink}"/>')
        rects.append(f'<rect x="{x-5}" y="8" width="3" height="3" fill="{ink}"/>') # Nail
    return svg_wrap(w, h, "\n".join(rects))

def make_platform_crystal():
    w, h = 160, 32
    ink = "#1c1426"
    slate = "#422e4d"
    rects = []
    rects.append(f'<rect x="0" y="0" width="{w}" height="{h}" fill="{ink}"/>')
    rects.append(f'<rect x="2" y="2" width="{w-4}" height="{h-4}" fill="{slate}"/>')
    rects.append(f'<rect x="2" y="2" width="{w-4}" height="4" fill="#84579e"/>')
    # Glowing embedded crystals
    for gx in [30, 80, 130]:
        rects.append(f'<rect x="{gx}" y="10" width="8" height="8" fill="#38bdf8"/>')
        rects.append(f'<rect x="{gx+2}" y="12" width="4" height="4" fill="#ffffff"/>')
    return svg_wrap(w, h, "\n".join(rects))

def make_platform_cloud():
    w, h = 160, 32
    ink = "#1c1426"
    cloud = "#e0e7ff"
    rects = []
    rects.append(f'<rect x="0" y="0" width="{w}" height="{h}" fill="{ink}"/>')
    rects.append(f'<rect x="2" y="2" width="{w-4}" height="{h-4}" fill="{cloud}"/>')
    rects.append(f'<rect x="2" y="2" width="{w-4}" height="6" fill="#ffffff"/>')
    rects.append(f'<rect x="2" y="{h-8}" width="{w-4}" height="6" fill="#c7d2fe"/>')
    return svg_wrap(w, h, "\n".join(rects))

# -------------------------------------------------------------
# 16. Interactive Furniture (Desk, Grandfather Clock, Wardrobe, Dresser)
# -------------------------------------------------------------
def make_furniture_desk():
    w, h = 96, 64
    ink = "#1c1426"
    wood = "#78350f"
    wood_light = "#a16207"
    rects = []
    # Desktop
    rects.append(f'<rect x="4" y="10" width="88" height="12" fill="{ink}"/>')
    rects.append(f'<rect x="6" y="12" width="84" height="8" fill="{wood_light}"/>')
    # Legs
    rects.append(f'<rect x="10" y="22" width="10" height="40" fill="{ink}"/>')
    rects.append(f'<rect x="12" y="22" width="6" height="40" fill="{wood}"/>')
    rects.append(f'<rect x="76" y="22" width="10" height="40" fill="{ink}"/>')
    rects.append(f'<rect x="78" y="22" width="6" height="40" fill="{wood}"/>')
    # Center drawer
    rects.append(f'<rect x="26" y="22" width="44" height="20" fill="{ink}"/>')
    rects.append(f'<rect x="28" y="24" width="40" height="16" fill="{wood}"/>')
    rects.append('<rect x="44" y="30" width="8" height="4" fill="#fbbf24"/>') # Brass handle
    return svg_wrap(w, h, "\n".join(rects))

def make_furniture_clock():
    w, h = 64, 110
    ink = "#1c1426"
    wood = "#581c87"
    gold = "#fbbf24"
    rects = []
    # Base cabinet
    rects.append(f'<rect x="8" y="30" width="48" height="76" fill="{ink}"/>')
    rects.append(f'<rect x="10" y="32" width="44" height="72" fill="#3b0764"/>')
    # Glass window
    rects.append(f'<rect x="18" y="40" width="28" height="50" fill="{ink}"/>')
    rects.append(f'<rect x="20" y="42" width="24" height="46" fill="#1e1b4b"/>')
    # Pendulum
    rects.append(f'<rect x="31" y="42" width="2" height="34" fill="{gold}"/>')
    rects.append(f'<circle cx="32" cy="76" r="6" fill="{gold}"/>')
    rects.append('<circle cx="32" cy="76" r="3" fill="#ffffff"/>')
    # Clock hood & dial
    rects.append(f'<rect x="12" y="4" width="40" height="28" fill="{ink}"/>')
    rects.append(f'<rect x="14" y="6" width="36" height="24" fill="{gold}"/>')
    rects.append('<circle cx="32" cy="18" r="9" fill="#fef9c3"/>')
    rects.append(f'<line x1="32" y1="18" x2="32" y2="12" stroke="{ink}" stroke-width="1.5"/>')
    rects.append(f'<line x1="32" y1="18" x2="36" y2="18" stroke="{ink}" stroke-width="1.5"/>')
    return svg_wrap(w, h, "\n".join(rects))

def make_furniture_wardrobe():
    w, h = 88, 100
    ink = "#1c1426"
    wood = "#451a03"
    gold = "#fbbf24"
    rects = []
    rects.append(f'<rect x="6" y="6" width="76" height="90" fill="{ink}"/>')
    rects.append(f'<rect x="8" y="8" width="72" height="86" fill="{wood}"/>')
    # Two carved doors
    rects.append(f'<rect x="12" y="14" width="30" height="74" fill="{ink}"/>')
    rects.append('<rect x="14" y="16" width="26" height="70" fill="#78350f"/>')
    rects.append(f'<rect x="46" y="14" width="30" height="74" fill="{ink}"/>')
    rects.append('<rect x="48" y="16" width="26" height="70" fill="#78350f"/>')
    # Brass latch & keyhole
    rects.append(f'<rect x="38" y="48" width="12" height="8" fill="{gold}"/>')
    rects.append(f'<rect x="43" y="50" width="2" height="4" fill="{ink}"/>')
    return svg_wrap(w, h, "\n".join(rects))

# -------------------------------------------------------------
# 17. UI & Game Icon
# -------------------------------------------------------------
def make_pause_icon():
    w, h = 32, 32
    rects = [
        '<rect x="8" y="6" width="5" height="20" fill="#ffffff" stroke="#1c1426" stroke-width="1"/>',
        '<rect x="19" y="6" width="5" height="20" fill="#ffffff" stroke="#1c1426" stroke-width="1"/>'
    ]
    return svg_wrap(w, h, "\n".join(rects))

def make_game_icon():
    w, h = 128, 128
    rects = [
        '<rect width="128" height="128" rx="20" fill="#181224"/>',
        '<circle cx="64" cy="64" r="50" fill="rgba(251, 191, 36, 0.2)"/>',
        # Golden halo
        '<rect x="44" y="24" width="40" height="10" fill="#fbbf24" stroke="#181224" stroke-width="2"/>',
        '<rect x="52" y="26" width="24" height="4" fill="#ffffff"/>',
        # Corin body
        '<rect x="40" y="40" width="48" height="52" rx="4" fill="#faf5ea" stroke="#181224" stroke-width="3"/>',
        # Eyes
        '<rect x="48" y="54" width="8" height="12" fill="#181224"/>',
        '<rect x="50" y="56" width="3" height="4" fill="#ffffff"/>',
        '<rect x="72" y="54" width="8" height="12" fill="#181224"/>',
        '<rect x="74" y="56" width="3" height="4" fill="#ffffff"/>',
        # Blush
        '<rect x="44" y="68" width="6" height="3" fill="#f87171"/>',
        '<rect x="78" y="68" width="6" height="3" fill="#f87171"/>',
        # Wavy hem
        '<polygon points="40,92 46,98 52,92 58,98 64,92 70,98 76,92 82,98 88,92 88,88 40,88" fill="#181224"/>'
    ]
    return svg_wrap(w, h, "\n".join(rects))

def main():
    sprites = {
        "corin_ghost_normal.svg": make_corin_normal(),
        "corin_ghost_phased.svg": make_corin_phased(),
        "corin_ascended.svg": make_corin_ascended(),
        "ghost_mother_maria.svg": make_ghost_mother(),
        "ghost_grandmother_elena.svg": make_ghost_grandmother(),
        "ghost_matriarch_victoria.svg": make_ghost_victoria(),
        "ww2_patrol_soldier.svg": make_ww2_soldier(False),
        "ww2_soldier_alert.svg": make_ww2_soldier(True),
        "necklace_piece_1_chain.svg": make_necklace_piece_1(),
        "necklace_piece_2_cameo.svg": make_necklace_piece_2(),
        "necklace_piece_3_ruby.svg": make_necklace_piece_3(),
        "necklace_complete_unified.svg": make_complete_necklace(),
        "brass_key.svg": make_brass_key(),
        "relic_pocket_watch.svg": make_pocket_watch(),
        "relic_lighthouse_flame.svg": make_lighthouse_flame(),
        "relic_golden_canary.svg": make_golden_canary(),
        "ancestral_altar.svg": make_ancestral_altar(),
        "platform_brass_clockwork.svg": make_platform_brass(),
        "platform_military_steel.svg": make_platform_steel(),
        "platform_wooden_dock.svg": make_platform_wood(),
        "platform_crystal_cave.svg": make_platform_crystal(),
        "platform_celestial_cloud.svg": make_platform_cloud(),
        "furniture_watchmaker_desk.svg": make_furniture_desk(),
        "furniture_grandfather_clock.svg": make_furniture_clock(),
        "furniture_attic_wardrobe.svg": make_furniture_wardrobe(),
        "icon_pause.svg": make_pause_icon(),
        "game_icon.svg": make_game_icon()
    }
    
    for filename, content in sprites.items():
        save_svg(filename, content)
        
    print(f"\nAll {len(sprites)} SVGs exported successfully!")

if __name__ == "__main__":
    main()
