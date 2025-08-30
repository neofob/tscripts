#!/usr/bin/env bash
# Download Ollama models from a given list

MODELS=${MODELS="devstral:latest"}

for m in ${MODELS}; do
	echo "Downloading model $m"
	time ollama pull $m
done

printf 'Runtime: %dd:%dh:%dm:%ds\n' "$((SECONDS / 86400))" "$(( (SECONDS % 86400) / 3600 ))" "$(( (SECONDS % 3600) / 60 ))" "$(( SECONDS % 60 ))"
