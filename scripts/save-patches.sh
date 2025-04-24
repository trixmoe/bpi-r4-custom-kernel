#!/bin/sh

vps_root_dir=$(realpath "$(dirname "$0")"/../)
cd "$vps_root_dir" || { printf " --- Error: cannot enter versioned patch system root directory\n"; exit 1; }

# shellcheck source=./modules
. ./modules

save_patches()
{
    git rev-parse "$INCLUDING_COMMIT" >/dev/null 2>&1 || { printf " --- Error: \"%s\" is missing from module \"%s\"\n" "$INCLUDING_COMMIT" "$DIRECTORY"; exit 1; }
    git format-patch -k --patience -o "$vps_ouput_dir" "$BEFORE_COMMIT..$INCLUDING_COMMIT"
}

for module in $MODULES; do
    printf " --- Saving patches for module: %s\n" "$module"
    cd "$vps_root_dir" || { printf " --- Error: cannot enter versioned patch system root directory\n"; exit 1; }
    eval DIRECTORY="\$${module}_DIRECTORY"
    cd "$DIRECTORY" || { printf " --- Error: cannot enter module directory \"%s\"\n" "$DIRECTORY"; continue; }

    vps_ouput_dir=$vps_root_dir/patches/$DIRECTORY/
    mkdir -p "$vps_ouput_dir"

    eval COMMIT="\$${module}_COMMIT"

    # Set the right committer and date to have fixed commit hashes
    git config --local user.name "vps"
    git config --local user.email "vps@invalid"
    git rebase -r "$COMMIT" --exec 'git commit --amend --no-edit'
    FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch --env-filter 'export GIT_COMMITTER_DATE="$GIT_AUTHOR_DATE"' "$COMMIT..HEAD"
    git config --local --unset user.name
    git config --local --unset user.email

    # Save generic
    vps_ouput_dir="$vps_root_dir"/patches/"$DIRECTORY"/generic
    mkdir -p "$vps_ouput_dir"
    BEFORE_COMMIT=$COMMIT
    INCLUDING_COMMIT=generic
    save_patches

    # Save specific
    # TODO: use tags to save to the right directory
    # TODO: move to vps-specific tags to be able to have n layers
    vps_ouput_dir="$vps_root_dir"/patches/"$DIRECTORY"/specific
    mkdir -p "$vps_ouput_dir"
    BEFORE_COMMIT=$INCLUDING_COMMIT
    INCLUDING_COMMIT=HEAD
    save_patches
done