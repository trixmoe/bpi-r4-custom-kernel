#!/bin/sh

vps_root_dir=$(realpath "$(dirname "$0")"/../)
cd "$vps_root_dir" || { printf " --- Error: cannot enter versioned patch system root directory\n"; exit 1; }

# shellcheck source=./modules
. ./modules

for module in $MODULES; do
    printf " --- Removing module: %s\n" "$module"

    # Get module information
    module_dir="" # SC2154/SC2034
    eval module_dir="\$${module}_DIRECTORY"

    # Remove module
    if [ -d "$module_dir" ]; then
        rm -rf "$module_dir" || { printf " --- Error: failed to remove module directory\n"; exit 1; }
    fi
done