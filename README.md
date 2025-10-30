# MD_to_Files.sh

[![Version](https://img.shields.io/badge/version-5.1.8-blue.svg)](https://github.com/paulmann/1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash%20%E2%89%A54.0-orange.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20WSL-lightgrey.svg)]()

> 🚀 Transform LLM-generated Markdown documentation with code examples into production-ready project structures

A powerful Bash utility that converts AI assistant responses (ChatGPT, Claude, DeepSeek, Gemini) containing project structures and code samples from Markdown format into fully functional file systems.

---

## 📑 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [Quick Start](#-quick-start)
- [Installation](#-installation)
- [Usage](#-usage)
- [Input Format Reference](#-input-format-reference)
- [Command-Line Options](#-command-line-options)
- [Examples](#-examples)
- [Integration](#-integration)
- [Troubleshooting](#-troubleshooting)
- [Documentation](#-documentation)
- [Contributing](#-contributing)
- [License](#-license)
- [Contact](#-contact)

---

## 🎯 Overview

**MD_to_Files.sh** (also known as **LLM Code Projector**) solves a fundamental challenge in modern development: transforming theoretical architectural designs and code examples from AI assistants into real, working file structures.

### The Problem

You receive a perfect project structure with code examples in Markdown from ChatGPT or Claude. What's next? Manually creating each directory and file? Copying code one file at a time?

### The Solution

```bash
# One simple command
./MD_to_Files.sh chatgpt_response.md ./my-new-project

# Your project is ready to use!
```

### Who It's For

- 👨‍💻 **Developers** — rapid prototyping from AI responses
- 🔧 **DevOps Engineers** — automated project template generation
- 📝 **Technical Writers** — creating working examples from documentation
- 👨‍🏫 **Educators** — preparing course materials with executable code
- 👥 **Development Teams** — standardizing project initialization workflows

---

## ✨ Key Features

### 🌳 Intelligent Structure Parsing

- ✅ Recognizes both ASCII and Unicode directory trees
- ✅ Creates nested directories of any depth
- ✅ Supports multiple tree notation formats
- ✅ Automatically distinguishes between directories and files

### 💻 Smart Code Handling

- ✅ Extracts fenced code blocks from Markdown
- ✅ Automatically associates code with corresponding files
- ✅ Supports 30+ programming languages
- ✅ Preserves formatting, indentation, and character encoding

### 🔒 Security & Reliability

- ✅ Path validation and path traversal prevention
- ✅ Automatic encoding detection and conversion
- ✅ Atomic file operations
- ✅ Optional backup creation on updates

### ⚙️ Flexible Configuration

- ✅ Dry-run mode for previewing changes
- ✅ Interactive selection from multiple structures
- ✅ Batch processing of all detected structures
- ✅ Comprehensive logging with verbose levels

---

## 🚀 Quick Start

### Installation (5 seconds)

```bash
# Clone the repository
git clone https://github.com/paulmann/1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures.git
cd 1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures

# Make executable
chmod +x MD_to_Files.sh

# Verify installation
./MD_to_Files.sh --version
```

### First Run (1 minute)

Create a simple Markdown file `test.md`:

````markdown
# Test Project

```
test-app/
├── src/
│   └── app.js
└── package.json
```

**src/app.js**
```javascript
console.log('Hello from MD_to_Files!');
```

**package.json**
```json
{
  "name": "test-app",
  "version": "1.0.0"
}
```
````

Execute:

```bash
./MD_to_Files.sh test.md ./output
```

Result:

```
✓ Created directory: output/test-app/src
✓ Created file: output/test-app/src/app.js (38 bytes)
✓ Created file: output/test-app/package.json (45 bytes)
✓ Success! 2 files created in 1 directory
```

---

## 📦 Installation

### Method 1: Git Clone (Recommended)

```bash
# Clone repository
git clone https://github.com/paulmann/1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures.git
cd 1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures

# Set executable permissions
chmod +x MD_to_Files.sh

# Create alias (optional)
echo 'alias md2files="$(pwd)/MD_to_Files.sh"' >> ~/.bashrc
source ~/.bashrc
```

### Method 2: Direct Download

```bash
# Using curl
curl -L -o ~/bin/md2files.sh \
  https://raw.githubusercontent.com/paulmann/1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures/main/MD_to_Files.sh

chmod +x ~/bin/md2files.sh

# Using wget
wget -O ~/bin/md2files.sh \
  https://raw.githubusercontent.com/paulmann/1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures/main/MD_to_Files.sh

chmod +x ~/bin/md2files.sh
```

### Method 3: Global Installation

```bash
# Create symlink in PATH
sudo ln -s $(pwd)/MD_to_Files.sh /usr/local/bin/md2files

# Verify installation
which md2files
md2files --version
```

### System Requirements

| Component | Requirement |
|-----------|-------------|
| **OS** | Linux 3.2+, macOS 10.12+, Windows (WSL/Cygwin), BSD |
| **Shell** | Bash ≥ 4.0 (5.0+ recommended) |
| **RAM** | 512 MB (1 GB for large projects) |
| **Disk** | 100 MB free space |
| **Core Utils** | `mkdir`, `touch`, `cat`, `grep`, `sed` |
| **Optional** | `file`, `iconv`, `git` |

### Dependency Check

```bash
# Check Bash version
bash --version

# Verify utilities
for cmd in mkdir touch cat grep sed file iconv; do
    command -v $cmd &>/dev/null && echo "✓ $cmd" || echo "✗ $cmd"
done
```

---

## 💡 Usage

### Basic Syntax

```bash
./MD_to_Files.sh [OPTIONS] <input_file.md> [target_directory]
```

### Simple Examples

```bash
# Generate in current directory
./MD_to_Files.sh structure.md

# Generate in specified directory
./MD_to_Files.sh structure.md ./my-project

# Preview changes (dry-run)
./MD_to_Files.sh -d structure.md ./preview

# Update existing project
./MD_to_Files.sh -U structure.md ./existing-project

# Create with project metadata
./MD_to_Files.sh -P structure.md ./professional-project

# Interactive structure selection
./MD_to_Files.sh -i multi_structures.md ./output

# Process all structures in file
./MD_to_Files.sh -a documentation.md ./batch-output
```

### Operation Modes

| Mode | Option | Description |
|------|--------|-------------|
| **Create** | (default) | Creates new file structure |
| **Update** | `-U`, `--update` | Updates existing files |
| **Project** | `-P`, `--project` | Creates with README and metadata |
| **Interactive** | `-i`, `--ask` | Select from multiple structures |
| **Batch** | `-a`, `--find-all` | Process all structures |
| **Dry-run** | `-d`, `--dry-run` | Simulate without changes |

### Additional Options

| Option | Long Form | Description |
|--------|-----------|-------------|
| `-n N` | `--tree-number N` | Process structure number N |
| `-C` | `--no-code` | Create empty files without code |
| `-f` | `--force` | Overwrite without confirmation |
| `-b` | `--backup` | Create backup copies |
| `-v` | `--verbose` | Detailed output |
| `-l FILE` | `--log FILE` | Write to log file |
| `-h` | `--help` | Show help message |
| `-V` | `--version` | Display version |

### Option Combinations

```bash
# Safe update with backups and logging
./MD_to_Files.sh -U -b -v -l update.log structure.md ./project

# Batch processing in project mode
./MD_to_Files.sh -a -P documentation.md ./projects

# Force update without code extraction
./MD_to_Files.sh -U -f -C skeleton.md ./scaffold

# Select specific structure (3rd in file)
./MD_to_Files.sh -n 3 variants.md ./variant-3
```

---

## 📝 Input Format Reference

### Markdown Document Structure

Recommended format:

````markdown
# Project Name

Brief description.

## Project Structure

```
project-name/
├── directory1/
│   ├── file1.ext
│   └── file2.ext
└── file3.ext
```

## Implementation

**directory1/file1.ext**
```language
// Code for file1
```

**directory1/file2.ext**
```language
// Code for file2
```
````

### Directory Tree Formats

**Unicode Box-Drawing (Recommended):**

```
my-project/
├── src/
│   ├── main.js
│   ├── utils.js
│   └── lib/
│       └── helper.js
├── tests/
│   └── main.test.js
└── package.json
```

**ASCII Tree:**

```
my-project/
|-- src/
|   |-- main.js
|   `-- utils.js
`-- package.json
```

**Simple Indentation:**

```
my-project/
  src/
    main.js
    utils.js
  package.json
```

### Code Blocks

**Fenced Code Blocks with Language:**

````markdown
**src/app.js**
```javascript
const express = require('express');
app.listen(3000);
```

**config/database.json**
```json
{
  "host": "localhost",
  "port": 5432
}
```
````

### Supported Languages

JavaScript, TypeScript, Python, PHP, Java, C, C++, C#, Ruby, Go, Rust, Shell, Bash, HTML, CSS, SCSS, SQL, JSON, YAML, XML, Markdown, and more (30+ languages)

### Code-to-File Association Methods

**Method 1: Bold Marker (Recommended)**

````markdown
**src/controllers/userController.js**
```javascript
exports.getUser = (req, res) => {
    res.json({ user: 'John' });
};
```
````

**Method 2: Section Header**

````markdown
## src/models/User.js

```javascript
class User {
    constructor(name) { this.name = name; }
}
```
````

**Method 3: Label with Colon**

````markdown
File: config/database.js

```javascript
module.exports = { host: 'localhost' };
```
````

**Priority:** Bold marker > Header > Label > Code comment

---

## 🎬 Examples

### Example 1: React Application

**Create `react_app.md`:**

````markdown
# React Application

```
react-app/
├── public/
│   └── index.html
├── src/
│   ├── index.js
│   ├── App.js
│   └── components/
│       ├── Header.js
│       └── Footer.js
└── package.json
```

**src/index.js**
```javascript
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);
```

**src/App.js**
```javascript
import React from 'react';
import Header from './components/Header';
import Footer from './components/Footer';

function App() {
  return (
    <div className="App">
      <Header />
      <main><h1>Welcome to React</h1></main>
      <Footer />
    </div>
  );
}

export default App;
```

**src/components/Header.js**
```javascript
import React from 'react';

function Header() {
  return <header><h2>My React App</h2></header>;
}

export default Header;
```

**src/components/Footer.js**
```javascript
import React from 'react';

function Footer() {
  return <footer><p>&copy; 2025 My App</p></footer>;
}

export default Footer;
```

**package.json**
```json
{
  "name": "react-app",
  "version": "1.0.0",
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build"
  }
}
```
````

**Execute:**

```bash
./MD_to_Files.sh -P react_app.md ./my-react-app
cd my-react-app/react-app
npm install
npm start
```

### Example 2: Express API

````markdown
# Express REST API

```
express-api/
├── src/
│   ├── app.js
│   ├── routes/
│   │   └── users.js
│   ├── controllers/
│   │   └── userController.js
│   └── config/
│       └── database.js
└── package.json
```

**src/app.js**
```javascript
const express = require('express');
const userRoutes = require('./routes/users');

const app = express();
app.use(express.json());
app.use('/api/users', userRoutes);

app.listen(3000, () => {
    console.log('Server running on port 3000');
});
```

**src/routes/users.js**
```javascript
const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

router.get('/', userController.getAll);
router.get('/:id', userController.getById);

module.exports = router;
```

**src/controllers/userController.js**
```javascript
exports.getAll = (req, res) => {
    res.json({ users: ['John', 'Jane'] });
};

exports.getById = (req, res) => {
    const { id } = req.params;
    res.json({ user: `User ${id}` });
};
```

**package.json**
```json
{
  "name": "express-api",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.18.0"
  }
}
```
````

**Execute:**

```bash
./MD_to_Files.sh express_api.md ./my-api
cd my-api/express-api
npm install
node src/app.js
```

### Example 3: Python Course

````markdown
# Python Course

## Lesson 1

```
lesson-1/
├── hello.py
└── README.md
```

**hello.py**
```python
print("Hello, World!")
```

**README.md**
```markdown
# Lesson 1: Hello World
Your first Python program.
```

## Lesson 2

```
lesson-2/
├── variables.py
└── README.md
```

**variables.py**
```python
name = "Student"
age = 20
print(f"Name: {name}, Age: {age}")
```

**README.md**
```markdown
# Lesson 2: Variables
Working with variables in Python.
```
````

**Execute:**

```bash
./MD_to_Files.sh -a python_course.md ./course-materials
```

### Example 4: Updating Existing Project

```bash
# 1. Create backup
cp -r ./my-project ./my-project.backup

# 2. Run update with backups
./MD_to_Files.sh -U -b -v improvements.md ./my-project

# 3. Verify changes
diff -r ./my-project ./my-project.backup

# 4. Rollback if needed
rm -rf ./my-project
mv ./my-project.backup ./my-project
```

---

## 🔗 Integration

### Git Hooks

**Pre-commit Hook for Validation:**

```bash
#!/bin/bash
# .git/hooks/pre-commit

for md_file in $(git diff --cached --name-only | grep '\.md$'); do
    if [[ -f "$md_file" ]]; then
        if ! ./tools/MD_to_Files.sh -d "$md_file" /tmp/test &>/dev/null; then
            echo "❌ Invalid structure in $md_file"
            exit 1
        fi
    fi
done

echo "✅ All Markdown structures are valid"
```

### GitHub Actions

```yaml
name: Generate Project Structure

on:
  push:
    paths:
      - 'docs/project-structure.md'

jobs:
  generate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Generate project files
        run: |
          chmod +x ./tools/MD_to_Files.sh
          ./tools/MD_to_Files.sh -P docs/project-structure.md ./generated
          
      - name: Commit generated files
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add generated/
          git commit -m "Auto-generate project structure" || true
          git push
```

### GitLab CI

```yaml
generate-structure:
  script:
    - chmod +x ./tools/MD_to_Files.sh
    - ./tools/MD_to_Files.sh -P docs/structure.md ./output
  artifacts:
    paths:
      - output/
  only:
    changes:
      - docs/structure.md
```

### VS Code Task

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Generate from Markdown",
      "type": "shell",
      "command": "./tools/MD_to_Files.sh",
      "args": [
        "${file}",
        "${workspaceFolder}/generated"
      ],
      "presentation": {
        "reveal": "always"
      }
    }
  ]
}
```

### Makefile

```makefile
.PHONY: generate update clean test

MD2FILES := ./tools/MD_to_Files.sh
INPUT := docs/structure.md
OUTPUT := ./generated

generate:
	$(MD2FILES) -P $(INPUT) $(OUTPUT)

update:
	$(MD2FILES) -U -b $(INPUT) $(OUTPUT)

clean:
	rm -rf $(OUTPUT)

test:
	$(MD2FILES) -d $(INPUT) $(OUTPUT)
```

### AI Assistant Integration

**Optimized Prompt for ChatGPT/Claude:**

```
Create a project structure for [project description].
Use the following format for MD_to_Files.sh:

# Project Name

## Project Structure
```
project-name/
├── src/
│   └── main.js
└── package.json
```

## Implementation

**src/main.js**
```javascript
// code
```

**package.json**
```json
{
  "name": "project-name"
}
```

Ensure that:
- Tree uses Unicode box-drawing characters (├─└│)
- Directories end with /
- Files are marked with bold: **path/to/file.ext**
- Code blocks use triple backticks with language identifier
```

---

## 🔧 Troubleshooting

### Common Issues

#### Error: "No tree structures found"

**Cause:** Markdown doesn't contain recognizable directory tree.

**Solution:**

```bash
# ✓ Correct
├── src/
│   └── file.js

# ✗ Incorrect
- src/
  - file.js
```

#### Error: "Permission denied"

**Cause:** No write permissions.

**Solution:**

```bash
# Check permissions
ls -la target_directory

# Adjust permissions
chmod 755 target_directory
```

#### Error: "File encoding not supported"

**Cause:** Unsupported file encoding.

**Solution:**

```bash
# Detect encoding
file -i problem_file.md

# Convert to UTF-8
iconv -f WINDOWS-1252 -t UTF-8 problem_file.md > fixed_file.md
```

### Diagnostics

```bash
# Verbose output with logging
./MD_to_Files.sh -v -l debug.log structure.md ./output

# Search for errors in log
grep -E "(ERROR|WARNING)" debug.log

# Dry-run for verification
./MD_to_Files.sh -d -v structure.md ./test
```

### FAQ

<details>
<summary><b>Q: Why isn't code being extracted to files?</b></summary>

A: Verify file markers:

```markdown
# ✓ Correct
**src/app.js**
```javascript
code
```

# ✗ Incorrect
src/app.js  # Missing bold formatting
```javascript
code
```
```
</details>

<details>
<summary><b>Q: How to process multiple structures?</b></summary>

A: Use batch mode:

```bash
./MD_to_Files.sh -a multi_structures.md ./output
```
</details>

<details>
<summary><b>Q: Can I update only specific files?</b></summary>

A: Yes, use update mode:

```bash
./MD_to_Files.sh -U specific_files.md ./existing-project
```
</details>

<details>
<summary><b>Q: Are binary files supported?</b></summary>

A: No, only text files. Binary files must be added manually.
</details>

<details>
<summary><b>Q: How does it work on Windows?</b></summary>

A: Use WSL (Windows Subsystem for Linux) or Cygwin:

```powershell
# In WSL
wsl bash MD_to_Files.sh structure.md ./output
```
</details>

---

## 📚 Documentation

### Comprehensive Guides

- 📖 [Complete User Guide](docs/USER_GUIDE.md)
- 🏗️ [Architecture & Logic](docs/ARCHITECTURE.md)
- 🔌 [Integration & Automation](docs/INTEGRATION.md)
- 💡 [Best Practices](docs/BEST_PRACTICES.md)
- 🐛 [Troubleshooting Guide](docs/TROUBLESHOOTING.md)

### Additional Resources

- [CHANGELOG](CHANGELOG.md) — Version history
- [CODE_OF_CONDUCT](CODE_OF_CONDUCT.md) — Community guidelines
- [CONTRIBUTING](CONTRIBUTING.md) — Contribution guide
- [LICENSE](LICENSE) — MIT License

### Templates

- [Express API Template](templates/express-api.md)
- [React App Template](templates/react-app.md)
- [Python Project Template](templates/python-project.md)
- [Node.js CLI Template](templates/nodejs-cli.md)

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### Ways to Contribute

1. 🐛 **Report Bugs** — open an [issue](https://github.com/paulmann/1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures/issues)
2. 💡 **Suggest Features** — create a feature request
3. 📝 **Improve Documentation** — fix typos, add examples
4. 💻 **Submit Pull Requests** — bug fixes and new features

### Contribution Process

```bash
# 1. Fork the repository
# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures.git

# 3. Create feature branch
git checkout -b feature/amazing-feature

# 4. Make changes and commit
git commit -m "Add amazing feature"

# 5. Push to your fork
git push origin feature/amazing-feature

# 6. Open Pull Request
```

### Code Standards

- Use ShellCheck for script validation
- Comment complex logic
- Follow existing code style
- Update documentation for new features
- Add tests for new functionality

### Testing

```bash
# Run tests
./tests/run_tests.sh

# Run ShellCheck
shellcheck MD_to_Files.sh
```

---

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Paul Mann

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 📞 Contact

### Author

**Mikhail Deynekin**
- 🌐 Website: [deynekin.com](https://deynekin.com)
- 📧 Email: [mid1977@gmail.com](mailto:mid1977@gmail.com)
- 💼 LinkedIn: [linkedin.com/in/mikhail-deynekin](https://linkedin.com/in/mikhail-deynekin)

### Project

- 🐙 **GitHub:** [1st-Launch-Projects-Code-from-LLM](https://github.com/paulmann/1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures)
- 🐛 **Issues:** [Report a Problem](https://github.com/paulmann/1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures/issues)
- 💬 **Discussions:** [Join Discussions](https://github.com/paulmann/1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures/discussions)

---

## 🌟 Support the Project

If MD_to_Files.sh has helped you:

- ⭐ Star the repository on GitHub
- 🐦 Share the project on social media
- 📝 Write an article or tutorial

---

## 🙏 Acknowledgments

Thanks to everyone who contributed to this project:

- [@paulmann](https://github.com/paulmann) — original author
- All contributors — thank you for your Pull Requests
- The community — for feedback and suggestions

### Related Projects

- [Clean_BOM_Senior](https://github.com/paulmann/Clean_BOM_Senior) — Remove BOM from PHP files

---

## 📈 Statistics

![GitHub stars](https://img.shields.io/github/stars/paulmann/1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures?style=social)
![GitHub forks](https://img.shields.io/github/forks/paulmann/1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/paulmann/1st-Launch-Projects-Code-from-LLM-Responses-in-Markdown-into-Actual-File-Structures?style=social)

---

<div align="center">

**[⬆ Back to Top](#md_to_filessh)**

Made with ❤️ for the developer community

**Happy Coding! 🚀**

</div>
