#!/bin/bash

# Primeiro, observa todos os jobs agendados para o dia de hoje
num_scheduled_jobs=\
`echo "status scheduled days=1" | bconsole | egrep -E "^(Incremental|Full)" | wc -l`

echo $num_scheduled_jobs
