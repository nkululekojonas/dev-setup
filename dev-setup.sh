#!/usr/bin/env bash
#
# setup-dev.sh: C Dev Setup Automator

# Constants
PROJECT_NAME="$1"

macos=false
linux=false
case "$OSTYPE" in
    darwin*) macos=true ;;
    linux*) linux=true ;;
    *)
        echo "$0: unsupported $OSTYPE" 
        exit 1
        ;;
esac

usage()
{
    echo "usage: $0 directory_name"
    exit 1
}

hascmmnd()
{
    local commnd="$1"
    if command -v "$commnd" &>/dev/null
    then
        return 0
    else
        return 1
    fi
}

install()
{
    local tool="$1"
    echo " "
    echo "Attempting to install [ $tool ] ..."

    if [[ "$macos" = true ]]
    then
        if brew install "$tool"
        then
            echo " "
            echo " [ tick ] $tool installed. "
            return 0
        else
            echo " [ cross ] could'nt install $tool using 'brew'" 
            return 1
        fi
    fi

    if [[ "$linux" = true ]]
    then
        if sudo apt install "$tool"
        then
            echo " "
            echo " [ tick ] $tool installed. "
            return 0
        else
            echo " [ cross ] could'nt install $tool using $OSTYPE package manager "
            return 1
        fi
    fi
}

found()
{
    local tool="$1"
    echo "[ tick ] $tool found"
}

create_project()
{
    local project_dir="$1"
    if [[ ! -d "$project_dir" ]]
    then
        if mkdir -p "${project_dir}/src" "${project_dir}/include" "${project_dir}/build" "${project_dir}/docs"
        then
            echo "[ tick ] Created project directory structure"
        else
            echo "[ cross ] Couldn't create project directory structure"
            exit 1
        fi
    else
        echo "[ cross ] Directory ./$project_dir already exists"
        read -r -p "Do you want to continue[y/n]? " answer

        case $answer in
            [Yy]*) ;;
            [Nn]*) exit 1 ;;
            *) echo "Invalid Input"; exit 1 ;;
        esac
    fi

    cd ./"$PROJECT_NAME" || { echo "$(pwd): No such directory"; exit 1; }
}

create_ignore_file()
{

cat - << _EOF_ > .gitignore
build/
*.o
*.log
_EOF_

}

init_project_repo()
{
    local git_status="$1"
    if [[ "$git_status" = true ]]
    then
        git init .

        create_ignore_file
        echo "# $PROJECT_NAME" >> README.md

        git add --all .
        git commit -m "Initial project setup"
    else
        echo "[ cross ] Git not found. Skipping Repository Initialisation."
    fi
}

if [[ $# -ne 1 ]]
then
    usage
fi

# Supported tools
hasgit=false
hasgcc=false
hasmake=false
hasack=false

tools=("git" "gcc" "make" "ack")

check_tool()
{
    local tool="$1"
    if hascmmnd "$tool"
    then
        found "$tool"
        "has${tool}"=true
    else
        install "$tool" && "has${tool}"=true
    fi
}

for tool in "${tools[@]}"
do
    case "$tool" in
        "git") 
            if hascmmnd "$tool"
            then
                found "$tool"
                hasgit=true
            else
                install "$tool" && hasgit=true
            fi
            ;;
        "gcc") 
            if hascmmnd "$tool"
            then
                found "$tool"
                hasgcc=true
            else
                install "$tool" && hasgcc=true
            fi
            ;;
        "make") 
            if hascmmnd "$tool"
            then
                found "$tool"
                hasmake=true
            else
                install "$tool" && hasmake=true
            fi
            ;;
        "ack")
            check_tool "$tool"
            ;;
        *) echo "$0: Tool not supported"
    esac
done

echo " "

if init_project_repo "$hasgit"
then
    echo "[ tick ] $PROJECT_NAME Repo Initialised."
fi

exit 0
