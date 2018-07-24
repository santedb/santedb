# SanteDB

Welcome to SanteDB! SanteDB provides a general purpose Clinical Data Repository (CDR) and client software for storage of applications in a variety of 
use cases. SanteDB is a holistic package and includes:

* A general purpose CDR based on the powerful HL7 Reference Information Model (RIM) and FHIR.
* A fully functional disconnected client environment which:
    * Can partially replicate the master CDR data on demand based on subscriptions
    * Operate offline for months at a time
    * Execute all business rules on the CDR with no connection to the server software
    * Operates in Windows, Android, Linux, MacOS X
    * Can operate as a server permitting offline hospitals to share one portal over a disconnected LAN
* Standards based interfaces which allow full communication with the CDR, standards interfaces available include:
  * HL7 FHIR R4
  * HL7 Version 2.5
  * HL7 Version 3
  * GS1 BMS 3.3 XML (over AS.2 or REST)
* Fully open interfaces using REST interfaces and either XML, JSON or condensed JSON for view-model applications. Provides 100% access to the CDR functionality
* Support for transport compression schemes such as DEFLATE, GZIP, BZIP or LZMA
* You can customize SanteDB for any use case using the following technologies:
  * HTML5 + JavaScript (AngularJS) for user interface screens (operates on all platforms that SanteDB operates on)
  * SanteDB CDSS RulesML an XML when/then rules engine
  * JavaScript business rule triggers based on ECMA Script 5 (before/after insert/update/delete/query triggers supported)
* A robust plugin architecture for endless expansion of functionality.

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
> build-nuget
```

Please note that you will need to have the followig additional projects cloned and compiled in your local nugetstaging (until we upload the packages to nuget):
* [SwaggerWCF MEDIC Fork](https://github.com/MohawkMEDIC/swaggerwcf) - Which provides support for JSON.NET structures
* [SQLite.NET-PCL MEDIC Fork](https://github.com/MohawkMEDIC/SQLite.NET-PCL) - Which provides support for SQLCipher

Additional documentation for setup of individual SanteDB components can be found in each project repository.

## Get All SanteDB Projects

This project represents the collection of SanteDB APIs that are used by other projects. These APIs and other projects are located in other repositories in the SanteDB community.
If you would like to clone **all** of the SanteDB code to your local environment, use the command:

```
> cloneall.bat
```

This will clone all projects on the SanteDB project in the parent directory for SanteDB and will initialize any submodule references. 
