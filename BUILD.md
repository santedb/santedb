# Building SanteDB

Welcome to the SanteDB community! As you may have noticed from the many repositories and sub-modules for this project, SanteDB is a very robust platform for deploying health information solutions. 

SanteDB can be used in a variety of use cases, for example:
* A clinical Data Repository
* A master patient index
* A facility/location registry
* An audit repository
* A shared health record
* etc.

If you're looking to leverage the SanteDB platform to develop a solution on top of the platform, we recommend using the binary copy of the [SanteDB Server](https://github.com/santedb/santedb-server/releases), and [SanteDB SDK](https://github.com/santedb/santedb-sdk/releases).

If, however, you're interested in contributing or maintaining the core solution items, then this guide is for you.

## Tooling Required

In order to compile SanteDB you'll need one of the two following environments:

* Microsoft Windows 8 or higher
* Microsoft Visual Studio Community / Professional / Enterprise (2017 or 2019)
* Git Client
* Microsoft Visual Studio Code (recommended)

On Linux you'll need:

* A modern Linux distribution (like Ubuntu or Cent-OS)
* Mono 5.x (development packages)
* Monodevelop
* Visual Studio Code (recommended)

# Obtaining the Code & Repository Structure

The primary [SanteDB Repository](https://github.com/santedb/santedb) is a meta-repository which contains tools which allow for the easy
compilation and maintenance of the SanteDB core. This repository mostly houses the APIs and Libraries upon which SanteDB is built. There 
are several other repositories which produce actual executables:

* SanteDB Server - https://github.com/santedb/santedb-server
* SanteDB SDK - https://github.com/santedb/santedb-sdk
* SanteDB Disconnected Gateway - https://github.com/santedb/santedb-dcg
* SanteDB Disconnected Android App - https://github.com/santedb/santedb-dc-android
* SanteDB Web Portal Server - https://github.com/santedb/santedb-www

Additionally useful solutions exist which enable a series of "plugins" on SanteDB:

* Sante Guard (Enhanced Audit Repository) - https://github.com/santedb/santeguard
* SanteMPI (PIX/PDQ Support & UI) - https://github.com/santedb/santempi

## Solution Structures

In each project within SanteDB, you may notice a collection of .sln files. These files modify the way in which the solution is loaded and some are better suited for certain use cases than others.

* *-ext* - Solutions ending with -ext (example: santedb-server-ext.sln) will load the source files for all sub-modules into the solution. This is useful if you want to debug and edit submodule files within an execution context.
* *-linux* - Solutions ending with -linux (example: santedb-linux.sln) exclude projects which require Windows to successfully compile.

# Checking out SanteDB code

It is recommended you create a new folder (for example: santedb-dev) into which you can clone the various projects. 

You can checkout the primary repository by running:

```
git clone https://github.com/santedb/santedb
```

This will create a new directory santedb, you can then clone all the relevant projects into that directory by running: 

```
cd santedb
cloneall
```

This will check out the relevant projects from Github and initialize the submodule structure. After this is complete you should have a directory structure such as:

```
+ santedb-dev
    + santedb
        |- santedb-api
        |- santedb-dc-core
        |- santedb-bre-js
        ...
    + santedb-server
        |- santedb-api
        |- santedb-dc-core
        |- santedb-bre-js
        ...
    + santedb-sdk
        ...
    + santempi
        ...
    + santeguard
        ...
```

## Prepare your Compile Environment

The SanteDB git project is typically a few versions ahead of the Nuget repository, as such, before you compile you'll have to setup a local Nuget repository where the compile process can 
place nupkg files to support your compile. You should create a directory in ```%localappdata%\NugetStaging``` or in linux ```~/.nugetstaging```. Then edit
your nuget configuration to register that path as a local nuget repository.

## Compile SanteDB core

To compile santedb core, first, change to the santedb directory, run a submodule-pull and then compile:

```
cd santedb
submodule-pull
build-nuget-symbols VERSION-CODE
```

**Note** On linux the commands are ```./submodule-pull.sh``` and ```./build-nuget-symbols.sh```

### Versioning Flags

By default, when you compile the SanteDB services in Visual Studio, they will receive a version of 2.1.0-debug, when you're attempting to build an actual versioned copy of the solution (either server or this repository) you should indicate the version. This is done using the batch file as `build-nuget-symbols version` (for example, to tag the nuget packages as version 2.1.99 `build-nuget-symbold 2.1.99`) or by using the `/p:VersionNumber=X` parameter on the msbuild command:

```
msbuild /t:restore /t:clean /t:build /p:Configuration=Debug /p:VersionNumber=2.1.99 santedb-server-ext.sln
```

## Compile SanteDB Server

To compile the santedb server, the process is very similar to compiling the core libraries:

```
cd santedb-server
submodule-pull
build-pack
```

On linux, you'll have to manually build using these commands:

```
cd ./santedb-server
../santedb/submodule-pull.sh
msbuild /t:clean /t:restore /t:build /p:Configuration=Debug santedb-server-linux-nuget.sln
```

You should only compile the server after compiling the core libraries.

## Compiling the Applets

Several of the projects in the core platform are applet packages. These packages require the [SanteDB SDK](https://github.com/santedb/santedb-sdk) in order to 
be compiled into usable PAK files. To compile applet projects, open a **SanteDB SDK Command Prompt** and run:

```
cd applets
pack-debug.bat
```

This command will work on the directories **applets, santempi, santeguard**.
