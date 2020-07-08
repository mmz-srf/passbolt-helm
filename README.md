# Passbolt Kubernetes Helm Charts

## Requirements
- Kubernetes > 1.16.X
- Helm > v2.16.X

## GPG key genereation

1. Create GPG config file gpg-server-key.conf

        %echo Generating a basic OpenPGP key
        Key-Type: RSA
        Key-Length: 4096
        Subkey-Type: RSA
        Subkey-Length: 4096
        Name-Email: joe@foo.bar
        Name-Real: Joe Tester
        Expire-Date: 0
        %echo done

---
**NOTE**

Do not set a Password, since passbolt won't start 

---

2. Create GPG keys

        gpg --gen-key --batch gpg-server-key.conf


3. List GPG keys 

        gpg --list-secret-keys --keyid-format LONG

You will need this to export it and in your values.yaml to validate the keys.

4. Export keys

        gpg --armor --export $KEY_ID > serverkey.asc
        gpg --armor --export-secret-keys $KEY_ID > serverkey_private.asc

## Generate SALT
    openssl rand -base64 32

## Create first passbolt admin user

    root@passbolt-passbolt-app:/var/www/passbolt# su -m -c "bin/cake passbolt register_user -u passboltadmin@yourdomain.com -f Admin -l Istrator -r admin" -s /bin/sh www-data