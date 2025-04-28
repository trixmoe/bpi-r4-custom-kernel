#!/bin/sh

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
            will_tag=1
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

patch_set=$1

vps_root_dir=$(realpath "$(dirname "$0")"/../)
cd "$vps_root_dir" || { printf " --- Error: cannot enter versioned patch system root directory\n"; exit 1; }

# shellcheck source=./modules
. ./modules

for module in $MODULES; do
    module_dir="" # SC2154/SC2034
    eval module_dir="\$${module}_DIRECTORY"
    patches_dir=$vps_root_dir/patches/$module_dir/$patch_set

    ! [ -d "$patches_dir" ] && { printf " --- Warning: patches \"%s\" do not exist for module \"%s\"\n" "$patch_set" "$module_dir"; continue; }

    cd "$vps_root_dir/$module_dir" || { printf " --- Error: cannot enter module \"%s\"\n" "$vps_root_dir/$module_dir"; exit 1; }

    git config --local user.name "vps"
    git config --local user.email "vps@invalid"

    git am --committer-date-is-author-date "$patches_dir"/*

    if [ -n "$will_tag" ]; then
        git tag "$patch_set"
    fi

    git config --local --unset user.name
    git config --local --unset user.email
done
