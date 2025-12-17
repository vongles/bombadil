build_prompt() {
    local exit_status=$?
    local C_RESET='\[\e[0m\]'
    local C_B_RED='\[\e[1;31m\]'
    local C_B_GREEN='\[\e[1;32m\]'
    local C_B_YELLOW='\[\e[1;33m\]'
    local C_D_GRAY='\[\e[2;37m\]'

    local prompt_exit
    if [[ $exit_status -eq 0 ]]; then prompt_exit="${C_B_GREEN}✔${C_RESET}"; else prompt_exit="${C_B_RED}✘ ${exit_status}${C_RESET}"; fi

    if command -v git &> /dev/null; then
         local git_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
         if [ -n "$git_branch" ]; then git_branch=" (${git_branch})"; fi
    fi

    PS1="\n${C_D_GRAY}[${C_RESET}\u${C_D_GRAY}@${C_RESET}\h${C_D_GRAY}] ${C_B_YELLOW}\w${C_B_RED}${git_branch}\n${C_D_GRAY}↳ ${prompt_exit} \$ "
}
PROMPT_COMMAND=build_prompt
