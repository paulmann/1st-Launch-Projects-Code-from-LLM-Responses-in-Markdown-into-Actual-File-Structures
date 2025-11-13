#!/usr/bin/env bash
################################################################################
# MD to Files: LLM Code Projector v6.0.1
#
# Author: Mikhail Deynekin (https://deynekin.com)
# Email: mid1977@gmail.com
# Date: 2025-10-31
# License: MIT
#
# Compatibility: bash 4.2+
# Requirements: standard Unix tools (mkdir, find, grep, sed)
#
# Usage:
# ./MD_to_Files.sh [OPTIONS] INPUT_FILE [TARGET_DIR]
################################################################################
set -euo pipefail
IFS=$'\n\t'
# ============================================================================
# CONFIGURATION & CONSTANTS
# ============================================================================
readonly SCRIPT_VERSION="6.0.1"
readonly SCRIPT_AUTHOR="Mikhail Deynekin"
readonly MIN_BASH_VERSION=4
# Terminal colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'
# Configuration flags
VERBOSE=false
DRY_RUN=false
FORCE_OVERWRITE=false
BACKUP_EXISTING=false
EXTRACT_CODE=true
UPDATE_MODE=false
FIND_ALL_STRUCTURES=false
INTERACTIVE_MODE=false
PROJECT_MODE="create"
# File operations
LOG_FILE=""
declare -a TEMP_FILES=()
# Extracted data storage
declare -A CODE_BLOCKS=()
declare -A TREE_STRUCTURES=()
# Statistics
STATS_LINES_PROCESSED=0
STATS_DIRS_CREATED=0
STATS_FILES_CREATED=0
STATS_FILES_WITH_CODE=0
STATS_BLOCKS_EXTRACTED=0
STATS_FILES_UPDATED=0
# ============================================================================
# SIGNAL HANDLING & CLEANUP
# ============================================================================
handle_signal() {
    log_err "Script interrupted by user"
    cleanup
    exit 130
}
cleanup() {
    local file
    if [[ -v TEMP_FILES[@] ]]; then
        for file in "${TEMP_FILES[@]:-}"; do
            if [[ -f "$file" ]]; then
                rm -f "$file" 2>/dev/null || true
            fi
        done
    fi
}
trap cleanup EXIT
trap handle_signal INT TERM
# ============================================================================
# BASH VERSION CHECK
# ============================================================================
check_bash_version() {
    if [[ ${BASH_VERSINFO[0]} -lt ${MIN_BASH_VERSION} ]]; then
        printf "%b\n" "${RED}ERROR: Bash ${MIN_BASH_VERSION}.0+ required (current: ${BASH_VERSION})${NC}" >&2
        exit 1
    fi
}
# ============================================================================
# LOGGING SYSTEM
# ============================================================================
log_info() {
    printf "%b\n" "${GREEN}ℹ️  INFO${NC} $*" >&2
    if [[ -v LOG_FILE ]] && [[ -n "$LOG_FILE" ]]; then
        printf "[INFO] %s\n" "$*" >> "$LOG_FILE"
    fi
}
log_warn() {
    printf "%b\n" "${YELLOW}⚠️  WARN${NC} $*" >&2
    if [[ -v LOG_FILE ]] && [[ -n "$LOG_FILE" ]]; then
        printf "[WARN] %s\n" "$*" >> "$LOG_FILE"
    fi
}
log_err() {
    printf "%b\n" "${RED}❌ ERROR${NC} $*" >&2
    if [[ -v LOG_FILE ]] && [[ -n "$LOG_FILE" ]]; then
        printf "[ERROR] %s\n" "$*" >> "$LOG_FILE"
    fi
}
log_ok() {
    printf "%b\n" "${GREEN}✅ OK${NC} $*" >&2
    if [[ -v LOG_FILE ]] && [[ -n "$LOG_FILE" ]]; then
        printf "[OK] %s\n" "$*" >> "$LOG_FILE"
    fi
}
log_debug() {
    if [[ "$VERBOSE" == true ]]; then
        printf "%b\n" "${BLUE}🔵 DEBUG${NC} $*" >&2
        if [[ -v LOG_FILE ]] && [[ -n "$LOG_FILE" ]]; then
            printf "[DEBUG] %s\n" "$*" >> "$LOG_FILE"
        fi
    fi
}
log_progress() {
    printf "%b\n" "${CYAN}⏳ PROGRESS${NC} $*" >&2
    if [[ -v LOG_FILE ]] && [[ -n "$LOG_FILE" ]]; then
        printf "[PROGRESS] %s\n" "$*" >> "$LOG_FILE"
    fi
}
# ============================================================================
# HELP & VERSION
# ============================================================================
show_help() {
    cat << 'EOF'
MD to Files: LLM Code Projector v5.1.9
Professional-grade LLM markdown-to-project converter
USAGE:
  MD_to_Files.sh [OPTIONS] INPUT_FILE [TARGET_DIR]
OPTIONS:
  -h, --help              Show this help message
  -v, --verbose           Enable verbose debug output
  -V, --version           Show version information
  -d, --dry-run           Simulate without making changes
  -f, --force             Overwrite existing files without prompting
  -b, --backup            Backup existing files before overwriting
  -l, --log FILE          Write detailed log to specified file
  -C, --no-code           Don't extract code from markdown
  -U, --update            Update mode: find existing files and update with LLM content
  -P, --project           Project mode: enhanced creation with README and project info
  -a, --all               Process ALL project structures found
  -i, --interactive       Ask user to select structure (interactive)
MODES:
  Create (default)        Creates new project structure from LLM response
  Update (-U)             Updates existing files with content from LLM response
  Project (-P)            Enhanced creation with project metadata
ARGUMENTS:
  INPUT_FILE              Markdown file with LLM response
  TARGET_DIR              Where to create project (default: current dir)
EXAMPLES:
  ./MD_to_Files.sh README.md ./myproject
  ./MD_to_Files.sh -vb response.md ~/projects/app
  ./MD_to_Files.sh -d README.md ./test
  ./MD_to_Files.sh -U -f response.md ~/existing_project
EOF
}
show_version() {
    cat << EOF
MD to Files v${SCRIPT_VERSION}
Author: ${SCRIPT_AUTHOR}
License: MIT
Bash: ${BASH_VERSION}
Transform LLM conversations into working code projects!
EOF
}
# ============================================================================
# ARGUMENT PARSING
# ============================================================================
parse_arguments() {
    local input_file=""
    local target_dir="."
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                printf "%s\n" "--help"
                return 0
                ;;
            -V|--version)
                printf "%s\n" "--version"
                return 0
                ;;
            -v|--verbose)
                VERBOSE=true
                ;;
            -d|--dry-run)
                DRY_RUN=true
                log_info "Dry-run mode enabled"
                ;;
            -f|--force)
                FORCE_OVERWRITE=true
                ;;
            -b|--backup)
                BACKUP_EXISTING=true
                ;;
            -l|--log)
                if [[ -z "${2:-}" ]]; then
                    log_err "Log file path not specified"
                    exit 1
                fi
                LOG_FILE="$2"
                shift
                ;;
            -C|--no-code)
                EXTRACT_CODE=false
                ;;
            -U|--update)
                UPDATE_MODE=true
                PROJECT_MODE="update"
                ;;
            -P|--project)
                PROJECT_MODE="project"
                ;;
            -a|--all)
                FIND_ALL_STRUCTURES=true
                ;;
            -i|--interactive)
                INTERACTIVE_MODE=true
                FIND_ALL_STRUCTURES=true
                ;;
            -*)
                log_err "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                if [[ -z "$input_file" ]]; then
                    input_file="$1"
                else
                    target_dir="$1"
                fi
                ;;
        esac
        shift
    done
    # Validation
    if [[ -z "$input_file" ]]; then
        log_err "Input file not specified"
        show_help
        exit 1
    fi
    if [[ ! -f "$input_file" ]]; then
        log_err "Input file not found: $input_file"
        exit 1
    fi
    if [[ ! -r "$input_file" ]]; then
        log_err "Cannot read input file: $input_file"
        exit 1
    fi
    if [[ ! -s "$input_file" ]]; then
        log_err "Input file is empty: $input_file"
        exit 1
    fi
    if [[ ! -d "$target_dir" ]]; then
        if ! mkdir -p "$target_dir" 2>/dev/null; then
            log_err "Cannot create target directory: $target_dir"
            exit 1
        fi
    fi
    if [[ ! -w "$target_dir" ]]; then
        log_err "Cannot write to target directory: $target_dir"
        exit 1
    fi
    printf "%s\t%s\n" "$input_file" "$target_dir"
}
# ============================================================================
# ENCODING DETECTION & HANDLING
# ============================================================================
detect_encoding() {
    local file="$1"
    if ! command -v file >/dev/null 2>&1; then
        log_debug "file command not available, assuming UTF-8"
        printf "UTF-8\n"
        return 0
    fi
    local encoding_info
    encoding_info=$(file -b --mime-encoding "$file" 2>/dev/null || printf "unknown")
    log_debug "Detected encoding: $encoding_info"
    case "$encoding_info" in
        *utf-8*|*ascii*)
            printf "UTF-8\n"
            ;;
        *iso-8859-1*|*windows-1252*|*cp1252*)
            printf "WINDOWS-1252\n"
            ;;
        *)
            log_warn "Unknown encoding: $encoding_info, assuming UTF-8"
            printf "UTF-8\n"
            ;;
    esac
}
ensure_utf8() {
    local input_file="$1"
    local encoding
    local temp_file
    encoding=$(detect_encoding "$input_file")
    if [[ "$encoding" == "UTF-8" ]]; then
        printf "%s\n" "$input_file"
        return 0
    fi
    if ! command -v iconv >/dev/null 2>&1; then
        log_warn "iconv not available, using original file"
        printf "%s\n" "$input_file"
        return 0
    fi
    temp_file=$(mktemp) || {
        log_warn "Cannot create temp file, using original"
        printf "%s\n" "$input_file"
        return 0
    }
    TEMP_FILES+=("$temp_file")
    if iconv -f "$encoding" -t UTF-8//TRANSLIT "$input_file" > "$temp_file" 2>/dev/null; then
        log_info "Converted file from $encoding to UTF-8"
        printf "%s\n" "$temp_file"
        return 0
    else
        log_warn "Failed to convert encoding, using original file"
        rm -f "$temp_file"
        printf "%s\n" "$input_file"
        return 0
    fi
}
# ============================================================================
# PATH HANDLING
# ============================================================================
get_absolute_path() {
    local path="$1"
    local dir
    local file
    if command -v readlink >/dev/null 2>&1; then
        if readlink -f "$path" 2>/dev/null; then
            return 0
        fi
    fi
    if [[ -d "$path" ]]; then
        (cd "$path" && pwd)
    else
        dir=$(dirname "$path")
        file=$(basename "$path")
        if [[ -d "$dir" ]]; then
            printf "%s" "$(cd "$dir" && pwd)/$file"
        else
            printf "%s" "$path"
        fi
    fi
}
sanitize_path() {
    local path="$1"
    path=$(printf "%s" "$path" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    path=$(printf "%s" "$path" | sed 's/\[[0-9;]*m//g')
    path=$(printf "%s" "$path" | tr -d '<>:"|?*')
    path=$(printf "%s" "$path" | sed 's|/\+|/|g')
    path="${path#./}"
    path="${path#/}"
    while [[ "$path" =~ ^\.\./ ]]; do
        path="${path#../}"
    done
    if [[ ${#path} -gt 255 ]]; then
        path="${path:0:255}"
        log_warn "Path truncated to 255 characters"
    fi
    printf "%s" "$path"
}
# ============================================================================
# CODE EXTRACTION
# ============================================================================
extract_code_blocks() {
    local input_file="$1"
    local in_code_block=0
    local current_file=""
    local current_content=""
    local lang=""
    local line_num=0
    local skip_next_line=false
    local deepseek_format=false
    local last_header=""
    
    log_progress "Extracting code blocks from markdown..."
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        ((line_num++))
        line="${line%$'\r'}"
        
        # Save headers for context
        if [[ "$line" =~ ^#[#]?[[:space:]]+(.+) ]]; then
            last_header="${BASH_REMATCH[1]}"
            log_debug "Line $line_num: Found header: $last_header"
        fi
        
        # Check for code block start/end
        if [[ "$line" =~ ^[[:space:]]*\`\`\`([a-zA-Z0-9+]*) ]]; then
            if [[ $in_code_block -eq 0 ]]; then
                in_code_block=1
                lang="${BASH_REMATCH[1]}"
                current_content=""
                current_file=""
                skip_next_line=false
                deepseek_format=false
                log_debug "Line $line_num: Opening code block (language: $lang)"
            else
                in_code_block=0
                if [[ -n "$current_file" ]] && [[ -n "$current_content" ]]; then
                    # Remove the file marker line from content
                    if [[ "$deepseek_format" == true ]]; then
                        current_content="${current_content#*$'\n'}"
                    fi
                    current_content="${current_content%$'\n'}"
                    CODE_BLOCKS["$current_file"]="$current_content"
                    ((STATS_BLOCKS_EXTRACTED++))
                    log_debug "Line $line_num: Saved code block '$current_file' (${#current_content} bytes)"
                elif [[ -n "$current_content" ]] && [[ -n "$last_header" ]]; then
                    # Try to extract filename from header as fallback
                    local extracted_file=""
                    if [[ "$last_header" =~ ([a-zA-Z0-9_~./-]+\.[a-zA-Z0-9]+) ]]; then
                        extracted_file="${BASH_REMATCH[1]}"
                    elif [[ "$last_header" =~ ([a-zA-Z0-9_~./-]+\/[a-zA-Z0-9_~./-]+\.[a-zA-Z0-9]+) ]]; then
                        extracted_file="${BASH_REMATCH[1]}"
                    fi
                    
                    if [[ -n "$extracted_file" ]]; then
                        current_content="${current_content%$'\n'}"
                        CODE_BLOCKS["$extracted_file"]="$current_content"
                        ((STATS_BLOCKS_EXTRACTED++))
                        log_debug "Line $line_num: Saved code block from header '$extracted_file'"
                    fi
                fi
                current_file=""
                current_content=""
                lang=""
                skip_next_line=false
                deepseek_format=false
            fi
            continue
        fi
        
        if [[ $in_code_block -eq 1 ]]; then
            # Look for file name markers in ANY format at the beginning of code block
            
            # Old format: // [file name]: path/to/file
            if [[ -z "$current_file" ]] && [[ "$line" =~ ^[[:space:]]*(\/\/|#|--|REM)[[:space:]]*\[file[[:space:]]name\]:[[:space:]]*(.+) ]]; then
                current_file=$(printf "%s\n" "${BASH_REMATCH[2]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                current_file="${current_file#/}"
                log_debug "Line $line_num: Found file reference (old format): $current_file"
                skip_next_line=true
                continue
            fi
            
            # DeepSeek format 1: path/to/file (as first line after code block start)
            if [[ -z "$current_file" ]] && [[ -z "$current_content" ]]; then
                # Try to detect file path in first line
                local potential_file=$(printf "%s\n" "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                
                # Check if it looks like a file path (has extension or is in common directories)
                if [[ "$potential_file" =~ ^[a-zA-Z0-9_~./-]+\.[a-zA-Z0-9]+$ ]] ||
                   [[ "$potential_file" =~ ^(src|config|lang|templates|assets|api)/ ]] ||
                   [[ "$potential_file" =~ ^/[a-zA-Z0-9_~./-]+ ]] ||
                   [[ "$potential_file" =~ \.(php|js|css|html|md|json|sql|txt|sh|py|java|c|cpp|xml|yaml|yml)$ ]]; then
                    
                    # Skip common false positives
                    if [[ ! "$potential_file" =~ ^(Структура проекта:|Основные исправления:|[0-9]+\.[0-9]+|[#]+) ]] &&
                       [[ ! "$potential_file" =~ ^(├|└|│) ]] &&
                       [[ ${#potential_file} -lt 100 ]]; then
                        
                        current_file="$potential_file"
                        current_file="${current_file#/}"
                        deepseek_format=true
                        log_debug "Line $line_num: Found file reference (DeepSeek format): $current_file"
                        skip_next_line=true
                        continue
                    fi
                fi
            fi
            
            # If we have a file reference, collect content (skip the marker line)
            if [[ -n "$current_file" ]]; then
                if [[ "$skip_next_line" == true ]]; then
                    skip_next_line=false
                    continue
                fi
                current_content+="$line"$'\n'
            else
                # If no file reference found yet, still collect content (might be determined from header later)
                current_content+="$line"$'\n'
            fi
        fi
    done < "$input_file"
    
    # Handle final block if still open
    if [[ $in_code_block -eq 1 ]] && [[ -n "$current_content" ]]; then
        if [[ -n "$current_file" ]]; then
            if [[ "$deepseek_format" == true ]]; then
                current_content="${current_content#*$'\n'}"
            fi
            current_content="${current_content%$'\n'}"
            CODE_BLOCKS["$current_file"]="$current_content"
            ((STATS_BLOCKS_EXTRACTED++))
            log_debug "Saved final code block: $current_file"
        elif [[ -n "$last_header" ]]; then
            # Try to extract filename from header as fallback for the last block
            local extracted_file=""
            if [[ "$last_header" =~ ([a-zA-Z0-9_~./-]+\.[a-zA-Z0-9]+) ]]; then
                extracted_file="${BASH_REMATCH[1]}"
            elif [[ "$last_header" =~ ([a-zA-Z0-9_~./-]+\/[a-zA-Z0-9_~./-]+\.[a-zA-Z0-9]+) ]]; then
                extracted_file="${BASH_REMATCH[1]}"
            fi
            
            if [[ -n "$extracted_file" ]]; then
                current_content="${current_content%$'\n'}"
                CODE_BLOCKS["$extracted_file"]="$current_content"
                ((STATS_BLOCKS_EXTRACTED++))
                log_debug "Saved final code block from header '$extracted_file'"
            fi
        fi
    fi
    
    if [[ ${#CODE_BLOCKS[@]} -gt 0 ]]; then
        log_ok "Extracted ${#CODE_BLOCKS[@]} code block(s)"
        # Debug: show extracted files
        log_debug "Extracted files:"
        for file in "${!CODE_BLOCKS[@]}"; do
            log_debug "  - $file"
        done
        return 0
    else
        log_warn "No code blocks with file markers found"
        return 1
    fi
}
# ============================================================================
# CREATE STRUCTURE FROM CODE BLOCKS
# ============================================================================
create_structure_from_code_blocks() {
    local target_dir="$1"
    local created_dirs=0
    local created_files=0
    
    log_progress "Creating project structure from code blocks..."
    
    # First, create all directories
    for file_path in "${!CODE_BLOCKS[@]}"; do
        local dir_path
        dir_path=$(dirname "$file_path")
        if [[ "$dir_path" != "." ]] && [[ "$dir_path" != "/" ]]; then
            local full_dir_path="${target_dir%/}/${dir_path}"
            if create_directory "$full_dir_path"; then
                ((created_dirs++))
            fi
        fi
    done
    
    # Then, create all files with content
    for file_path in "${!CODE_BLOCKS[@]}"; do
        local full_file_path="${target_dir%/}/${file_path}"
        local file_content="${CODE_BLOCKS[$file_path]}"
        
        if create_file "$full_file_path" "$file_content"; then
            ((created_files++))
        fi
    done
    
    log_ok "Structure from code blocks completed:"
    log_info " Directories: $created_dirs | Files: $created_files"
    return 0
}
# ============================================================================
# TREE STRUCTURE DETECTION (ОСТАВЛЯЕМ ДЛЯ СОВМЕСТИМОСТИ, НО НЕ ИСПОЛЬЗУЕМ)
# ============================================================================
find_tree_structures() {
    local input_file="$1"
    # Игнорируем дерево структуры, используем только code blocks
    log_info "Ignoring tree structures, using code blocks only"
    
    # Создаем фиктивную структуру для совместимости
    TREE_STRUCTURES[1]="project/"
    for file_path in "${!CODE_BLOCKS[@]}"; do
        TREE_STRUCTURES[1]+=$'\n'"├── $file_path"
    done
    
    log_ok "Using code blocks structure with ${#CODE_BLOCKS[@]} files"
    return 0
}
# ============================================================================
# INTERACTIVE SELECTION
# ============================================================================
select_tree_interactive() {
    printf "1\n"
    return 0
}
# ============================================================================
# PROJECT METADATA
# ============================================================================
create_project_metadata() {
    local target_dir="$1"
    local input_file="$2"
    if [[ "$PROJECT_MODE" != "project" ]] || [[ "$DRY_RUN" == true ]]; then
        return 0
    fi
    log_progress "Creating project metadata files..."
    local project_name
    local current_date
    project_name=$(basename "$target_dir")
    current_date=$(date '+%Y-%m-%d')
    local readme_file="${target_dir}/README.md"
    if [[ ! -f "$readme_file" ]] || [[ "$FORCE_OVERWRITE" == true ]]; then
        cat > "$readme_file" << EOF
# ${project_name}
Project generated from LLM response using LLM Code Projector.
## Source
- **LLM Response**: $(basename "$input_file")
- **Generated**: ${current_date}
- **Tool**: LLM Code Projector v${SCRIPT_VERSION}
## Project Structure
This project was automatically generated from an AI assistant response.
## Getting Started
[Add your project-specific instructions here]
## License
[Specify your license here]
EOF
        log_ok "Created project README: $readme_file"
    fi
    local meta_file="${target_dir}/.llm-projector"
    cat > "$meta_file" << EOF
# LLM Projector Metadata
version=${SCRIPT_VERSION}
source_file=$(basename "$input_file")
generated_date=${current_date}
project_mode=${PROJECT_MODE}
EOF
    log_ok "Project metadata created"
}
# ============================================================================
# FILE OPERATIONS
# ============================================================================
backup_file() {
    local file_path="$1"
    if [[ "$BACKUP_EXISTING" != true ]] || [[ ! -f "$file_path" ]]; then
        return 0
    fi
    local backup_path="${file_path}.bak.$(date +%Y%m%d_%H%M%S)"
    if cp "$file_path" "$backup_path" 2>/dev/null; then
        log_info "Backed up: $(basename "$file_path")"
        return 0
    else
        log_warn "Failed to backup: $file_path"
        return 1
    fi
}
create_directory() {
    local dir_path="$1"
    if [[ -d "$dir_path" ]]; then
        log_debug "Directory exists: $dir_path"
        return 0
    fi
    if [[ -e "$dir_path" ]] && [[ ! -d "$dir_path" ]]; then
        log_warn "Path exists but is not a directory: $dir_path"
        return 1
    fi
    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] mkdir -p '$dir_path'"
        return 0
    fi
    if mkdir -p "$dir_path" 2>/dev/null; then
        log_info "Created directory: $dir_path"
        ((STATS_DIRS_CREATED++))
        return 0
    else
        log_err "Failed to create directory: $dir_path"
        return 1
    fi
}
create_file() {
    local file_path="$1"
    local file_content="${2:-}"
    local dir_path
    dir_path=$(dirname "$file_path")
    if [[ ! -d "$dir_path" ]]; then
        if ! create_directory "$dir_path"; then
            return 1
        fi
    fi
    if [[ -f "$file_path" ]]; then
        if [[ "$FORCE_OVERWRITE" != true ]]; then
            log_warn "File exists, skipping: $file_path"
            return 1
        fi
        backup_file "$file_path"
        log_info "Overwriting: $file_path"
    elif [[ -e "$file_path" ]]; then
        log_warn "Path exists but is not a file: $file_path"
        return 1
    fi
    if [[ "$DRY_RUN" == true ]]; then
        if [[ -n "$file_content" ]]; then
            log_info "[DRY-RUN] create: $file_path (${#file_content} bytes)"
        else
            log_info "[DRY-RUN] create empty: $file_path"
        fi
        return 0
    fi
    if [[ -n "$file_content" ]]; then
        if printf "%s" "$file_content" > "$file_path" 2>/dev/null; then
            log_ok "Created with content: $file_path (${#file_content} bytes)"
            ((STATS_FILES_CREATED++))
            ((STATS_FILES_WITH_CODE++))
            return 0
        else
            log_err "Failed to create file: $file_path"
            return 1
        fi
    else
        if touch "$file_path" 2>/dev/null; then
            log_info "Created empty: $file_path"
            ((STATS_FILES_CREATED++))
            return 0
        else
            log_err "Failed to create file: $file_path"
            return 1
        fi
    fi
}
# ============================================================================
# UPDATE MODE - FIND AND UPDATE EXISTING FILES
# ============================================================================
update_file() {
    local file_path="$1"
    local file_content="$2"
    if [[ ! -f "$file_path" ]]; then
        log_debug "File does not exist, skipping: $file_path"
        return 1
    fi
    if [[ "$FORCE_OVERWRITE" == true ]]; then
        backup_file "$file_path"
        log_info "Updating: $file_path"
    else
        local current_content
        current_content=$(cat "$file_path" 2>/dev/null || printf "")
        if [[ "$current_content" == "$file_content" ]]; then
            log_debug "Content unchanged: $file_path"
            return 1
        fi
        backup_file "$file_path"
        log_info "Updating modified: $file_path"
    fi
    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would update: $file_path (${#file_content} bytes)"
        return 0
    fi
    if printf "%s" "$file_content" > "$file_path" 2>/dev/null; then
        log_ok "Updated: $file_path"
        ((STATS_FILES_UPDATED++))
        return 0
    else
        log_err "Failed to update: $file_path"
        return 1
    fi
}
find_existing_files() {
    local target_dir="$1"
    local updated=0
    local skipped=0
    
    log_progress "Scanning for existing files in: $target_dir"
    
    for file_path in "${!CODE_BLOCKS[@]}"; do
        local full_file_path="${target_dir%/}/${file_path}"
        local file_content="${CODE_BLOCKS[$file_path]}"
        
        if [[ -f "$full_file_path" ]]; then
            if update_file "$full_file_path" "$file_content"; then
                ((updated++))
            else
                ((skipped++))
            fi
        fi
    done
    
    log_ok "Update scan completed: $updated updated, $skipped skipped"
    return $([[ $updated -gt 0 ]] && echo 0 || echo 1)
}
# ============================================================================
# MAIN FUNCTION
# ============================================================================
main() {
    check_bash_version
    local parsed_args
    parsed_args=$(parse_arguments "$@") || exit 1

    # Check for special tokens returned by parse_arguments
    if [[ "$parsed_args" == "--help" ]]; then
        show_help
        exit 0
    fi
    if [[ "$parsed_args" == "--version" ]]; then
        show_version
        exit 0
    fi

    # If we get here, it's a normal run. Parse the actual file and directory.
    local input_file target_dir
    input_file=$(printf "%s" "$parsed_args" | cut -f1)
    target_dir=$(printf "%s" "$parsed_args" | cut -f2)

    log_info "Input: $input_file"
    log_info "Target: $target_dir"

    local working_file
    working_file=$(ensure_utf8 "$input_file")

    if [[ "$EXTRACT_CODE" == true ]]; then
        extract_code_blocks "$working_file" || log_warn "No code blocks extracted"
    fi

    # Всегда используем структуру из code blocks, игнорируем дерево
    if [[ ${#CODE_BLOCKS[@]} -eq 0 ]]; then
        log_err "No code blocks found - cannot create project structure"
        exit 1
    fi

    printf "\n%b\n" "${CYAN}=== Creating Project Structure from Code Blocks ===${NC}"
    printf "%b\n" "${BLUE}Files to create:${NC}"
    for file_path in "${!CODE_BLOCKS[@]}"; do
        printf "  %s\n" "$file_path"
    done
    printf "\n"

    if [[ "$UPDATE_MODE" == true ]]; then
        if find_existing_files "$target_dir"; then
            log_ok "Update completed successfully"
        else
            log_warn "Update completed with warnings"
        fi
    else
        if create_structure_from_code_blocks "$target_dir"; then
            log_ok "Project structure created successfully"
        else
            log_warn "Project structure completed with warnings"
        fi
    fi

    if [[ "$PROJECT_MODE" == "project" ]] && [[ "$DRY_RUN" != true ]]; then
        create_project_metadata "$target_dir" "$input_file"
    fi

    printf "\n%b\n" "${GREEN}=== SUMMARY ===${NC}"
    if [[ "$UPDATE_MODE" == true ]]; then
        log_ok "Updated: $STATS_FILES_UPDATED files"
    else
        log_ok "Created: $STATS_FILES_CREATED files, $STATS_DIRS_CREATED directories"
    fi
    log_info "Code blocks: $STATS_BLOCKS_EXTRACTED extracted, $STATS_FILES_WITH_CODE applied"
    if [[ "$DRY_RUN" == true ]]; then
        printf "%b\n" "${YELLOW}⚠️  Dry-run mode: no files were actually created${NC}"
    else
        printf "%b\n" "${GREEN}✨ Project successfully created/updated!${NC}"
    fi
}
# ============================================================================
# ENTRY POINT
# ============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
