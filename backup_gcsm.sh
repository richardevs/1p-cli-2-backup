#!/bin/bash

print_usage()
{
    echo "1Password Cloud Backup, Google Cloud Secret Manager integrated edition"
    echo ""
    echo "usage: $0 -f <output file> -k <login password secret name> -p <encryption password secret name>"
    echo ""
    echo "example: $0 -f <path>/\$(date +\"%Y-%m-%dT%H:%M%z\").1pbak -k 1p-master -p openssl-pass"
    exit 0
}

# define variables
tool_op="/usr/bin/op"
tool_jq="/usr/bin/jq"
tool_gcloud="/usr/bin/gcloud"

# parse arguments
while getopts "f:k:p:" option
do
    case "${option}" in
        f) var_outputfile=${OPTARG};;
        k) master_pass=${OPTARG};;
        p) openssl_pass=${OPTARG};;
        *) print_usage
    esac
done

# check arguments
if [ -z "${var_outputfile}" ]; then print_usage; fi
if [ -z "${master_pass}" ]; then print_usage; fi
if [ -z "${openssl_pass}" ]; then print_usage; fi

# signin to 1Password
echo "1Password Cloud Backup"
echo "- signin to 1Password..."
eval $(echo $(${tool_gcloud} secrets versions access latest --secret=${master_pass}) | ${tool_op} signin)

# get a list of all items
echo "- get list of all items from 1Password..."
items=$(${tool_op} item list --format=json | ${tool_jq} --raw-output '.[].id')

# get all items from 1Password
output=""
for item in $items
do
    echo "  - get item ${item}..."
    output+=$(${tool_op} item get ${item})
    output+=$'\n'
done

# encrypt items and write to output file
echo "- store items in encrypted output file ${var_outputfile}..."
echo "$output" | openssl enc -aes128 -pbkdf2 -pass pass:$(${tool_gcloud} secrets versions access latest --secret=${openssl_pass}) > ${var_outputfile}

# signout from 1Password
echo "- signout from 1Password"
${tool_op} signout
