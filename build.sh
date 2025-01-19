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

[[ -z "${APP_ENV}" ]] && app_env='local' || app_env="${APP_ENV}"
[[ "$verbose" = true ]] && build_repo_command_args="${build_repo_command_args} --progress=plain" || build_repo_command_args=""

echo "Building ..."

initiable_dockerfiles=(
  'laravel-base'
)

echo "Make Basic Docker Images ..."

cd "dockerfiles"
for dockerfile in ${initiable_dockerfiles[@]}; do
  if [ -n "$(docker images -q microservice-kickstart/${dockerfile}:${DOCKER_IMAGE_LARAVEL_BASE_VERSION})" ]
    if [ -e "${dockerfile}.Dockerfile" ]; then
      echo "making ${dockerfile} ..."
      make build-${dockerfile}-latest args="${build_repo_command_args}"
    else
      echo "Not such file ${PWD}/${dockerfile}"
    fi
  fi
done
cd ".."

makable_repos=(
  'service_link_shortner'
)

echo "Make Repos ..."

for repo in ${makable_repos[@]}; do
  git clone https://github.com/vahidForughi/${repo}
  if [ -d "${repo}" ]; then
    cd "${repo}"
    chmod +x "entrypoint.sh"
    chmod +x "healthcheck.sh"
    echo "making ${repo} ..."
    make build-base args="${build_repo_command_args}"
    make build-${app_env} args="${build_repo_command_args}"
    cd ".."
  else
    echo "Not such directory ${PWD}/${repo}"
  fi
done
