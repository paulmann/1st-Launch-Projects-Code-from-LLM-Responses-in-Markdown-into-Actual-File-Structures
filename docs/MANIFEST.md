# 📦 Documentation Package — Manifest

**Version:** 1.1
**Date:** 2026-10-19
**Author:** Mikhail Deynekin (https://deynekin.com)
**License:** PolyForm Noncommercial 1.0.0
**Compatibility:** MD_to_Files.sh v6.0.1+

---

## 📋 What is in this package

Eight documents, all in `docs/`, plus the script and the README at the repository root.

### 📖 Core documentation (English)

| File | Purpose | Audience | Time |
|------|---------|----------|------|
| **INDEX.md** | Navigation and overview of the set | Everyone | 10 min |
| **QUICK_REFERENCE.md** | One-page cheat sheet: markers, checklist, mistakes | Active users | 5 min |
| **PROMPT_TEMPLATES.md** | Copy-paste prompts per language and project type | Prompt authors | 5 min |
| **PROMPT_GUIDE.md** | Complete reference on prompt formatting and validation | Deep learners | 30 min |
| **EXAMPLES.md** | Worked examples, request → generated project | Learning by doing | 15 min |

### 📚 Support documentation

| File | Purpose | Content |
|------|---------|---------|
| **PROMPTS.txt** | All prompts in plain text | Copy-paste source, no Markdown |
| **RUSSIAN_QUICK_START.md** | Краткая инструкция на русском | 30-second guide |
| **MANIFEST.md** | This file | What the package contains |

### 🔧 Implementation

| File | Purpose |
|------|---------|
| **../MD_to_Files.sh** | The script (v6.0.1), Bash 4.0+ |
| **../README.md** | Installation, CLI reference, troubleshooting, FAQ |
| **../CHANGELOG.md** | Version history |
| **../CONTRIBUTING.md** | How to report and propose changes |
| **../CODE_OF_CONDUCT.md** | Community rules |
| **../LICENSE** | PolyForm Noncommercial License 1.0.0 |

`examples/` contains the same `EXAMPLES.md` and `PROMPTS.txt` as `docs/`, kept for
links that point at that path.

---

## 🎯 Reading paths

### Path 1 — "Just tell me what to do" (5 minutes)

```
1. Read: QUICK_REFERENCE.md (3 min)
2. Copy: a prompt from PROMPT_TEMPLATES.md (1 min)
3. Run:  ./MD_to_Files.sh response.md ./output
```

### Path 2 — "I want to understand everything" (1 hour)

```
1. README.md — how the parser works (10 min)
2. INDEX.md — map of the set (5 min)
3. PROMPT_GUIDE.md — full formatting rules (30 min)
4. EXAMPLES.md — worked cases (15 min)
```

### Path 3 — "I am debugging a response" (10 minutes)

```
QUICK_REFERENCE.md (checklist and common mistakes)
        ↓
README.md → Troubleshooting (error text → cause → fix)
        ↓
./MD_to_Files.sh -d -v -l debug.log response.md ./preview
```

---

## 📖 What each document covers

**QUICK_REFERENCE.md** — 30-second summary, three elements of a parsable response,
marker syntax, tree rules, checklist before sending a prompt, troubleshooting table.

**PROMPT_TEMPLATES.md** — short, medium and extended prompts; per-language variants
(Python, JavaScript, full-stack, Docker); system prompts for ChatGPT and Claude.

**EXAMPLES.md** — Python script, full-stack TODO application, Node.js REST API,
microservices layout, good-versus-bad responses, timing of the generated workflow.

**PROMPT_GUIDE.md** — purpose and benefits, required components, marker syntax in all
three recognised forms, tree rules, code block requirements, validation checklist,
troubleshooting, CI/CD integration, do's and don'ts, version compatibility.

**RUSSIAN_QUICK_START.md** — the same flow in Russian, for teams that read prompts in
Russian: что это, зачем, как, три обязательных элемента, частые ошибки.

---

## 🔄 Keeping the set consistent

The documents describe the parser, so they must follow it:

1. Marker formats in the docs must match `extract_code_blocks()` in the script.
2. The script name is always `MD_to_Files.sh`; the version comes from `SCRIPT_VERSION`.
3. License statements say PolyForm Noncommercial 1.0.0, matching `LICENSE`.
4. When a document is added or removed, update this file and `docs/INDEX.md` in the
   same commit — both are navigation, and stale navigation is worse than none.

---

## 📞 Support

- Email: mid1977@gmail.com
- Website: https://deynekin.com
- License: PolyForm Noncommercial 1.0.0 — free for noncommercial use, commercial use
  requires a separate license.
