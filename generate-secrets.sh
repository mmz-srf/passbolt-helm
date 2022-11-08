#!/usr/bin/env bash

set -euo pipefail

GPG_NAME="John Doe"
GPG_EMAIL="john@doe.com"

rm -rf secrets
mkdir -p secrets/gpg
cd secrets/gpg
mkdir -m 0700 gpg-tmp
gpg --homedir gpg-tmp --batch --no-tty --gen-key <<EOF
    Key-Type: eddsa
    Key-Curve: ed25519
    Key-Usage: sign,cert
    Subkey-Type: ecdh
    Subkey-Curve: cv25519
    SubKey-Usage: encrypt
    Name-Real: ${GPG_NAME}
    Name-Email: ${GPG_EMAIL}
    Expire-Date: 0
    %no-protection
    %commit
EOF

gpg --homedir gpg-tmp --armor --export "${GPG_EMAIL}" > serverkey.asc
gpg --homedir gpg-tmp --armor --export-secret-keys "${GPG_EMAIL}" > serverkey_private.asc

rm -rf gpg-tmp

cd -

mkdir -p secrets/jwt

openssl genrsa -out secrets/jwt/jwt.key 4096
openssl rsa -in secrets/jwt/jwt.key -outform PEM -pubout -out secrets/jwt/jwt.pem

mkdir -p secrets/pro-license
touch secrets/pro-license/subscription_key.txt

cat << EOF > values-fingerprint.yaml
passbolt:
  config:
    gpgServerKeyFingerprint: "$(gpg --show-keys secrets/gpg/serverkey.asc | grep -Ev "(pub|uid|sub)" | xargs)"
EOF
