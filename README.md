# SanteDB

Welcome to SanteDB community! SanteDB provides a general purpose Clinical Data Repository (CDR) and client software for storage of applications in a variety of 
use cases. SanteDB is a holistic package and includes:

* [A general purpose Intelligent CDR based on the powerful HL7 Reference Information Model (RIM) and FHIR](https://github.com/santedb/santedb-server).
    * All resources are fully versioned
    * Customizable Act<>Act, Act<>Entity, Entity<>Entity relationship tracking
    * Completely customizable concept dictionary & reference term set
    * Works on PostgreSQL Server 9.4+ or FirebirdSQL Server 3.0
    * Powerful caching solution using either REDIS or native in-memory cache
* A powerful privacy, security and audit trail
    * Authorization with TFA supported (currently SMS and E-Mail) when online
    * Full provenance of data is maintained on the server infrastructure (application, device, user, session, time tracking)
    * Device / Application / User level authentication 
    * Policy based access controls 
    * Powerful consent management system (PDP, PEP, PIP implementation) supporting policy based data masking 
    * Support for user elevation (break-the-glass)
* [A fully functional disconnected client environment which](https://github.com/santedb/santedb-dc-core):
    * Can partially replicate the master CDR data on demand based on subscriptions
    * Operate offline for months at a time
    * Execute all business rules on the CDR with no connection to the server software
    * Operates in Windows, Android, Linux, MacOS X
    * Can operate as a server permitting offline hospitals to share one portal over a disconnected LAN
    * Operates as a Disconnected Gateway, allowing "online-only" applications to harness the power of offline-first
    * Disconnected Client for Windows fully encrypts data at rest (Linux SQLCipher help needed)
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

To clone this project follow these steps:

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

Please note that you will need to have the followig additional projects cloned and compiled in your local nugetstaging (until we upload the packages to nuget):
* [SwaggerWCF MEDIC Fork](https://github.com/MohawkMEDIC/swaggerwcf) - Which provides support for JSON.NET structures
* [SQLite.NET-PCL MEDIC Fork](https://github.com/MohawkMEDIC/SQLite.NET-PCL) - Which provides support for SQLCipher

Additional documentation for setup of individual SanteDB components can be found in each project repository.

## Get All SanteDB Projects

This project represents the collection of SanteDB APIs that are used by other projects. These APIs and other projects are located in other repositories in the SanteDB community.
If you would like to clone **all** of the SanteDB code to your local environment, use the command:

```
> cd ..
> santedb\cloneall.bat
> cloneall.bat
```

This will clone all projects on the SanteDB project in the parent directory for SanteDB and will initialize any submodule references. 

## Compilation / Running on Linux

SanteDB has recently undergone a very massive refactor and all service references to WCF have been removed. This means it is theoretically 
possible to compile and run SanteDB on Linux. However, it should be known that at this early phase of development, SanteDB
is still only officially tested and built on Microsoft Windows. As more time becomes available for testing, it will be done 
on Linux.