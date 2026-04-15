#!/bin/bash

oras_opts=(${ORAS_OPTIONS:-})

# When a custom CA file is provided, concatenate it with the system CA bundle
# and set SSL_CERT_FILE. This ensures both public and self-hosted registries
# are trusted. SSL_CERT_FILE is respected by Go's crypto/x509 (used by oras).
if [[ -v CA_FILE && -n "$CA_FILE" ]]; then
    if [[ -f "$CA_FILE" && -s "$CA_FILE" ]]; then
        COMBINED="/tmp/combined-ca-bundle.crt"
        { cat /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem 2>/dev/null; echo; cat "$CA_FILE"; } > "$COMBINED"
        export SSL_CERT_FILE="$COMBINED"
        echo "Using combined CA certificate (system + custom): $COMBINED" >&2
    elif [[ -f "$CA_FILE" ]]; then
        echo "Warning: CA certificate file is empty: $CA_FILE" >&2
        echo "Falling back to system trust store" >&2
    else
        echo "Warning: CA certificate path provided but file not found: $CA_FILE" >&2
        echo "Falling back to system trust store" >&2
    fi
fi

if [[ ! -z "${DEBUG:-}" ]]; then
    oras_opts+=(--debug)
fi
