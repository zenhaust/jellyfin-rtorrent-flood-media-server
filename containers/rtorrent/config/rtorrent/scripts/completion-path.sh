#! /usr/bin/env bash
#
# Determine a dynamic completion path and print it on stdout for capturing
#
# Call with "-h" for installation instructions!

# List of attributes passed by the 'completion_path' method
arglist=( default session hash name directory base_path tied_to_file is_multi_file label display_name )

# Determine target path (adapt this to your needs)
set_target_path() {
    local month=$(date +'%Y-%m')

    # Only move data downloaded into a "download" directory
    egrep >/dev/null "/download/" <<<"${base_path}/" || return

    # "target_base" is used to complete a non-empty but relative "target" path
    target_base=$(sed -re 's~^(.*)/download/.*~\1/done~' <<<"${base_path}")
    target_tail=$(sed -re 's~^.*/download/(.*)~\1~' <<<"${base_path}")
    test "$is_multi_file" -eq 1 || target_tail="$(dirname "$target_tail")"
    test "$target_tail" != '.' || target_tail=""

    # Append tail path if non-empty
    test -z "$target" -o -z "$target_tail" || target="$target/$target_tail"
} # set_target_path


fail() {
    echo ERROR: "$@"
    exit 1
}

# Take arguments
for argname in "${arglist[@]}"; do
    test $# -gt 0 || fail "'$argname' is missing!"
    eval "$argname"'="$1"'
    shift
done
#set | egrep '^[a-z_]+=' >&2

# Determine target path
target="."
set_target_path
# Return result (an empty target prevents moving)
if test -n "$target"; then
    if test "${target:0:1}" = '/'; then
        echo -n "$target"
    else
        echo -n "${target_base%/}/$target"
    fi
fi
