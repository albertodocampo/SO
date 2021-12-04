#!/bin/bash

a=2
b=5
echo "$a $b"
let "a+=b"
echo "$a $b"

c="e"
declare -A al
declare -A bl

al=