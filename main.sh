#!/bin/bash
set -e
set -o pipefail
set -o nounset

cd "${AUTOGIT_REPO_ROOT}"

readonly known_file_patterns="${XDG_DATA_HOME}/auto-git/known-patterns"

_grep_and_succeed_when_no_matches(){
	grep --text "$@" || [ $? = 1 ]
}

find_and_notify_of_unknown_file_patterns(){
    local -r untracked_files="${1}"
    local -r unknown_file_patterns=$(mktemp)

    _grep_and_succeed_when_no_matches --null-data -E -v --file "${known_file_patterns}" "${untracked_files}" | tr '\0' '\n' > "${unknown_file_patterns}"
    if [ "$(wc -l "${unknown_file_patterns}" | cut -d' ' -f1 )" != 0 ]; then
        notify-send --app-name=auto-git --action=logs="See ${unknown_file_patterns}" "Unknown patterns found" |
		while read -r action; do
			if [ "${action}" = logs ]; then
				open-in-terminal less "${unknown_file_patterns}"
			fi
		done
    fi
}

track_known_file_patterns(){
    local -r untracked_files="${1}"
    _grep_and_succeed_when_no_matches --null-data -E --file "${known_file_patterns}" "${untracked_files}" |
    find -files0-from - -maxdepth 0 -mmin +15 -exec git add {} +
}

get_modified_files(){
    git status -u -z --porcelain=v1 |
    _grep_and_succeed_when_no_matches --null-data -vE '/$' # exclude submodules
}

main(){
    local -r tracked_files=$(mktemp)
    local -r untracked_files=$(mktemp)
    local -r deleted_files=$(mktemp)

    # In case there are leftover files in the staging area from the previous run
    if ! git diff --cached --quiet; then
    	git commit --quiet -m Updates
    fi

    get_modified_files |
    awk -v untracked_files="${untracked_files}" -v tracked_files="${tracked_files}" -v deleted_files="${deleted_files}" \
   	 'BEGIN { RS = "\0" } { if ($1 ~ /^\?\?/) { printf "%s\0", substr($0, 4) > untracked_files; next } if ($0 ~ /^ D/) { printf "%s\0", substr($0, 4) > deleted_files; next } printf "%s\0", substr($0, 4) > tracked_files }'

    xargs --no-run-if-empty -0 git add < "${deleted_files}"
    find -files0-from "${tracked_files}" -maxdepth 0 -mmin +15 -exec git add {} +
    find -files0-from "${untracked_files}" -maxdepth 0 -type l -mmin +15 -exec git add {} +
    find_and_notify_of_unknown_file_patterns "${untracked_files}"
    track_known_file_patterns "${untracked_files}"
    if ! git diff --cached --quiet; then
    	git commit --quiet -m Updates
    fi
}

(return 2>/dev/null) || main
