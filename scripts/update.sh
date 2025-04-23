#!/bin/sh

vps_root_dir="$(dirname "$0")"/../
cd "$vps_root_dir" || { printf " --- Error: cannot enter versioned patch system root directory\n"; exit 1; }

# shellcheck source=./modules
. ./modules

for module in $MODULES; do
    cd "$vps_root_dir" || { printf " --- Error: cannot return to versioned patch system root directory\n"; exit 1; }
    printf " --- Updating module: %s\n" "$module"
    
    # Get module information
    eval URL="\$${module}_URL"
    eval BRANCH="\$${module}_BRANCH"
    eval COMMIT="\$${module}_COMMIT"
    eval DIRECTORY="\$${module}_DIRECTORY"

    # Download/Update the module
    if [ -d "$DIRECTORY" ]; then
        cd "$DIRECTORY" || { printf " --- Error: cannot enter module directory\n"; exit 1; }
        git rev-parse --is-inside-work-tree > /dev/null 2>&1 || { printf " --- Error: module directory \"%s\" is not a git repository\n" "$DIRECTORY"; exit 1; }
        printf " --- Module already cloned\n"
        # TODO: re-update anyways, and throw away unsaved changes, possibly saving them in a branch
        continue
    else
        printf " --- Cloning module...\n"
        git clone "$URL" "$DIRECTORY" || { printf " --- Error: failed to clone module:%s\n" "$URL" ; exit 1; }
    fi

    # Check out branch/commit
    cd "$DIRECTORY" || { printf " --- Error: cannot enter module directory\n"; exit 1; }
    git checkout "$BRANCH"
    HEAD_COMMIT=$(git rev-parse HEAD)
    if [ "$HEAD_COMMIT" != "$COMMIT" ]; then
        printf " --- Warning: HEAD commit of branch \"%s\" does not match wanted commit\n" "$BRANCH"
        printf "              Wanted:   %s\n" "$COMMIT"
        printf "              Upstream: %s\n" "$HEAD_COMMIT"
        git checkout "$COMMIT"
    fi
done