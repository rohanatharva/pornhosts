#!/usr/bin/env bash

# **********************
# Run PyFunceble Testing
# **********************
# Created by: Mitchell Krog (mitchellkrog@gmail.com)
# Copyright: Mitchell Krog - https://github.com/mitchellkrogza

# ****************************************************************
# This uses the awesome PyFunceble script created by Nissar Chababy
# Find PyFunceble at: https://github.com/funilrys/PyFunceble
# ****************************************************************

# **********************
# Setting date variables
# **********************

version=$(date +%Y.%m)

# ******************
# Set our Input File
# ******************

# As the TRAVIS_BUILD_DIR no longer seems to be working. I'm changing
# that to git_dir
git_dir="$(git rev-parse --show-toplevel)"

testFile="${git_dir}/PULL_REQUESTS/domains.txt"
#testFile="${git_dir}/dev-tools/debug.list"
testDomains=$(git log --word-diff=porcelain -1 -p  -- submit_here/hosts.txt | \
  grep -e "^+" | tail -1 | cut -d "+" -f2 )

RunFunceble () {

    #yeartag="$(date +%Y)"
    #monthtag="$(date +%m)"

    #ulimit -u
    cd "${git_dir}/dev-tools" || exit 1

    hash pyfunceble

	printf "\n\tYou are running with RunFunceble\n\n"

        pyfunceble --ci -q -h -ex --plain \
	    --dns 127.0.0.1:5300 95.216.209.53 116.203.32.67 \
            --autosave-minutes 15 --share-logs --http --idna --dots \
            --hierarchical --ci-branch "${TRAVIS_BRANCH}" \
            --ci-distribution-branch "${TRAVIS_BRANCH}" \
            -db --database-type mariadb \
            --commit-autosave-message "V1.${version}.${TRAVIS_BUILD_NUMBER} [Auto Saved]" \
            --commit-results-message "V1.${version}.${TRAVIS_BUILD_NUMBER} [ci skip]" \
            --cmd-before-end "bash ${git_dir}/dev-tools/FinalCommit.sh" \
            -f "${testFile}"

}
RunFunceble

exit ${?}

# Travis has become single core
#
# -m -p "$(nproc --ignore=1)"
# -db --database-type mariadb
