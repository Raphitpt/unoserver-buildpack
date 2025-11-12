#!/bin/bash

function indent() {
  sed -u 's/^/       /'
}

function warn() {
  echo " !     $*" >&2
}

function topic() {
  echo "-----> $*"
}

function apt_install() {
  local apt_deps="${1}"
  local build_dir="${2}"
  local cache_dir="${3}"
  local env_dir="${4}"

  local apt_manifest="$(mktemp "${build_dir}/Aptfile.unoserver-XXX")"
  echo "${apt_deps}" | tr ' ' '\n' > "${apt_manifest}"

  local apt_deps_buildpack_dir=$(mktemp -d /tmp/apt_buildpack_XXXX)
  local apt_buildpack_url="https://github.com/Scalingo/apt-buildpack.git"

  topic "Cloning apt-buildpack for dependencies"
  git clone --quiet --depth=1 "${apt_buildpack_url}" "${apt_deps_buildpack_dir}" >/dev/null 2>&1

  local apt_log_file=$(mktemp /tmp/apt_log_XXXX.log)

  topic "Installing apt dependencies: ${apt_deps}"
  APT_FILE_MANIFEST="$(basename ${apt_manifest})" "${apt_deps_buildpack_dir}/bin/compile" "${build_dir}" "${cache_dir}" "${env_dir}" >"${apt_log_file}" 2>&1

  if [ $? -ne 0 ] ; then
    tail -n 50 "${apt_log_file}" | indent
    echo
    warn "Failed to install apt packages: $apt_deps"
    echo
    rm -f "${apt_manifest}"
    rm -rf "${apt_deps_buildpack_dir}"
    rm -f "${apt_log_file}"
    exit 1
  fi

  # Source new libs for future operations
  if [ -f "${apt_deps_buildpack_dir}/export" ]; then
    topic "Sourcing apt-buildpack environment"
    source "${apt_deps_buildpack_dir}/export"
  fi

  # Cleanup
  rm -f "${apt_manifest}"
  rm -rf "${apt_deps_buildpack_dir}"
  rm -f "${apt_log_file}"
}
