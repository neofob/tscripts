#!/usr/bin/env bash

#
# Generates SSL Certificates (Self-signed and CSR)
# Optimized for DevOps workflows and security best practices.

set -euo pipefail

# --- Configuration & Defaults ---
CERT_ENV="${CERT_ENV:-cert.env}"

# Default values if not provided in the env file
# Using sensible defaults to prevent script failure if env file is partially empty
COUNTRY_NAME="${COUNTRY_NAME:-US}"
STATE="${STATE:-Virginia}"
LOCALITY="${LOCALITY:-Arlington}"
ORG="${ORG:-Piped Piper LLC}"
ORG_UNIT="${ORG_UNIT:-Anton}"
COMMON_NAME="${COMMON_NAME:-metrics.local}"
DAYS="${DAYS:-365}"
# Use rsa:2048 as a safe default if $NEW_KEY isn't defined in env
NEW_KEY="${NEW_KEY:-rsa:4096}"
DOMAIN="${DOMAIN:-metrics.local}"

# --- Environment Loading ---
if [[ -f "$CERT_ENV" ]]; then
    # shellcheck source=/dev/null
    source "$CERT_ENV"
else
    printf "Error: Configuration file '%s' not found.\n" "$CERT_ENV" >&2
    exit 1
fi

# --- Validation ---
# Ensure required variables are present after sourcing
: "${DOMAIN:?DOMAIN must be set in $CERT_ENV}"
: "${COMMON_NAME:?COMMON_NAME must be set in $CERT_ENV}"

# --- Logic ---

# Construct the Subject string once to ensure consistency and prevent typos
# Format: /C=.../ST=.../L=.../O=.../OU=.../CN=...
SUBJECT="/C=$COUNTRY_NAME/ST=$STATE/L=$LOCALITY/O=$ORG/OU=$ORG_UNIT/CN=$COMMON_NAME"

printf "Generating certificates for: %s\n" "$COMMON_NAME"

# 1. Generate Self-Signed Certificate and Private Key
# We use -nodes (no DES) if you want the key not to be encrypted with a password,
# which is common for automated web server deployments.
# Remove '-nodes' if you want to prompt for a passphrase.
printf "Step 1: Creating self-signed certificate (%s days)...\n" "$DAYS"
openssl req -x509 -newkey "$NEW_KEY" \
    -keyout "${DOMAIN}.key" \
    -out "${DOMAIN}.crt" \
    -days "$DAYS" \
    -subj "$SUBJECT" \
    -nodes

# 2. Generate Certificate Signing Request (CSR)
# This uses the key we just created.
printf "Step 2: Creating Certificate Signing Request (CSR)...\n"
openssl req -new \
    -key "${DOMAIN}.key" \
    -out "${DOMAIN}.csr" \
    -subj "$SUBJECT"

printf "\nSuccess! Files generated:\n"
printf "  - %s.key (Private Key)\n" "$DOMAIN"
printf "  - %s.crt (Self-signed Certificate)\n" "$DOMAIN"
printf "  - %s.csr (Certificate Signing Request)\n" "$DOMAIN"
