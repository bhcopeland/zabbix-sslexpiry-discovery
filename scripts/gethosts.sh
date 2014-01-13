#!/bin/bash
echo -e "{\n\t\"data\":["	    
	    cat /etc/zabbix/scripts/ssldays.json | grep {#HOST} | cut -f4 -d '"' | while read line
	    do
		XHOST=`echo $line | awk '{print $1}'`
		echo -e "\t{ \"{#HOST}\":\t\"${XHOST}\" },"
	    done
	    echo -e "\t]\n}"
