#!/bin/sh

unset WILL_TAG

print_help()
{
    echo "Usage: apply-patches.sh [option] [patch set]"
    echo "    --tag       Tag the last patch applied with patch set name."
    echo "                ! Required for applying/saving multiple patches."
}

while :; do
    case $1 in
        -\?|--help)
            print_help
            exit
            ;;
        --tag)
            WILL_TAG=1
            shift
            break
            ;;
        --)
            shift
            break
            ;;
        -?*)
            printf 'Ignored unknown parameter: %s\n' "$1"
            ;;
        *)
            break
    esac

    shift
done

PATCH_SET=$1

vps_root_dir=$(realpath "$(dirname "$0")"/../)
cd "$vps_root_dir" || { printf " --- Error: cannot enter versioned patch system root directory\n"; exit 1; }

# shellcheck source=./modules
. ./modules

for module in $MODULES; do
    eval DIRECTORY="\$${module}_DIRECTORY"
    cd "$vps_root_dir/$DIRECTORY" || { printf " --- Error: cannot enter module \"%s\"\n" "$vps_root_dir/$DIRECTORY"; exit 1; }

    git config --local user.name "vps"
    git config --local user.email "vps@invalid"

    git am --committer-date-is-author-date "$vps_root_dir/patches/$DIRECTORY/$PATCH_SET"/*

    if [ -n "$WILL_TAG" ]; then
        git tag "$PATCH_SET"
    fi

    git config --local --unset user.name
    git config --local --unset user.email
done
