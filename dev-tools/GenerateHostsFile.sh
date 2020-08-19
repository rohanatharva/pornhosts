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
# issue at https://github.com/mypdns/matrix/issues

# Fail if exit != 0
set -e

# Run script in verbose
# set -x

printf "\n\tRunning GenerateHostFile.sh\n\n"

# ******************
echo -e "\n\tSet Some Variables"
# ******************

# As the TRAVIS_BUILD_DIR no longer seems to be working. I'm changing
# that to git_dir
git_dir="$(git rev-parse --show-toplevel)"

now=$(date '+%F %T %z (%Z)')
my_git_tag="build: ${TRAVIS_BUILD_NUMBER}"
activelist="${git_dir}/dev-tools/output/domains/ACTIVE/list"

# *********************************************************************************
echo -e "\n\tSet the output files"
# *********************************************************************************

outdir="${git_dir}/download_here" # no trailing / as it would make a double //
ssoutdir="${outdir}/safesearch" # no trailing / as it would make a double //

# First let us clean out old data in output folders
echo -e "\n\tDeleting files in\n\t${outdir}\n\n\tAND\n\n\t${ssoutdir}\n"

#find "${outdir}" -type f -delete
#find "${ssoutdir}" -type f -delete

# *********************************************************************************
echo -e "\n\t Generate the raw data list, as we need it for the rest of our work"
# *********************************************************************************

rawlist="${outdir}/active_raw_data.txt"
touch "${rawlist}"
grep -vE "^(#|$)" "${activelist}" > "${rawlist}"

bad_referrers=$(wc -l < "${rawlist}")

# *********************************************************************************
echo -e "\n\tPrint some stats"
# *********************************************************************************
printf "\n\tRows in active list: $(wc -l < "${activelist}")\n"
printf "\n\tRows of raw data: ${bad_referrers}\n"

# *********************************************************************************
echo -e "\n\tOrdinary without safe search records"
# *********************************************************************************
hosts="${outdir}/0.0.0.0/hosts"
hosts127="${outdir}/127.0.0.1/hosts"
mobile="${outdir}/mobile/hosts"
dnsmasq="${outdir}/dnsmasq/pornhosts.conf"
rpz="${outdir}/rpz/pornhosts.rpz"
unbound="${outdir}/unbound/pornhosts.zone"

# *********************************************************************************
echo -e "\n\tSafe Search enabled output"
# *********************************************************************************
sshosts="${ssoutdir}/0.0.0.0/hosts"
sshosts127="${ssoutdir}/127.0.0.1/hosts"
ssmobile="${ssoutdir}/mobile/hosts"
ssdnsmasq="${ssoutdir}/dnsmasq/pornhosts.conf"
#ssrpz="${ssoutdir}/rpz/pornhosts.rpz"
ssunbound="${ssoutdir}/unbound/pornhosts.zone"

# *********************************************************************************
echo -e "\n\tSet templates path"
# *********************************************************************************
templpath="${git_dir}/dev-tools/templates"

hostsTempl=${templpath}/hosts.template
mobileTempl=${templpath}/mobile.template
dnsmasqTempl=${templpath}/ddwrt-dnsmasq.template
#unboundTempl # None as we print the header directly

# *********************************************************************************
echo -e "\n\tSafe Search is in sub-path"
# *********************************************************************************

# TODO Get templates from the master source at 
# https://gitlab.com/my-privacy-dns/matrix/matrix/tree/master/safesearch
# Template file for 0.0.0.0 and 127.0.0.1 are the same

sstemplpath="${templpath}/safesearch"

sshostsTempl="${sstemplpath}/hosts.template" # same for mobile
ssdnsmasqTempl="${sstemplpath}/ddwrt-dnsmasq.template"
ssrpzTempl="${sstemplpath}/safesearch.rpz"
ssunboundTempl="${sstemplpath}/unbound.template"

# *********************************************************************************
printf "\n\tUpdate our safe search templates\n"
# *********************************************************************************

wget -qO "${sshostsTempl}" 'https://gitlab.com/my-privacy-dns/rpz-dns-firewall-tools/hosts/raw/master/matrix/safesearch.hosts'
wget -qO "${ssdnsmasqTempl}" 'https://gitlab.com/my-privacy-dns/rpz-dns-firewall-tools/dnsmasq/raw/master/safesearch.dnsmasq.conf'
wget -qO "${ssrpzTempl}" 'https://gitlab.com/my-privacy-dns/rpz-dns-firewall-tools/bind-9/raw/master/rpz_zones/safesearch.mypdns.cloud.rpz'
wget -qO "${ssunboundTempl}" 'https://gitlab.com/my-privacy-dns/rpz-dns-firewall-tools/unbound/raw/master/safesearch.conf'

# *********************************************************************************
echo -e "\n\tNext ensure all output folders is there"
# *********************************************************************************
mkdir -p "${outdir}/0.0.0.0" \
  "${outdir}/127.0.0.1" \
  "${outdir}/mobile" \
  "${outdir}/dnsmasq" \
  "${outdir}/rpz" \
  "${outdir}/unbound/" \
  "${ssoutdir}/0.0.0.0" \
  "${ssoutdir}/127.0.0.1" \
  "${ssoutdir}/mobile" \
  "${ssoutdir}/dnsmasq" \
  "${ssoutdir}/rpz" \
  "${ssoutdir}/unbound/"

# *********************************************************************************
printf "\nGenerate hosts 0.0.0.0\n"
# *********************************************************************************

printf "# Last Updated: ${now} Build: ${my_git_tag}\n# Porn Hosts Count: ${bad_referrers}\n#\n" > "${hosts}"
cat "${hostsTempl}" >> "${hosts}"
awk '{ printf("0.0.0.0 %s\n",tolower($1)) }' "${rawlist}" >> "${hosts}"

# *********************************************************************************
printf "\nGenerate safe hosts 0.0.0.0\n"
# *********************************************************************************

printf "# Last Updated: ${now} Build: ${my_git_tag}\n# Porn Hosts Count: ${bad_referrers}\n#\n" > "${sshosts}"
cat "${hostsTempl}" >> "${sshosts}"
cat "${sshostsTempl}" >> "${sshosts}"
awk '{ printf("0.0.0.0 %s\n",tolower($1)) }' "${rawlist}" >> "${sshosts}"

# *********************************************************************************
printf "\nGenerate hosts 127.0.0.1\n"
# *********************************************************************************

printf "# Last Updated: ${now} Build: ${my_git_tag}\n# Porn Hosts Count: ${bad_referrers}\n#\n" > "${hosts127}"
cat "${hostsTempl}" >> "${hosts127}"
awk '{ printf("127.0.0.1 %s\n",tolower($1)) }' "${rawlist}" >> "${hosts127}"

# *********************************************************************************
printf "\nGenerate safe hosts 127.0.0.1\n"
# *********************************************************************************

printf "# Last Updated: ${now} Build: ${my_git_tag}\n# Porn Hosts Count: ${bad_referrers}\n#\n" > "${sshosts127}"
cat "${hostsTempl}" >> "${sshosts127}"
cat "${sshostsTempl}" >> "${sshosts127}"
awk '{ printf("127.0.0.1 %s\n",tolower($1)) }' "${rawlist}" >> "${sshosts127}"

# *********************************************************************************
printf "\nGenerate Mobile hosts\n"
# *********************************************************************************

printf "# Last Updated: ${now} Build: ${my_git_tag}\n# Porn Hosts Count: ${bad_referrers}\n#\n" > "${mobile}"
cat "${mobileTempl}" >> "${mobile}"
awk '{ printf("0.0.0.0 %s\n",tolower($1)) }' "${rawlist}" >> "${mobile}"

# *********************************************************************************
printf "\nGenerate safe Mobile hosts\n"
# *********************************************************************************

printf "# Last Updated: ${now} Build: ${my_git_tag}\n# Porn Hosts Count: ${bad_referrers}\n#\n" > "${ssmobile}"
cat "${mobileTempl}" >> "${ssmobile}"
cat "${sshostsTempl}" >> "${ssmobile}"
awk '{ printf("0.0.0.0 %s\n",tolower($1)) }' "${rawlist}" >> "${ssmobile}"

# *********************************************************************************
# DNSMASQ https://gitlab.com/my-privacy-dns/rpz-dns-firewall-tools/dnsmasq/issues/1
# *********************************************************************************

printf "# Last Updated: ${now} Build: ${my_git_tag}\n# Porn Hosts Count: ${bad_referrers}\n#\n" > "${dnsmasq}"
cat "${dnsmasqTempl}" >> "${dnsmasq}"
awk '{ printf("server=/%s/\n",tolower($1)) }' "${rawlist}" >> "${dnsmasq}"

# *********************************************************************************
printf "\nbuild Safe search for dnsmasq\n"
# *********************************************************************************

printf "# Last Updated: ${now} Build: ${my_git_tag}\n# Porn Hosts Count: ${bad_referrers}\n#\n" > "${ssdnsmasq}"
cat "${ssdnsmasqTempl}" >> "${ssdnsmasq}"
awk '{ printf("server=/%s/\n",tolower($1)) }' "${rawlist}" >> "${ssdnsmasq}"


# *********************************************************************************
# UNBOUND
# *********************************************************************************

# *********************************************************************************
printf "\nUnbound zone file always_nxdomain\n"
# *********************************************************************************

printf '{server:\n}' > "${unbound}"
awk '{ printf("local-zone: \"%s\" always_nxdomain\n",tolower($1)) }' "${rawlist}" >> "${unbound}"

# *********************************************************************************
printf "\nUnbound safe search zone file always_nxdomain\n"
# *********************************************************************************

cat "${ssunboundTempl}" > "${ssunbound}"
awk '{ printf("local-zone: \"%s\" always_nxdomain\n",tolower($1)) }' "${rawlist}" >> "${ssunbound}"


# *********************************************************************************
# RPZ and Bind formatted
# *********************************************************************************

# *********************************************************************************
printf "\nMaking Bind formatted RPZ zones\n"
# *********************************************************************************

#cat ${rpzTempl} > ${rpz}
printf "\$ORIGIN\tlocalhost.
\$TTL 1800;
@\tIN\tSOA\tlocalhost. hostmaster.mypdns.org. `date +%s`\t; Serial
\t\t\t3600\t\t; refresh
\t\t\t60\t\t; retry
\t\t\t604800\t\t; Expire
\t\t\t60;\t\t; TTL
\t\t\t\)
\t\t\tIN\tNS\tlocalhost\t;out-of-zone no A/AAAA RR required
\n; begin RPZ RR definitions\n\n" > "${rpz}"

awk '{ printf("%s\tCNAME\t.\n*.%s\tCNAME\t.\n",tolower($1),tolower($1)) }' "${rawlist}" >> "${rpz}"

exit ${?}
