### Environment Variable List ###
---

__This is the full list of environment variables.___


#### Container Variables ####
---

* *PANEL_VERSION*: Panel Version the image is built against.
* *STARTUP_TIMEOUT*: Timeout in seconds before the panel starts (ignored when updating or dropping to shell).
* *CONFIG_FILE*: Location of the Configuration File.
* *STORAGE_DIR*: Location of storage/cache files.


#### WebServer Variables ####
---

__*General Webserver Options*__
* *UPLOAD_LIMIT*: Limit the size a user is allowed to upload through the webserver (default 100mb)

__*Security Options*__
* *SSL*: <True/False> Enables or Disables SSL.
* *SSL_CERT*: Location for the SSL Certificate.
* *SSL_CERT_KEY*: Location of the private key.

#### Panel Variables ####
---

* *APP_URL*: URL you want to use for the panel [required on startup].
* *TIMEZONE*: 


* *CACHE_DRIVER*:

__*Database Options*__
* *DB_HOST*:
* *DB_PORT*:
* *DB_DATABASE*:
* *DB_USERNAME*:
* *DB_PASSWORD*:

__*Mailing Options*__
* *MAIL_DRIVER*:
* *MAIL_EMAIL*:
* *MAIL_FROM*:


__*Memcached Only Options*__
* *MEMCACHED_HOST*:
* *MEMCACHED_PORT*: