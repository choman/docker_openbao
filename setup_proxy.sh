#!/usr/bin/env bash

EXTERNAL_IP_URL="https://ifconfig.me"
PROXY_INFO="proxyinfo.env"
PROXY_ENV="proxy.env"

test_curl() {
   if ! command -v curl > /dev/null 2>&1; then
      echo "This script requires curl"
      exit 1
   fi
}

initialize_proxy_info() {
   if [[ ! -f "${PROXY_INFO}" ]]; then
      echo "EXTERNAL_IP=$(curl -sS "${EXTERNAL_IP_URL}")" >  "${PROXY_INFO}"
      echo "EXTERNAL_PROXY=" >> "${PROXY_INFO}"
   fi
}

update_proxy_env() {
   local ip=""
   local proxy=""

   ip="$(curl -sS "${EXTERNAL_IP_URL}")"

   if [[ "$ip" = "${EXTERNAL_IP:-}" ]]; then
       proxy="${EXTERNAL_PROXY:-}"
   fi

   # sanatize proxy
   [[ "${proxy}" != */ ]] && proxy="${proxy}/"

   echo "PROXY='${proxy:-}'" > "${PROXY_ENV}"
}

test_curl
initialize_proxy_info

# shellcheck disable=SC1090
source "${PROXY_INFO}"
update_proxy_env

