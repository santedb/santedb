# <img src="http://santesuite.org/assets/img/logo.png" height="32px" style="float:left; padding:4px; margin-top:3px" /> SanteDB Core Project

Welcome to SanteDB community! 

SanteDB provides a general purpose Clinical Data Repository (CDR) and client software for storage of applications in a variety of 
use cases. This repository is a meta-repository which contains the core modules of the SanteDB project. If you're looking to run 
SanteDB you'll want one of the other repositories such as:

* [SanteDB iCDR (integrated Clinical Data Repository)](https://github.com/santedb/santedb-server)
    * SanteDB server platform running in a central datacenter
    * Supports PostgreSQL 9+ or Firebird 3
    * Runs on Windows, Linux and MacOS
* SanteDB dCDR Technologies
    * [SanteDB Disconnected Client](https://github.com/santedb/santedb-dcc): Self contained user-facing application for deployment into the field
    * [SanteDB Disconnected Gateway](https://github.com/santedb/santedb-dcg): Offline Gateway platform bridging HL7v2.x, FHIR, ATNA, and HDSI services for third party applications
    * [SanteDB Disconnected App](https://github.com/santedb/santedb-dc-android): Offline mobile application running on Android 5.0 or higher
* [SanteDB Software Development Kit](https://github.com/santedb/santedb-sdk) 
    * Develop your own applicatons and plugins in the SanteDB platform.

## Key Modules for iCDR and dCDR

SanteDB provides several solutions which can combined to morph SanteDB based on need.

* [SanteGuard Audit Repository](https://github.com/santedb/santeguard): 
  * Integrates IETF RFC3881 and NEMA DICOM audits into the audit store
  * Provides more detailed storage schema for audits in the SanteDB software stack
  * Enables Syslog receive endpoint over UDP, TCP, STCP, and HTTP
  * (Roadmap): Implements FHIR Audit Endpoints
* [SanteMPI Master Patient Index Addons](https://github.com/santedb/santempi):
  * Integrates rules for IHE PIX/PDQ v2 into SanteDB's HL7 messaging infrastructure
  * Provides enhanced user interfaces for searching, merging, and de-duplicating patients
  * (Roadmap): Implements FHIR PIXm and PDQm 
 * [SanteDB Enhanced Data Matcher](https://github.com/santedb/santedb-match):
   * Provides probabilistic and deterministic matching services for SanteDB
   * Extends the baseline SanteDB query matching engine with fuzzy API calls (soundex, metaphone, levenshtein, etc.)
 * [SanteDB Business Intelligence Services (BIS)](https://github.com/santedb/santedb-bis):
   * Allows definition of re-usable BI components (Queries, Views, Reports)
   * (Roadmap): Exposing of measures via FHIR MeasureReport

## Key Features of iCDR and dCDR

* Privacy and Security
  * Full audit trail of all data operations within the solution
  * Audit shipping via IETF RFC3881 and NEMA DICOM
  * Allows easy integration with SIEM infrastructure and monitoring software
  * Implementation of OpenID Conect authentication
  * Allow policy based access controls on a per-device, per-user, per-application level
  * Customizable consent management system (PDP, PEP, PIP implementations) including consent override functions.
  * (Roadmap): Credential delegation (on-behalf of grants)
  * (Roadmap): Multi-role authentication (different policy grants based on site, job, etc.)
* Standards based interfaces which allow full communication with the CDR, standards interfaces available include:
  * HL7 FHIR R3
  * HL7 Version 2.5
  * OAUTH2.0 & JWT
  * NEMA DICOM & RFC-3881 format security
  * GS1 BMS 3.3 XML (over AS.2 or REST)
* Fully open interfaces using REST interfaces and either XML, JSON or condensed JSON for view-model applications. Provides 100% access to the CDR functionality
* Support for transport compression schemes such as DEFLATE, GZIP, BZIP or LZMA
* You can customize SanteDB for any use case using the following technologies:
  * HTML5 + JavaScript (AngularJS) for user interface screens (operates on all platforms that SanteDB operates on)
  * SanteDB CDSS RulesML an XML when/then rules engine
  * JavaScript business rule triggers based on ECMA Script 5 (before/after insert/update/delete/query triggers supported)
  * A robust plugin architecture for endless expansion of functionality in C#

SanteDB is based on the underlying CDR used by the [Open Immunize Platform](http://openiz.org).

## Getting Started

This project is a meta-project used for bundling and distributing the NUGET packages which make-up the rest of the SanteDB platform.

You don't need this project's source code to start developing SanteDB plugins and applications. That can be done by following the documentation
over on the [SanteDB Help Portal](https://help.santesuite.org/ops/santedb/santedb).

If you're looking to contribute to the core SanteDB source code tree, you can get started by cloning this core module set.

```
> git clone https://github.com/santedb/santedb.git
> cd santedb
> git submodule init
> git submodule update --remote
```

Ensure that nuget.exe is located in your path and that ```%localappdata%\nugetstaging```, is registered as a local repository, 
then build the nuget packages for SanteDB with:

```
> build-nuget-symbols
```

Additional documentation for setup of individual SanteDB components can be found in each project repository.

## Get All SanteDB Projects

This project represents the collection of SanteDB APIs that are used by other projects. These APIs and other projects are located in other repositories in the SanteDB community.
If you would like to clone **all** of the SanteDB code to your local environment, use the command:

```
> cd ..
> santedb\cloneall.bat
```

This will clone all projects on the SanteDB project in the parent directory for SanteDB and will initialize any submodule references. 

## Compilation / Running on Linux

SanteDB has recently undergone a very massive refactor and all service references to WCF have been removed. This means it is theoretically 
possible to compile and run SanteDB on Linux. However, it should be known that at this early phase of development, SanteDB
is still only officially tested and built on Microsoft Windows. As more time becomes available for testing, it will be done 
on Linux.

Pre-requisites for developing on Linux:
* Mono Framework 5.x or higher
* Git client
* MonoDevelop 
* 7z

Projects which require special compilation steps in linux will have -linux appended to the file. For example, the 
santedb-linux.sln project will load linux specific projects.

To clone in linux:

```
$ git clone https://github.com/santedb/santedb.git
$ cd santedb
$ git submodule init
$ git submodule update --remote
```

To clone all projects:

```
$ cd ..
$ ./santedb/cloneall.sh
```

To build SanteDB on linux, you'll have to ensure that ~/.nugetstaging exists and is configured as a Nuget package source.

```
$ ./build-nuget-staging
```