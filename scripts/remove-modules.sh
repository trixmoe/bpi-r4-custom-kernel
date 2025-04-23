#!/bin/sh

vps_root_dir=$(realpath "$(dirname "$0")"/../)
cd "$vps_root_dir" || { printf " --- Error: cannot enter versioned patch system root directory\n"; exit 1; }

# shellcheck source=./modules
. ./modules

for module in $MODULES; do
    printf " --- Remove module: %s\n" "$module"

    # Get module information
    eval DIRECTORY="\$${module}_DIRECTORY"

    # Remove module
    if [ -d "$DIRECTORY" ]; then
        rm -rf "$DIRECTORY" || { printf " --- Error: failed to remove module directory\n"; exit 1; }
        printf " --- Module cleaned\n"
    else
        printf " --- Module already cleaned\n"
    fi
done