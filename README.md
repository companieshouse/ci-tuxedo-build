# ci-tuxedo-build

A multi-stage Docker configuration for Tuxedo-based CI builds suitable for building 32-bit ELF binaries.

## Build Tools

The following list details the build tools installed in the container image:

* GNU Compiler Collection 4.8.5
* Tuxedo (version configurable with build argument)
* Oracle Database (version configurable with build argument)
* Oracle Instant (version configurable with build argument)
* IBM Informix Client SDK (version configurable with build argument)

## Dependencies

The following list details the distribution-managed packages installed in the container image and the reason for their inclusion:

| Name                    | Purpose                                                                        |
|-------------------------|--------------------------------------------------------------------------------|
| `@Development tools`    | Satisfies core project build requirements including GCC, make, and autoconf    |
| `platform-tools-common` | Provides logging functions for CI build tasks                                  |
| `cyrus-sasl-devel.i686` | Required for [chl-tuxedo](https://github.com/companieshouse/chl-tuxedo/) build |
| `expat-devel.i686`      | Required for [chl-tuxedo](https://github.com/companieshouse/chl-tuxedo/) build |
| `glibc-devel.i686`      | Required for [chl-tuxedo](https://github.com/companieshouse/chl-tuxedo/), [ois-tuxedo](https://github.com/companieshouse/ois-tuxedo/) and [fil-tuxedo](https://github.com/companieshouse/fil-tuxedo/) builds |
| `glibc-static.i686`     | Required for [chl-tuxedo](https://github.com/companieshouse/chl-tuxedo/) build |
| `libcurl-devel.i686`    | Required for [chl-tuxedo](https://github.com/companieshouse/chl-tuxedo/) build |
| `ncurses-devel.i686`    | Required for [chl-tuxedo](https://github.com/companieshouse/chl-tuxedo/) build |
| `net-snmp-devel.i686`   | Required for [chl-tuxedo](https://github.com/companieshouse/chl-tuxedo/) build |
| `openssl-devel.i686`    | Required for [chl-tuxedo](https://github.com/companieshouse/chl-tuxedo/) build |
| `readline-devel.i686`   | Required for [chl-tuxedo](https://github.com/companieshouse/chl-tuxedo/) build |
| `libaio-devel.i686`     | Required for [fil-tuxedo](https://github.com/companieshouse/fil-tuxedo/) build |

In addition to the distribution-managed packages detailed above, the following dynamic library dependencies are also installed:

| Name                       | Purpose                                                                                                       |
|----------------------------|---------------------------------------------------------------------------------------------------------------|
| `libstdc++-libc6.2-2.so.3` | Required build and runtime dependency for [chl-tuxedo](https://github.com/companieshouse/chl-tuxedo/) project |

## SQL*Net Configuration

[fil-tuxedo](https://github.com/companieshouse/fil-tuxedo/) builds require a `tnsnames.ora` file with suitable Oracle database connection details. This file must be present in the build directory when building container images from this repository (i.e. it is required by a `COPY` instruction). However, the file is not committed to this public repository to avoid exposing connection details. The file is instead created in a separate task in the CI pipeline associated with this repository, before the image build is executed.
