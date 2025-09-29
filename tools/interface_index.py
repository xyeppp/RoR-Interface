from __future__ import annotations

import shutil
from pathlib import Path
from typing import Dict, List

try:  # pragma: no cover - optional dependency
    from PIL import Image
    import pillow_dds  # noqa: F401  # pylint: disable=unused-import
except Exception:  # pragma: no cover - optional dependency
    Image = None  # type: ignore

CODE_EXTENSIONS = {".lua": "lua", ".xml": "xml"}


def _project_dir(config: Dict) -> Path:
    config_path = config.get("config_file_path")
    if config_path:
        return Path(config_path).resolve().parent
    return Path.cwd()


def _docs_dir(project_dir: Path, config: Dict) -> Path:
    docs_dir = Path(config.get("docs_dir", "docs"))
    if not docs_dir.is_absolute():
        docs_dir = project_dir / docs_dir
    return docs_dir.resolve()


def _load_settings(config: Dict) -> Dict:
    extra = config.get("extra") or {}
    return extra.get("interface_index", {})


def _ensure_gitignore(target: Path) -> None:
    gitignore = target / ".gitignore"
    gitignore.write_text("*\n!/.gitignore\n", encoding="utf-8")


def _truncate_text(content: str, limit: int) -> str:
    if limit <= 0:
        return content
    encoded = content.encode("utf-8", errors="ignore")
    if len(encoded) <= limit:
        return content
    truncated = encoded[:limit]
    safe = truncated.decode("utf-8", errors="ignore")
    return safe + "\n... (truncated for preview) ..."


def _code_page_content(rel_path: str, language: str, truncated_source: str) -> str:
    lines = [
        f"# {rel_path}\n",
        "\n",
        f"*Source path*: `interface/{rel_path}`\n",
        "\n",
        "[Download original](source." + language + ")\n",
        "\n",
        f"```{language}\n",
        truncated_source,
        "\n```\n",
    ]
    return "".join(lines)


def _csv_page_content(rel_path: str, csv_rel_path: str) -> str:
    lines = [
        f"# {rel_path}\n",
        "\n",
        f"*Source path*: `interface/{rel_path}`\n",
        "\n",
        "[Download CSV](data.csv)\n",
        "\n",
        f"{{{{ read_csv('{csv_rel_path}') }}}}\n",
    ]
    return "".join(lines)


def _build_index(entries: Dict[str, List[Dict]], settings: Dict, image_conversion: bool) -> str:
    max_code_entries = int(settings.get("max_code_entries", 200))
    max_image_entries = int(settings.get("max_image_entries", 300))

    lines: List[str] = [
        "# Interface Browser (Latest)\n",
        "\n",
        "This page is generated from the repository's `interface/` folder during the MkDocs build.\n",
        "Use the links below to browse the available previews.\n",
    ]

    for label, key in (("Lua scripts", "lua"), ("XML layouts", "xml")):
        if entries[key]:
            lines.append(f"\n## {label}\n\n")
            limit = max_code_entries
            for item in entries[key][:limit]:
                lines.append(f"- [{item['title']}]({item['link']})\n")
            remaining = len(entries[key]) - limit
            if remaining > 0:
                lines.append(
                    f"\n_+{remaining} additional files not listed here. Browse the folders for more._\n"
                )

    if entries["csv"]:
        lines.append("\n## CSV tables\n\n")
        for item in entries["csv"]:
            lines.append(f"- [{item['title']}]({item['link']})\n")

    if not image_conversion:
        lines.append(
            "\n!!! warning \"DDS previews unavailable\"\n"
            "    pillow-dds is not installed, so DDS textures are not converted during the build.\n"
        )
    elif entries["images"]:
        lines.append("\n## Textures (DDS → PNG)\n\n")
        limit = max_image_entries
        for item in entries["images"][:limit]:
            lines.append(f"![{item['title']}]({item['link']})\n")
        remaining = len(entries["images"]) - limit
        if remaining > 0:
            lines.append(
                f"\n_+{remaining} additional textures converted. Browse the image folders for the rest._\n"
            )

    return "".join(lines)


def generate_docs(config: Dict) -> None:
    """Hook entry point for mkdocs-simple-hooks."""

    settings = _load_settings(config)
    project_dir = _project_dir(config)
    docs_dir = _docs_dir(project_dir, config)

    interface_dir = project_dir / settings.get("interface_dir", "interface")
    output_subdir = settings.get("output_subdir", "interface/latest")
    output_dir = docs_dir / output_subdir

    output_dir.mkdir(parents=True, exist_ok=True)

    # Clean previously generated content but preserve .gitignore if present
    for path in output_dir.iterdir():
        if path.name == ".gitignore":
            continue
        if path.is_dir():
            shutil.rmtree(path)
        else:
            path.unlink()

    entries: Dict[str, List[Dict]] = {"lua": [], "xml": [], "csv": [], "images": []}

    truncate_bytes = int(settings.get("truncate_bytes", 8000))
    image_conversion_enabled = Image is not None

    if not interface_dir.exists():
        index_path = output_dir / "index.md"
        index_path.write_text(
            "# Interface Browser (Latest)\n\nNo interface assets were found in this repository.\n",
            encoding="utf-8",
        )
        _ensure_gitignore(output_dir)
        return

    for source_path in sorted(interface_dir.rglob("*")):
        if not source_path.is_file():
            continue
        suffix = source_path.suffix.lower()
        rel = source_path.relative_to(interface_dir)
        rel_str = rel.as_posix()

        if suffix in CODE_EXTENSIONS:
            language = CODE_EXTENSIONS[suffix]
            page_dir = output_dir / language / rel.parent / source_path.stem
            page_dir.mkdir(parents=True, exist_ok=True)

            destination_source = page_dir / f"source.{language}"
            destination_source.write_bytes(source_path.read_bytes())

            text_content = source_path.read_text(encoding="utf-8", errors="ignore")
            preview = _truncate_text(text_content, truncate_bytes)
            page_md = _code_page_content(rel_str, language, preview)
            (page_dir / "index.md").write_text(page_md, encoding="utf-8")

            parent_rel = rel.parent.as_posix()
            link_parts = [language]
            if parent_rel and parent_rel != ".":
                link_parts.append(parent_rel)
            link_parts.append(source_path.stem)
            link = "/".join(part.strip("/") for part in link_parts if part)
            entries[language].append({"title": rel_str, "link": f"{link}/"})

        elif suffix == ".csv":
            page_dir = output_dir / "csv" / rel.parent / source_path.stem
            page_dir.mkdir(parents=True, exist_ok=True)

            data_file = page_dir / "data.csv"
            data_file.write_bytes(source_path.read_bytes())

            csv_rel_path = data_file.relative_to(docs_dir).as_posix()
            page_md = _csv_page_content(rel_str, csv_rel_path)
            (page_dir / "index.md").write_text(page_md, encoding="utf-8")

            parent_rel = rel.parent.as_posix()
            link_parts = ["csv"]
            if parent_rel and parent_rel != ".":
                link_parts.append(parent_rel)
            link_parts.append(source_path.stem)
            link = "/".join(part.strip("/") for part in link_parts if part)
            entries["csv"].append({"title": rel_str, "link": f"{link}/"})

        elif suffix == ".dds" and image_conversion_enabled:
            image_rel = rel.with_suffix(".png").as_posix()
            destination = output_dir / "images" / rel.with_suffix(".png")
            destination.parent.mkdir(parents=True, exist_ok=True)
            try:
                with Image.open(source_path) as img:  # type: ignore
                    img.save(destination, format="PNG")
            except Exception as exc:  # pragma: no cover - log error for visibility
                print(f"[interface-index] Failed to convert {rel_str}: {exc}")
                continue

            entries["images"].append({"title": rel_str, "link": f"images/{image_rel}"})

    for key in entries:
        entries[key].sort(key=lambda item: item["title"].lower())

    index_content = _build_index(entries, settings, image_conversion_enabled)
    (output_dir / "index.md").write_text(index_content, encoding="utf-8")

    _ensure_gitignore(output_dir)

    total_pages = sum(len(entries[key]) for key in ("lua", "xml", "csv"))
    print(
        "[interface-index] Generated"
        f" {total_pages} pages and {len(entries['images'])} image previews in {output_dir}"
    )
