Ben Copeland 10/01/2014

- Description

	- Retrieve expiry dates on SSL certificates using CLI53 and Zabbix Descovery to automatically generate alerts

	The script uses cli53 (command line route53) to get our hostnames. 
	Using the retrieves hostnames, openssl retrieves the certificates 
	from the given host and exports the results into a json file.

	This file is fed through another script to export only hostnames
	to zabbix. Zabbix uses the hostname field to discover the hosts
	that have ssl certicates. Using Zabbix discovery rules the hosts
	and days left on the ssl certificate are import into zabbix.

- Files explained

- sslcheck.sh
	- The scripts that uses cli53 and gets the certificate
	- Runs in location /etc/zabbix/scripts/
	- Must export file ssldays.json for sslcheck.sh
- gethosts.sh
	- Discovery script for zabbix. Exports hostnames in json format
	- Depends on exported json file from sslcheck.sh (/etc/zabbix/scripts/ssldays.json)
- zabbix_template_sslcheck.xml
	- Zabbix template file. Holds the descovery rules and triggers. 


- Dependencies 

- CLI53 (https://github.com/barnybug/cli53)
	- /etc/boto.cfg (aws_access_key and aws_secert_key) IAM user dns-editor 
	- pythonpip
- zabbix_template_sslcheck.xml (zabbix template, descovery rules + triggers)
	- /etc/zabbix/scripts/sslcheck.sh  
			- /etc/zabbix/scripts/ssldays.json
			- cronjob (0 0 * * * /bin/bash /etc/zabbix/scripts/sslcheck.sh linaro.org 443 > /etc/zabbix/scripts/ssldays.json)
				- Script MUST run at midnight and not overlap zabbix retreving the json file, others zabbix will fail.
	- /etc/zabbix/scripts/gethosts.sh
	- userparameter_sslcheck.conf - parameters set on zabbix-agent for the zabbix server
	

- Limitations/Improvements
	- Openssl does not support timeout. This means bash command "timeout" has to be used, which results in the bash script running slowly.
	- Maybe look into using SSL3 (http://thinkinginsoftware.blogspot.co.uk/2013/01/openssl-hanging-connected00000003.html)
	- zabbix CANNOT access ssldays.json when sslcheck.sh is running, since it will NOT be a complete json file
		- have to login into zabbix and click every SSL certifcate and "reenable" the unsupported item. Or delete and recreate the template on the host
		- crontab runs at midnight
		- Look into only writing file once the list is complete
	- When SSL has over 1000days zabbix reports "kdays". 
		- Patch to fix problem:  https://support.zabbix.com/browse/ZBXNEXT-768