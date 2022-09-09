# Passbolt Kubernetes Helm Charts

[![GitHub license](https://img.shields.io/github/license/mmz-srf/passbolt-helm)](https://github.com/mmz-srf/passbolt-helm/blob/master/LICENSE)
![GitHub issues](https://img.shields.io/badge/kubernetes-v1.16-green)
[![GitHub issues](https://img.shields.io/github/issues/mmz-srf/passbolt-helm)](https://github.com/mmz-srf/passbolt-helm/issues)

This helm chart installs the [passbolt container](https://github.com/passbolt/passbolt_docker/tree/master)  and a mysql database (mariadb)

## Quick start

Clone this repository:

```
git clone git@github.com:AnatomicJC/passbolt-helm.git
cd passbolt-helm
```

Update helm dependencies:

```
helm dep update .
```

You must generate some secrets:

* passbolt GPG server keys
* passbolt JWT keys for mobile

Copy `variables.env.sample` to `variables.env` and update the variables with your own:

```
GPG_NAME="John Doe"
GPG_EMAIL="john@doe.com"
FIRST_ADMIN_EMAIL="passboltadmin@yourdomain.com"
FIRST_ADMIN_NAME="Admin"
FIRST_ADMIN_SURNAME="Istrator"
```

Generate the secrets:

```
bash generate-secrets.sh
```

> If you are a PRO user
> * put your subscription key in `secrets/pro-license/subscription_key.txt` file.
> * Set passbolt.config.license.enabled to true in values.yaml
> * Set a [pro image tag](https://hub.docker.com/r/passbolt/passbolt/tags?page=1&name=pro) in values.yaml

Review values.yaml file, then deploy passbolt in your cluster:

```
helm install passbolt .
```

Once all pods deployed and running, create the first admin user:

```
bash create-first-admin.sh
```
## Parameters

For more parameters you should have a look at ...
- the [values.yaml](values.yaml) file of this helm chart
- the [values.yaml](https://github.com/helm/charts/blob/master/stable/mariadb/values.yaml) file of the mariadb helm chart, when enabled
- the [enviroment variables](https://github.com/passbolt/passbolt_docker/tree/master) of the passbold docker image.

### General

| Parameter          | Description                          | Default                   |
|--------------------|--------------------------------------|---------------------------|
| `replicaCount`     | How many replicas should be deployed | `1`                       |
| `image.repository` | Passbolt image repository            | `"passbolt/passbolt"`     |
| `image.tag`        | Passbolt image tag                   | `"latest"`                |
| `image.pullPolicy` | Image pull policy                    | `IfNotPresent`            |
| `imagePullSecrets` | Image pull secrets                   | `[]`                      |
| `nameOverride`     | Name override                        | `""`                      |
| `fullnameOverride` | Full name override                   | `""`                      |
| `service.type`     | Service type                         | `ClusterIP`               |
| `service.port`     | Service port                         | `80`                      |
| `ingress.enabled`  | Enable ingress                       | `true`                    |
| `ingress.host`     | Ingress host                         | `passbolt.yourdomain.com` |

### Passbolt

| Parameter                                            | Description                                                                                                          | Default                             |
|------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|-------------------------------------|
| `passbolt.persistence.enabled`                       | Enable/Disable persistence Disk for uploaded Files (Avatars)                                                         | `true`                              |
| `passbolt.persistence.storageClass`                  | Disk storageclass                                                                                                    | `-`                                 |
| `passbolt.persistence.accessMode`                    | Disk access mode                                                                                                     | `ReadWriteMany`                     |
| `passbolt.persistence.size`                          | Disk size                                                                                                            | `1Gi`                               |
| `passbolt.config.debug`                              | Enable/Disable debug output in passbolt image                                                                        | `false`                             |
| `passbolt.config.registration`                       | Enable/Disable user can register                                                                                     | `false`                             |
| `passbolt.config.salt`                               | Salt. Generate: ```openssl rand -base64 32```                                                                        | `"your salt"`                       |
| `passbolt.config.gpgServerKeyFingerprint`            | The GPG server key fingerprint. See [GPG key generation](#gpg-key-generation)                                        | `"your gpg server key fingerprint"` |
| `passbolt.config.serverkey`                          | The GPG server key. If set the key will not be read from [file](secrets/gpg/serverkey.asc)                           | ` `                                 |
| `passbolt.config.serverkey_private`                  | The GPG private server key. If set the private key will not be read from [file](secrets/gpg/serverkey_private.asc)   | ` `                                 |
| `passbolt.config.jwtkey`                             | The JWT key. If set the key will not be read from [file](secrets/jwt/jwt.key)                                        | ` `                                 |
| `passbolt.config.jwtcert`                            | The JWT certificate. If set the cert will not be read from [file](secrets/jwt/jwt.pem)                               | ` `                                 |
| `passbolt.config.license.enabled`                    | Set true if you own a license key. Add the license key in [secrets/pro-license/license](secrets/pro-license/license) | `false`                             |
| `passbolt.config.license.key`                        | The license key. If set the license key will not be read from [file](secrets/pro-license/license).                   | `false`                             |
| `passbolt.config.php.session.lifetime`               | Lifetime of your user sessions in seconds                                                                            | `3600`                              |
| `passbolt.config.php.session.redis.enabled`          | Enable this if you want to provide your own redis as a session backend                                               | `false`                             |
| `passbolt.config.php.session.redis.service`          | The URL of your redis endpoint, only useful if enabled                                                               | `redis`                             |
| `passbolt.config.plugins.exportenabled`              | Enable export plugin                                                                                                 | `true`                              |
| `passbolt.config.plugins.importenabled`              | Enable import plugin                                                                                                 | `true`                              |
| `passbolt.config.email.enabled`                      | Enable/Disable sending emails transport                                                                              | `false`                             |
| `passbolt.config.email.from`                         | From email address                                                                                                   | `you@localhost`                     |
| `passbolt.config.email.host`                         | Email server hostname                                                                                                | `localhost`                         |
| `passbolt.config.email.port`                         | Email server port                                                                                                    | `25`                                |
| `passbolt.config.email.timeout`                      | Email server timeout                                                                                                 | `30`                                |
| `passbolt.config.email.username`                     | Username for email server auth                                                                                       | `username`                          |
| `passbolt.config.email.password`                     | Password for email server auth                                                                                       | `password`                          |
| `passbolt.config.livenessProbe.failureThreshold`     | failureThreshold for livenessProbe                                                                                   | `3`                                 |
| `passbolt.config.livenessProbe.successThreshold`     | successThreshold for livenessProbe                                                                                   | `1`                                 |
| `passbolt.config.livenessProbe.periodSeconds`        | periodSeconds for livenessProbe                                                                                      | `10`                                |
| `passbolt.config.livenessProbe.initialDelaySeconds`  | initialDelaySeconds for livenessProbe                                                                                | `60`                                |
| `passbolt.config.livenessProbe.timeoutSeconds`       | timeoutSeconds for livenessProbe                                                                                     | `10`                                |
| `passbolt.config.readinessProbe.failureThreshold`    | failureThreshold for readinessProbe                                                                                  | `3`                                 |
| `passbolt.config.readinessProbe.successThreshold`    | successThreshold for readinessProbe                                                                                  | `1`                                 |
| `passbolt.config.readinessProbe.periodSeconds`       | periodSeconds for readinessProbe                                                                                     | `10`                                |
| `passbolt.config.readinessProbe.initialDelaySeconds` | initialDelaySeconds for readinessProbe                                                                               | `60`                                |
| `passbolt.config.readinessProbe.timeoutSeconds`      | timeoutSeconds for readinessProbe                                                                                    | `10`                                |

### Database
| Parameter             | Description                                       | Default    |
|-----------------------|---------------------------------------------------|------------|
| `mariadb.enabled`     | Set to false to use an existing external database | `true`     |
| `mariadb.db.host`     | Name of the passbolt database                     | `passbolt` |
| `mariadb.db.name`     | Name of the passbolt database                     | `passbolt` |
| `mariadb.db.user`     | Username of the passbolt user                     | `passbolt` |
| `mariadb.db.password` | Passwort for the passbold database user           | `passbolt` |

## GPG key generation

1. Create GPG config file gpg-server-key.conf with the following content

        %echo Generating a basic OpenPGP key
        Key-Type: RSA
        Key-Length: 4096
        Subkey-Type: RSA
        Subkey-Length: 4096
        Name-Email: joe@foo.bar
        Name-Real: Joe Tester
        Expire-Date: 0
        %echo done

2. Create GPG keys

    :warning: do not set a password, since passbolt won't start :warning:

        gpg --gen-key --batch gpg-server-key.conf


3. List GPG keys

        gpg --list-secret-keys --keyid-format LONG

    You will need this to export it and in your values.yaml to validate the keys.

4. Export keys

        KEY_ID=<put your key here>
        gpg --armor --export $KEY_ID > serverkey.asc
        gpg --armor --export-secret-keys $KEY_ID > serverkey_private.asc


:warning: Copy the serverkey.asc and serverkey_private.asc files to secrets/gpg.

## JWT key generation

1. Create a private key

        openssl genrsa -out secrets/jwt/jwt.key 4096

2. Extract the public key

        openssl rsa -in secrets/jwt/jwt.key -outform PEM -pubout -out secrets/jwt/jwt.pem

### Usage

 1. Create custom values.yaml
 2. Create gpg and jwt keys
 3. Execute:
    ```
    helm install \
      -f values.yaml \
      --set-file passbolt.config.serverkey=./gpg/serverkey.asc \
      --set-file passbolt.config.serverkey_private=./gpg/serverkey_private.asc \
      --set-file passbolt.config.jwtkey=./jwt/jwt.key \
      --set-file passbolt.config.jwtcert=./jwt/jwt.pem \
      passbolt ../passbolt-helm/

## Create first passbolt admin user

    root@passbolt-passbolt-app:/var/www/passbolt# su -m -c "bin/cake passbolt register_user -u passboltadmin@yourdomain.com -f Admin -l Istrator -r admin" -s /bin/sh www-data

## Mail testing

```
kubectl run mailpit --image=anatomicjc/mailpit
kubectl expose pod mailpit --port 1025 --name mailpit
kubectl port-forward mailpit 8025
```