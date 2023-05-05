# Passbolt Kubernetes Helm Charts

> **Warning**
> 
> This Repository is marked **deprecated** in favor of the official Passbolt charts. 
>
> https://github.com/passbolt/charts-passbolt


[![GitHub license](https://img.shields.io/github/license/mmz-srf/passbolt-helm)](https://github.com/mmz-srf/passbolt-helm/blob/master/LICENSE)
![GitHub issues](https://img.shields.io/badge/kubernetes-v1.19-green)
[![GitHub issues](https://img.shields.io/github/issues/mmz-srf/passbolt-helm)](https://github.com/mmz-srf/passbolt-helm/issues)

## Quick start

Clone this repository:

```
git clone git@github.com:mmz-srf/passbolt-helm.git
cd passbolt-helm
```

Update helm dependencies:

```
helm dep build .
```

Before deploying this chart, you must define some secrets:

* passbolt GPG server keys
* passbolt JWT keys for mobile

You can generate them with this script:

```
bash generate-secrets.sh
```

A `values-fingerprint.yaml` file will be created containing GPG keys fingerprint.

> If you are a PRO user
> * put your subscription key in `secrets/pro-license/subscription_key.txt` file.
> * Set passbolt.config.license.enabled to true in values.yaml
> * Set a [pro image tag](https://hub.docker.com/r/passbolt/passbolt/tags?page=1&name=pro) in values.yaml

Review values.yaml file, especially the `ingress.hosts.host` for passbolt domain name then deploy passbolt in your cluster

Always review passbolt configuration options it self.
Especially their environment variables https://help.passbolt.com/configure/environment/reference

### non-HA mode

This mode will deploy the [passbolt container](https://github.com/passbolt/passbolt_docker/tree/master) and a mysql database (mariadb)

> *values-fingerprint.yaml* is a file automatically created by [generate-secrets.sh](generate-secrets.sh) script and contains your GPG server fingerprint.

```
helm install passbolt . --values values-fingerprint.yaml
```

### HA mode

If you are interested with HA deployment, take care of the `passbolt.config.php.session.redis.service` setting. It is the first pod name by default of the xxx-redis-headless service where xxx is your helm release name (passbolt by default in the below helm command).

If your helm release name is **pblt**, replace **passbolt-redis-node-0.passbolt-redis-headless** with **pblt-redis-node-0.pblt-redis-headless**

While the database is not yet initialized, the replicaCount of passbolt-helm deployment must be set to 1. Once the database initialized, you can scale passbolt deployment to more than 1 replica.

If you want to import your passwords from keepass or csv, it is recommended to scale to 1. Database concurrency is not well managed while importing.

HA Mode uses MariaDB Galera cluster and Redis cluster.

You must have at least 3 worker nodes.

If you are ok with the above points, review the values-ha.yaml file and deploy the HA mode with:

```
helm upgrade --install passbolt . --values values-ha.yaml --values values-fingerprint.yaml
```

## Parameters

For more parameters you should have a look at ...
- the [values.yaml](values.yaml) file of this helm chart
- the [values.yaml](https://github.com/helm/charts/blob/master/stable/mariadb/values.yaml) file of the mariadb helm chart, when enabled
- the [values.yaml](https://github.com/bitnami/charts/blob/master/bitnami/mariadb-galera/values.yaml) file of the mariadb-galera helm chart, when enabled
- the [values.yaml](https://github.com/bitnami/charts/blob/master/bitnami/redis/values.yaml) file of the redis helm chart, when enabled
- the [environment variables](https://github.com/passbolt/passbolt_docker/tree/master) of the passbolt docker image.

### General

| Parameter          | Description                          | Default                   |
|--------------------|--------------------------------------|---------------------------|
| `replicaCount`     | How many replicas should be deployed | `1`                       |
| `image.repository` | Passbolt image repositorys           | `"passbolt/passbolt"`     |
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
| `passbolt.config.php.max_execution_time`             | PHP Max execution time                                                                                               | `300`                               |
| `passbolt.config.php.memory_limit`                   | PHP Memory Limit                                                                                                     | `512M`                              |
| `passbolt.config.php.post_max_size`                  | PHP post max size                                                                                                    | `24M`                               |
| `passbolt.config.php.upload_max_filesize`            | PHP upload max filesize                                                                                              | `24M`                               |
| `passbolt.config.php.pm_value`                       | PHP-FPM pm_value                                                                                                     | `dynamic`                           |
| `passbolt.config.php.pm.max_children`                | PHP-FPM pm.max_children                                                                                              | `40`                                |
| `passbolt.config.php.pm.start_servers`               | PHP-FPM pm.start_servers                                                                                             | `16`                                |
| `passbolt.config.php.pm.min_spare_servers`           | PHP-FPM pm.min_spare_servers                                                                                         | `8`                                 |
| `passbolt.config.php.pm.max_spare_servers`           | PHP-FPM pm.max_spare_servers                                                                                         | `16`                                |
| `passbolt.config.php.pm.process_idle_timeout`        | PHP-FPM pm.process_idle_timeout                                                                                      | `10s`                               |
| `passbolt.config.php.pm.max_requests`                | PHP-FPM pm.max_requests                                                                                              | `500`                               |
| `passbolt.config.php.session.lifetime`               | Lifetime of your user sessions in seconds                                                                            | `3600`                              |
| `passbolt.config.php.session.redis.enabled`          | Enable this if you want to provide your own redis as a session backend                                               | `false`                             |
| `passbolt.config.php.session.redis.service`          | The URL of your redis endpoint, only useful if enabled                                                               | `redis`                             |
| `passbolt.config.plugins.exportenabled`              | Enable export plugin                                                                                                 | `true`                              |
| `passbolt.config.plugins.importenabled`              | Enable import plugin                                                                                                 | `true`                              |
| `passbolt.config.plugins.ssoenabled`                 | Enable SSO plugin                                                                                                    | `true`                              |
| `passbolt.config.email.enabled`                      | Enable/Disable sending emails transport                                                                              | `false`                             |
| `passbolt.config.email.from`                         | From email address                                                                                                   | `you@localhost`                     |
| `passbolt.config.email.from_name`                    | From Name                                                                                                            | `Your Sender Name`                  |
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
      --set-file passbolt.config.serverkey=./secrets/gpg/serverkey.asc \
      --set-file passbolt.config.serverkey_private=./secrets/gpg/serverkey_private.asc \
      --set-file passbolt.config.jwtkey=./secrets/jwt/jwt.key \
      --set-file passbolt.config.jwtcert=./secrets/jwt/jwt.pem \
      passbolt ../passbolt-helm/

## Create first passbolt admin user

    root@passbolt-passbolt-app:/var/www/passbolt# su -m -c "bin/cake passbolt register_user -u passboltadmin@yourdomain.com -f Admin -l Istrator -r admin" -s /bin/sh www-data

## Mail testing

```
kubectl run mailpit --image=anatomicjc/mailpit
kubectl expose pod mailpit --port 1025 --name mailpit
kubectl port-forward mailpit 8025
```
