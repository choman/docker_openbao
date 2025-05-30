#!/usr/bin/env bash

EXTERNAL_IP_URL="https://ifconfig.me"
PROXY_INFO="proxyinfo.env"

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
   echo "Please ensure EXTERNAL_PROXY is set correctly in: ${PROXY_INFO}"
}

update_compose_override() {
   local ip=""
   local proxy=""

   ip="$(curl -sS "${EXTERNAL_IP_URL}")"

   if [[ "$ip" = "${EXTERNAL_IP:-}" ]]; then
       proxy="${EXTERNAL_PROXY:-}"
   fi

   # sanatize proxy
   [[ "${proxy}" != */ ]] && proxy="${proxy}/"

   if [[ -n "${proxy}" ]]; then
       echo "Updating override file: compose.override.yml"
       sed -e "s|PROXY|${proxy}|" compose.override.yml.tmpl > compose.override.yml
   fi
}

test_curl
initialize_proxy_info

# shellcheck disable=SC1090
source "${PROXY_INFO}"
update_compose_override

