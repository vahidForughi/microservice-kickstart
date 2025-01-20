#!/bin/bash

verbose=false

declare -A initiable_dockerfiles=(
  ["laravel-base"]="1.0.0",
)
makable_repos=(
  'service_link_shortner'
)

while [ "$#" -gt 0 ]
do
    case "$1" in
        -h | --help) echo "Build All Repos";;
        -v | --verbose) verbose=true;;
    esac
    shift
done

[[ -z "${APP_ENV}" ]] && app_env='local' || app_env="${APP_ENV}"
[[ "$verbose" = true ]] && build_repo_command_args="${build_repo_command_args} --progress=plain" || build_repo_command_args=""

echo "Building ..."

echo "Make Basic Docker Images ..."

cd "dockerfiles"
for dockerfile_name in ${initiable_dockerfiles[@]}; do
  dockerfile_version="${initiable_dockerfiles[${dockerfile_name}]}"
  if [ -n "$(docker images -q microservice-kickstart/${dockerfile_name}:${dockerfile_version})" ]; then
    if [ -e "${dockerfile}.Dockerfile" ]; then
      echo "making ${dockerfile} ..."
      make build-latest name="${dockerfile_name}" version="${dockerfile_version}" args="${build_repo_command_args}"
    else
      echo "Not such file ${PWD}/${dockerfile_name}"
    fi
  else
    echo "Image exists: ${dockerfile_name}"
  fi
done
cd ".."

echo "Make Repos ..."

for repo in ${makable_repos[@]}; do
  git clone https://github.com/vahidForughi/${repo}
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
