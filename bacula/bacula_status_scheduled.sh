#!/bin/bash

# Primeiro, observa todos os jobs agendados para o dia de hoje
echo "status scheduled days=1" | bconsole | egrep -E "^Incremental|Full"

