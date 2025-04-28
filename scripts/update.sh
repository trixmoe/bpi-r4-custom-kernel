#!/bin/sh

vps_root_dir=$(realpath "$(dirname "$0")"/../)
cd "$vps_root_dir" || { printf " --- Error: cannot enter versioned patch system root directory\n"; exit 1; }

# shellcheck source=./modules
. ./modules

for module in $MODULES; do
    cd "$vps_root_dir" || { printf " --- Error: cannot return to versioned patch system root directory\n"; exit 1; }
    printf " --- Updating module: %s\n" "$module"
    
    # Get module information
    url=""; branch=""; commit=""; directory="" # SC2154/SC2034
    eval url="\$${module}_URL"
    eval branch="\$${module}_BRANCH"
    eval commit="\$${module}_COMMIT"
    eval directory="\$${module}_DIRECTORY"

    # Download/Update the module
    if [ -d "$directory" ]; then
        cd "$directory" || { printf " --- Error: cannot enter module directory \"%s\"\n" "$directory"; exit 1; }
        git rev-parse --is-inside-work-tree > /dev/null 2>&1 || { printf " --- Error: module directory \"%s\" is not a git repository\n" "$directory"; exit 1; }
        printf " --- Module already cloned\n"
        # git checkout -b vps-"$CURR_BRANCH"-"$(date +%s)"
        # TODO: re-update anyways, and throw away unsaved changes, possibly saving them in a branch
        continue
    else
        printf " --- Cloning module...\n"
        git clone "$url" "$directory" || { printf " --- Error: failed to clone module:%s\n" "$url" ; exit 1; }
    fi

    # Check out branch/commit
    cd "$directory" || { printf " --- Error: cannot enter module directory\n"; exit 1; }
    git checkout "$branch"
    head_commit=$(git rev-parse HEAD)
    if [ "$head_commit" != "$commit" ]; then
        printf " --- Warning: HEAD commit of branch \"%s\" does not match wanted commit\n" "$branch"
        printf "              Wanted:   %s\n" "$commit"
        printf "              Upstream: %s\n" "$head_commit"
        git checkout "$commit"
    fi
done