#!/bin/sh

cd "$(dirname "$0")"/../ || { printf " --- Error: cannot enter versioned patch system root directory\n"; exit 1; }

# shellcheck source=./modules
. ./modules

for module in $MODULES; do
    cd "$(dirname "$0")"/../ || { printf " --- Error: cannot return to versioned patch system root directory\n"; exit 1; }
    printf " --- Updating module: %s\n" "$module"
    
    # Get module information
    eval URL="\$${module}_URL"
    eval BRANCH="\$${module}_BRANCH"
    eval COMMIT="\$${module}_COMMIT"
    eval DIRECTORY="\$${module}_DIRECTORY"

    # Download/Update the module
    if [ -d "$DIRECTORY" ]; then
        printf " --- Module already cloned\n"
        cd "$DIRECTORY" || { printf " --- Error: cannot enter module directory to update\n"; exit 1; }
        git pull
        cd .. || { printf " --- Error: cannot return to versioned patch system root directory\n"; exit 1; }
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