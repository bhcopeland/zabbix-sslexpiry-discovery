#!/bin/bash
################################################################################
# Ben Copeland (ben.comobile@gmail.com) 04/01/2014
# Description:
#  Retrieves SSL certificate from remote server and returns the remaining number
#  of valid days.
#
# Usage:
#   sslcheck.sh <hostname_or_IP> <port> > /etc/scripts/zabbix/ssldays.json 
#
# Zabbix item:
#  Type               : external check
#  Key                : zext_ssl_cert.sh[port]
#  Type of information: Numeric (float)
################################################################################
SHELL=/bin/bash PATH=/bin:/sbin:/usr/bin:/usr/sbin 
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
domain=$1
getport=$2
getdomain=`cli53 export $domain | awk '{ print $1 }' |  sed 's/[^a-z|0-9|.-]//g; ' | sed '/^$/d' | uniq `
fqdn=`echo "$getdomain" | while read a; do echo $a.$domain; done`
port=`echo "$fqdn" | while read b; do echo $getport; done`
IFS=" "
set -- $fqdn
N=0

printf "{\n";
printf "\t\"data\":[\n\n";

echo $fqdn | while read LINE;do
	N=$((N+1))
	#####TIMEOUT is important. Due to openssl having no timeout options, hosts can hang for a long time.
	end_date=`timeout 15 openssl s_client -ssl3 -host $LINE -port $getport -showcerts </dev/null 2>/dev/null |
        sed -n '/BEGIN CERTIFICATE/,/END CERT/p' |
        openssl x509 -text 2>/dev/null |
        sed -n 's/ *Not After : *//p'`

#	echo $end_date

	if [ -n "$end_date" ]
		then
		end_date_seconds=`date '+%s' --date "$end_date"`
    		now_seconds=`date '+%s'`
	        days=`echo "($end_date_seconds-$now_seconds)/24/3600" | bc`
#		printf '{"hostname":"%s","days":"%s"}\n' "$LINE" "$days"

		printf "\t{\n";
	    	printf "\t\t\"{#HOST}\":\"$LINE\",\n";
		printf "\t\t\"{#DAYS}\":\"$days\"\n";
		printf "\t}\n";

	fi
done

printf "\n\t]\n";
printf "}\n";
