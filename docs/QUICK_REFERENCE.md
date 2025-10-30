# MD to Files Parser - Quick Reference Card

## ⚡ 30-Second Summary

**What**: Standardized markdown format for LLM responses to enable automatic project generation  
**Why**: Convert AI-generated code into working project structure in seconds  
**How**: Add project tree, file markers, and code blocks to LLM response  
**Result**: Run `./MD_to_Files_v5.1.3.sh response.md ./output` → complete project created

---

## 🎯 Three Mandatory Elements

### 1. Project Tree (In Code Block)

```text
project/
├── src/
│   └── main.py
└── requirements.txt
```

**Rules:**
- Start with `project/`
- Use `├──`, `│`, `└──` symbols
- Directories end with `/`
- Wrap in triple backticks with `text` language

### 2. File Markers (First Line in Code Block)

```python
# [file name]: src/main.py
```

**Rules:**
- Exact format: `[file name]: path/to/file.ext`
- First line after opening fence
- Works with any comment: `#`, `//`, `--`, `REM`

### 3. Code Blocks (With Language)

```python
# [file name]: src/main.py
def hello():
    print("Hello World")
```

**Rules:**
- Language identifier required: `python`, `js`, `ts`, etc.
- Complete, working code
- All imports included

---

## 📋 Checklist Before Submitting Response

```
□ Tree starts with "project/"
□ Tree uses ├──, │, └── symbols
□ Tree in code block with ```
□ File marker: [file name]: path
□ Marker on first line after fence
□ Code block has language identifier
□ All tree files have code blocks
□ Code is complete and functional
□ README.md included
□ Dependencies specified
```

---

## 🔴 Common Mistakes

| ❌ Wrong | ✅ Right |
|---------|---------|
| No tree | Tree with project/ root |
| Marker after imports | Marker on line 1 |
| Absolute paths | Relative paths |
| Backslashes `\` | Forward slashes `/` |
| No language identifier | ```python, ```js |
| Incomplete code | Full working code |
| Missing markers | Every file marked |

---

## 💬 Ready-to-Use Prompt

**Add this to ANY code request:**

```
Format for MD to Files Parser (v5.1.3+):
- Complete project tree at start with project/ root
- Each file's code block marked with [file name]: path on line 1
- Language identifiers on code blocks (python, js, etc.)
- Include all config files and dependencies
- Provide setup instructions in README
```

---

## 🛠️ One-Line Commands

```bash
# Check if response is valid format
./MD_to_Files_v5.1.3.sh -d response.md /tmp/test

# Create actual project
./MD_to_Files_v5.1.3.sh -v response.md ./my_project

# With backup of existing files
./MD_to_Files_v5.1.3.sh -vb response.md ./my_project

# With project metadata (README, etc.)
./MD_to_Files_v5.1.3.sh -vbP response.md ./my_project
```

---

## 📁 File Marker Examples

```python
# [file name]: src/main.py
```

```javascript
// [file name]: src/index.js
```

```bash
# [file name]: scripts/setup.sh
```

```json
// [file name]: config.json
```

---

## 🎓 Why This Format Matters

| Benefit | Impact |
|---------|--------|
| **Automation** | Manual → Seconds |
| **Accuracy** | Human errors → Zero |
| **Reproducibility** | One-time → Repeatable |
| **Scalability** | 5 files → 100+ files |
| **CI/CD Ready** | Manual → Automated |

---

## 🔗 File Path Rules

```
✅ VALID:
[file name]: src/main.py
[file name]: config/settings.json
[file name]: tests/unit/test_auth.py
[file name]: .gitignore

❌ INVALID:
[file name]: /usr/bin/script.sh          (absolute path)
[file name]: ../../../../etc/passwd       (parent traversal)
[file name]: ../../../ (../../../main.py  (with parent dir)
```

---

## 🎯 Tree Format

```
✅ CORRECT SYMBOLS:
├── (branch: ├ + 2 dashes)
│  (pipe: vertical line, space)
└── (last: └ + 2 dashes)

✅ CORRECT STRUCTURE:
project/
├── directory/
│   └── file.txt
└── file2.txt

❌ WRONG SYMBOLS:
|-- (should be ├--)
|   (should be │)
\-- (should be └--)
```

---

## 📊 Response Size Guidelines

| Project Size | Tree Depth | Files | Time |
|--------------|-----------|-------|------|
| Small | 2-3 | 5-10 | <5 sec |
| Medium | 3-4 | 15-30 | 5-10 sec |
| Large | 4-5 | 50+ | 10-30 sec |

---

## 🆘 Quick Troubleshooting

**Problem**: "No project structures found"  
**Solution**: Ensure tree starts with `project/` and is in code block

**Problem**: "File name too long"  
**Solution**: Marker must be clean `[file name]: path` without extra text

**Problem**: Files created but empty  
**Solution**: Marker must be on line 1 after code fence, not after imports

**Problem**: Duplication/errors with --help  
**Solution**: Update to v5.1.3+

---

## 🔄 Complete Workflow

```
1. Write Request
   ↓
2. Add Prompt Suffix (see below)
   ↓
3. Get Response from LLM
   ↓
4. Validate: ./MD_to_Files_v5.1.3.sh -d response.md /tmp/check
   ↓
5. Generate: ./MD_to_Files_v5.1.3.sh response.md ./output
   ↓
6. Done! → Complete project ready
```

---

## 📄 Minimal Prompt to Add

**Just copy-paste this to end of your request:**

```
Format for MD to Files Parser:
1. Complete project tree in code block
2. Each file marked with: [file name]: path on first line
3. Include all dependencies and setup
```

---

## 💾 File Structure Example

```
REQUEST:
"Generate a Python Flask API"

+ PROMPT SUFFIX:
"Format for MD to Files Parser v5.1.3+: [see above]"

= RESPONSE:
```text
project/
├── app.py
├── requirements.txt
└── README.md
```

```python
# [file name]: app.py
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello'

if __name__ == '__main__':
    app.run()
```

```
requirements.txt
# [file name]: requirements.txt
Flask==2.0.0
```

```markdown
# [file name]: README.md
# Flask API

## Setup
pip install -r requirements.txt
```

RESULT:
✓ Created: project/app.py
✓ Created: project/requirements.txt
✓ Created: project/README.md
```

---

## 🎨 Language Identifiers Cheat Sheet

| Language | Identifier |
|----------|------------|
| Python | `python` or `py` |
| JavaScript | `javascript` or `js` |
| TypeScript | `typescript` or `ts` |
| Bash/Shell | `bash` or `sh` |
| JSON | `json` |
| YAML | `yaml` or `yml` |
| PHP | `php` |
| SQL | `sql` |
| HTML | `html` |
| CSS | `css` |
| Java | `java` |
| C++ | `cpp` or `c++` |
| Go | `go` |
| Rust | `rust` |
| Project Tree | `text` or `markdown` |

---

## 🔐 Security Rules

**Always verify paths:**
- ✅ `src/main.py` - safe
- ❌ `/etc/passwd` - dangerous
- ❌ `../../secrets.txt` - dangerous
- ❌ `$(rm -rf /)` - injection attempt

---

## 📞 Quick Help

**Format valid?**
```bash
shellcheck -x MD_to_Files_v5.1.3.sh  # validate script
grep "project/" response.md           # check tree
grep "\[file name\]:" response.md     # check markers
```

**Generate project:**
```bash
./MD_to_Files_v5.1.3.sh response.md ./output
```

**More options:**
```bash
./MD_to_Files_v5.1.3.sh --help
```

---

## 📚 Documentation Links

- **Full Guide**: PROMPT_GUIDE.md
- **Prompt Templates**: PROMPT_TEMPLATES.md
- **Error Analysis**: ERROR_ANALYSIS.md
- **Testing**: TESTING_GUIDE.md
- **Summary**: SUMMARY.md

---

## ⚡ Power User Tips

1. **Template it**: Save prompt suffix as shell function
   ```bash
   alias md2files-prompt='echo "Format for MD to Files Parser v5.1.3+..."'
   ```

2. **Pipe responses**: Direct from API to parser
   ```bash
   curl api.example.com | ./MD_to_Files_v5.1.3.sh - ./output
   ```

3. **Batch processing**: Multiple responses
   ```bash
   for file in responses/*.md; do
     ./MD_to_Files_v5.1.3.sh "$file" "output/$(basename $file .md)"
   done
   ```

4. **CI/CD integration**: Automate project generation
   ```bash
   gh workflow run generate.yml -f prompt="Your request"
   ```

---

**Version**: 1.0 | **Date**: 2025-10-30 | **Compatibility**: v5.1.3+

