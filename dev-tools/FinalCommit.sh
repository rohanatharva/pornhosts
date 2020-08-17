#!/usr/bin/env bash

# Copyright: https://www.mypdns.org/
# Content: https://www.mypdns.org/p/Spirillen/
# Source: https://github.com/Import-External-Sources/pornhosts
# License: https://www.mypdns.org/w/license
# License Comment: GNU AGPLv3, MODIFIED FOR NON COMMERCIAL USE
#
# License in short:
# You are free to copy and distribute this file for non-commercial uses,
# as long the original URL and attribution is included.
#
# Please forward any additions, corrections or comments by logging an
# issue at https://www.mypdns.org/maniphest/
#
# Original attributes and credit
# This hosts file for DD-WRT Routers with DNSMasq is brought to you by Mitchell Krog
# Copyright:Code: https://github.com/mitchellkrogza
# Source:Code: https://github.com/mitchellkrogza/Badd-Boyz-Hosts
# The credit for the original bash scripts goes to Mitchell Krogza

# ***********************************************************
# echo Remove our inactive and invalid domains from PULL_REQUESTS
# ***********************************************************
set -e #-x -v

printf "\n\tRunning FinalCommit.sh\n"

# As the TRAVIS_BUILD_DIR no longer seems to be working. I'm changing
# that to git_dir
git_dir="$(git rev-parse --show-toplevel)"

#exit 0

#cat ${git_dir}/dev-tools/output/domains/ACTIVE/list | grep -v "^$" | grep -v "^#" > tempdomains.txt
#mv tempdomains.txt ${git_dir}/PULL_REQUESTS/domains.txt

if [ -f "${git_dir}/dev-tools/output/domains/INACTIVE/list" ]
then
	echo -e "\nMoving the INACTIVE list to submit_here\n"
	rm "${git_dir}/submit_here/apparently_inactive.txt"
	touch "${git_dir}/submit_here/apparently_inactive.txt"
	grep -vE "^($|#)" "${git_dir}/dev-tools/output/domains/INACTIVE/list" \
	  > "${git_dir}/submit_here/apparently_inactive.txt"
	#sort -u -f "${git_dir}/submit_here/apparently_inactive.txt"
#else
	#exit 0
fi

#exit 0

## fail the pyfunceble test if any submissions are invalid
if [ -f "${git_dir}/dev-tools/output/domains/INVALID/list" ]
then
	echo -e "The following are invalid\n\n"
	cat "${git_dir}/dev-tools/output/domains/INVALID/list"
	#exit 99
fi

# ***************************************************************************
printf "\n\tGenerate our host file\n"
# ***************************************************************************

#exit 0

#bash ${git_dir}/dev-tools/UpdateReadme.sh
bash "${git_dir}/dev-tools/GenerateHostsFile.sh"

# *************************************************************
# Travis now moves to the before_deploy: section of .travis.yml
# *************************************************************

exit ${?}
