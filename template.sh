#!/bin/bash

declare -A all=()
a="a"
b="b"
c="c"
all[$a]=1
all[$b]=2
all[$c]=3
echo "${all[*]}"