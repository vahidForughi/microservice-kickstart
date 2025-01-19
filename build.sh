#!/bin/bash

verbose=false

while [ "$#" -gt 0 ]
do
    case "$1" in
        -h | --help) echo "Build All Repos";;
        -v | --verbose) verbose=true;;
    esac
    shift
done

echo "Building ..."

makable_repos=(
  'service_link_shortner'
)

[[ -z "${APP_ENV}" ]] && app_env='local' || app_env="${APP_ENV}"
[[ "$verbose" = true ]] && build_repo_command_args="${build_repo_command_args} --progress=plain" || build_repo_command_args=""

for repo in ${makable_repos[@]}; do
  git clone vahidForughi/${repo}
  if [ -d "${repo}" ]; then
    cd "${repo}"
    chmod +x "entrypoint.sh"
    chmod +x "healthcheck.sh"
    echo "making ${repo} ..."
    make build-${app_env} args="${build_repo_command_args}"
    cd ".."
  else
    echo "Not such directory ${PWD}/${repo}"
  fi
done
