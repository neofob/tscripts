#!/usr/bin/env bash
#
#Read in variables from cert.env
CERT_ENV=${CERT_ENV:-cert.env}
source ${CERT_ENV}

### Reference initial bash commands
# generate key
# pattern:
# * site-domain.key
# * site-domain.crt
openssl req -x509 -newkey $NEW_KEY \
	-keyout $DOMAIN.key -out $DOMAIN.crt \
	-days $DAYS \
	-subj "/C=$COUNTRY_NAME/ST=$STATE/L=$LOCALITY/O=$ORG/OU=$ORG_UNIT/CN=$COMMON_NAME"

# generate .csr file
openssl req -new \
    -key $DOMAIN.key \
    -out $DOMAIN.csr \
    -subj "/C=$COUNTRY_NAME/ST=$STATE/L=$LOCALITY/O=$ORG/OU=$ORG_UNIT/CN=$COMMON_NAME"
