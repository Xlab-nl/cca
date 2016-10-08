#!/bin/bash

function serial() {
    echo $(od -vAn -N4 -tu < /dev/urandom | tr -d ' ')
}

create_client_cert() {
    local name="$1";
    local ca="$2"; shift

    if [ ! -e "bundles/$ca" ]; then
        echo "error: Bundle $ca does not exist"
        exit 1
    fi

    echo "---> Making certificate: name (derived from $ca) (in $DEST)"
    if [ -e "$DEST" ]; then
        echo "$DEST already exists. Removing."
        rm -rf "$DEST" && mkdir "$DEST" || exit 1
    fi

    # Generate passphrase
    echo $(openssl rand -base64 32) > $DEST/passphrase
    
    # Generate key and cert
    openssl genrsa -out "$DEST/client.key" 1024
    openssl req -new -key "$DEST/client.key" \
        -out "$DEST/client.csr" \
        -subj "/C="$COUNTRY"/ST=${STATE}/L=${LOCALITY}/O=${ORGANISATION}/OU=${UNIT}/CN=${COMMON_NAME}/emailAddress=${EMAIL}"
 

    # Sign with ca
    openssl x509 -req -days 365 -in "$DEST/client.csr" \
        -CA "bundles/$ca/ca.crt" \
        -CAkey "bundles/$ca/ca.key" \
        -set_serial $(serial) \
        -passin "pass:$(cat "bundles/$ca/passphrase")" \
        -out "$DEST/client.crt"

    # Create p12 file for osx/windows
    openssl pkcs12 -export -in "$DEST/client.crt" \
        -inkey "$DEST/client.key" \
        -out "$DEST/client.p12" \
        -passout "pass:$(cat "$DEST/passphrase")"

    # Store information in a json object for later use
    cat > $DEST/client_cert.json <<DVEOF
{
    "checksum": "$(openssl x509 -in "$DEST/client.crt" -outform DER | shasum | sed 's/-//' | tr -d ' ')",
    "subject": "$(openssl x509 -noout -subject -in "$DEST/client.crt" | sed 's/subject=//' | tr -d ' ')",
    "issuer": "$(openssl x509 -noout -issuer -in "$DEST/client.crt" | sed 's/issuer=//' | tr -d ' ')",
    "serial": "$(openssl x509 -noout -serial -in "$DEST/client.crt" | sed 's/serial=//' | tr -d ' ')"
}
DVEOF

}

main() {
    if [ ! -n "$1" ]; then
        echo "Provide a name for the client certificate."
        exit 1
    fi
    
    if [ ! -n "$2" ]; then
        echo "Provide a ca bundle name for the client certificate."
        exit 1
    fi

    name=($1)
    ca=($2)
    export DEST="certs/$name"
    mkdir -p "$DEST"
    ABS_DEST="$(cd "$DEST" && pwd =P)"
    create_client_cert "$name" "$ca"
}

main "$@"
