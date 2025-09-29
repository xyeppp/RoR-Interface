from pathlib import Path

ROOT = Path("docs/interface/latest")
ROOT.mkdir(parents=True, exist_ok=True)

def section_header(title):
    return f"\n## {title}\n"

lines = [
    "# Interface Browser (Latest)\n",
    "Auto-generated from the repository's `interface/` folder on branch **codex**.\n"
]

# Images (converted DDS -> PNG)
images = sorted(ROOT.glob("images/**/*.png"))
if images:
    lines.append(section_header("Textures (converted from DDS)"))
    # Limit previews to keep page light; link the rest
    for img in images[:400]:
        rel = img.relative_to(ROOT).as_posix()
        lines.append(f"![{rel}]({rel})\n")
    if len(images) > 400:
        lines.append(f"\n_+{len(images)-400} more images not inlined; browse the folders above._\n")

def embed_code(label, pattern, fence):
    files = sorted(ROOT.glob(pattern))
    if not files:
        return
    lines.append(section_header(label))
    for f in files[:200]:
        rel = f.relative_to(ROOT).as_posix()
        try:
            text = f.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            text = ""
        if len(text) > 8000:
            text = text[:8000] + "\n... (truncated) ..."
        lines.append(f"### {rel}\n```{fence}\n{text}\n```\n")
    if len(files) > 200:
        lines.append(f"_+{len(files)-200} more files; browse the folders above._\n")

embed_code("Lua", "lua/**/*.lua", "lua")
embed_code("XML", "xml/**/*.xml", "xml")

# CSV (link list + one inline preview)
csvs = sorted(ROOT.glob("csv/**/*.csv"))
if csvs:
    lines.append(section_header("CSV"))
    for f in csvs:
        rel = f.relative_to(ROOT).as_posix()
        lines.append(f"- [{rel}]({rel})\n")
    first = csvs[0].relative_to(ROOT).as_posix()
    lines.append("\n### Inline preview (first CSV)\n")
    lines.append(f"{{{{ read_csv('interface/latest/{first}') }}}}\n")

(Path(ROOT) / "index.md").write_text("".join(lines), encoding="utf-8")
print("Wrote docs/interface/latest/index.md")
