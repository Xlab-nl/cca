#!/bin/bash

bundle() {
    local bundle="$1"; shift
	echo "---> Making bundle: $(basename "$bunlde") (in $DEST)"
    
    if [ -e "$DEST" ] && [ -z "$OVERWRITE" ]; then
        echo "error: $DEST already exists. Aborting. use OVERWRITE=1 to overwrite the current bundle."
        exit 1
    else
        echo "$DEST already exists. Removing."
        rm -rf "$DEST" && mkdir "$DEST" || exit 1
    fi

	mkdir -p "$DEST"

    # Create password file.
    echo $(openssl rand -base64 32) > $DEST/passphrase

    # Create index.txt
    touch $DEST/index.txt

    # Create serial
    echo "$CA_SERIAL" > $DEST/serial

    # Create certificate based on config
    openssl req -new -x509 -extensions v3_ca \
        -keyout "$DEST/ca.key" \
        -out "$DEST/ca.crt" \
        -days "$CA_DAYS" \
        -batch \
        -passout "pass:$(cat $DEST/passphrase)" \
        -config "$CA_CONFIG_DIR/$(basename "$bundle").cnf"

}

main() {
	if [ $# -lt 1 ]; then
		bundles=(${DEFAULT_BUNDLES[@]})
	else
		bundles=($@)
	fi

	for bundle in ${bundles[@]}; do
		export DEST="bundles/$(basename "$bundle")"
		bundle "$bundle"
		echo
	done	

}

main "$@"
