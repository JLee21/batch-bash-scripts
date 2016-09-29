#!/bin/bash

#check if nmap is installed
hash nmap 2>/dev/null || { echo >&2 "nmap is not installed...exiting";exit 1; }

nmap -v -sP 192.168.16.0/25 | grep -B 1 "Host is up"


