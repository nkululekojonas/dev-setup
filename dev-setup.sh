#!/usr/bin/env bash
#
# setup-dev.sh: C Dev Setup Automator

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
    echo "Attempting to install $tool..."
    if [[ "$macos" = true ]]
    then
        if command brew install "$tool"
        then
            echo " [ tick ] $tool installed. "
        else
            echo " [ x ] could'nt install $tool using 'brew'" 
        fi
    fi

    if [[ "$linux" = true ]]
    then
        if command sudo apt install "$tool"
        then
            echo " [ tick ] $tool installed. "
        else
            echo " [ x ] could'nt install $tool using $OSTYPE package manager "
        fi
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
                hasgit=true
            else
                install "$tool"
            fi
            ;;
        "gcc") 
            if hascmmnd "$tool"
            then
                hasgcc=true
            else
                install "$tool"
            fi
            ;;
        "make") 
            if hascmmnd "$tool"
            then
                hasmake=true
            else
                install "$tool"
            fi
            ;;
        "ack")
            if hascmmnd "$tool"
            then
                hasack=true
            else
                install "$tool"
            fi
            ;;
        *) echo "$0: Tool not supported"
    esac
done

echo "Has git: $hasgit"
echo "Has gcc: $hasgcc"
echo "Has make: $hasmake"
echo "has ack: $hasack"

exit 1

