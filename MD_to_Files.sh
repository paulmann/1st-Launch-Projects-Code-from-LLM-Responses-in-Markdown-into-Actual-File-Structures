#!/usr/bin/env bash
################################################################################
# MD to Files: LLM Code Projector v5.1.9
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
readonly SCRIPT_VERSION="5.1.9"
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
                # Return a special token to indicate help was requested
                printf "%s\n" "--help"
                return 0
                ;;
            -V|--version)
                # Return a special token to indicate version was requested
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
    local in_file_content=0
    local current_file=""
    local current_content=""
    local lang=""
    local line_num=0
    log_progress "Extracting code blocks from markdown..."
    while IFS= read -r line || [[ -n "$line" ]]; do
        ((line_num++))
        line="${line%$'\r'}"
        
        # Check for code block start/end
        if [[ "$line" =~ ^[[:space:]]*\`\`\`([a-zA-Z0-9+]*)$ ]]; then
            if [[ $in_code_block -eq 0 ]]; then
                in_code_block=1
                lang="${BASH_REMATCH[1]}"
                current_content=""
                current_file=""
                in_file_content=0
                log_debug "Line $line_num: Opening code block (language: $lang)"
            else
                in_code_block=0
                if [[ -n "$current_file" ]] && [[ -n "$current_content" ]]; then
                    current_content="${current_content%$'\n'}"
                    CODE_BLOCKS["$current_file"]="$current_content"
                    ((STATS_BLOCKS_EXTRACTED++))
                    log_debug "Line $line_num: Saved code block '$current_file' (${#current_content} bytes)"
                fi
                current_file=""
                current_content=""
                lang=""
                in_file_content=0
            fi
            continue
        fi
        
        if [[ $in_code_block -eq 1 ]]; then
            # Look for file name markers
            if [[ -z "$current_file" ]]; then
                if [[ "$line" =~ \[file[[:space:]]name\]:[[:space:]]*(.+) ]]; then
                    current_file=$(printf "%s\n" "${BASH_REMATCH[1]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                    current_file="${current_file#/}"
                    log_debug "Line $line_num: Found file reference: $current_file"
                    continue
                fi
            fi
            
            # Check for content begin marker
            if [[ "$line" =~ \[file[[:space:]]content[[:space:]]begin\] ]]; then
                in_file_content=1
                log_debug "Line $line_num: Starting file content section"
                continue
            fi
            
            # Check for content end marker
            if [[ "$line" =~ \[file[[:space:]]content[[:space:]]end\] ]]; then
                in_file_content=0
                log_debug "Line $line_num: Ending file content section"
                continue
            fi
            
            # Collect content based on mode
            if [[ $in_file_content -eq 1 ]] || [[ -n "$current_file" ]]; then
                # Skip empty lines at the beginning of content
                if [[ -z "$current_content" ]] && [[ -z "$(printf "%s" "$line" | tr -d '[:space:]')" ]]; then
                    continue
                fi
                current_content+="$line"$'\n'
            fi
        fi
    done < "$input_file"
    
    # Handle final block if still open
    if [[ $in_code_block -eq 1 ]] && [[ -n "$current_file" ]] && [[ -n "$current_content" ]]; then
        current_content="${current_content%$'\n'}"
        CODE_BLOCKS["$current_file"]="$current_content"
        ((STATS_BLOCKS_EXTRACTED++))
        log_debug "Saved final code block: $current_file"
    fi
    
    if [[ ${#CODE_BLOCKS[@]} -gt 0 ]]; then
        log_ok "Extracted ${#CODE_BLOCKS[@]} code block(s)"
        return 0
    else
        log_warn "No code blocks with [file name] markers found"
        return 1
    fi
}
# ============================================================================
# STRUCTURE EXTRACTION FROM COMMENTS
# ============================================================================
extract_structure_from_comments() {
    local input_file="$1"
    local -a files=()
    local line_count=0
    log_progress "Extracting file structure from embedded comments..."
    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line%$'\r'}"
        if [[ "$line" =~ \[file[[:space:]]name\]:[[:space:]]*([^[:space:]]+) ]]; then
            local file_path="${BASH_REMATCH[1]}"
            if [[ "$file_path" =~ ^(\[|/var|/home|/usr|⏳|🟡|🟢|🔵|🔴) ]] || \
               [[ "$file_path" =~ "[0-9;]+m" ]]; then
                continue
            fi
            if ! [[ "$file_path" =~ \.[a-zA-Z0-9]{1,10}$ ]]; then
                continue
            fi
            local found=0
            local existing
            if [[ ${#files[@]} -gt 0 ]]; then
                for existing in "${files[@]}"; do
                    if [[ "$existing" == "$file_path" ]]; then
                        found=1
                        break
                    fi
                done
            fi
            if [[ $found -eq 0 ]]; then
                files+=("$file_path")
                log_debug "Registered file path: $file_path"
            fi
        fi
    done < "$input_file"
    if [[ ${#files[@]} -eq 0 ]]; then
        log_warn "No valid file paths found in comments"
        return 1
    fi
    local tree_str="project/"
    if [[ ${#files[@]} -gt 0 ]]; then
        for file_path in "${files[@]}"; do
            tree_str+=$'\n'"├── ${file_path}"
        done
    fi
    printf "%s\n" "$tree_str"
    return 0
}
# ============================================================================
# TREE STRUCTURE DETECTION
# ============================================================================
is_valid_tree_structure() {
    local tree_content="$1"
    
    # Count tree-specific characters
    local tree_chars=$(printf "%s" "$tree_content" | grep -o '[├│└──]' | wc -l)
    local total_lines=$(printf "%s" "$tree_content" | wc -l)
    
    # If no tree characters at all, it's not a valid tree
    if [[ $tree_chars -eq 0 ]]; then
        return 1
    fi
    
    # Check for common code patterns that indicate this is not a tree
    if printf "%s" "$tree_content" | grep -q -E '(function|class|namespace|public|private|protected|\$|->|;|/\*|\*/)'; then
        return 1
    fi
    
    # Check for excessive special characters that indicate code
    local special_chars=$(printf "%s" "$tree_content" | grep -o '[$;{}()=]' | wc -l)
    if [[ $special_chars -gt $((total_lines / 2)) ]]; then
        return 1
    fi
    
    # Check for file/directory patterns
    local file_patterns=$(printf "%s" "$tree_content" | grep -c -E '([a-zA-Z0-9_-]+\.[a-zA-Z0-9]+|[a-zA-Z0-9_-]+/)')
    if [[ $file_patterns -lt $((total_lines / 3)) ]]; then
        return 1
    fi
    
    return 0
}
find_tree_structures() {
    local input_file="$1"
    local in_tree_block=0
    local current_tree=""
    local tree_count=0
    local line_num=0
    log_progress "Scanning for project structures in markdown..."
    while IFS= read -r line || [[ -n "$line" ]]; do
        ((line_num++))
        line="${line%$'\r'}"
        
        # Look for tree structure headers
        if [[ "$line" =~ [Dd][Ii][Rr][Ee][Cc][Tt][Oo][Rr][Yy][[:space:]]+[Ss][Tt][Rr][Uu][Cc][Tt][Uu][Rr][Ee]: ]] || 
           [[ "$line" =~ [Pp][Rr][Oo][Jj][Ee][Cc][Tt][[:space:]]+[Ss][Tt][Rr][Uu][Cc][Tt][Uu][Rr][Ee]: ]] ||
           [[ "$line" =~ ^[[:space:]]*[├│└] ]] ||
           [[ "$line" =~ ^[[:space:]]*[|] ]]; then
            
            if [[ $in_tree_block -eq 0 ]]; then
                in_tree_block=1
                current_tree="$line"
                log_debug "Line $line_num: Starting tree block"
            else
                current_tree+=$'\n'"$line"
            fi
            continue
        fi
        
        if [[ $in_tree_block -eq 1 ]]; then
            # Continue collecting tree lines if they contain tree characters
            if [[ "$line" =~ [├│└──] ]] || [[ "$line" =~ [|] && "$line" =~ [/] ]] || 
               [[ "$line" =~ ^[[:space:]]*$ ]] || [[ "$line" =~ [a-zA-Z0-9_-]+\.[a-zA-Z0-9]+ ]] ||
               [[ "$line" =~ [a-zA-Z0-9_-]+/ ]]; then
                current_tree+=$'\n'"$line"
            else
                # End of tree block
                in_tree_block=0
                if [[ -n "$current_tree" ]] && is_valid_tree_structure "$current_tree"; then
                    ((tree_count++))
                    TREE_STRUCTURES["$tree_count"]="$current_tree"
                    log_debug "Found valid tree structure #$tree_count"
                else
                    log_debug "Skipping invalid tree structure"
                fi
                current_tree=""
            fi
        fi
        
        # Also check code blocks for trees
        if [[ "$line" =~ ^[[:space:]]*\`\`\` ]]; then
            if [[ $in_tree_block -eq 1 ]]; then
                in_tree_block=0
                if [[ -n "$current_tree" ]] && is_valid_tree_structure "$current_tree"; then
                    ((tree_count++))
                    TREE_STRUCTURES["$tree_count"]="$current_tree"
                    log_debug "Found tree structure #$tree_count in code block"
                fi
                current_tree=""
            fi
        fi
    done < "$input_file"
    
    # Handle final tree block
    if [[ $in_tree_block -eq 1 ]] && [[ -n "$current_tree" ]] && is_valid_tree_structure "$current_tree"; then
        ((tree_count++))
        TREE_STRUCTURES["$tree_count"]="$current_tree"
        log_debug "Saved final tree structure #$tree_count"
    fi
    
    if [[ $tree_count -eq 0 ]]; then
        log_info "No visual tree structures found, trying comment-based extraction..."
        local comment_tree
        if comment_tree=$(extract_structure_from_comments "$input_file"); then
            ((tree_count++))
            TREE_STRUCTURES[$tree_count]="$comment_tree"
            log_ok "Generated tree structure from file comments"
        fi
    fi
    
    if [[ $tree_count -gt 0 ]]; then
        log_ok "Found $tree_count project structure(s)"
        return 0
    else
        log_err "No project structures found in markdown"
        return 1
    fi
}
# ============================================================================
# INTERACTIVE SELECTION
# ============================================================================
select_tree_interactive() {
    local count=${#TREE_STRUCTURES[@]}
    if [[ $count -eq 0 ]]; then
        return 1
    fi
    if [[ $count -eq 1 ]]; then
        printf "1\n"
        return 0
    fi
    printf "\n%b\n" "${CYAN}Found $count structures:${NC}"
    local i
    for ((i=1; i<=count; i++)); do
        local preview=$(printf "%s" "${TREE_STRUCTURES[$i]}" | head -5 | sed 's/^/    /')
        printf " %d)\n%s\n" "$i" "$preview"
        printf "\n"
    done
    while true; do
        printf "%b" "${GREEN}Select structure (1-$count) or q to quit: ${NC}"
        read -r choice
        case "$choice" in
            [qQ])
                log_info "Operation cancelled by user"
                exit 0
                ;;
            *)
                if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "$count" ]]; then
                    printf "%s\n" "$choice"
                    return 0
                else
                    printf "%b\n" "${RED}Invalid choice${NC}"
                fi
                ;;
        esac
    done
}
# ============================================================================
# TREE LINE NORMALIZATION
# ============================================================================
normalize_tree_lines() {
    local tree_block="$1"
    while IFS= read -r line; do
        line="${line%$'\r'}"
        [[ -z "$line" ]] && continue
        # Skip lines that are clearly code or regex patterns
        if [[ "$line" =~ (preg_match|function|class|namespace|\$|->) ]]; then
            continue
        fi
        # Only process lines that look like file/directory structures
        if [[ "$line" =~ ([├│└──]|[|]) ]] || [[ "$line" =~ ([a-zA-Z0-9_-]+\.[a-zA-Z0-9]+|[a-zA-Z0-9_-]+/) ]]; then
            line=$(printf "%s" "$line" | sed -e 's/├/|/g' -e 's/│/|/g' -e 's/└/|/g' -e 's/─/-/g')
            printf "%s\n" "$line"
        fi
    done <<< "$tree_block"
}
# ============================================================================
# FILE CONTENT RETRIEVAL
# ============================================================================
get_file_content() {
    local file_name="$1"
    if [[ -v CODE_BLOCKS[$file_name] ]]; then
        printf "%s" "${CODE_BLOCKS[$file_name]}"
        return 0
    fi
    local base_name
    base_name=$(basename "$file_name")
    local key
    for key in "${!CODE_BLOCKS[@]}"; do
        if [[ "$(basename "$key")" == "$base_name" ]]; then
            log_debug "Found code for '$file_name' via basename match: $key"
            printf "%s" "${CODE_BLOCKS[$key]}"
            return 0
        fi
    done
    return 1
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
    local tree_block="$2"
    local updated=0
    local skipped=0
    log_progress "Scanning for existing files in: $target_dir"
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        local item_name
        item_name=$(printf "%s" "$line" | sed 's/^[|\\ \-]*//' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [[ -z "$item_name" ]] && continue
        if [[ "$item_name" =~ /$ ]]; then
            continue
        fi
        local file_name
        file_name=$(sanitize_path "$item_name")
        local full_path="${target_dir%/}/${file_name}"
        if [[ ! -f "$full_path" ]]; then
            local found_file
            found_file=$(find "$target_dir" -name "$(basename "$file_name")" -type f 2>/dev/null | head -1)
            if [[ -n "$found_file" ]]; then
                full_path="$found_file"
            fi
        fi
        if [[ -f "$full_path" ]]; then
            local file_content
            file_content=$(get_file_content "$(basename "$file_name")" 2>/dev/null || printf "")
            if [[ -n "$file_content" ]]; then
                if update_file "$full_path" "$file_content"; then
                    ((updated++))
                else
                    ((skipped++))
                fi
            else
                log_debug "No code content found for: $(basename "$file_name")"
                ((skipped++))
            fi
        fi
    done < <(normalize_tree_lines "$tree_block")
    log_ok "Update scan completed: $updated updated, $skipped skipped"
    return $([[ $updated -gt 0 ]] && echo 0 || echo 1)
}
# ============================================================================
# TREE PARSING & STRUCTURE CREATION
# ============================================================================
parse_and_create_structure() {
    local tree_block="$1"
    local target_dir="$2"
    local tree_id="$3"
    local -a dir_stack=()
    local current_path="$target_dir"
    local line_count=0
    local created_dirs=0
    local created_files=0
    local skipped_items=0
    log_progress "Creating structure #$tree_id in: $target_dir"
    while IFS= read -r line; do
        ((line_count++))
        [[ -z "$line" ]] && continue
        log_debug "Tree line $line_count: $line"
        local indent_count=0
        local temp_line="$line"
        while [[ "$temp_line" =~ ^\ [\ │├└─]* ]]; do
            temp_line="${temp_line:1}"
            ((indent_count++))
        done
        local level=$((indent_count / 2))
        [[ $level -lt 0 ]] && level=0
        while [[ ${#dir_stack[@]} -gt $level ]]; do
            unset "dir_stack[${#dir_stack[@]}-1]"
        done
        current_path="$target_dir"
        local i
        for ((i=0; i<${#dir_stack[@]}; i++)); do
            current_path="${current_path%/}/${dir_stack[$i]}"
        done
        local item_name="$line"
        item_name=$(printf "%s" "$item_name" | sed 's/^[[:space:]│├└─]*//;s/^[[:space:]]*//;s/[[:space:]]*$//')
        [[ -z "$item_name" ]] && continue
        [[ "$item_name" == "project/" ]] && continue
        
        # Skip lines that are clearly not file/directory names
        if [[ "$item_name" =~ (preg_match|function|class|foreach|if|return|private|public) ]] ||
           [[ "$item_name" =~ (\$|->|;|,|\[|\]|\(|\)) ]] ||
           [[ "$item_name" =~ ^[[:space:]]*\/ ]] ||
           [[ ${#item_name} -gt 100 ]]; then
            log_debug "Skipping invalid item: $item_name"
            continue
        fi
        
        if [[ "$item_name" =~ /$ ]]; then
            local dir_name=$(sanitize_path "${item_name%/}")
            local full_dir_path="${current_path%/}/$dir_name"
            if create_directory "$full_dir_path"; then
                dir_stack+=("$dir_name")
                ((created_dirs++))
            else
                ((skipped_items++))
            fi
        else
            local file_name=$(sanitize_path "$item_name")
            local full_file_path="${current_path%/}/$file_name"
            local file_content=""
            if [[ "$EXTRACT_CODE" == true ]]; then
                file_content=$(get_file_content "$file_name" 2>/dev/null || printf "")
            fi
            if create_file "$full_file_path" "$file_content"; then
                ((created_files++))
            else
                ((skipped_items++))
            fi
        fi
    done <<< "$tree_block"
    log_ok "Structure #$tree_id completed:"
    log_info " Lines: $line_count | Dirs: $created_dirs | Files: $created_files"
    return $([[ $skipped_items -eq 0 ]] && echo 0 || echo 1)
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

    if ! find_tree_structures "$working_file"; then
        log_err "No project structures found in markdown"
        exit 1
    fi

    local -a selected=()
    if [[ "$INTERACTIVE_MODE" == true ]]; then
        local choice
        choice=$(select_tree_interactive) || exit 1
        selected=("$choice")
    elif [[ "$FIND_ALL_STRUCTURES" == true ]]; then
        local i
        for ((i=1; i<=${#TREE_STRUCTURES[@]}; i++)); do
            selected+=("$i")
        done
    else
        selected=(1)
    fi

    local tree_num
    for tree_num in "${selected[@]}"; do
        printf "\n%b\n" "${CYAN}=== Processing Structure #$tree_num ===${NC}"
        printf "%b\n" "${BLUE}Structure preview:${NC}"
        printf "%s\n" "${TREE_STRUCTURES[$tree_num]}" | head -10
        printf "\n"
        
        if [[ "$UPDATE_MODE" == true ]]; then
            if find_existing_files "$target_dir" "${TREE_STRUCTURES[$tree_num]}"; then
                log_ok "Structure #$tree_num updated successfully"
            else
                log_warn "Structure #$tree_num completed with warnings"
            fi
        else
            if parse_and_create_structure "${TREE_STRUCTURES[$tree_num]}" "$target_dir" "$tree_num"; then
                log_ok "Structure #$tree_num completed successfully"
            else
                log_warn "Structure #$tree_num completed with warnings"
            fi
        fi
    done

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
