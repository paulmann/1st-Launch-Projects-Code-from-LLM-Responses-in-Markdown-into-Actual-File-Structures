#!/usr/bin/env bash

# MD to Files: LLM Code Projector v3.1
# DeepSeek and other LLM Answers to Files Converter
# Author: Mikhail Deynekin (https://deynekin.com)
# Email: mid1977@gmail.com
# Date: 2025-10-28

set -euo pipefail
IFS=$'\n\t'

# Script metadata
SCRIPT_VERSION="3.1.0"
SCRIPT_AUTHOR="GitHub Community"
SCRIPT_DESCRIPTION="DeepSeek and other LLM Answers to Files Converter - Projects code from markdown responses into file structures"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner art

#

show_banner() {
    cat << "EOF"

██████╗ ███████╗██╗   ██╗███╗   ██╗███████╗██╗  ██╗██╗███╗   ██╗     ██████╗ ██████╗ ███╗   ███╗
██╔══██╗██╔════╝╚██╗ ██╔╝████╗  ██║██╔════╝██║ ██╔╝██║████╗  ██║    ██╔════╝██╔═══██╗████╗ ████║
██║  ██║█████╗   ╚████╔╝ ██╔██╗ ██║█████╗  █████╔╝ ██║██╔██╗ ██║    ██║     ██║   ██║██╔████╔██║
██║  ██║██╔══╝    ╚██╔╝  ██║╚██╗██║██╔══╝  ██╔═██╗ ██║██║╚██╗██║    ██║     ██║   ██║██║╚██╔╝██║
██████╔╝███████╗   ██║   ██║ ╚████║███████╗██║  ██╗██║██║ ╚████║    ╚██████╗╚██████╔╝██║ ╚═╝ ██║
╚═════╝ ╚══════╝   ╚═╝   ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝     ╚═════╝ ╚═════╝ ╚═╝     ╚═╝

EOF
    echo -e "${CYAN}DeepSeek and other LLM Answers to Files Converter v${SCRIPT_VERSION}${NC}"
    echo -e "${GREEN}Projects code from LLM markdown responses into actual file structures${NC}"
    echo -e "${YELLOW}=======================================================================${NC}"
}

# Configuration variables
VERBOSE=false
DRY_RUN=false
FORCE_OVERWRITE=false
BACKUP_EXISTING=false
LOG_FILE=""
FIND_ALL=false
ASK_MODE=false
TREE_NUMBER=1
EXTRACT_CODE=true
UPDATE_MODE=false
PROJECT_MODE="create"
TREE_BLOCKS=()
declare -A CODE_BLOCKS

# Logger functions with enhanced formatting
log_info() {
    local message="$1"
    echo -e "${GREEN}🟢 [INFO]${NC} $message"
    log_to_file "INFO" "$message"
}

log_warning() {
    local message="$1"
    echo -e "${YELLOW}🟡 [WARNING]${NC} $message" >&2
    log_to_file "WARNING" "$message"
}

log_error() {
    local message="$1"
    echo -e "${RED}🔴 [ERROR]${NC} $message" >&2
    log_to_file "ERROR" "$message"
}

log_debug() {
    local message="$1"
    if [[ "$VERBOSE" == true ]]; then
        echo -e "${BLUE}🔵 [DEBUG]${NC} $message"
        log_to_file "DEBUG" "$message"
    fi
}

log_success() {
    local message="$1"
    echo -e "${GREEN}✅ [SUCCESS]${NC} $message"
    log_to_file "SUCCESS" "$message"
}

log_progress() {
    local message="$1"
    echo -e "${CYAN}⏳ [PROGRESS]${NC} $message"
    log_to_file "PROGRESS" "$message"
}

log_to_file() {
    local level="$1"
    local message="$2"
    if [[ -n "$LOG_FILE" ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" >> "$LOG_FILE"
    fi
}

# Display usage information with better formatting
show_help() {
    show_banner
    echo -e ""
    echo -e "${CYAN}USAGE:${NC}"
    echo -e "    $0 [OPTIONS] <input_file> [target_directory]"
    echo -e ""
    echo -e "${CYAN}DESCRIPTION:${NC}"
    echo -e "    ${SCRIPT_DESCRIPTION}"
    echo -e "    "
    echo -e "    This tool extracts file structures and code content from LLM responses in markdown format"
    echo -e "    and creates actual directory structures with properly formatted files."
    echo -e ""
    echo -e "${CYAN}MODES:${NC}"
    echo -e "    ${GREEN}Create Mode${NC} (default): Creates new project structure from LLM response"
    echo -e "    ${BLUE}Update Mode${NC} (-U): Updates existing files with content from LLM response"
    echo -e "    ${YELLOW}Project Mode${NC} (-P): Enhanced creation with project metadata"
    echo -e ""
    echo -e "${CYAN}OPTIONS:${NC}"
    echo -e "    -h, --help              Show this help message and exit"
    echo -e "    -v, --verbose           Enable verbose output with debug information"
    echo -e "    -d, --dry-run           Simulate operations without making changes"
    echo -e "    -f, --force             Overwrite existing files without prompting"
    echo -e "    -b, --backup            Backup existing files before overwriting"
    echo -e "    -l, --log FILE          Write detailed log to specified file"
    echo -e "    -V, --version           Show version information"
    echo -e "    -a, --find-all          Find and process ALL tree structures in the file"
    echo -e "    -i, --ask               Find all trees and ask user to select one"
    echo -e "    -n, --tree-number N     Process specific tree number (default: 1)"
    echo -e "    -C, --no-code           Do not extract code content from markdown"
    echo -e "    -U, --update            Update mode: find existing files and update with LLM content"
    echo -e "    -P, --project           Project mode: enhanced creation with README and project info"
    echo -e ""
    echo -e "${CYAN}ARGUMENTS:${NC}"
    echo -e "    ${MAGENTA}input_file${NC}              Markdown file containing LLM response with code and file structures"
    echo -e "    ${MAGENTA}target_directory${NC}        Directory where project will be created/updated (default: current directory)"
    echo -e ""
    echo -e "${CYAN}EXAMPLES:${NC}"
    echo -e "    ${GREEN}# Create new project from LLM response${NC}"
    echo -e "    $0 deepseek_response.md ./my-project"
    echo -e ""
    echo -e "    ${BLUE}# Update existing project with latest LLM code${NC}"
    echo -e "    $0 -U documentation.md ./existing-project"
    echo -e ""
    echo -e "    ${YELLOW}# Create enhanced project with metadata${NC}"
    echo -e "    $0 -P llm_design.md ./new-app"
    echo -e ""
    echo -e "    ${CYAN}# Interactive selection from multiple structures${NC}"
    echo -e "    $0 -i complex_design.md"
    echo -e ""
    echo -e "    ${MAGENTA}# Update with backups and verbose logging${NC}"
    echo -e "    $0 -U -b -v tutorial.md src/"
    echo -e ""
    echo -e "${CYAN}SUPPORTED LLMS:${NC}"
    echo -e "    • DeepSeek • ChatGPT • Claude • Gemini • Copilot • and other AI assistants"
    echo -e ""
    echo -e "${CYAN}FEATURES:${NC}"
    echo -e "    • 📁 Smart tree structure detection in markdown"
    echo -e "    • 💻 Code block extraction with syntax highlighting"
    echo -e "    • 🔄 Update mode for existing projects"
    echo -e "    • 📝 Project metadata generation"
    echo -e "    • 🛡️ Safe file operations with backups"
    echo -e "    • 🔍 Multiple encoding support (UTF-8, Windows-1252)"
    echo -e "    • 📊 Progress tracking and detailed reporting"
    echo -e ""
    echo -e "${YELLOW}Report issues: https://github.com/username/llm-projector/issues${NC}"
}

# Display version information
show_version() {
    show_banner
    printf "\n${CYAN}Version:${NC}       ${SCRIPT_VERSION}\n"
    printf "${CYAN}Author:${NC}        ${SCRIPT_AUTHOR}\n"
    printf "${CYAN}License:${NC}       MIT\n"
    printf "${CYAN}Description:${NC}   ${SCRIPT_DESCRIPTION}\n\n"
    printf "${GREEN}Transform LLM conversations into working code projects!${NC}\n"
}

# Parse command line arguments
parse_arguments() {
    local args=()
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                log_info "Dry run mode enabled - no changes will be made"
                shift
                ;;
            -f|--force)
                FORCE_OVERWRITE=true
                shift
                ;;
            -b|--backup)
                BACKUP_EXISTING=true
                shift
                ;;
            -l|--log)
                if [[ -z "${2:-}" ]]; then
                    log_error "Log file path not specified"
                    exit 1
                fi
                LOG_FILE="$2"
                shift 2
                ;;
            -V|--version)
                show_version
                exit 0
                ;;
            -a|--find-all|--FA)
                FIND_ALL=true
                shift
                ;;
            -i|--ask)
                ASK_MODE=true
                shift
                ;;
            -n|--tree-number)
                if [[ -z "${2:-}" ]] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
                    log_error "Invalid tree number: $2. Must be a positive integer."
                    exit 1
                fi
                TREE_NUMBER="$2"
                shift 2
                ;;
            -C|--no-code)
                EXTRACT_CODE=false
                shift
                ;;
            -U|--update)
                UPDATE_MODE=true
                PROJECT_MODE="update"
                shift
                ;;
            -P|--project)
                PROJECT_MODE="project"
                shift
                ;;
            --)
                shift
                args+=("$@")
                break
                ;;
            -*)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                args+=("$1")
                shift
                ;;
        esac
    done

    if [[ ${#args[@]} -lt 1 ]]; then
        log_error "Input file not specified"
        show_help
        exit 1
    fi

    echo "${args[@]}"
}

# Detect file encoding
detect_encoding() {
    local file="$1"
    
    if command -v file >/dev/null 2>&1; then
        local encoding_info
        encoding_info=$(file -b --mime-encoding "$file")
        log_debug "Detected encoding: $encoding_info"
        
        case "$encoding_info" in
            *utf-8*)
                echo "UTF-8"
                ;;
            *ascii*)
                echo "UTF-8"
                ;;
            *iso-8859-1*|*windows-1252*)
                echo "WINDOWS-1252"
                ;;
            *)
                log_warning "Unknown encoding $encoding_info, assuming UTF-8"
                echo "UTF-8"
                ;;
        esac
    else
        log_warning "file command not available, assuming UTF-8 encoding"
        echo "UTF-8"
    fi
}

# Convert file to UTF-8 if needed
ensure_utf8() {
    local input_file="$1"
    local encoding
    
    encoding=$(detect_encoding "$input_file")
    
    if [[ "$encoding" == "UTF-8" ]]; then
        echo "$input_file"
        return
    fi
    
    if [[ "$encoding" == "WINDOWS-1252" ]]; then
        local temp_file
        temp_file=$(mktemp)
        
        if command -v iconv >/dev/null 2>&1; then
            if iconv -f WINDOWS-1252 -t UTF-8//TRANSLIT "$input_file" > "$temp_file" 2>/dev/null; then
                log_info "Converted file from $encoding to UTF-8"
                echo "$temp_file"
                return
            else
                log_warning "Failed to convert encoding, using original file"
                echo "$input_file"
                return
            fi
        else
            log_warning "iconv not available, using original file with encoding $encoding"
            echo "$input_file"
            return
        fi
    fi
    
    echo "$input_file"
}

# Validate input file and target directory
validate_input() {
    local input_file="$1"
    local target_dir="${2:-.}"

    # Validate input file
    if [[ ! -f "$input_file" ]]; then
        log_error "Input file $input_file not found"
        exit 1
    fi

    if [[ ! -r "$input_file" ]]; then
        log_error "Cannot read input file $input_file"
        exit 1
    fi

    if [[ ! -s "$input_file" ]]; then
        log_error "Input file $input_file is empty"
        exit 1
    fi

    # Validate target directory based on mode
    if [[ "$UPDATE_MODE" == true ]]; then
        if [[ ! -d "$target_dir" ]]; then
            log_error "Target directory $target_dir does not exist (required for update mode)"
            exit 1
        fi
    else
        if [[ ! -d "$target_dir" ]]; then
            log_progress "Creating target directory: $target_dir"
            mkdir -p "$target_dir" || {
                log_error "Cannot create target directory $target_dir"
                exit 1
            }
        fi
    fi

    if [[ ! -w "$target_dir" ]]; then
        log_error "Cannot write to target directory $target_dir"
        exit 1
    fi

    # Get absolute path
    target_dir=$(get_absolute_path "$target_dir")
    
    echo "$target_dir"
}

# Get absolute path in cross-platform way
get_absolute_path() {
    local path="$1"
    local dir
    local file
    
    # Try readlink -f first (Linux)
    if command -v readlink >/dev/null 2>&1; then
        if readlink -f "$path" 2>/dev/null; then
            return
        fi
    fi
    
    # Fallback for macOS and other systems
    if [[ -d "$path" ]]; then
        (cd "$path" && pwd)
    else
        dir=$(dirname "$path")
        file=$(basename "$path")
        echo "$(cd "$dir" && pwd)/$file"
    fi
}

# Enhanced code block extraction with better markdown parsing
extract_code_blocks() {
    local input_file="$1"
    local in_code_block=false
    local current_file=""
    local current_content=""
    local current_language=""
    local -A code_blocks
    
    log_progress "Extracting code blocks from LLM response..."
    
    # Read file content to avoid multiple reads
    local file_content
    file_content=$(cat "$input_file")
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Remove carriage returns for Windows compatibility
        line=$(echo "$line" | tr -d '\r')
        
        # Check for file path markers in various markdown formats
        if [[ ! "$in_code_block" == true ]]; then
            # Pattern 1: **filename.ext**
            if [[ "$line" =~ \*\*([a-zA-Z0-9_./-]+\.([a-zA-Z0-9]{1,10}))\*\* ]]; then
                current_file="${BASH_REMATCH[1]}"
                log_debug "Found file reference (bold): $current_file"
                continue
            fi
            
            # Pattern 2: # filename.ext or ## filename.ext
            if [[ "$line" =~ ^[#]+[[:space:]]+([a-zA-Z0-9_./-]+\.[a-zA-Z0-9]+) ]]; then
                current_file="${BASH_REMATCH[1]}"
                log_debug "Found file reference (header): $current_file"
                continue
            fi
            
            # Pattern 3: File: filename.ext or File path: filename.ext
            if [[ "$line" =~ [Ff]ile[[:space:]]*:?[[:space:]]*([a-zA-Z0-9_./-]+\.[a-zA-Z0-9]+) ]]; then
                current_file="${BASH_REMATCH[1]}"
                log_debug "Found file reference (label): $current_file"
                continue
            fi
        fi
        
        # Check for code block start with optional language specification
        local code_fence_pattern='^[[:space:]]*```([a-zA-Z0-9+]*)$'
        if [[ "$line" =~ $code_fence_pattern ]]; then
            if [[ "$in_code_block" == true ]]; then
                # End of code block
                in_code_block=false
                if [[ -n "$current_file" && -n "$current_content" ]]; then
                    # Remove trailing newline from content
                    current_content="${current_content%$'\n'}"
                    code_blocks["$current_file"]="$current_content"
                    log_debug "Extracted code block: $current_file (${#current_content} bytes, language: $current_language)"
                fi
                current_file=""
                current_content=""
                current_language=""
            else
                # Start of code block
                in_code_block=true
                current_language="${BASH_REMATCH[1]}"
                current_content=""
            fi
            continue
        fi
        
        # Check for PHP file markers (common in PHP documentation)
        if [[ ! "$in_code_block" == true ]] && [[ "$line" =~ ^[[:space:]]*(\<\?php|namespace[[:space:]]+|class[[:space:]]+|interface[[:space:]]+|trait[[:space:]]+) ]]; then
            if [[ -z "$current_file" ]]; then
                # Extract filename from context using the pre-loaded content
                local prev_line
                if command -v tac >/dev/null 2>&1; then
                    prev_line=$(echo "$file_content" | grep -B 5 -A 1 "^$line" | head -6 | tac | grep -E '\*\*.*\.php\*\*' | head -1)
                else
                    prev_line=$(echo "$file_content" | grep -B 5 "^$line" | head -6 | tail -r 2>/dev/null | grep -E '\*\*.*\.php\*\*' | head -1)
                fi
                if [[ "$prev_line" =~ \*\*([a-zA-Z0-9_./-]+\.php)\*\* ]]; then
                    current_file="${BASH_REMATCH[1]}"
                    log_debug "Inferred PHP file from context: $current_file"
                fi
            fi
        fi
        
        # Add content if in code block and we have a current file
        if [[ "$in_code_block" == true ]] && [[ -n "$current_file" ]]; then
            current_content+="$line"$'\n'
        fi
        
    done <<< "$file_content"
    
    # Handle case where file ends during code block
    if [[ "$in_code_block" == true ]] && [[ -n "$current_file" && -n "$current_content" ]]; then
        current_content="${current_content%$'\n'}"
        code_blocks["$current_file"]="$current_content"
        log_debug "Extracted final code block: $current_file (${#current_content} bytes)"
    fi
    
    local count=${#code_blocks[@]}
    if [[ $count -gt 0 ]]; then
        log_success "Extracted $count code block(s) from LLM response"
        # Log extracted files for debugging
        if [[ "$VERBOSE" == true ]]; then
            for file in "${!code_blocks[@]}"; do
                local content_length=${#code_blocks[$file]}
                log_debug "  📄 $file ($content_length bytes)"
            done
        fi
    else
        log_warning "No code blocks found in LLM response"
    fi
    
    # Return the code blocks associative array
    for key in "${!code_blocks[@]}"; do
        echo "${key}|${code_blocks[$key]}"
    done
}

# Detect tree structures in input file with enhanced patterns
find_tree_structures() {
    local input_file="$1"
    local in_tree_block=false
    local current_tree=""
    local tree_count=0
    local -a trees=()
    
    log_progress "Scanning for project structures in LLM response..."
    
    # Read file content once to avoid multiple reads
    local file_content
    file_content=$(cat "$input_file")
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Remove carriage returns for Windows compatibility
        line=$(echo "$line" | tr -d '\r')
        
        # Check for code block start with optional language specification
        if [[ "$line" =~ ^[[:space:]]*\`\`\`([a-zA-Z0-9+]*) ]]; then
            if [[ "$in_tree_block" == true ]]; then
                # End of code block
                in_tree_block=false
                if [[ -n "$current_tree" ]]; then
                    ((tree_count++)) || true
                    trees+=("$current_tree")
                    log_debug "Found tree structure #$tree_count in code block"
                    current_tree=""
                fi
            else
                # Start of code block - check if it might contain a tree
                in_tree_block=true
                current_tree=""
            fi
            continue
        fi
        
        # Enhanced tree pattern detection
        if [[ "$line" =~ [├│└──┌] ]] || 
           [[ "$line" =~ \| ]] && [[ "$line" =~ / ]] ||
           [[ "$line" =~ ^[[:space:]]*[┌├└][─┐│] ]] ||
           [[ "$line" =~ ^[[:space:]]*[a-zA-Z0-9_]+/ ]] && [[ "$line" =~ /$ ]]; then
            
            if [[ -n "$current_tree" ]]; then
                current_tree+=$'\n'"$line"
            else
                current_tree="$line"
            fi
        elif [[ -n "$current_tree" ]] && [[ "$in_tree_block" == false ]]; then
            # Outside code block, check if we should continue or end the tree
            if [[ "$line" =~ ^[[:space:]]*$ ]] || 
               { [[ ! "$line" =~ [/\\] ]] && [[ ! "$line" =~ [├│└──┌] ]]; }; then
                # Empty line or line without path/tree characters - likely end of tree
                if [[ $(echo "$current_tree" | wc -l) -gt 1 ]]; then
                    ((tree_count++)) || true
                    trees+=("$current_tree")
                    log_debug "Found tree structure #$tree_count"
                fi
                current_tree=""
            else
                # Continue collecting tree lines
                current_tree+=$'\n'"$line"
            fi
        elif [[ "$in_tree_block" == true ]] && [[ -n "$current_tree" ]]; then
            # Inside code block, continue collecting if we already started a tree
            current_tree+=$'\n'"$line"
        fi
        
    done <<< "$file_content"
    
    # Do not forget the last tree...
    if [[ -n "$current_tree" ]] && [[ $(echo "$current_tree" | wc -l) -gt 1 ]]; then
        ((tree_count++)) || true
        trees+=("$current_tree")
        log_debug "Found tree structure #$tree_count"
    fi
    
    if [[ $tree_count -eq 0 ]]; then
        log_error "No project structures found in $input_file"
        log_error "Looking for tree patterns with: ├, │, └, ─, ┌ characters and directory structures"
        log_error "Make sure your LLM response includes proper file tree diagrams"
        exit 1
    fi
    
    log_success "Found $tree_count project structure(s) in LLM response"
    
    # Return the trees array
    printf "%s\n" "${trees[@]}"
}

# Display found trees and let user select one with better UI
select_tree_interactive() {
    local trees=("$@")
    local count=${#trees[@]}
    local line_count
    
    echo -e "\n${CYAN}🔄 Found $count project structure(s) in LLM response:${NC}"
    echo -e "${CYAN}=====================================================${NC}"
    
    for i in $(seq 0 $((count-1))); do
        echo -e "\n${YELLOW}🌳 Structure $((i+1)):${NC}"
        echo -e "${BLUE}$(echo "${trees[$i]}" | head -1)${NC}"
        
        line_count=$(echo "${trees[$i]}" | wc -l)
        if [[ $line_count -gt 8 ]]; then
            echo "${trees[$i]}" | head -4
            echo -e "${MAGENTA}    ... ($((line_count - 8)) more lines) ...${NC}"
            echo "${trees[$i]}" | tail -4
        else
            echo "${trees[$i]}"
        fi
        echo
    done
    
    while true; do
        echo -n -e "${GREEN}🎯 Select structure to project (1-$count) or q to quit: ${NC}"
        read -r choice
        
        case "$choice" in
            [qQ])
                log_info "Operation cancelled by user"
                exit 0
                ;;
            *)
                if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le $count ]]; then
                    echo "$((choice-1))"
                    return
                else
                    echo -e "${RED}❌ Invalid selection. Please enter a number between 1 and $count.${NC}"
                fi
                ;;
        esac
    done
}

# Sanitize path names to prevent security issues
sanitize_path() {
    local path="$1"
    
    # Remove leading/trailing whitespace
    path=$(echo "$path" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    # Remove null bytes and control characters
    path=$(echo "$path" | tr -d '\000-\037')
    
    # Remove potentially dangerous characters
    path=$(echo "$path" | tr -d '<>:"|?*')
    
    # Collapse multiple slashes and remove leading ./ ../
    path=$(echo "$path" | sed 's|//*|/|g; s|^\./||; s|^\.\./||')
    
    # Ensure we do not have absolute paths or path traversal
    if [[ "$path" == /* ]]; then
        path="${path#/}"
    fi
    
    # Limit path length (prevent extremely long paths)
    if [[ ${#path} -gt 255 ]]; then
        path="${path:0:255}"
        log_warning "Path truncated to 255 characters"
    fi
    
    echo "$path"
}

# Normalize tree lines for parsing
normalize_tree_lines() {
    local tree_block="$1"
    
    while IFS= read -r line; do
        # Skip empty lines and comments
        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        
        # Remove carriage returns
        line=$(echo "$line" | tr -d '\r')
        
        # Replace Unicode tree characters with ASCII equivalents for parsing
        line=$(echo "$line" | sed -e 's/├/|/g' -e 's/│/|/g' -e 's/└/|/g' -e 's/─/-/g' -e 's/┌/|/g')
        
        echo "$line"
    done <<< "$tree_block"
}

# Get code content for a file with enhanced matching
get_file_content() {
    local file_path="$1"
    
    if [[ "$EXTRACT_CODE" == false ]]; then
        echo ""
        return
    fi
    
    # Try exact match first
    if [[ -n "${CODE_BLOCKS[$file_path]+_}" ]]; then
        echo "${CODE_BLOCKS[$file_path]}"
        return
    fi
    
    # Try basename match (for cases where path might be different)
    local base_name
    base_name=$(basename "$file_path")
    for key in "${!CODE_BLOCKS[@]}"; do
        if [[ "$(basename "$key")" == "$base_name" ]]; then
            log_debug "Using code block for $base_name (original path: $key)"
            echo "${CODE_BLOCKS[$key]}"
            return
        fi
    done
    
    # Try partial path matching
    for key in "${!CODE_BLOCKS[@]}"; do
        if [[ "$key" == *"$base_name" ]]; then
            log_debug "Using partial match for $base_name (found: $key)"
            echo "${CODE_BLOCKS[$key]}"
            return
        fi
    done
    
    # No code block found
    echo ""
}

# Create project metadata files in project mode
create_project_metadata() {
    local target_dir="$1"
    local input_file="$2"
    local project_name
    local current_date
    
    if [[ "$PROJECT_MODE" != "project" ]] || [[ "$DRY_RUN" == true ]]; then
        return 0
    fi
    
    log_progress "Creating project metadata files..."
    
    project_name=$(basename "$target_dir")
    current_date=$(date '+%Y-%m-%d')
    
    # Create README.md
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

### Features
- Automatically extracted from markdown documentation
- Code blocks preserved with original formatting
- Directory structure maintained as specified

## Getting Started
[Add your project-specific instructions here]

## License
[Specify your license here]
EOF
        log_info "Created project README: $readme_file"
    fi
    
    # Create .llm-projector metadata
    local meta_file="${target_dir}/.llm-projector"
    cat > "$meta_file" << EOF
# LLM Projector Metadata
version=${SCRIPT_VERSION}
source_file=$(basename "$input_file")
generated_date=${current_date}
project_mode=${PROJECT_MODE}
files_created=$(find "$target_dir" -type f | wc -l)
directories_created=$(find "$target_dir" -type d | wc -l)
EOF
    
    log_success "Project metadata created successfully"
}

# Find all files in directory recursively that match files from tree
find_existing_files() {
    local target_dir="$1"
    local tree_block="$2"
    local item_name
    local file_name
    local full_file_path
    local file_content
    
    # Extract file list from tree
    local -a tree_files=()
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        
        # Extract item name (remove tree characters and trim)
        item_name=$(echo "$line" | sed 's/^[|\ \-]*//' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [[ -z "$item_name" ]] && continue
        
        # Check if it is a file (not ending with /)
        if [[ ! "$item_name" =~ /$ ]]; then
            file_name=$(sanitize_path "$item_name")
            tree_files+=("$file_name")
        fi
    done < <(normalize_tree_lines "$tree_block")
    
    log_progress "Scanning for ${#tree_files[@]} files in project directory..."
    
    local updated_count=0
    local skipped_count=0
    local not_found_count=0
    
    # Find and update existing files
    for relative_file in "${tree_files[@]}"; do
        full_file_path="${target_dir%/}/$relative_file"
        file_content=""
        
        if [[ -f "$full_file_path" ]]; then
            # Get content for this file if available
            if [[ "$EXTRACT_CODE" == true ]]; then
                file_content=$(get_file_content "$relative_file")
            fi
            
            if [[ -n "$file_content" ]]; then
                if update_file "$full_file_path" "$file_content"; then
                    ((updated_count++)) || true
                else
                    ((skipped_count++)) || true
                fi
            else
                log_debug "No code content found for: $relative_file"
                ((skipped_count++)) || true
            fi
        else
            log_debug "File not found, skipping: $full_file_path"
            ((not_found_count++)) || true
        fi
    done
    
    log_success "Update completed: $updated_count files updated, $skipped_count files skipped, $not_found_count files not found"
    return $((updated_count > 0 ? 0 : 1))
}

# Parse tree structure and create files/directories with content
parse_and_create_structure() {
    local tree_block="$1"
    local target_dir="$2"
    local tree_id="${3:-unknown}"
    local dir_stack=()
    local current_path="$target_dir"
    local line_count=0
    local created_dirs=0
    local created_files=0
    local files_with_content=0
    local skipped_items=0
    local indent
    local level
    local tree_chars
    local item_name
    local dir_name
    local full_dir_path
    local file_name
    local full_file_path
    local file_content
    
    log_progress "Projecting structure #$tree_id into: $target_dir"
    
    while IFS= read -r line; do
        ((line_count++))
        
        # Skip empty lines
        [[ -z "$line" ]] && continue
        
        log_debug "Processing line $line_count: $line"
        
        # Calculate indentation level
        if [[ "$line" =~ ^([|\ \-]*) ]]; then
            indent="${BASH_REMATCH[1]}"
        else
            indent=""
        fi
        
        # Calculate level based on indentation
        level=0
        if [[ -n "$indent" ]]; then
            tree_chars=$(echo "$indent" | tr -d ' ' | wc -c)
            level=$(( (tree_chars - 1) / 2 ))
        fi
        
        # Trim stack to current level
        while [[ ${#dir_stack[@]} -gt $level ]]; do
            unset 'dir_stack[${#dir_stack[@]}-1]'
        done
        
        # Rebuild current path from stack
        current_path="$target_dir"
        for dir in "${dir_stack[@]}"; do
            current_path="${current_path%/}/$dir"
        done
        
        # Extract item name (remove tree characters and trim)
        item_name=$(echo "$line" | sed 's/^[|\ \-]*//' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # Skip if no item name found
        [[ -z "$item_name" ]] && continue
        
        # Check if it is a directory (ends with /)
        if [[ "$item_name" =~ /$ ]]; then
            dir_name=$(sanitize_path "${item_name%/}")
            full_dir_path="${current_path%/}/$dir_name"
            
            if create_directory "$full_dir_path" "$line_count"; then
                dir_stack+=("$dir_name")
                current_path="$full_dir_path"
                ((created_dirs++)) || true
            else
                ((skipped_items++)) || true
            fi
            
        else
            # It is a file
            file_name=$(sanitize_path "$item_name")
            full_file_path="${current_path%/}/$file_name"
            file_content=""
            
            # Get content for this file if available
            if [[ "$EXTRACT_CODE" == true ]]; then
                file_content=$(get_file_content "$file_name")
                if [[ -n "$file_content" ]]; then
                    ((files_with_content++)) || true
                fi
            fi
            
            if create_file "$full_file_path" "$line_count" "$file_content"; then
                ((created_files++)) || true
            else
                ((skipped_items++)) || true
            fi
        fi
        
    done < <(normalize_tree_lines "$tree_block")
    
    log_success "Structure #$tree_id projection completed:"
    log_info "  📊 Lines processed: $line_count"
    log_info "  📁 Directories created: $created_dirs"
    log_info "  📄 Files created: $created_files"
    log_info "  💻 Files with content: $files_with_content"
    log_info "  ⏭️  Items skipped: $skipped_items"
    
    # Create project metadata if in project mode
    if [[ "$PROJECT_MODE" == "project" ]]; then
        create_project_metadata "$target_dir" "$input_file"
    fi
    
    return $((skipped_items > 0 ? 1 : 0))
}

# Backup existing file if backup is enabled
backup_file() {
    local file_path="$1"
    local backup_path
    
    if [[ "$BACKUP_EXISTING" == true && -f "$file_path" ]]; then
        backup_path="${file_path}.bak.$(date +%Y%m%d_%H%M%S)"
        if cp "$file_path" "$backup_path" 2>/dev/null; then
            log_info "Backed up: $file_path → $backup_path"
        else
            log_warning "Failed to backup: $file_path"
        fi
    fi
}

# Update existing file with new content
update_file() {
    local file_path="$1"
    local file_content="$2"
    local current_content
    
    # Check if file exists and is regular file
    if [[ ! -f "$file_path" ]]; then
        log_debug "File does not exist, skipping update: $file_path"
        return 1
    fi
    
    # Handle existing file
    if [[ -f "$file_path" ]]; then
        if [[ "$FORCE_OVERWRITE" == true ]]; then
            backup_file "$file_path"
            log_info "Updating: $file_path"
        else
            # Check if content is different
            current_content=$(cat "$file_path" 2>/dev/null || echo "")
            if [[ "$current_content" == "$file_content" ]]; then
                log_debug "Content unchanged: $file_path"
                return 1
            else
                backup_file "$file_path"
                log_info "Updating modified: $file_path"
            fi
        fi
    fi
    
    # Execute or simulate based on dry-run mode
    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would update: $file_path (${#file_content} bytes)"
        return 0
    else
        # Create file with content
        if echo "$file_content" > "$file_path" 2>/dev/null; then
            log_success "Updated: $file_path (${#file_content} bytes)"
            return 0
        else
            log_error "Failed to update: $file_path"
            return 1
        fi
    fi
}

# Create directory with proper error handling
create_directory() {
    local dir_path="$1"
    local line_number="$2"
    
    # Check if directory already exists
    if [[ -d "$dir_path" ]]; then
        log_debug "Directory exists: $dir_path"
        return 0
    fi
    
    # Check if path exists but is not a directory
    if [[ -e "$dir_path" && ! -d "$dir_path" ]]; then
        log_warning "Path exists but not directory: $dir_path"
        return 1
    fi
    
    # Execute or simulate based on dry-run mode
    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would create directory: $dir_path"
        return 0
    else
        if mkdir -p "$dir_path" 2>/dev/null; then
            log_info "Created directory: $dir_path"
            return 0
        else
            log_error "Failed to create directory: $dir_path"
            return 1
        fi
    fi
}

# Create file with content and proper error handling
create_file() {
    local file_path="$1"
    local line_number="$2"
    local file_content="${3:-}"
    local dir_path
    
    dir_path=$(dirname "$file_path")
    
    # Ensure parent directory exists
    if [[ ! -d "$dir_path" ]]; then
        if ! create_directory "$dir_path" "$line_number"; then
            log_error "Cannot create file (parent dir failed): $file_path"
            return 1
        fi
    fi
    
    # Handle existing file
    if [[ -f "$file_path" ]]; then
        if [[ "$FORCE_OVERWRITE" == true ]]; then
            backup_file "$file_path"
            log_info "Overwriting: $file_path"
        else
            log_warning "File exists, skipping: $file_path"
            return 1
        fi
    elif [[ -e "$file_path" ]]; then
        log_warning "Path exists but not file: $file_path"
        return 1
    fi
    
    # Execute or simulate based on dry-run mode
    if [[ "$DRY_RUN" == true ]]; then
        if [[ -n "$file_content" ]]; then
            log_info "[DRY-RUN] Would create file with content: $file_path (${#file_content} bytes)"
        else
            log_info "[DRY-RUN] Would create empty file: $file_path"
        fi
        return 0
    else
        if [[ -n "$file_content" ]]; then
            # Create file with content
            if echo "$file_content" > "$file_path" 2>/dev/null; then
                if [[ -n "$file_content" ]]; then
                    log_success "Created with content: $file_path (${#file_content} bytes)"
                else
                    log_info "Created empty: $file_path"
                fi
                return 0
            else
                log_error "Failed to create file: $file_path"
                return 1
            fi
        else
            # Create empty file
            if touch "$file_path" 2>/dev/null; then
                log_info "Created empty: $file_path"
                return 0
            else
                log_error "Failed to create file: $file_path"
                return 1
            fi
        fi
    fi
}

# Cleanup function for signal handling
cleanup() {
    log_info "Script interrupted by user"
    # Clean up temporary files if any were created
    if [[ -n "${TEMP_FILE:-}" && -f "$TEMP_FILE" ]]; then
        rm -f "$TEMP_FILE"
    fi
    exit 1
}

# Main execution function
# Main execution function
main() {
    # Set up signal handlers
    trap cleanup INT TERM
    
    # Show banner if not in quiet mode
    if [[ "$VERBOSE" == true ]] || [[ "$DRY_RUN" == true ]] || [[ "$ASK_MODE" == true ]]; then
        show_banner
    fi

    # Check for help and version options before parsing
    for arg in "$@"; do
        case "$arg" in
            -h|--help)
                show_help
                exit 0
                ;;
            -V|--version)
                show_version
                exit 0
                ;;
        esac
    done
    
    # Parse command line arguments
    local args=("$@")
    local input_file=""
    local target_dir="."
    local processed_file
    local total_trees
    local selected_trees=()
    local processed_count=0
    local error_count=0
    local tree_index
    local tree_id
    local selected_index
    
    # Parse arguments directly in main function
    while [[ ${#args[@]} -gt 0 ]]; do
        case "${args[0]}" in
            -v|--verbose)
                VERBOSE=true
                args=("${args[@]:1}")
                ;;
            -d|--dry-run)
                DRY_RUN=true
                log_info "Dry run mode enabled - no changes will be made"
                args=("${args[@]:1}")
                ;;
            -f|--force)
                FORCE_OVERWRITE=true
                args=("${args[@]:1}")
                ;;
            -b|--backup)
                BACKUP_EXISTING=true
                args=("${args[@]:1}")
                ;;
            -l|--log)
                if [[ -z "${args[1]:-}" ]]; then
                    log_error "Log file path not specified"
                    exit 1
                fi
                LOG_FILE="${args[1]}"
                args=("${args[@]:2}")
                ;;
            -a|--find-all|--FA)
                FIND_ALL=true
                args=("${args[@]:1}")
                ;;
            -i|--ask)
                ASK_MODE=true
                args=("${args[@]:1}")
                ;;
            -n|--tree-number)
                if [[ -z "${args[1]:-}" ]] || ! [[ "${args[1]}" =~ ^[0-9]+$ ]]; then
                    log_error "Invalid tree number: ${args[1]}. Must be a positive integer."
                    exit 1
                fi
                TREE_NUMBER="${args[1]}"
                args=("${args[@]:2}")
                ;;
            -C|--no-code)
                EXTRACT_CODE=false
                args=("${args[@]:1}")
                ;;
            -U|--update)
                UPDATE_MODE=true
                PROJECT_MODE="update"
                args=("${args[@]:1}")
                ;;
            -P|--project)
                PROJECT_MODE="project"
                args=("${args[@]:1}")
                ;;
            --)
                args=("${args[@]:1}")
                # Remaining arguments after -- are treated as positional
                if [[ ${#args[@]} -gt 0 ]]; then
                    if [[ -z "$input_file" ]]; then
                        input_file="${args[0]}"
                        args=("${args[@]:1}")
                    fi
                    if [[ ${#args[@]} -gt 0 ]]; then
                        target_dir="${args[0]}"
                        args=("${args[@]:1}")
                    fi
                fi
                break
                ;;
            -*)
                log_error "Unknown option: ${args[0]}"
                show_help
                exit 1
                ;;
            *)
                # Positional arguments
                if [[ -z "$input_file" ]]; then
                    input_file="${args[0]}"
                else
                    target_dir="${args[0]}"
                fi
                args=("${args[@]:1}")
                ;;
        esac
    done

    # Validate that input file is provided
    if [[ -z "$input_file" ]]; then
        log_error "Input file not specified"
        show_help
        exit 1
    fi

    # Handle encoding and create temporary UTF-8 file if needed
    processed_file=$(ensure_utf8 "$input_file")
    if [[ "$processed_file" != "$input_file" ]]; then
        TEMP_FILE="$processed_file"
    fi

    # Validate input
    target_dir=$(validate_input "$processed_file" "$target_dir")
    
    # Extract code blocks if enabled
    if [[ "$EXTRACT_CODE" == true ]]; then
        log_progress "Extracting code from LLM response..."
        while IFS='|' read -r key value; do
            if [[ -n "$key" && -n "$value" ]]; then
                CODE_BLOCKS["$key"]="$value"
            fi
        done < <(extract_code_blocks "$processed_file")
    else
        log_info "Code extraction disabled - creating empty files"
    fi
    
    # Find all tree structures in the file
    log_progress "Analyzing LLM response for project structures..."
    mapfile -t TREE_BLOCKS < <(find_tree_structures "$processed_file")
    
    total_trees=${#TREE_BLOCKS[@]}
    
    # Determine which trees to process
    if [[ "$FIND_ALL" == true ]]; then
        # Process all trees
        for i in $(seq 0 $((total_trees-1))); do
            selected_trees+=("$i")
        done
        log_info "Processing ALL $total_trees project structure(s)"
    elif [[ "$ASK_MODE" == true ]]; then
        # Interactive selection
        selected_index=$(select_tree_interactive "${TREE_BLOCKS[@]}")
        selected_trees=("$selected_index")
        log_info "Processing selected structure #$((selected_index+1))"
    else
        # Process specific tree number
        if [[ "$TREE_NUMBER" -gt "$total_trees" ]]; then
            log_error "Structure number $TREE_NUMBER not found. Only $total_trees structure(s) available."
            exit 1
        fi
        selected_trees=($((TREE_NUMBER-1)))
        log_info "Processing structure #$TREE_NUMBER"
    fi
    
    # Process selected trees
    for tree_index in "${selected_trees[@]}"; do
        tree_id=$((tree_index+1))
        
        if [[ $tree_index -ge 0 ]] && [[ $tree_index -lt $total_trees ]]; then
            echo -e "\n${CYAN}🚀 Processing Structure #$tree_id${NC}"
            echo -e "${CYAN}=========================================${NC}"
            
            if [[ "$UPDATE_MODE" == true ]]; then
                # Update mode: find and update existing files
                if find_existing_files "$target_dir" "${TREE_BLOCKS[$tree_index]}"; then
                    ((processed_count++)) || true
                else
                    ((error_count++)) || true
                    log_warning "Structure #$tree_id update completed with warnings"
                fi
            else
                # Create mode: create new structure
                if parse_and_create_structure "${TREE_BLOCKS[$tree_index]}" "$target_dir" "$tree_id"; then
                    ((processed_count++)) || true
                else
                    ((error_count++)) || true
                    log_warning "Structure #$tree_id creation completed with warnings"
                fi
            fi
        else
            log_error "Invalid structure index: $tree_index"
            ((error_count++)) || true
        fi
    done
    
    # Clean up temporary file if created
    if [[ -n "${TEMP_FILE:-}" && -f "$TEMP_FILE" ]]; then
        rm -f "$TEMP_FILE"
    fi
    
    # Summary
    echo -e "\n${GREEN}🎉 PROJECTION SUMMARY${NC}"
    echo -e "${GREEN}=====================${NC}"
    if [[ $processed_count -gt 0 ]]; then
        if [[ "$UPDATE_MODE" == true ]]; then
            log_success "✅ Update mode: Successfully processed $processed_count structure(s)"
        elif [[ "$PROJECT_MODE" == "project" ]]; then
            log_success "✅ Project mode: Successfully projected $processed_count structure(s)"
        else
            log_success "✅ Create mode: Successfully processed $processed_count structure(s)"
        fi
        
        if [[ "$EXTRACT_CODE" == true ]]; then
            log_info "📚 Code blocks utilized: ${#CODE_BLOCKS[@]}"
        fi
        
        if [[ $error_count -gt 0 ]]; then
            log_warning "⚠️  Completed with warnings in: $error_count structure(s)"
        fi
        
        # Final success message
        if [[ "$DRY_RUN" == false ]]; then
            if [[ "$UPDATE_MODE" == true ]]; then
                echo -e "${GREEN}🔄 Project updated successfully! Your files are now synchronized with the LLM response.${NC}"
            else
                echo -e "${GREEN}✨ Project created successfully! Your LLM response has been transformed into a working project.${NC}"
            fi
            echo -e "${CYAN}📁 Project location: $target_dir${NC}"
        else
            echo -e "${YELLOW}🔍 Dry run completed. Review the planned changes above.${NC}"
        fi
    else
        log_error "❌ No structures were successfully processed"
        exit 1
    fi
}
# Entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
