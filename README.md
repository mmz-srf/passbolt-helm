# Passbolt Kubernetes Helm Charts

This helm chart installs the [passbolt container](https://github.com/passbolt/passbolt_docker/tree/master)  and a mysql database (mariadb)

## Parameters

For more parameters you should have a look at ...
- the [values.yaml](values.yaml) file of this helm chart
- the [values.yaml](https://github.com/helm/charts/blob/master/stable/mariadb/values.yaml) file of the mariadb helm chart
- the [enviroment variables](https://github.com/passbolt/passbolt_docker/tree/master) of the passbold docker image.

### General 

| Parameter | Description | Default |
| - | - | - |
| `replicaCount` | How many replicas should be deployed | `1` |
| `image.repository` | Passbolt image repository | `"passbolt/passbolt"` |
| `image.tag` | Passbolt image tag | `"latest"` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Image pull secrets | `[]` |
| `nameOverride` | Name override | `""` |
| `fullnameOverride` | Full name override | `""` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `80` |
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.host` | Ingress host | `passbolt.yourdomain.com` |

### Passbolt 

| Parameter | Description | Default |
| - | - | - |
| `passbolt.config.debug` | Enable/Disable debug output in passbolt image | `false` |
| `passbolt.config.registration` | Enable/Disable user can register | `false` |
| `passbolt.config.salt` | Salt. Generate: ```openssl rand -base64 32``` | `"your salt"` |
| `passbolt.config.gpgServerKeyFingerprint` | The GPG server key fingerprint. See [GPG key genereation](#gpg-key-generation)  | `"your gpg server key fingerprint"` |
| `passbolt.config.license.enabled` | Set true if you own a license key. You have to put the key after the deployment in the passbolt secret. | `false` |
| `passbolt.config.plugins.exportenabled` | Enable export plugin | `true` |
| `passbolt.config.plugins.importenabled` | Enable import plugin | `true` |
| `passbolt.config.email.enabled` | Enable/Disable sending emails transport | `false` |
| `passbolt.config.email.from` | From email address	| `you@localhost` |
| `passbolt.config.email.host` | Email server hostname | `localhost` |
| `passbolt.config.email.port` | Email server port | `25` |
| `passbolt.config.email.timeout` | Email server timeout | `30` |
| `passbolt.config.email.username` | Username for email server auth | `username` |
| `passbolt.config.email.password` | Password for email server auth | `password` |

### Database
| Parameter | Description | Default |
| - | - | - | 
| `db.replication.enabled` | Enable mariadb replication. | `false` |
| `db.db.name` | Name of the passbolt database | `passbolt` |
| `db.db.user` | Username of the passbolt user | `passbolt` |
| `db.db.password` | Passwort for the passbold database user | `passbolt` | 



## GPG key genereation

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

## Create first passbolt admin user

    root@passbolt-passbolt-app:/var/www/passbolt# su -m -c "bin/cake passbolt register_user -u passboltadmin@yourdomain.com -f Admin -l Istrator -r admin" -s /bin/sh www-data