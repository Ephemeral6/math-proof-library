# Build op1_proof_clean.pdf from op1_proof_clean.md
# Inline math -> Unicode + reportlab <sub>/<super> tags.
# Display math ($$...$$) -> matplotlib mathtext rendered to PNG.

import os
import re
import hashlib
import tempfile
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

from reportlab.lib.pagesizes import A4
from reportlab.lib.units import cm
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_JUSTIFY
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Image, Preformatted,
    KeepTogether, Table, TableStyle,
)
from reportlab.lib import colors
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

# Register Unicode-capable fonts shipped with matplotlib
_MPL_FONT_DIR = Path(matplotlib.__file__).resolve().parent / "mpl-data" / "fonts" / "ttf"

def _reg(name, fname):
    pdfmetrics.registerFont(TTFont(name, str(_MPL_FONT_DIR / fname)))

_reg("BodyRoman",      "DejaVuSerif.ttf")
_reg("BodyBold",       "DejaVuSerif-Bold.ttf")
_reg("BodyItalic",     "DejaVuSerif-Italic.ttf")
_reg("BodyBoldItalic", "DejaVuSerif-BoldItalic.ttf")
pdfmetrics.registerFontFamily(
    "BodyRoman",
    normal="BodyRoman", bold="BodyBold",
    italic="BodyItalic", boldItalic="BodyBoldItalic",
)
_reg("MonoRoman", "DejaVuSansMono.ttf")
_reg("MonoBold",  "DejaVuSansMono-Bold.ttf")
pdfmetrics.registerFontFamily(
    "MonoRoman",
    normal="MonoRoman", bold="MonoBold",
    italic="MonoRoman", boldItalic="MonoBold",
)

# STIX has the full Math Alphanumeric block (U+1D400+); DejaVu does not.
_reg("MathRoman", "STIXGeneral.ttf")


HERE = Path(__file__).resolve().parent
SRC = HERE / "op1_proof_clean.md"
OUT_PDF = HERE / "op1_proof_clean.pdf"
IMG_DIR = HERE / "_pdf_eq_cache"
IMG_DIR.mkdir(exist_ok=True)


# ----------------------------------------------------------------------
# LaTeX-inline -> reportlab paragraph XML (Unicode + <sub>/<super>)
# ----------------------------------------------------------------------

GREEK = {
    r"\alpha": "α", r"\beta": "β", r"\gamma": "γ", r"\delta": "δ",
    r"\epsilon": "ε", r"\varepsilon": "ε", r"\zeta": "ζ", r"\eta": "η",
    r"\theta": "θ", r"\vartheta": "ϑ", r"\iota": "ι", r"\kappa": "κ",
    r"\lambda": "λ", r"\mu": "μ", r"\nu": "ν", r"\xi": "ξ",
    r"\pi": "π", r"\varpi": "ϖ", r"\rho": "ρ", r"\sigma": "σ",
    r"\tau": "τ", r"\upsilon": "υ", r"\phi": "φ", r"\varphi": "φ",
    r"\chi": "χ", r"\psi": "ψ", r"\omega": "ω", r"\ell": "ℓ",
    r"\Gamma": "Γ", r"\Delta": "Δ", r"\Theta": "Θ", r"\Lambda": "Λ",
    r"\Xi": "Ξ", r"\Pi": "Π", r"\Sigma": "Σ", r"\Upsilon": "Υ",
    r"\Phi": "Φ", r"\Psi": "Ψ", r"\Omega": "Ω",
}
SYMBOLS = {
    r"\leq": "≤", r"\le": "≤", r"\geq": "≥", r"\ge": "≥",
    r"\neq": "≠", r"\ne": "≠",
    r"\to": "→", r"\rightarrow": "→", r"\leftarrow": "←",
    r"\Rightarrow": "⇒", r"\Leftarrow": "⇐",
    r"\leftrightarrow": "↔", r"\Leftrightarrow": "⇔",
    r"\xleftrightarrow": "↔", r"\mapsto": "↦",
    r"\cup": "∪", r"\cap": "∩", r"\sqcup": "⊔",
    r"\setminus": "∖", r"\backslash": "\\",
    r"\subset": "⊂", r"\subseteq": "⊆", r"\supset": "⊃",
    r"\in": "∈", r"\notin": "∉", r"\ni": "∋",
    r"\vee": "∨", r"\wedge": "∧",
    r"\cong": "≅", r"\approx": "≈", r"\sim": "∼", r"\equiv": "≡",
    r"\partial": "∂", r"\emptyset": "∅", r"\infty": "∞",
    r"\square": "□", r"\blacksquare": "■", r"\star": "★",
    r"\pm": "±", r"\mp": "∓",
    r"\times": "×", r"\div": "÷",
    r"\cdot": "·", r"\cdots": "⋯", r"\ldots": "…", r"\dots": "…",
    r"\circ": "∘", r"\bullet": "•",
    r"\langle": "⟨", r"\rangle": "⟩",
}
BLACKBOARD = {
    "Z": "ℤ", "R": "ℝ", "Q": "ℚ", "N": "ℕ", "C": "ℂ",
    "P": "ℙ", "E": "𝔼", "F": "𝔽", "H": "ℍ",
}
CALLIG = {
    "A": "𝒜", "B": "ℬ", "C": "𝒞", "D": "𝒟", "E": "ℰ",
    "F": "ℱ", "G": "𝒢", "H": "ℋ", "I": "ℐ", "J": "𝒥",
    "K": "𝒦", "L": "ℒ", "M": "ℳ", "N": "𝒩", "O": "𝒪",
    "P": "𝒫", "Q": "𝒬", "R": "ℛ", "S": "𝒮", "T": "𝒯",
    "U": "𝒰", "V": "𝒱", "W": "𝒲", "X": "𝒳", "Y": "𝒴", "Z": "𝒵",
}


def _replace_brace_cmd(s, cmd, transform):
    """Replace \\cmd{...} (one level of nesting tolerated via repeated pass)."""
    pat = re.compile(re.escape(cmd) + r"\{([^{}]*)\}")
    while True:
        m = pat.search(s)
        if not m:
            return s
        s = s[: m.start()] + transform(m.group(1)) + s[m.end() :]


def latex_inline_to_xml(s: str) -> str:
    # Escape XML-significant chars first (we'll add our own tags later)
    s = s.replace("&", "&amp;")
    # We deliberately allow < and > to be replaced with entities since
    # mathematical < / > are written as \le / \ge in the source.
    s = s.replace("<", "&lt;").replace(">", "&gt;")

    # Font / decoration commands
    s = _replace_brace_cmd(s, r"\mathbb",
                           lambda x: BLACKBOARD.get(x, x))
    s = _replace_brace_cmd(
        s, r"\mathcal",
        lambda x: f'<font face="MathRoman">{CALLIG.get(x, x)}</font>',
    )
    s = _replace_brace_cmd(s, r"\mathrm", lambda x: x)
    s = _replace_brace_cmd(s, r"\mathsf", lambda x: x)
    s = _replace_brace_cmd(s, r"\mathbf", lambda x: f"<b>{x}</b>")
    s = _replace_brace_cmd(s, r"\mathit", lambda x: f"<i>{x}</i>")
    s = _replace_brace_cmd(s, r"\textbf", lambda x: f"<b>{x}</b>")
    s = _replace_brace_cmd(s, r"\textit", lambda x: f"<i>{x}</i>")
    s = _replace_brace_cmd(s, r"\texttt",
                           lambda x: f'<font face="Courier">{x}</font>')
    s = _replace_brace_cmd(s, r"\text", lambda x: x)
    s = _replace_brace_cmd(s, r"\mbox", lambda x: x)
    s = _replace_brace_cmd(s, r"\widetilde", lambda x: f"{x}̃")
    s = _replace_brace_cmd(s, r"\widehat", lambda x: f"{x}̂")
    s = _replace_brace_cmd(s, r"\overline", lambda x: f"{x}̅")
    s = _replace_brace_cmd(s, r"\bar", lambda x: f"{x}̅")
    s = _replace_brace_cmd(s, r"\tilde", lambda x: f"{x}̃")
    s = _replace_brace_cmd(s, r"\hat", lambda x: f"{x}̂")
    s = _replace_brace_cmd(s, r"\boxed", lambda x: x)

    # \widetilde\alpha (no braces): apply combining tilde to the next macro
    s = re.sub(
        r"\\widetilde\\([A-Za-z]+)",
        lambda m: GREEK.get("\\" + m.group(1), m.group(1)) + "̃",
        s,
    )
    s = re.sub(
        r"\\widehat\\([A-Za-z]+)",
        lambda m: GREEK.get("\\" + m.group(1), m.group(1)) + "̂",
        s,
    )

    # \bigl( \bigr) etc. -> drop the size hint
    s = re.sub(r"\\(?:big|Big|bigg|Bigg)[lr]?", "", s)

    # \frac{a}{b} -> (a)/(b)
    s = re.sub(r"\\frac\{([^{}]*)\}\{([^{}]*)\}", r"(\1)/(\2)", s)
    # \sqrt{x}
    s = re.sub(r"\\sqrt\{([^{}]*)\}", r"√(\1)", s)

    # Symbols (sorted longest first to avoid prefix-collisions)
    for k in sorted(SYMBOLS.keys(), key=len, reverse=True):
        v = SYMBOLS[k]
        s = re.sub(re.escape(k) + r"(?![A-Za-z])", lambda _m, _v=v: _v, s)
    for k in sorted(GREEK.keys(), key=len, reverse=True):
        v = GREEK[k]
        s = re.sub(re.escape(k) + r"(?![A-Za-z])", lambda _m, _v=v: _v, s)

    # Spacing macros
    s = s.replace(r"\quad", "  ").replace(r"\qquad", "    ")
    s = re.sub(r"\\[,;:!\s]", " ", s)

    # Subscripts and superscripts
    s = re.sub(r"_\{([^{}]+)\}", r"<sub>\1</sub>", s)
    s = re.sub(r"\^\{([^{}]+)\}", r"<super>\1</super>", s)
    s = re.sub(r"_([A-Za-z0-9])", r"<sub>\1</sub>", s)
    s = re.sub(r"\^([A-Za-z0-9])", r"<super>\1</super>", s)

    # Drop any leftover commands (best effort)
    s = re.sub(r"\\([A-Za-z]+)\*?", r"\1", s)
    # Collapse double spaces but keep newlines
    s = re.sub(r" {2,}", " ", s)
    return s


# ----------------------------------------------------------------------
# Display math via matplotlib mathtext
# ----------------------------------------------------------------------

def _strip_brace_arg(s: str, cmd: str, replacement: str) -> str:
    """Replace ``cmd{...}`` with ``replacement``, with proper brace nesting."""
    out = []
    i = 0
    n = len(s)
    L = len(cmd)
    while i < n:
        if s.startswith(cmd, i) and i + L < n and s[i + L] == "{":
            # Skip over balanced braces
            depth = 1
            j = i + L + 1
            while j < n and depth > 0:
                if s[j] == "{":
                    depth += 1
                elif s[j] == "}":
                    depth -= 1
                j += 1
            out.append(replacement)
            i = j
        else:
            out.append(s[i])
            i += 1
    return "".join(out)


def _prepare_mathtext(latex: str) -> str:
    """Pre-process display LaTeX so matplotlib mathtext can parse it."""
    s = latex.strip()
    # Replace constructs mathtext does not support
    s = s.replace(r"\boxed", "")
    s = _strip_brace_arg(s, r"\xleftrightarrow", r"\leftrightarrow")
    s = _strip_brace_arg(s, r"\xrightarrow",     r"\rightarrow")
    s = _strip_brace_arg(s, r"\xleftarrow",      r"\leftarrow")
    # \iff / \implies are not in mathtext
    s = re.sub(r"\\iff(?![A-Za-z])", r"\\Leftrightarrow", s)
    s = re.sub(r"\\implies(?![A-Za-z])", r"\\Rightarrow", s)
    s = re.sub(r"\\impliedby(?![A-Za-z])", r"\\Leftarrow", s)
    s = s.replace(r"\texttt", r"\mathtt")
    s = s.replace(r"\textbf", r"\mathbf")
    s = s.replace(r"\textit", r"\mathit")
    # \big...l/r delimiters: just drop them (the bare delimiter remains)
    for cmd in (r"\bigl", r"\bigr", r"\Bigl", r"\Bigr",
                r"\biggl", r"\biggr", r"\Biggl", r"\Biggr",
                r"\bigg", r"\Bigg", r"\big", r"\Big"):
        s = s.replace(cmd, "")
    # mathtext only knows \leq/\geq/\neq, not the \le/\ge/\ne short forms
    s = re.sub(r"\\le(?![A-Za-z])", r"\\leq", s)
    s = re.sub(r"\\ge(?![A-Za-z])", r"\\geq", s)
    s = re.sub(r"\\ne(?![A-Za-z])", r"\\neq", s)
    # \lvert / \rvert -> | (mathtext does not have these macros)
    s = s.replace(r"\lvert", "|").replace(r"\rvert", "|")
    s = s.replace(r"\lVert", r"\|").replace(r"\rVert", r"\|")
    # \text{... $math$ ...} : mathtext loses math mode at the inner $.
    # Rewrite as \text{...}math\text{...}.
    def _fix_text(m):
        inner = m.group(1)
        inner = re.sub(r"\$([^$]+)\$", r"}\1\\text{", inner)
        return r"\text{" + inner + "}"
    s = re.sub(r"\\text\{([^{}]*)\}", _fix_text, s)
    # mathtext supports \\ for line breaks inside arrays via $\begin{array}{..}..\\..\end{array}$
    return s


def _render_mathtext(latex: str, fontsize: int = 13) -> str:
    """Render a display equation to PNG and return its file path."""
    prepared = _prepare_mathtext(latex)
    cache_key = hashlib.sha1(
        f"{fontsize}|{prepared}".encode("utf-8")
    ).hexdigest()[:16]
    out = IMG_DIR / f"eq_{cache_key}.png"
    if out.exists():
        return str(out)
    text = "$" + prepared.replace("\n", " ") + "$"
    fig = plt.figure(figsize=(0.01, 0.01), dpi=240)
    fig.text(0, 0, text, fontsize=fontsize)
    try:
        fig.savefig(out, dpi=240, bbox_inches="tight",
                    pad_inches=0.05, transparent=False)
    except Exception as exc:  # parsing failure -> render as plain text
        fig.clear()
        fig.text(0, 0, prepared, fontsize=fontsize)
        fig.savefig(out, dpi=240, bbox_inches="tight",
                    pad_inches=0.05, transparent=False)
    plt.close(fig)
    return str(out)


def display_equation_flowable(latex: str, max_width_pt: float):
    """Return an Image flowable scaled to fit max_width_pt."""
    if r"\begin{array}" in latex:
        try:
            return _render_array_as_table(latex, max_width_pt)
        except Exception:
            pass
    path = _render_mathtext(latex, fontsize=13)
    img = Image(path)
    nat_w = img.imageWidth * 72.0 / 240.0
    nat_h = img.imageHeight * 72.0 / 240.0
    scale = min(1.0, (max_width_pt - 8.0) / nat_w) if nat_w > 0 else 1.0
    img.drawWidth = nat_w * scale
    img.drawHeight = nat_h * scale
    img.hAlign = "CENTER"
    return img


def _math_image_cell(latex_or_text: str, fontsize: int = 11):
    """Render a single math expression (or plain text) as an Image flowable
    for use inside a Table cell."""
    s = latex_or_text.strip()
    if not s:
        return Paragraph(" ", style_body)
    # Plain \text{...} : strip and render as Paragraph (faster, no image churn)
    m = re.fullmatch(r"\s*\\text\{([^{}]*)\}\s*", s)
    if m:
        return Paragraph(render_markdown_inline(m.group(1)), style_body)
    try:
        path = _render_mathtext(s, fontsize=fontsize)
        img = Image(path)
        nat_w = img.imageWidth * 72.0 / 240.0
        nat_h = img.imageHeight * 72.0 / 240.0
        img.drawWidth = nat_w
        img.drawHeight = nat_h
        return img
    except Exception:
        return Paragraph(latex_inline_to_xml(s), style_body)


def _render_array_as_table(latex: str, max_width_pt: float):
    """Parse a \\begin{array}{...} ... \\end{array} block and turn it into
    a reportlab Table whose cells are mathtext images."""
    m = re.search(
        r"\\begin\{array\}\{[^}]*\}(.*?)\\end\{array\}",
        latex, flags=re.DOTALL,
    )
    if not m:
        raise ValueError("no array block")
    body = m.group(1).strip()
    # Split rows on \\ (but not on \\\hline; treat \hline as ignorable)
    rows = re.split(r"\\\\", body)
    parsed_rows = []
    has_hline_after = []
    for row in rows:
        row = row.strip()
        # Strip leading \hline tokens
        hline = False
        while row.startswith(r"\hline"):
            hline = True
            row = row[len(r"\hline"):].lstrip()
        if not row:
            if parsed_rows:
                has_hline_after[-1] = has_hline_after[-1] or hline
            continue
        cells = [c.strip() for c in row.split("&")]
        parsed_rows.append(cells)
        has_hline_after.append(False)

    table_data = [
        [_math_image_cell(c, fontsize=11) for c in row]
        for row in parsed_rows
    ]
    tbl = Table(table_data, hAlign="CENTER")
    style = [
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("ALIGN", (0, 0), (-1, -1), "CENTER"),
        ("LEFTPADDING", (0, 0), (-1, -1), 6),
        ("RIGHTPADDING", (0, 0), (-1, -1), 6),
        ("TOPPADDING", (0, 0), (-1, -1), 2),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 2),
        ("LINEBELOW", (0, 0), (-1, 0), 0.5, colors.black),
    ]
    # Header row underline already added; bottom rule for total row if last.
    style.append(("LINEABOVE", (0, -1), (-1, -1), 0.5, colors.black))
    tbl.setStyle(TableStyle(style))
    return tbl


# ----------------------------------------------------------------------
# Markdown parsing
# ----------------------------------------------------------------------

def strip_frontmatter(text: str) -> str:
    if text.startswith("---\n"):
        end = text.find("\n---\n", 4)
        if end != -1:
            return text[end + 5 :]
    return text


def split_inline_math(line: str):
    """Split a paragraph line into ('text', s) and ('math', s) tokens.

    Skips $ inside backticked spans and ignores $$ (display math is handled
    separately at the block level)."""
    tokens = []
    i = 0
    n = len(line)
    in_code = False
    text_buf = []
    while i < n:
        ch = line[i]
        if ch == "`":
            in_code = not in_code
            text_buf.append(ch)
            i += 1
            continue
        if ch == "$" and not in_code:
            # Find matching $
            j = line.find("$", i + 1)
            if j == -1:
                text_buf.append(ch)
                i += 1
                continue
            if text_buf:
                tokens.append(("text", "".join(text_buf)))
                text_buf = []
            tokens.append(("math", line[i + 1 : j]))
            i = j + 1
            continue
        text_buf.append(ch)
        i += 1
    if text_buf:
        tokens.append(("text", "".join(text_buf)))
    return tokens


def render_markdown_inline(text: str) -> str:
    """Render markdown inline (bold, italic, code) and inline math to XML.

    Strategy: tokenize math/code spans into opaque placeholders first, run
    bold/italic on the placeholder string, then expand placeholders with
    properly rendered XML so that `**...**` markers can span math segments.
    """
    tokens = split_inline_math(text)
    placeholders = {}  # idx -> rendered XML
    out_parts = []
    next_id = 0
    for kind, chunk in tokens:
        if kind == "math":
            key = f"M{next_id}"
            next_id += 1
            placeholders[key] = latex_inline_to_xml(chunk)
            out_parts.append(key)
        else:
            # Extract `code` spans as placeholders too (so * inside is safe)
            def _save_code(m):
                nonlocal next_id
                k = f"C{next_id}"
                next_id += 1
                inner = m.group(1)
                inner = (inner.replace("&", "&amp;")
                              .replace("<", "&lt;").replace(">", "&gt;"))
                placeholders[k] = (
                    f'<font face="MonoRoman">{inner}</font>'
                )
                return k
            chunk = re.sub(r"`([^`]+)`", _save_code, chunk)
            out_parts.append(chunk)

    merged = "".join(out_parts)
    # Now escape XML metacharacters in the non-placeholder portions.
    # Placeholders use Private-Use Area chars that won't collide.
    merged = (merged.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;"))
    # Apply bold and italic across the whole merged string.
    merged = re.sub(r"\*\*([^*]+)\*\*", r"<b>\1</b>", merged)
    merged = re.sub(
        r"(?<![*\w])\*([^*\n]+)\*(?!\w)", r"<i>\1</i>", merged
    )
    # Restore placeholders.
    for k, v in placeholders.items():
        merged = merged.replace(k, v)
    return merged


# ----------------------------------------------------------------------
# Build the story
# ----------------------------------------------------------------------

PAGE_W, PAGE_H = A4
MARGIN = 2.5 * cm
USABLE_W_PT = PAGE_W - 2 * MARGIN

styles = getSampleStyleSheet()

style_title = ParagraphStyle(
    "title", parent=styles["Title"],
    fontName="BodyBold", fontSize=17, leading=21,
    alignment=TA_CENTER, spaceAfter=6,
)
style_date = ParagraphStyle(
    "date", parent=styles["Normal"],
    fontName="BodyItalic", fontSize=11, leading=14,
    alignment=TA_CENTER, spaceAfter=16,
)
style_h1 = ParagraphStyle(
    "h1", parent=styles["Heading1"],
    fontName="BodyBold", fontSize=13.5, leading=17,
    spaceBefore=10, spaceAfter=5, textColor="black",
)
style_h2 = ParagraphStyle(
    "h2", parent=styles["Heading2"],
    fontName="BodyBold", fontSize=12, leading=15,
    spaceBefore=8, spaceAfter=3,
)
style_h3 = ParagraphStyle(
    "h3", parent=styles["Heading3"],
    fontName="BodyBold", fontSize=11, leading=14,
    spaceBefore=6, spaceAfter=2,
)
style_body = ParagraphStyle(
    "body", parent=styles["BodyText"],
    fontName="BodyRoman", fontSize=10.5, leading=13.7,
    alignment=TA_JUSTIFY, spaceAfter=3,
)
style_bullet = ParagraphStyle(
    "bullet", parent=style_body,
    leftIndent=18, bulletIndent=6,
    spaceAfter=1,
)
style_pre = ParagraphStyle(
    "pre", parent=styles["Code"],
    fontName="MonoRoman", fontSize=7.8, leading=9.4,
    leftIndent=10, spaceBefore=3, spaceAfter=4,
)


def heading_style(level: int) -> ParagraphStyle:
    return {1: style_h1, 2: style_h2, 3: style_h3}.get(level, style_h3)


def parse_blocks(md: str):
    """Yield ('heading', level, text) | ('para', text) |
              ('display', latex) | ('code', text) | ('hrule',) |
              ('bullet', items_list)."""
    lines = md.split("\n")
    i = 0
    n = len(lines)
    while i < n:
        line = lines[i]
        stripped = line.strip()

        if stripped == "":
            i += 1
            continue

        # Horizontal rule
        if re.match(r"^-{3,}$", stripped):
            yield ("hrule",)
            i += 1
            continue

        # Heading
        m = re.match(r"^(#{1,6})\s+(.*)$", stripped)
        if m:
            level = len(m.group(1))
            yield ("heading", level, m.group(2).strip())
            i += 1
            continue

        # Fenced code block
        if stripped.startswith("```"):
            i += 1
            buf = []
            while i < n and not lines[i].strip().startswith("```"):
                buf.append(lines[i])
                i += 1
            if i < n:
                i += 1  # consume closing fence
            yield ("code", "\n".join(buf))
            continue

        # Display math: $$ on its own line, possibly multi-line
        if stripped.startswith("$$"):
            # Allow $$...$$ on a single line
            single = re.match(r"^\$\$(.+)\$\$\s*$", stripped)
            if single:
                yield ("display", single.group(1))
                i += 1
                continue
            i += 1
            buf = []
            while i < n and not lines[i].strip().endswith("$$"):
                buf.append(lines[i])
                i += 1
            if i < n:
                last = lines[i].strip()
                if last != "$$":
                    buf.append(last[:-2])
                i += 1
            yield ("display", "\n".join(buf))
            continue

        # Bullet list
        if re.match(r"^\*\s+", stripped):
            items = []
            while i < n and re.match(r"^\*\s+", lines[i].strip()):
                item_lines = [re.sub(r"^\*\s+", "", lines[i].strip())]
                i += 1
                # Continuation lines (indented or non-empty without bullet)
                while (i < n
                       and lines[i].strip() != ""
                       and not re.match(r"^\*\s+", lines[i].strip())
                       and not lines[i].strip().startswith("#")
                       and not lines[i].strip().startswith("```")
                       and not lines[i].strip().startswith("$$")
                       and not re.match(r"^-{3,}$", lines[i].strip())):
                    item_lines.append(lines[i].strip())
                    i += 1
                items.append(" ".join(item_lines))
            yield ("bullet", items)
            continue

        # Paragraph: gather until blank or special line
        buf = [stripped]
        i += 1
        while i < n:
            nxt = lines[i]
            ns = nxt.strip()
            if ns == "":
                break
            if (ns.startswith("#")
                    or ns.startswith("```")
                    or ns.startswith("$$")
                    or re.match(r"^-{3,}$", ns)
                    or re.match(r"^\*\s+", ns)):
                break
            buf.append(ns)
            i += 1
        yield ("para", " ".join(buf))


def build_story(md: str):
    story = []
    story.append(Paragraph(
        'Contractibility of Descending Links in '
        '<font face="MathRoman">𝒞</font><super>1</super>'
        '(S<sub>1,2</sub>)',
        style_title,
    ))
    story.append(Paragraph("2026-05-03", style_date))

    blocks = list(parse_blocks(md))
    for block in blocks:
        kind = block[0]
        if kind == "heading":
            _, level, text = block
            # Skip the original markdown title block since we've added our own.
            xml = render_markdown_inline(text)
            story.append(Paragraph(xml, heading_style(level)))
        elif kind == "para":
            _, text = block
            xml = render_markdown_inline(text)
            story.append(Paragraph(xml, style_body))
        elif kind == "display":
            _, latex = block
            try:
                story.append(Spacer(1, 2))
                story.append(display_equation_flowable(latex, USABLE_W_PT))
                story.append(Spacer(1, 4))
            except Exception:
                # Fallback: render as monospace LaTeX source
                story.append(Preformatted(latex, style_pre))
        elif kind == "code":
            _, text = block
            story.append(Preformatted(text, style_pre))
        elif kind == "bullet":
            _, items = block
            for it in items:
                xml = render_markdown_inline(it)
                story.append(Paragraph(xml, style_bullet, bulletText="•"))
        elif kind == "hrule":
            story.append(Spacer(1, 6))

    return story


def main():
    text = SRC.read_text(encoding="utf-8")
    md = strip_frontmatter(text)

    doc = SimpleDocTemplate(
        str(OUT_PDF),
        pagesize=A4,
        leftMargin=MARGIN, rightMargin=MARGIN,
        topMargin=MARGIN, bottomMargin=MARGIN,
        title="Contractibility of Descending Links in C^1(S_{1,2})",
        author="",
    )
    story = build_story(md)
    doc.build(story)
    print(f"OK -> {OUT_PDF}")
    print(f"size: {OUT_PDF.stat().st_size} bytes")


if __name__ == "__main__":
    main()
