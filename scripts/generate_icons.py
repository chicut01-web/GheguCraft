#!/usr/bin/env python3
import os
import subprocess
import tempfile

ICONS_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "assets", "app-icons"))
os.makedirs(ICONS_DIR, exist_ok=True)

APPS = [
    {
        "id": "photocraft",
        "bg0": "#001e36", "bg1": "#000e1c",
        "stroke": "#31a8ff", "text_color": "#31a8ff",
        "text": "Ps", "font_size": 64,
        "badge": "PHOTOSHOP",
    },
    {
        "id": "vectorcraft",
        "bg0": "#330000", "bg1": "#180000",
        "stroke": "#ff9a00", "text_color": "#ff9a00",
        "text": "Ai", "font_size": 64,
        "badge": "ILLUSTRATOR",
    },
    {
        "id": "filmcraft",
        "bg0": "#1f0033", "bg1": "#0c0017",
        "stroke": "#ea77ff", "text_color": "#ea77ff",
        "text": "Pr", "font_size": 64,
        "badge": "PREMIERE",
    },
    {
        "id": "lightcraft",
        "bg0": "#001a2e", "bg1": "#000b14",
        "stroke": "#38bdf8", "text_color": "#38bdf8",
        "text": "Lr", "font_size": 64,
        "badge": "LIGHTROOM",
    },
    {
        "id": "pdfcraft",
        "bg0": "#2b0004", "bg1": "#120002",
        "stroke": "#ff3b30", "text_color": "#ff3b30",
        "text": "Ac", "font_size": 64,
        "badge": "ACROBAT",
    },
    {
        "id": "effectcraft",
        "bg0": "#1b0026", "bg1": "#0a0010",
        "stroke": "#d166ff", "text_color": "#d166ff",
        "text": "Ae", "font_size": 64,
        "badge": "AFTER EFFECTS",
    },
    {
        "id": "designcraft",
        "bg0": "#290014", "bg1": "#100008",
        "stroke": "#ff3366", "text_color": "#ff3366",
        "text": "Id", "font_size": 64,
        "badge": "INDESIGN",
    },
    {
        "id": "wordcraft",
        "bg0": "#002050", "bg1": "#00102b",
        "stroke": "#2b7cd3", "text_color": "#ffffff",
        "text": "W", "font_size": 70,
        "badge": "WORD",
    },
    {
        "id": "deckcraft",
        "bg0": "#401500", "bg1": "#1c0700",
        "stroke": "#d83b01", "text_color": "#ffffff",
        "text": "P", "font_size": 70,
        "badge": "POWERPOINT",
    },
    {
        "id": "gridcraft",
        "bg0": "#002b12", "bg1": "#001205",
        "stroke": "#107c41", "text_color": "#ffffff",
        "text": "X", "font_size": 70,
        "badge": "EXCEL",
    },
    {
        "id": "cadcraft",
        "bg0": "#1a1a22", "bg1": "#0d0d12",
        "stroke": "#e5252a", "text_color": "#ffffff",
        "text": "CAD", "font_size": 48,
        "badge": "AUTOCAD",
    },
    {
        "id": "soundcraft",
        "bg0": "#001e38", "bg1": "#000d1a",
        "stroke": "#00b4d8", "text_color": "#00b4d8",
        "text": "Au", "font_size": 64,
        "badge": "AUDACITY",
    },
]

def generate_app_svg(app):
    return f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" width="128" height="128">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="{app['bg0']}"/>
      <stop offset="100%" stop-color="{app['bg1']}"/>
    </linearGradient>
    <filter id="glow" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="0" dy="2" stdDeviation="4" flood-color="{app['stroke']}" flood-opacity="0.35"/>
    </filter>
  </defs>
  <!-- Card background -->
  <rect x="5" y="5" width="118" height="118" rx="26" fill="url(#bg)" stroke="{app['stroke']}" stroke-width="3.5" filter="url(#glow)"/>
  <rect x="9" y="9" width="110" height="110" rx="22" fill="none" stroke="{app['stroke']}" stroke-width="1" stroke-opacity="0.25"/>
  
  <!-- Subtle top badge label -->
  <text x="64" y="24" font-family="-apple-system, BlinkMacSystemFont, 'Inter', 'SF Pro Text', sans-serif" font-size="9" font-weight="700" fill="{app['stroke']}" text-anchor="middle" letter-spacing="1.2" opacity="0.85">{app['badge']}</text>

  <!-- Main center monogram -->
  <text x="64" y="{82 if app['font_size'] >= 60 else 76}" font-family="-apple-system, BlinkMacSystemFont, 'Inter', 'SF Pro Display', 'Arial Black', sans-serif" font-size="{app['font_size']}" font-weight="900" fill="{app['text_color']}" text-anchor="middle" letter-spacing="-1">{app['text']}</text>
  
  <!-- Bottom accent line -->
  <line x1="36" y1="106" x2="92" y2="106" stroke="{app['stroke']}" stroke-width="2.5" stroke-linecap="round" opacity="0.6"/>
</svg>"""

def generate_figma_svg():
    return """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128" width="128" height="128">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#0f172a"/>
      <stop offset="100%" stop-color="#020617"/>
    </linearGradient>
    <filter id="glow" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="0" dy="2" stdDeviation="4" flood-color="#a259ff" flood-opacity="0.35"/>
    </filter>
  </defs>
  <!-- Card background -->
  <rect x="5" y="5" width="118" height="118" rx="26" fill="url(#bg)" stroke="#a259ff" stroke-width="3.5" filter="url(#glow)"/>
  <rect x="9" y="9" width="110" height="110" rx="22" fill="none" stroke="#a259ff" stroke-width="1" stroke-opacity="0.25"/>
  
  <!-- Subtle top badge label -->
  <text x="64" y="24" font-family="-apple-system, BlinkMacSystemFont, 'Inter', 'SF Pro Text', sans-serif" font-size="9" font-weight="700" fill="#a259ff" text-anchor="middle" letter-spacing="1.2" opacity="0.85">FIGMA</text>

  <!-- Figma 5 shapes -->
  <g transform="translate(42, 34) scale(0.9)">
    <!-- top left: orange -->
    <rect x="0" y="0" width="24" height="24" rx="12" fill="#f24e1e"/>
    <!-- top right: violet -->
    <rect x="24" y="0" width="24" height="24" rx="12" fill="#ff7262"/>
    <!-- mid left: purple -->
    <rect x="0" y="24" width="24" height="24" rx="12" fill="#a259ff"/>
    <!-- mid right (circle): cyan -->
    <circle cx="36" cy="36" r="12" fill="#1abcfe"/>
    <!-- bottom left: green -->
    <rect x="0" y="48" width="24" height="24" rx="12" fill="#0acf83"/>
  </g>
  
  <!-- Bottom accent line -->
  <line x1="36" y1="106" x2="92" y2="106" stroke="#1abcfe" stroke-width="2.5" stroke-linecap="round" opacity="0.6"/>
</svg>"""

with tempfile.TemporaryDirectory() as tmpdir:
    for app in APPS:
        svg_content = generate_app_svg(app)
        svg_path = os.path.join(tmpdir, f"{app['id']}.svg")
        with open(svg_path, "w") as f:
            f.write(svg_content)
        subprocess.run(["qlmanage", "-t", "-s", "128", "-o", tmpdir, svg_path], check=True, capture_output=True)
        rendered_png = os.path.join(tmpdir, f"{app['id']}.svg.png")
        dest_png = os.path.join(ICONS_DIR, f"{app['id']}.png")
        subprocess.run(["sips", "-z", "128", "128", rendered_png, "--out", dest_png], check=True, capture_output=True)
        print(f"Generated {app['id']}.png")

    # Figma
    figma_svg = generate_figma_svg()
    svg_path = os.path.join(tmpdir, "figcraft.svg")
    with open(svg_path, "w") as f:
        f.write(figma_svg)
    subprocess.run(["qlmanage", "-t", "-s", "128", "-o", tmpdir, svg_path], check=True, capture_output=True)
    rendered_png = os.path.join(tmpdir, "figcraft.svg.png")
    dest_png = os.path.join(ICONS_DIR, "figcraft.png")
    subprocess.run(["sips", "-z", "128", "128", rendered_png, "--out", dest_png], check=True, capture_output=True)
    print("Generated figcraft.png")

print("All 13 icons generated successfully in", ICONS_DIR)
