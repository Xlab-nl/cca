Client Certificate Automation
=============================
Creating and managing Client-certificates and CA certs can be quite a hassle. I created these script to ease this process.


## How to use
The best way is to fork this repository and add your own configuration files and update the `DEFAULT_BUNDLES` in the `Make file` to reflect your defaults. 

## Create CA-Certificates
Every CA Certificate has a accompanying config file that has to be in the `config/` directory. The name of the configuration file reflects the `bundle` name it will generate. 

> A `bundle` is a directory that contains all assets associated with the certificate like the `.crt`, `.key` and `passphrase` file.

You can create a new CA-Certificate by:

```bash
make ca bundle=<configfilename>
```

Or create all by:

```bash
make ca
```

> `make ca` checks the `DEFAULT_BUNDLES` variable in the Makefile to create the certificates. You can change this to suit your needs.

### Variables
```
CA_DAYS        ?= 730 #number of days the certificate is valid
CA_CONFIG_DIR  ?= ./config #where is the config dir
CA_SERIAL      ?= '01' #ssl serial for the certificate, this is shared between bundles.
```

## Create Client-Certificates
A client certificate can be created by naming it and giving it a `bundle` name where to look for the CA Certificates.

```
make client name=somename bundle=default
```
This wil create the dir `certs/somename` with the following files:

* `client.crt`: The certificate
* `client.key`: The certificate private key
* `client.csr`: The certificate singing request
* `client.p12`: P12 is compatible for use in MacOSX and Windows.
* `passphrase`: Passphrase for the `p12` file
* `client_cert.json`: JSON representation of what we just created

Example with variables

```
DAYS=30 \
COUNTRY=NL \
STATE=Amsterdam \
LOCALITY=Amsterdam \
ORGANISATION=SomeOrg \
UNIT=tech \
COMMON_NAME=client_cert \
EMAIL=someone@someorg.com \
make client name=someorg bundle=default
```


### Variables
```bash
DAYS         ?= 365
COUNTRY      ?= NL
STATE        ?= ''
LOCALITY     ?= ''
ORGANISATION ?= ''
UNIT         ?= ''
COMMON_NAME  ?= client_cert
EMAIL        ?= ''
```

