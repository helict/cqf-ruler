#!/bin/bash

function autogenerate_keystores() {
  # Keystore infix notation as used in templates to keystore name mapping
  declare -A KEYSTORES=( ["https"]="HTTPS" )

  local CN="${VIRTUAL_HOST}"
  if [ -z "$CN" ]
  then
     CN="localhost"
  fi

  local KEYSTORES_STORAGE="/server/keystores"
  if [ ! -d "${KEYSTORES_STORAGE}" ]; then
    mkdir -p "${KEYSTORES_STORAGE}"
  fi

  # Auto-generate the HTTPS keystore if volumes for OpenShift's
  # serving x509 certificate secrets service were properly mounted

    local X509_KEYSTORE_DIR="/usr/local/ssl"
    local X509_CRT="${X509_KEYSTORE_DIR}/server.crt"
    local X509_KEY="${X509_KEYSTORE_DIR}/server.key"
    local NAME="tls"
    local PASSWORD="secret"
    local PKCS12_KEYSTORE_FILE="keystore.pk12"

    # if no cert provided, create key and self-signed cert
    if [ ! -f "${X509_CRT}" ] || [ ! -f "${X509_KEY}" ]; then
      echo "No server certificate information specified. Generating key and self-signed cert for CN=${CN}..."
      mkdir -p "${X509_KEYSTORE_DIR}"
      mkdir -p "${X509_KEYSTORE_DIR}"
      openssl req -new -newkey rsa:4096 -days 730 -nodes -x509 \
        -subj "/C=DE/ST=Saxony/L=Dresden/O=TUDresden/OU=FGDH/CN=${CN}" \
        -keyout "${X509_KEY}" \
        -out "${X509_CRT}"
      echo "...Done!"
    else
      echo "Use existing certificate at "${X509_CRT}" with content:"
      openssl x509 -in "${X509_CRT}" -text -noout
    fi

    # Add trusted certs to JAVA truststore
    local -r X509_CRT_DELIMITER="/-----BEGIN CERTIFICATE-----/"
    local TEMPORARY_CERTIFICATE="temporary_ca.crt"
    cat ${X509_KEYSTORE_DIR}/*.crt > ${TEMPORARY_CERTIFICATE}
    csplit -s -z -f crt- "${TEMPORARY_CERTIFICATE}" "${X509_CRT_DELIMITER}" '{*}'
    echo "Importing trusted CAs..."
    for CERT_FILE in crt-*; do
      echo "Trying to delete previous alias service-${CERT_FILE}"
      keytool -delete -cacerts -storepass changeit -alias "service-${CERT_FILE}" -noprompt
      echo "Importing trusted CA with alias service-${CERT_FILE}"
      keytool -import -v -cacerts -alias "service-${CERT_FILE}" -file "${CERT_FILE}" -storepass changeit -noprompt
    done
    echo "Done."

    echo "Creating keystore via OpenShift's service serving x509 certificate secrets for alias ${NAME}..."

    openssl pkcs12 -export \
    -name "${NAME}" \
    -inkey "${X509_KEY}" \
    -in "${X509_CRT}" \
    -out "${KEYSTORES_STORAGE}/${PKCS12_KEYSTORE_FILE}" \
    -password pass:"${PASSWORD}" >& /dev/null

    if [ -f "${KEYSTORES_STORAGE}/${PKCS12_KEYSTORE_FILE}" ]; then
      echo "keystore successfully created at: ${KEYSTORES_STORAGE}/${PKCS12_KEYSTORE_FILE}"
      [[ -z "${SERVER_SSL_KEYSTORE}" ]] && export SERVER_SSL_KEYSTORE=${KEYSTORES_STORAGE}/${PKCS12_KEYSTORE_FILE}
      [[ -z "${SERVER_SSL_KEYSTOREPASSWORD}" ]] && export SERVER_SSL_KEYSTOREPASSWORD=${PASSWORD}
      [[ -z "${SERVER_SSL_KEYSTORETYPE}" ]] && export SERVER_SSL_KEYSTORETYPE="pkcs12"
      [[ -z "${SERVER_SSL_KEYALIAS}" ]] && export SERVER_SSL_KEYALIAS=${NAME}
      [[ -z "${SERVER_SSL_KEYPASSWORD}" ]] && export SERVER_SSL_KEYPASSWORD=${PASSWORD}
      [[ -z "${SERVER_PORT}" ]] && export SERVER_PORT=8443
      echo "Spring configuration is setup with following ENVs:"
      echo "- SERVER_SSL_KEYSTORE = ${SERVER_SSL_KEYSTORE}"
      echo "- SERVER_SSL_KEYSTOREPASSWORD = ********"
      echo "- SERVER_SSL_KEYSTORETYPE = ${SERVER_SSL_KEYSTORETYPE}"
      echo "- SERVER_SSL_KEYALIAS = ${SERVER_SSL_KEYALIAS}"
      echo "- SERVER_SSL_KEYPASSWORD = ********"
      echo "- SERVER_PORT = ${SERVER_PORT}"
    else
      echo "keystore not created at: ${KEYSTORES_STORAGE}/${PKCS12_KEYSTORE_FILE} (check permissions?)"
    fi

  popd >& /dev/null
}

# Create keystore
autogenerate_keystores

# Start container
exec $@
exit $?
