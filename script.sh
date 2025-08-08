#!/data/data/com.termux/files/usr/bin/bash

# Define color codes for a more vibrant output
Color_Off='\033[0m'
Red='\033[0;31m'
Green='\033[1;32m'
Blue='\033[1;34m'
Yellow='\033[1;33m'
Purple='\033[0;35m'
Cyan='\033[0;36m'

# Define paths for configuration files and a version constant
CONFIG_FISH_PATH="$PREFIX/etc/fish/config.fish"
NEOFETCH_CONFIG_DIR="$HOME/.config/neofetch"
NEOFETCH_CONFIG_FILE="$NEOFETCH_CONFIG_DIR/config.conf"
SCRIPT_VERSION="1.1.3"
SETUP_COMPLETE_FILE="$HOME/.mintos_setup_complete"

# Function to print colored messages
print_message() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${Color_Off}"
}

# Function to check if a command exists in the system's PATH
command_exists() {
    type -p "$1" &>/dev/null
}

# Function to display system information and changelog
show_system_info() {
    print_message "$Purple" "--- MintOS Software Update Utility ---"
    echo ""
    print_message "$Yellow" "System Information:"
    echo -e "  ${Cyan}OS Version:${Color_Off} MintOS 1.1.3"
    echo -e "  ${Cyan}Security Patch:${Color_Off} 1 August 2025"
    echo ""
    print_message "$Yellow" "Changelog:"
    echo -e "  ${Green}*${Color_Off} Fixed the 'software-update' command pathing issue."
    echo -e "  ${Green}*${Color_Off} Added more robust error handling for dependencies."
    echo -e "  ${Green}*${Color_Off} Updated the core 'updateme' alias for stability."
    echo -e "  ${Green}*${Color_Off} Fixed the color code formatting for 'software-update' output."
    echo ""
    print_message "$Purple" "--------------------------------------"
}

# The following functions contain the original setup logic from the user's script
# They are now called only on the first run of the script.

check_dependencies() {
    print_message "$Yellow" "Updating package lists..."
    if ! pkg update -y; then
        print_message "$Red" "Failed to update package lists."
        exit 1
    fi
    print_message "$Green" "Package lists updated."

    print_message "$Yellow" "Checking and installing dependencies..."
    
    local essential_pkgs=("fish" "figlet" "neofetch")
    local optional_pkgs=("lolcat")

    for pkg in "${essential_pkgs[@]}"; do
        if ! command_exists "$pkg"; then
            print_message "$Cyan" "Attempting to install dependency: $pkg..."
            if ! pkg install -y "$pkg"; then
                print_message "$Red" "Failed to install dependency: $pkg."
                exit 1
            fi
            if ! command_exists "$pkg"; then
                print_message "$Red" "Dependency $pkg still not found."
                exit 1
            fi
        fi
    done
    
    for pkg in "${optional_pkgs[@]}"; do
        if ! command_exists "$pkg"; then
            print_message "$Cyan" "Attempting to install optional dependency: $pkg..."
            if pkg install -y "$pkg"; then
                if command_exists "$pkg"; then
                    print_message "$Green" "Optional dependency $pkg installed."
                fi
            fi
        fi
    done
}

backup_neofetch_config() {
    if [[ -f "$NEOFETCH_CONFIG_FILE" ]]; then
        local backup_file="${NEOFETCH_CONFIG_FILE}.bak_$(date +%Y%m%d_%H%M%S)"
        mv "$NEOFETCH_CONFIG_FILE" "$backup_file"
    fi
    mkdir -p "$NEOFETCH_CONFIG_DIR"
}

configure_banner_and_greeting() {
    read -r -p "$(echo -e "${Cyan}Enter text for your banner (default: MintOS Shell): ${Color_Off}")" banner_text
    banner_text=${banner_text:-"MintOS Shell"}
    local fonts=("smslant" "standard" "slant" "big" "banner" "digital" "starwars" "larry3d")
    for i in "${!fonts[@]}"; do
        echo -e "${Yellow}$((i+1))) ${fonts[$i]}${Color_Off}"
    done
    local font_choice
    while true; do
        read -r -p "$(echo -e "${Cyan}Choose a font number (default: 1 for smslant): ${Color_Off}")" font_choice
        font_choice=${font_choice:-1}
        if [[ "$font_choice" =~ ^[0-9]+$ ]] && [ "$font_choice" -ge 1 ] && [ "$font_choice" -le "${#fonts[@]}" ]; then
            banner_font="${fonts[$((font_choice-1))]}"
            break
        else
            print_message "$Red" "Invalid choice."
        fi
    done
    local banner_command
    if command_exists "lolcat"; then
        banner_command="figlet -f \"$banner_font\" \"$banner_text\" | lolcat -F 0.3"
    else
        banner_command="figlet -f \"$banner_font\" \"$banner_text\""
    fi

    local SCRIPT_PATH
    SCRIPT_PATH="$(realpath "$0")"

    cat > "$CONFIG_FISH_PATH" <<- EOF
# --- MintOS Fish Configuration v$SCRIPT_VERSION ---

function fish_greeting
    clear
    echo ""
    $banner_command
    echo ""
    set -l user_color (set_color blue --bold)
    set -l info_color (set_color cyan)
    set -l normal_color (set_color normal)
    set -l quote_color (set_color magenta)
    set -l version_color (set_color --bold white)

    echo -e "Welcome to \033[1;35mMintOS\033[0m \$version_color(v$SCRIPT_VERSION)\$normal_color, \$user_color\$USER\$normal_color!"
    echo -e "--------------------------------------"
    echo -e "\$info_colorKernel:\$normal_color "(uname -o)" "(uname -r)
    echo -e "\$info_colorUptime:\$normal_color "(uptime -p | sed 's/up //')
    echo -e "\$info_colorDate:\$normal_color "(date "+%A, %B %d, %Y %I:%M %p")
    echo -e "--------------------------------------"

    set -l quotes "Keep learning, stay curious!" \\
                 "Code something awesome today!" \\
                 "The only way to do great work is to love what you do." \\
                 "Persistence is key to success." \\
                 "Embrace the chaos, find the order."
    echo -e "\$quote_color\$(random choice \$quotes)\$normal_color"
    echo ""
    echo -e "Type '\033[1;32mupdateme\033[0m' to update Termux packages."
    echo -e "Type '\033[1;32msoftware-update\033[0m' for MintOS system info."
    echo -e "Type '\033[1;32mmyaliases\033[0m' to list your custom aliases."
    echo -e "Type '\033[1;32mneofetch\033[0m' to display system info."
    echo ""

end

# --- Core Aliases ---
alias updateme="pkg update -y && pkg upgrade -y && echo -e '${Green}System updated successfully!${Color_Off}'"
alias myaliases="echo -e '${Purple}--- Your Custom Aliases (v$SCRIPT_VERSION) ---${Color_Off}'; grep -E '^alias ' '$CONFIG_FISH_PATH' | grep -vE '^alias updateme|^alias myaliases|^alias software-update|^# User Defined Aliases Start'; echo -e '${Purple}-------------------------${Color_Off}'"
alias software-update="bash '$SCRIPT_PATH' --software-update"

# --- User Defined Aliases Start ---

Example: alias ll='ls -lAhF --color=auto'

EOF
}

configure_user_aliases() {
    while true; do
        read -r -p "$(echo -e "${Cyan}Do you want to add a custom alias? (y/n): ${Color_Off}")" add_alias_choice
        case $add_alias_choice in
            [Yy]* )
                read -r -p "$(echo -e "${Blue}Enter alias name: ${Color_Off}")" alias_name
                if [[ -z "$alias_name" ]]; then
                    continue
                fi
                read -r -p "$(echo -e "${Blue}Enter command for '$alias_name': ${Color_Off}")" alias_command
                if [[ -z "$alias_command" ]]; then
                    continue
                fi
                echo "alias $alias_name='$alias_command'" >> "$CONFIG_FISH_PATH"
                ;;
            [Nn]* )
                break
                ;;
            * )
                ;;
        esac
    done
    echo "# --- User Defined Aliases End ---" >> "$CONFIG_FISH_PATH"
}

finalize_setup() {
    [[ -f "$PREFIX/etc/motd" ]] && rm "$PREFIX/etc/motd"
    local neofetch_command="neofetch"
    while true; do
        read -r -p "$(echo -e "${Cyan}Show Android logo with Neofetch on startup? (y/n, default: y): ${Color_Off}")" yn_neofetch
        yn_neofetch=${yn_neofetch:-y}
        case $yn_neofetch in
            [Yy]* )
                break
                ;;
            [Nn]* )
                neofetch_command="neofetch --off"
                break
                ;;
            * )
                ;;
        esac
    done
    echo "" >> "$CONFIG_FISH_PATH"
    echo "$neofetch_command" >> "$CONFIG_FISH_PATH"
    if [[ "$(basename "$SHELL")" != "fish" ]]; then
        chsh -s fish
    fi
}

run_initial_setup() {
    clear
    print_message "$Purple" "MintOS Shell Setup v$SCRIPT_VERSION Initializing..."
    echo -e "$Yellow===================================$Color_Off"
    sleep 1
    
    check_dependencies
    backup_neofetch_config
    configure_banner_and_greeting
    configure_user_aliases
    finalize_setup
    
    touch "$SETUP_COMPLETE_FILE"
    
    print_message "$Green" "Setup Complete!"
    print_message "$Yellow" "Please restart Termux for all changes to take effect."
    echo -e "$Purple Enjoy your enhanced MintOS Shell! ✨ $Color_Off"
}

case "$1" in
    "software-update" | "--software-update")
        show_system_info
        ;;
    *)
        if [[ -f "$SETUP_COMPLETE_FILE" ]]; then
            print_message "$Green" "You are using the latest version."
        else
            run_initial_setup
        fi
        ;;
esac

