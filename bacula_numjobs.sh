#!/bin/bash

# Count the number of jobs scheduled for today
num_scheduled_jobs=\
`echo "status scheduled days=1" | bconsole | egrep -E "^(Incremental|Full)" | wc -l`

echo $num_scheduled_jobs
