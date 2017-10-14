# docker_ejbca
A dockerized installation of EJBCA for use with a dockerized PostgreSQL 9.x., e.g. with `postgres:9` or `postgres:9-alpine`.

## Dependencies
|Dependency|Version|Website|
|-|
|EJBCA|6_5.0.5|https://www.ejbca.org/|
|Wildfly|10.1.0.Final|http://wildfly.org/|
|Dockerize|0.5.0|https://github.com/jwilder/dockerize|
|Tini|0.16.1|https://github.com/krallin/tini|
|PostgreSQL JDBC Driver|42.1.4|https://jdbc.postgresql.org/|
|OpenJDK (docker)|8-alpine|https://hub.docker.com/_/openjdk/|
|Apache ANT (alpine 3.6)|1.10.1-r0|https://pkgs.alpinelinux.org/package/v3.6/community/x86_64/apache-ant|
|postgresql-client (alpine 3.6)|9.6.5-r0|https://pkgs.alpinelinux.org/package/v3.6/main/x86_64/postgresql-client|

## Running with docker-compose
This image is designed to be used with `docker-compose`, use the following parameters as required:

||Parameter|Description|Default value|
|-|
|:exclamation:|EJBCA_DB_HOSTNAME|database server hostname|[required]|
||EJBCA_DB_PORT|database server port|5432|
||EJBCA_DB_NAME|database name|ejbca|
||EJBCA_DB_USER|database username|ejbca|
|:unlock:|EJBCA_DB_PASSWORD|database username password|ejbca|
||EJBCA_DB_JNDI|JNDI name of the DataSource used for EJBCA's database access|EjbcaDS|
||EJBCA_DB_USECERTTABLE|use a separate table for the certificate data?|false|
||EJBCA_ORGANIZATION|organization's name|EJBCA Sample|
||EJBCA_COUNTRY|organization's country|SE|
||EJBCA_MGMT_CA_NAME|name for the administrative CA|ManagementCA|
||EJBCA_MGMT_CA_KEYSPEC|RSA key size for the administrative CA|2048|
|:unlock:|EJBCA_JAVATRUSTPASSWORD|password for the java trust store|changeit|
||EJBCA_SUPERADMIN_CN|CN for the super administrator|SuperAdmin|
|:unlock:|EJBCA_SUPERADMIN_PASSWORD|password for the super administrator|ejbca|
|:unlock:|EJBCA_HTTPSSERVER_PASSWORD|password for the EJBCA server's TLS keystore|serverpwd|
||EJBCA_HTTPSSERVER_HOSTNAME|hostname for the EJBCA server|localhost|
||EJBCA_HTTPSERVER_PUBHTTP|the public port JBoss will listen to http on|8080|
||EJBCA_HTTPSERVER_PUBHTTPS|the public port JBoss will listen to https on, no client cert required|8442|
||EJBCA_HTTPSERVER_PRIVHTTPS|the private port JBoss will listen to https on, client cert required|8443|
||EJBCA_HTTPSERVER_PROXIED|configures the external TLS port to 443 when the server is running behind a reverse proxy|false|

For example, look at this minimal compose file (test-only):
```yml
version: '3'
services:
  db:
    image: postgres:9-alpine
    container_name: test-ejbca-db
    volumes:
      - ./test/var/postgresql/data:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=ejbca
      - POSTGRES_PASSWORD=ejbca

  ejbca:
    build: docker_ejbca
    links:
      - db
    container_name: test-ejbca
    environment:
      - EJBCA_DB_HOSTNAME=db
```

:exclamation: Please note that, in the example above, this repo is used as the parameter for the `build:` option.

## License
GNU General Public License v3. See [LICENSE](./LICENSE) for details.
