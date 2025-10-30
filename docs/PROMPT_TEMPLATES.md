# MD to Files Parser - Quick Prompt Injection

## Short Prompt (Copy-Paste Ready)

Use this as a suffix to any code generation request:

```
Format your response for MD to Files Parser (v5.1.3+):
- Start with complete project tree using ├──, │, └── symbols
- Wrap project tree in code block with ```text notation
- Each file's code block must have [file name]: path/to/file.ext as first line
- Use appropriate language identifiers (python, javascript, etc.)
- Include all required configuration and dependency files
- Provide clear setup instructions
```

---

## Medium Prompt (More Detailed)

Use this when you want to emphasize quality and completeness:

```
Please structure your code generation response for compatibility with MD to Files Parser:

1. PROJECT STRUCTURE: Display the complete directory tree at the beginning
   ```text
   project/
   ├── directory/
   │   └── file.ext
   └── config.json
   ```

2. CODE DELIVERY: Each file must be provided in a code block with:
   - Language identifier: ```python, ```javascript, etc.
   - File marker as first line: // [file name]: src/main.py
   - Complete, production-ready code with all imports
   - Documentation and error handling included

3. FILE MARKERS: Use exact format - [file name]: path/to/file.ext
   - Works with any comment style: //, #, --, REM
   - Place immediately after code fence
   - Use forward slashes for paths (works cross-platform)

4. COMPLETENESS: Include ALL files needed for project to run:
   - Configuration files (.env, .gitignore, etc.)
   - Dependency specifications (requirements.txt, package.json)
   - README with setup and usage instructions
   - Test files if applicable

This format enables automatic project structure generation via MD to Files script.
```

---

## Extended Prompt (Comprehensive)

For complex projects requiring precise specifications:

```
Generate [PROJECT_DESCRIPTION] with the following constraints:

## Quality Requirements
- Production-ready code with proper error handling
- Full docstrings and inline comments
- All dependencies explicitly listed
- Cross-platform compatible paths

## Response Format (MD to Files v5.1.3+)
Your response MUST follow this structure for automated project generation:

### 1. Executive Summary
Brief description of what will be built (2-3 sentences)

### 2. Project Structure
```text
project/
├── src/
│   ├── main.py
│   └── utils.py
├── tests/
│   └── test_main.py
├── requirements.txt
├── README.md
└── .gitignore
```

### 3. Implementation Details
For each file listed in the tree, provide:

**CODE BLOCK FORMAT**:
- Opening fence with language: ```python, ```javascript, etc.
- First line: [file name]: complete/path/to/file.ext
- Full file content with imports at top
- Closing fence: ```

Example structure:
```python
# [file name]: src/auth.py
"""Authentication module."""

import os
from typing import Optional

def authenticate(token: str) -> bool:
    """Validate authentication token."""
    return len(token) > 0
```

### 4. Dependencies
List all required packages with versions

### 5. Setup Instructions
Step-by-step guide for environment setup and running the project

### 6. Notes
Any important considerations or assumptions

## Critical Markers
[file name]: - Exact syntax, placed as first line in code blocks
├──, │, └── - Use for directory tree visualization
```python, ```js, etc. - Language identifiers for all code blocks

This format ensures MD to Files Parser can:
- Automatically extract file structure
- Create project directories
- Populate files with correct code
- Generate working projects in seconds
```

---

## Per-Language Prompt Variants

### Python Projects

```
Generate a Python [PROJECT] with MD to Files compatibility:

Format requirements:
- Tree in first code block with ```text fence
- Each .py file marked with: # [file name]: path/to/file.py
- Include setup.py or pyproject.toml
- Add requirements.txt with all dependencies
- Include docstrings (module, class, function level)
- Provide README.md with installation steps

Supported language markers: python, py
```

### JavaScript/Node Projects

```
Generate a JavaScript/Node [PROJECT] with MD to Files compatibility:

Format requirements:
- Tree in first code block with ```text fence  
- Each .js/.ts file marked with: // [file name]: path/to/file.js
- Include package.json with dependencies
- Add .gitignore and .env.example
- Include README.md with npm install and npm start instructions
- Provide TSconfig.json if using TypeScript

Supported language markers: javascript, js, typescript, ts
```

### Full-Stack Web Projects

```
Generate a full-stack web application with MD to Files compatibility:

Format requirements:
- Complete tree showing both frontend and backend
- Backend files marked with backend language comment: # [file name]: backend/path
- Frontend files marked with frontend language comment: // [file name]: frontend/path
- Include all config files (both frontend and backend)
- Separate requirements.txt (backend) and package.json (frontend)
- Provide comprehensive README with full setup instructions

Directory structure example:
```text
project/
├── backend/
│   ├── app.py
│   ├── requirements.txt
│   └── config.py
├── frontend/
│   ├── package.json
│   └── src/
│       └── App.jsx
└── README.md
```
```

### Docker Projects

```
Generate a Dockerized [PROJECT] with MD to Files compatibility:

Include in response:
- Dockerfile (marked as: # [file name]: Dockerfile)
- docker-compose.yml (marked as: # [file name]: docker-compose.yml)
- .dockerignore file
- Shell scripts for setup (marked as: # [file name]: scripts/setup.sh)
- Complete project tree showing all services
- Detailed README with Docker setup instructions

Tree example:
```text
project/
├── Dockerfile
├── docker-compose.yml
├── .dockerignore
├── app/
│   └── main.py
├── scripts/
│   └── setup.sh
└── README.md
```
```

---

## Prompt Injection for Existing Projects

### Template for Refactoring Existing Code

```
Refactor/improve my [EXISTING_PROJECT] with MD to Files compatibility:

Current structure:
[paste current structure]

Requirements:
[your requirements]

Format response for MD to Files Parser:
1. Show complete updated project tree
2. Each file in code block with [file name]: marker
3. Highlight what changed from original
4. Include migration/upgrade guide if needed
```

---

## System Prompt for Custom ChatGPT/Claude

Use this if you're setting up a persistent system prompt:

```
You are an expert code generator that produces responses optimized for automated processing by the MD to Files Parser (v5.1.3+).

When generating code projects, always:

1. START with a complete project tree in a code block:
   ```text
   project/
   ├── [files and folders]
   ```

2. DELIVER each file in a code block with:
   - Appropriate language identifier (python, javascript, etc.)
   - First line: [file name]: relative/path/to/file.ext
   - Complete, working code with all imports
   - Comments and docstrings

3. USE exact file marker format:
   - Syntax: [file name]: path/to/file.ext (required on first line)
   - No variations: must be exactly as specified
   - Works with any comment style: //, #, --, REM

4. INCLUDE all files:
   - Configuration (.env, .gitignore, config.json)
   - Dependencies (requirements.txt, package.json)
   - Documentation (README.md)
   - Tests if applicable

5. VERIFY quality:
   - All code is production-ready
   - No incomplete implementations
   - Error handling included
   - Cross-platform compatible

This format enables users to automatically generate working projects by piping your response through the MD to Files script.
```

---

## Integration Examples

### Use with curl/API

```bash
# Send prompt to API and save response
curl -X POST https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4",
    "messages": [
      {
        "role": "user",
        "content": "Generate a REST API with FastAPI. Format for MD to Files Parser: [include short prompt above]"
      }
    ]
  }' > response.md

# Process with MD to Files
./MD_to_Files_v5.1.3.sh response.md ./generated_project
```

### Use with Claude API

```bash
# Save prompt to file
cat > request.txt << 'EOF'
[Your project requirements]

Format for MD to Files Parser v5.1.3+:
[include appropriate prompt variant above]
EOF

# Send request and process
claude-cli request.txt > response.md
./MD_to_Files_v5.1.3.sh -v response.md ./project
```

### Use with Local LLM (Ollama)

```bash
# Simple request with formatting
ollama run llama2 "
Generate a Python CLI tool.

Format output for MD to Files Parser:
- Complete project tree at start
- Each file in code block with [file name]: marker
- Include requirements.txt
- Add README with setup steps
"
```

---

## Testing Your Prompts

### Quick Validation After Getting Response

```bash
#!/bin/bash
response_file="$1"

echo "Checking response format..."

# Check tree
grep -q "^project/" "$response_file" && echo "✓ Tree found" || echo "✗ Missing tree"

# Check markers
markers=$(grep -c "\[file name\]:" "$response_file" || echo "0")
echo "✓ Found $markers file markers"

# Check code blocks
blocks=$(grep -c "^\\`\\`\\`" "$response_file" || echo "0")
echo "✓ Found $((blocks/2)) code blocks"

# Try dry-run
./MD_to_Files_v5.1.3.sh -d "$response_file" /tmp/validate > /dev/null 2>&1
[ $? -eq 0 ] && echo "✓ Valid format" || echo "✗ Format errors"
```

---

## Common Prompt Patterns

### Pattern 1: Simple Project

```
Generate a [PROJECT_TYPE] with these features: [list].

Format for MD to Files v5.1.3+:
- Show project tree
- Each file in code block with [file name]: marker
- Include requirements and setup
```

**Best for**: Small utilities, simple scripts, proof-of-concepts

### Pattern 2: Full Application

```
Design a [APPLICATION] that [requirements].

Must include:
- Complete project structure (tree format)
- All source files with [file name]: markers
- Configuration and deployment files  
- Comprehensive README

Format for MD to Files Parser v5.1.3+
```

**Best for**: Web apps, APIs, microservices

### Pattern 3: Refactoring

```
Refactor [EXISTING] to improve [GOALS].

Show:
- Updated project tree
- Modified files with [file name]: markers
- What changed (add comments)
- Migration guide

Optimize for MD to Files v5.1.3+
```

**Best for**: Code improvements, restructuring

### Pattern 4: Documentation

```
Create code with embedded documentation:
- Docstrings in all modules
- Inline comments for complex logic
- README with examples
- Setup instructions

Format for MD to Files v5.1.3+
```

**Best for**: Libraries, SDKs, frameworks

---

## Troubleshooting Prompts

### If parser doesn't recognize structure

Add to your prompt:
```
IMPORTANT: Ensure your tree starts with "project/" and uses these exact symbols:
├── (intermediate branch)
│  (vertical line)
└── (last branch)

All code blocks must have [file name]: on the first line.
```

### If files are missing

Add to your prompt:
```
CRITICAL: Include ALL files in the tree:
- Every source file
- Configuration files (.env, .gitignore, etc.)
- Package/dependency files (requirements.txt, package.json)
- Documentation (README.md)
- Tests if applicable

Missing files from tree but included in code will not be created.
```

### If wrong content in files

Add to your prompt:
```
Verify that:
1. Each code block has correct language identifier
2. [file name]: marker matches the actual file path
3. No code fragments - provide complete files
4. All imports and dependencies included
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-10-30 | Initial prompts and variants |

---

*Last Updated: 2025-10-30*  
*Compatible with: MD to Files v5.1.3+*

