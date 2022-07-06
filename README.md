# 1p-cli-2-backup
Simple 1Password backup script using 1Password CLI 2.  

This script is basically a 1Password CLI 2 adapted version of https://github.com/michael-batz/1password-backup.  

It will list all items from the logged in account and fetch the details to a file, which serves as a great offline backup.  

## Requirements

- 1Password CLI 2 (https://developer.1password.com/docs/cli/get-started#install)  
- jq

## Usage

The following command will download all items from 1Password Cloud and store it into an AES256 encrypted output file. The script will ask for the passphrase to encrypt the output file.

`./backup.sh -f <output file>`

The following command will decrypt an existing output file and print the content of 1Password Cloud data to <output file>:

`openssl enc -d -aes-256-cbc -pbkdf2 -in <backup file> -out <output file>`

## Automation

If you would like to automate the script, you could consider using service like Secret Manager.  
Using the gcloud CLI with service account can pipe the password to the script while keeping the access permission under control.  

Modification example:  

```
# signin to 1Password
echo "1Password Cloud Backup"
echo "- signin to 1Password..."
eval $(echo $(gcloud secrets versions access <version-id> --secret="<secret-name>") | ${tool_op} signin)
```

```
# encrypt items and write to output file
echo "- store items in encrypted output file ${var_outputfile}..."
echo $output | openssl enc -aes-256-cbc -pbkdf2 -pass pass:$(gcloud secrets versions access <version-id> --secret="<secret-name>") > ${var_outputfile}
```
