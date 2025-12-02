#!/usr/bin/env bash
#
# setup-dev.sh: C Dev Setup Automator

usage()
{
    echo "usage: $0 directory_name"
    exit 1
}

error()
{
    local message="$1"
    echo -e "\e[1;31m[ \u2717 ] ${message}\e[0m"
}

success()
{
    local message="$1"
    echo -e "\e[1;32m[ \u2713 ] ${message}\e[0m"

}

info()
{
    local message="$1"
    echo -e "\e[1;33m[ ! ] ${message}\e[0m"
}

has_cmd()
{
    local cmd="$1"
    if command -v "$cmd" &> /dev/null
    then
        return 0
    else
        return 1
    fi
}

install()
{
    local tool="$1"
    echo 
    echo "Attempting to install [ $tool ] ..."

    # First Check Macos
    if [[ "$macos" = true ]]
    then
        if brew install "$tool" &> /dev/null
        then
            success "$tool installed using 'brew'"
            return 0
        else
            error "Couldn't install $tool using 'brew'"
            return 1
        fi

    elif [[ "$linux" = true ]]
    then
        if sudo apt install "$tool" &> /dev/null
        then
            success "$tool installed using 'apt'"
            return 0
        elif sudo dnf install "$tool" &> /dev/null
        then
            success "$tool installed using 'dnf'"
            return 0
        elif sudo pacman -S --noconfirm "$tool" &> /dev/null
        then
            success "$tool installed using 'pacman'"
            return 0
        else
            error "Couldn't install $tool using $OSTYPE package manager"
            return 1
        fi
    else
        error "Unsupported $OSTYPE"
        exit 1
    fi
}

found()
{
    local tool="$1"
    success "$tool found"
}

create_project()
{
    local project_dir="$1"
    if [[ ! -d "$project_dir" ]]
    then
        if mkdir -p "${project_dir}/src" "${project_dir}/include" "${project_dir}/build" "${project_dir}/docs"
        then
            success "Created project directory structure: ${project_dir}/src ${project_dir}/include ${project_dir}/build ${project_dir}/docs"
        else
            error "Couldn't create project directory structure"
            exit 1
        fi
    else
        error "Directory ./$project_dir already exists"
        read -r -p "Do you want to continue[y/n]? " answer

        case $answer in
            [Yy]*) ;;
            [Nn]*) exit 1 ;;
            *) echo "Invalid Input"; exit 1 ;;
        esac
    fi

    cd ./"$project_dir" || { error "No such directory $project_dir"; exit 1; }
}

create_ignore_file()
{
cat - << _EOF_ > .gitignore
build/
*.o
*.log
_EOF_

success "Created .gitignore file"
}

init_project_repo()
{
    local git_status="$1"
    if [[ "$git_status" = true ]]
    then
        git init
        
        create_ignore_file
        echo "# $PROJECT_NAME" >> "README.md"
        
        git add --all
        git commit -m "Initial project setup" || { error "Git commit failed. Check Git Configurtion"; return 1; }

    else
       info "Git not found - skipping repository setup"
       return 1
    fi
}

update_tool_status()
{
    local tool="$1"
    case "$tool" in
        "git") hasgit=true ;;
        "gcc") hasgcc=true ;;
        "make") hasmake=true ;;
        "ack") hasack=true ;;
        *) info "Unsupported $tool"; return 0;
    esac
}

check_tool_status()
{
    local tool="$1"
    if has_cmd "$tool"
    then
        found "$tool" && update_tool_status "$tool"
    else
        if install "$tool" 
        then
            update_tool_status "$tool"
        fi
    fi
}

create_project_config()
{
cat - << _EOF_ > project-config.txt
Created Project $PROJECT_NAME : $(date)
OS:$OSTYPE
SHELL:$SHELL
Tools detected:
- git: $hasgit
- gcc: $hasgcc
- make: $hasmake
- ack: $hasack
_EOF_

success "Created project config file"
}

# --- Main Execution ---

# Validate inputs
if [[ $# -ne 1 ]]
then
    usage
fi

# Declare variables
PROJECT_NAME="$1"

# Detect host OS
macos=false
linux=false
case "$OSTYPE" in
    darwin*) macos=true ;;
    linux*) linux=true ;;
    *) error "$0: unsupported $OSTYPE"; exit 1 ;;
esac

# Tools to check
hasack=false
hasgit=false
hasgcc=false
hasmake=false

# Supported tools
tools=("git" "gcc" "make" "ack")

# Setup new directory or exit early
create_project "$PROJECT_NAME"

# Check installation
for tool in "${tools[@]}"
do
    check_tool_status "$tool"
done

# Try to initialiase repo
if init_project_repo "$hasgit"
then
    success "$PROJECT_NAME repository initialised"
else
    info "Skipped git repository not initialised"
fi

# Create project-config-file
create_project_config

exit 0
