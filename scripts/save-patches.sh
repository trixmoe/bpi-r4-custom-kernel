#!/bin/sh
# shellcheck source=./scripts/common.sh
. "$(dirname "$0")/common.sh"

vps_root_dir=$(rootdir)

# shellcheck source=./modules
. ./modules

save_patches()
{
    git rev-parse "$including_commit" >/dev/null 2>&1 || { errormsg "\"%s\" is missing from module \"%s\"\n" "$including_commit" "$module_dir"; return 1; }
    git format-patch -k --patience -o "$vps_ouput_dir" "$before_commit..$including_commit"
}

for module in $MODULES; do
    infomsg "Saving patches for module: %s\n" "$module"
    cd "$vps_root_dir" || { errormsg "cannot enter versioned patch system root directory\n"; exit 1; }
    module_dir="" # SC2154/SC2034
    eval module_dir="\$${module}_DIRECTORY"
    cd "$module_dir" || { warnmsg "cannot enter module directory \"%s\"\n" "$module_dir"; continue; }

    vps_ouput_dir=$vps_root_dir/patches/$module_dir/
    mkdir -p "$vps_ouput_dir"

    commit="" # SC2154/SC2034
    eval commit="\$${module}_COMMIT"

    # Set the right committer and date to have fixed commit hashes
    git config --local user.name "vps"
    git config --local user.email "vps@invalid"
    git rebase -r "$commit" --exec 'git commit --amend --no-edit'
    FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch --env-filter 'export GIT_COMMITTER_DATE="$GIT_AUTHOR_DATE"' "$commit..HEAD"
    git config --local --unset user.name
    git config --local --unset user.email

    # Saving commits bottom-up (from upstream to HEAD)
    # Save generic
    vps_ouput_dir="$vps_root_dir"/patches/"$module_dir"/generic
    mkdir -p "$vps_ouput_dir"
    before_commit=$commit
    including_commit=generic
    save_patches || continue

    # Save specific
    # TODO: use tags to save to the right directory
    # TODO: move to vps-specific tags to be able to have n layers
    vps_ouput_dir="$vps_root_dir"/patches/"$module_dir"/specific
    mkdir -p "$vps_ouput_dir"
    before_commit=$including_commit
    including_commit=HEAD
    save_patches || continue
done