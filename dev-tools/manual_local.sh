#!/usr/bin/env bash

# Copyright: https://www.mypdns.org/
# Content: https://gitlab.com/spirillen
# Source: https://github.com/Import-External-Sources/pornhosts
# License: https://www.mypdns.org/wiki/License
# License Comment: GNU AGPLv3, MODIFIED FOR NON COMMERCIAL USE
#
# License in short:
# You are free to copy and distribute this file for non-commercial uses,
# as long the original URL and attribution is included.
#
# Please forward any additions, corrections or comments by logging an
# issue at https://github.com/mypdns/matrix/issues

# As the TRAVIS_BUILD_DIR no longer seems to be working. I'm changing
# that to git_dir
git_dir="$(git rev-parse --show-toplevel)"

export TRAVIS_BUILD_DIR="${git_dir}"

cd "${SCRIPT_PATH}"

#PythonVersion () {
#if grep --quiet -F 'python3.8' $(which python3.8)

#then
  #python3=$(which python3.8)

#elif
  #grep --quiet -F 'python3.7' $(which python3.7)

#then
  #python3=$(which python3.7)

#elif
  #grep --quiet -F 'python3.6' $(which python3.6)

#then
  #printf "\nPyFunceble requires python >=3.7"
  #exit 99

#else
  #printf "\n\tPyFunceble requires Python >=3.7"
  #exit 99
#fi
#}
#PythonVersion

# ***********************************
# Setup input bots and referrer lists
# ***********************************

input="${git_dir}/submit_here/hosts.txt"
snuff="${git_dir}/submit_here/snuff.txt"
testfile="${git_dir}/PULL_REQUESTS/domains.txt"

# This should be replaced by a local whitelist

#whitelist="$(wget -qO ${git_dir}/whitelist 'https://gitlab.com/my-privacy-dns/matrix/matrix/raw/master/source/whitelist/domain.list' > ${git_dir}/whitelist && wget -qO- 'https://gitlab.com/my-privacy-dns/matrix/matrix/raw/master/source/whitelist/wildcard.list' >> ${git_dir}/whitelist )"

# **************************************************************************
# Sort lists alphabetically and remove duplicates before cleaning Dead Hosts
# **************************************************************************

PrepareLists () {

  mkdir -p "${git_dir}/PULL_REQUESTS/"

  sort -u -f "${input}" -o "${input}"
  sort -u -f "${snuff}" -o "${snuff}"

  cat "${snuff}" > "${testfile}"
  cat "${input}" >> "${testfile}"

  sort -u -f "${testfile}" -o "${testfile}"

  dos2unix "${testfile}"
 }
PrepareLists

# ***********************************
# Deletion of all whitelisted domains
# ***********************************

#WhiteListing () {
#if [[ "$(git log -1 | tail -1 | xargs)" =~ "ci skip" ]]
  #then
    #hash uhb_whitelist
    #uhb_whitelist -wc -w "${whitelist}" -f "${testfile}" -o "${testfile}"
#fi
#}
#WhiteListing

#pyfuncebleConfigurationFileLocation="${SCRIPT_PATH}/.PyFunceble.yaml"
#pyfuncebleProductionConfigurationFileLocation="${SCRIPT_PATH}/.PyFunceble_production.yaml"

RunFunceble () {
  PyFunceble=$(which PyFunceble)

  cd "${SCRIPT_PATH}"

  hash PyFunceble

    #if [[ -f "${pyfuncebleConfigurationFileLocation}" ]]
    #then
      #rm "${pyfuncebleConfigurationFileLocation}"
      #rm "${pyfuncebleProductionConfigurationFileLocation}"
    #fi

  #"${python3}"
  "$PyFunceble" -h -m -p $(nproc --ignore=2) -db --database-type mariadb \
    -ex --plain --dns 192.168.1.105 --share-logs --http --idna \
    --hierarchical -f "${testfile}"

  #"$PyFunceble" -h --http --complements --cooldown-time 1\
    #-ex --plain --dns 95.217.218.209:53 --share-logs --idna \
    #--hierarchical -f "${testfile}"
}
RunFunceble

head "${SCRIPT_PATH}/output/domains/ACTIVE/list"

if [ -f "${SCRIPT_PATH}/output/domains/INACTIVE/list" ]
then
  grep -Ev "^($|#)" "${SCRIPT_PATH}/output/domains/INACTIVE/list" > "${git_dir}/submit_here/apparently_inactive.txt"
fi

#if [ -f "${SCRIPT_PATH}/output/domains/ACTIVE/list" ]
#then
#  mkdir -p "${git_dir}/0.0.0.0/"
#  awk '/^(#|$)/{ next }; { printf("0.0.0.0\t%s\n",tolower($1)) }' "${SCRIPT_PATH}/output/domains/ACTIVE/list" > "${git_dir}/0.0.0.0/hosts"
#fi

# Testing the Real script
if [ -f "${SCRIPT_PATH}/output/domains/ACTIVE/list" ]
then
  bash "${SCRIPT_PATH}/GenerateHostsFile.sh"
fi

printf "${git_dir}\n"

#head "${input}"
