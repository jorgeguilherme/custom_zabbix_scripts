#!/bin/bash

# Watch for every job scheduled for today and count em
num_scheduled_jobs=\
`echo "status scheduled days=1" | bconsole | egrep -E "^(Incremental|Full)" | wc -l`

echo $num_scheduled_jobs
