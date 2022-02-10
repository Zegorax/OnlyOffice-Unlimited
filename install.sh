#!/bin/bash

FILE=OO_PubKey
if test -f "$FILE"; then
  echo Patch has already been applied. Starting DocumentServer...
else
  apt-get update && apt-get install -y python3.6-dev 
    wget https://bootstrap.pypa.io/pip/3.6/get-pip.py
    python3.6 get-pip.py
    pip install pycrypto
    rm -f /var/www/onlyoffice/Data/license.lic
    
    cat <<EOF > index.py
from Crypto.Hash import SHA, SHA256
from Crypto.Signature import PKCS1_v1_5
from Crypto.PublicKey import RSA
from shutil import copyfile
import json
import codecs

hexlify = codecs.getencoder('hex')

licenseFile = {
    "branding": False,
    "connections": 9999,
    "customization": False,
    "end_date": "2099-01-01T23:59:59.000Z",
    "light": "False",
    "mode": "",
    "portal_count": "0",
    "process": 2,
    "ssbranding": False,
    "test": "False",
    "trial": "False",
    "user_quota": "0",
    "users_count": 9999,
    "users_expire": 99999,
    "whiteLabel": False,
    "customer_id": "customerID",
    "start_date": "2020-01-01T00:00:00.000Z",
    "users": [],
    "version": 2
}

jsonLicenseFile = codecs.encode(json.dumps(licenseFile, separators=(',', ':')), encoding='utf-8')

privKey = RSA.generate(1024)
publKey = privKey.publickey().exportKey('PEM')

digest = SHA.new(jsonLicenseFile)
signer = PKCS1_v1_5.new(privKey)
signature = signer.sign(digest)

finalSignature = signature.hex()

licenseFile['signature'] = finalSignature

f = open("OO_License", "w+")
f.write(json.dumps(licenseFile))
f.close

f = open("OO_PubKey", "w+")
f.write(publKey.decode('utf-8'))
f.close()

print("The license file has been saved to OO_License. Here's the content :")
print(json.dumps(licenseFile))
print("It will be placed automatically in the Data directory of OnlyOffice")

copyfile("OO_License", "/var/www/onlyoffice/Data/license.lic")

print("Patching docservice and convert...")

basePath = "/var/www/onlyoffice/documentserver/server/"
files = ["DocService/docservice", "FileConverter/converter"]

for file in files:
    f = open(basePath+file, 'rb')
    data = f.read()
    f.close()

    replacedData = data.replace(b"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDRhGF7X4A0ZVlEg594WmODVVUI\niiPQs04aLmvfg8SborHss5gQXu0aIdUT6nb5rTh5hD2yfpF2WIW6M8z0WxRhwicg\nXwi80H1aLPf6lEPPLvN29EhQNjBpkFkAJUbS8uuhJEeKw0cE49g80eBBF4BCqSL6\nPFQbP9/rByxdxEoAIQIDAQAB\n-----END PUBLIC KEY-----", bytes(publKey))

    f = open(basePath+file, 'wb')
    f.write(replacedData)
    f.close()

EOF

    python3.6 index.py

    echo Patching docservice and convert...

    echo Done! Running Document Server...
fi

/app/ds/run-document-server.sh
