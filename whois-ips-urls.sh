#!/bin/bash

target=$1;
#wordlist=$2;

domain_list=$1
mkdir "output"
while read line
do
    name=$line
    echo "Looking up ${line}..."
    whois $name > ./output/${line}.txt
    cat ./output/${line}.txt | grep "Registrant Organization"
    sleep 1
done < $domain_list
