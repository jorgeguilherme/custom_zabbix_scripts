#!/usr/bin/env python

from subprocess import check_output
from json import dumps

job_list = check_output("cat /usr/share/zabbix-agent/bacula_status_scheduled | awk '{print $7}' | grep -v -e '^$'", shell=True)

# Transforma em uma lista
lines = job_list.splitlines()

# Vamos gerar um dicionario Python no formato certo
jobs_in_dict = {
    "data": []
}

for line in lines:
    macro = {
	"{#JOBNAME}":line
    }
    jobs_in_dict["data"].append(macro)

# Transforma dicionario em JSON

jobs_in_json = dumps(jobs_in_dict)

print (jobs_in_json)

