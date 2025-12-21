# @pastex file: btds_upgrade_kernel.sh
# @pastex exec: bash %f
# @pastex usage: Force-updates pastex to V4.5.1 (Git + Bombadil Compliant)

#!/bin/bash

# --- CONSTANTS ---
REPO_SCRIPT_DIR="$HOME/btds_dots/btds_scripts"
TARGET_FILE="$REPO_SCRIPT_DIR/pastex"
BACKUP_DIR="/tmp/btds_backup_$(date +%s)"

echo -e "\033[1;34m>> [KERNEL] Initiating Pastex V4.5.1 Upgrade...\033[0m"

# 1. PREP WORK
mkdir -p "$REPO_SCRIPT_DIR"
mkdir -p "$BACKUP_DIR"

if [ -f "$TARGET_FILE" ]; then
    cp "$TARGET_FILE" "$BACKUP_DIR/pastex_old"
    echo "   + Backup created at $BACKUP_DIR"
fi

# 2. INJECT CODE (The Payload)
# We write the raw V4.5.1 source code directly to the repository file.
cat << 'EOF' > "$TARGET_FILE"
#!/bin/bash
# ==============================================================================
# B.T.D.S. VELOCITY TOOL: pastex v4.5.1 (The Final Word)
# PURPOSE: Clipboard-to-Execution Pipeline with Git & Bombadil Compliance.
# COMPLIANCE: L.VIII Code Mandate / FHS Standard
# ==============================================================================

pastex() {
    # --- 1. CONFIGURATION & CONSTANTS ---
    # We use $HOME explicitly to avoid tilde expansion failures
    local CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/btds"
    local CONFIG_FILE="$CONFIG_DIR/pastex.toml"
    local TEMP_BUFFER="/tmp/pastex_buffer_$(date +%s)"
    
    # Ensure config directory exists
    mkdir -p "$CONFIG_DIR"
    if [[ ! -f "$CONFIG_FILE" ]]; then
        # Create default TOML if missing
        echo -e "[btds_core]\nversion = \"4.5.1\"\ncompliance = \"bombadil\"\n\n[paths]\n# SOURCE: The Git Repo\nscripts_dir = \"$HOME/btds_dots/btds_scripts\"\n# TARGET: The Executable Path\ndeploy_dir = \"$HOME/.local/bin/btds\"" > "$CONFIG_FILE"
    fi

    # --- 2. DEPENDENCY CHECK (yq) ---
    if ! command -v yq &> /dev/null; then
        echo -e "\033[31m>> [ERR] 'yq' missing. Please install 'go-yq' or 'yq'.\033[0m"
        return 1
    fi

    # --- 3. CLIPBOARD INGESTION ---
    if command -v termux-clipboard-get &> /dev/null; then 
        termux-clipboard-get > "$TEMP_BUFFER"
    elif command -v wl-paste &> /dev/null; then 
        wl-paste > "$TEMP_BUFFER"
    elif command -v pbpaste &> /dev/null; then 
        pbpaste > "$TEMP_BUFFER"
    elif command -v xclip &> /dev/null; then 
        xclip -selection clipboard -o > "$TEMP_BUFFER"
    else 
        echo -e "\033[31m>> [ERR] No clipboard tool found.\033[0m"
        rm "$TEMP_BUFFER"
        return 1
    fi

    # --- 4. METADATA EXTRACTION ---
    local head_content=$(head -n 20 "$TEMP_BUFFER")
    
    # Extract raw values
    local raw_file=$(echo "$head_content" | grep -i "# @pastex file:" | cut -d':' -f2 | xargs)
    local meta_boot=$(echo "$head_content" | grep -i "# @pastex boot:" | cut -d':' -f2- | sed 's/^[ \t]*//')
    local meta_exec=$(echo "$head_content" | grep -i "# @pastex exec:" | cut -d':' -f2- | sed 's/^[ \t]*//')
    local meta_args=$(echo "$head_content" | grep -i "# @pastex args:" | cut -d':' -f2- | sed 's/^[ \t]*//')
    
    # Fail if no target file defined
    if [[ -z "$raw_file" ]] && [[ -z "$1" ]]; then 
        echo -e "\033[31m>> [ERR] No filename detected. Add '# @pastex file: name' to clipboard.\033[0m"
        rm "$TEMP_BUFFER"
        return 1
    fi

    # --- 5. PATH SANITIZATION (THE FIX) ---
    # 1. Replace literal '~' with $HOME
    local target_file="${raw_file/#\~/$HOME}"
    
    # 2. Extract just the filename for Bombadil handling
    local filename=$(basename "$target_file")
    
    # 3. Handle CLI override
    if [[ "$1" != -* ]] && [[ -n "$1" ]]; then
        filename="$1"
        shift
    fi

    # --- 6. BOMBADIL COMPLIANCE LOGIC ---
    # Read config
    local compliance_mode=$(yq '.btds_core.compliance' "$CONFIG_FILE" -r)
    local source_dir=$(yq '.paths.scripts_dir' "$CONFIG_FILE" -r) # e.g. ~/btds_dots/btds_scripts
    local deploy_dir=$(yq '.paths.deploy_dir' "$CONFIG_FILE" -r)  # e.g. ~/.local/bin/btds

    # Expand variables in config paths if yq returned literal $HOME
    source_dir="${source_dir/#\$HOME/$HOME}"
    deploy_dir="${deploy_dir/#\$HOME/$HOME}"
    source_dir="${source_dir/#\~/$HOME}"
    deploy_dir="${deploy_dir/#\~/$HOME}"

    local final_path=""

    if [[ "$compliance_mode" == "bombadil" ]]; then
        # Ensure directories exist
        mkdir -p "$source_dir"
        mkdir -p "$deploy_dir"

        # A. Write to SOURCE (The Dotfile Repo)
        local source_path="$source_dir/$filename"
        cat "$TEMP_BUFFER" > "$source_path"
        chmod +x "$source_path"
        
        # B. Link to TARGET (The Executable Path)
        # We rely on 'bombadil link' usually, but we force-link here for immediate velocity
        local deploy_path="$deploy_dir/$filename"
        ln -sf "$source_path" "$deploy_path"
        
        final_path="$deploy_path"
        echo -e "\033[32m>> [BOMBADIL] Ingested: $source_path\033[0m"
        echo -e "\033[32m>> [LINK] Active: $deploy_path\033[0m"
    else
        # Standard Mode (Legacy)
        if [[ "$target_file" != /* ]]; then
            target_file="$deploy_dir/$target_file"
        fi
        
        mkdir -p "$(dirname "$target_file")"
        cat "$TEMP_BUFFER" > "$target_file"
        chmod +x "$target_file"
        final_path="$target_file"
        echo -e "\033[32m>> [PASTEX] Deployed: $final_path\033[0m"
    fi

    rm "$TEMP_BUFFER"

    # --- 7. ARGUMENT MERGE & EXECUTION ---
    local run_flag=false
    # Check flags
    for arg in "$@"; do if [[ "$arg" == "--run" ]]; then run_flag=true; fi; done
    
    # Merge args
    local exec_args=""
    if [[ -n "$meta_args" ]]; then exec_args="$meta_args"; fi
    
    # Execution
    if [[ "$run_flag" == true ]]; then
        
        # Boot (Install Deps)
        if [[ -n "$meta_boot" ]]; then
            echo ">> [BOOT] $meta_boot"
            # Replace %f with final_path in boot command if needed
            local boot_cmd="${meta_boot//%f/$final_path}"
            eval "$boot_cmd"
        fi

        echo "--------------------------------"
        # Exec
        if [[ -n "$meta_exec" ]]; then
            local cmd_str="${meta_exec//%f/$final_path}"
            echo ">> [EXEC] $cmd_str $exec_args"
            eval "$cmd_str $exec_args"
        else
            echo ">> [EXEC] $final_path $exec_args"
            "$final_path" $exec_args
        fi
    fi
}
EOF

# 3. SET PERMISSIONS
chmod +x "$TARGET_FILE"
echo "   + Code written to $TARGET_FILE"

# 4. FORCE LINK (Bombadil)
# We manually link it now just in case Bombadil misses it, 
# but then we run bombadil link to officialize it.
mkdir -p "$HOME/.local/bin/btds"
ln -sf "$TARGET_FILE" "$HOME/.local/bin/btds/pastex"
echo "   + Symlink verified at ~/.local/bin/btds/pastex"

if command -v bombadil &> /dev/null; then
    bombadil link
    echo "   + Bombadil state refreshed."
else
    echo "   ! Bombadil not found (Skipping link step)"
fi

# 5. VERSION CONTROL (Git)
cd "$HOME/btds_dots" || exit
if [ -d ".git" ]; then
    git add .
    git commit -m "System Upgrade: Pastex V4.5.1 (Self-Correction)"
    echo "   + Changes committed to Git."
else
    echo "   ! Not a git repo (Skipping commit)"
fi

echo -e "\033[1;32m>> [SUCCESS] B.T.D.S. Kernel Updated (V4.5.1)\033[0m"
echo "   Restart your shell or run 'source ~/.bashrc' to load the new function."
