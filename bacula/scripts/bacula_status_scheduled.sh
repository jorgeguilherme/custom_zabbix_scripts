#!/bin/bash

# Look for every job scheduled for today
echo "status scheduled days=1" | bconsole | egrep -E "^Incremental|Full"

