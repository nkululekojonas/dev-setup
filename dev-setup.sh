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
        if command brew install "$tool"
        then
            echo " "
            echo " [ tick ] $tool installed. "
            return 0
        else
            echo " [ x ] could'nt install $tool using 'brew'" 
            return 1
        fi
    fi

    if [[ "$linux" = true ]]
    then
        if command sudo apt install "$tool"
        then
            echo " "
            echo " [ tick ] $tool installed. "
            return 0
        else
            echo " [ x ] could'nt install $tool using $OSTYPE package manager "
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
            if hascmmnd "$tool"
            then
                found "$tool"
                hasack=true
            else
                install "$tool" && hasack=true
            fi
            ;;
        *) echo "$0: Tool not supported"
    esac
done

echo " "

create_project "$PROJECT_NAME"
exit 1
