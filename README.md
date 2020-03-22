# OnlyOffice-Unlimited
Script generating a valid license for OnlyOffice DocumentServer

# What is going on in this script
## Key generation
At the beginning, the script will generate a RSA SHA1 key pair and generate a signature for the custom license file.
After this step, it will append the signature as a key to the licence JSON dictionary and save it.
We then also save the public key, which we will use in OO to verify our license.

## Patching
OnlyOffice changed the way they ship their Docker images for IE (Integration Edition) and are now using "compiled" binaries of NodeJS code. This script will search the binary file for OnlyOffice's PEM certificate and replace it with the one generated earlier. The script automatically starts OnlyOffice DocumentServer after the operation

# How to use
Change the entrypoint of your docker-compose file to :

`entrypoint: bash -c "wget https://raw.githubusercontent.com/Zegorax/OnlyOffice-Unlimited/master/install.sh && bash install.sh"`

# Conclusion
You now have a working OnlyOffice license generator 
