#!/usr/bin/env bash

readonly COMMON_SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )/common.sh"
readonly REALPATH_SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )/realpath.sh"

source ${COMMON_SCRIPT}
source ${REALPATH_SCRIPT}

readonly JQ_1_3="$(_realpath ./jq-1.3)"
readonly JQ_1_6="$(_realpath ./jq-1.6)"

abort() {
  exit "$1"
}

download_jq() {
  wget \
    https://github.com/stedolan/jq/releases/download/jq-1.3/jq-linux-x86_64 \
    https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64

  sha256sum -c - <<EOF
dbacac81ebc00a7387e4c5e539a7a475981a1ac6ada20a2f6b1d8f950027751e  jq-linux-x86_64
af986793a515d500ab2d35f8d2aecd656e764504b789b66d7e1a0b727a124c44  jq-linux64
EOF

  mv jq-linux-x86_64 jq-1.3
  mv jq-linux64 jq-1.6
  chmod +x jq-1.3 jq-1.6

}

print_jq_versions() {
  hash -p ${JQ_1_3} jq
  hash -t jq
  jq --version

  hash -p ${JQ_1_6} jq
  hash -t jq
  jq --version
}

test_jqRawStrTop() {
  # jq version 1.3
  #
  local val
  echo "test_jqRawStrTop - jq 1.3"
  hash -p ${JQ_1_3} jq
  val=$(jqRawStrTop device-name blueline/config.json)
  if [[ ${val} != pixel3 ]]; then
    echo "[-] FAIL test_jqRawStrTop_jq-1.3 - val: ${val}" >&2
    exit 1
  fi

  echo "test_jqRawStrTop - jq 1.6"
  hash -p ${JQ_1_6} jq
  val=$(jqRawStrTop device-name blueline/config.json)
  if [[ ${val} != pixel3 ]]; then
    echo "[-] FAIL test_jqRawStrTop_jq-1.6 - val: ${val}" >&2
    exit 1
  fi
}

test_jqIncRawArrayTop() {
  local val
  local expected
  declare -a vala
  expected="abl aop cmnlib cmnlib64 devcfg hyp keymaster modem qupfw tz xbl xbl_config "

  echo "test_jqIncRawArrayTop - jq 1.3"
  hash -p ${JQ_1_3} jq
  val=$(jqIncRawArrayTop extra-partitions blueline/config.json | sort | tr '\n' ' ')
  if [[ "${val}" != "${expected}" ]]; then
    echo "[-] FAIL: test_jqIncRawArrayTop_jq-1.3 - actual: ${val}" >&2
    exit 1
  fi

  echo "test_jqIncRawArrayTop - jq 1.6"
  hash -p ${JQ_1_6} jq
  val=$(jqIncRawArrayTop extra-partitions blueline/config.json | sort | tr '\n' ' ')
  if [[ "${val}" != "${expected}" ]]; then
    echo "[-] FAIL: test_jqIncRawArrayTop_jq-1.6 - actual: ${val}" >&2
    exit 1
  fi
}

test_jqRawStr() {
  # jq version 1.3
  #
  local val
  echo "test_jqRawStr - jq 1.3"
  hash -p ${JQ_1_3} jq
  val=$(jqRawStr 28 full overlays-dir sailfish/config.json)
  if [[ ${val} != overlays-api26-full ]]; then
    echo "[-] FAIL test_jqRawStr_jq-1.3 - val: ${val}" >&2
    exit 1
  fi

  echo "test_jqRawStr - jq 1.6"
  hash -p ${JQ_1_6} jq
  val=$(jqRawStr 28 full overlays-dir sailfish/config.json)
  if [[ ${val} != overlays-api26-full ]]; then
    echo "[-] FAIL test_jqRawStr_jq-1.6 - val: ${val}" >&2
    exit 1
  fi
}

test_jqIncRawArray() {
  local val
  local expected
  declare -a vala
  expected="bufferhubd com.android.ims.rcsmanager libion libminui nanotool performanced PresencePolling RcsService virtual_touchpad vr_hwc "

  echo "test_jqIncRawArray - jq 1.3"
  hash -p ${JQ_1_3} jq
  val=$(jqIncRawArray 28 full forced-modules sailfish/config.json | sort | tr '\n' ' ')
  if [[ "${val}" != "${expected}" ]]; then
    echo "[-] FAIL: test_jqIncRawArray_jq-1.3 - actual: ${val}" >&2
    exit 1
  fi

  echo "test_jqIncRawArray - jq 1.6"
  hash -p ${JQ_1_6} jq
  val=$(jqIncRawArray 28 full forced-modules sailfish/config.json | sort | tr '\n' ' ')
  if [[ "${val}" != "${expected}" ]]; then
    echo "[-] FAIL: test_jqIncRawArray_jq-1.6 - actual: ${val}" >&2
    exit 1
  fi
}

if [[ ! -x jq-1.3  ]]; then
  download_jq
fi

print_jq_versions
test_jqRawStrTop
test_jqIncRawArrayTop
test_jqRawStr
test_jqIncRawArray
