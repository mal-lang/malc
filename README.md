# malc

A compiler for the Meta Attack Language.

## Installation

Release builds of malc are available at https://github.com/mal-lang/malc/releases/.

### Linux

There are three different builds available for Linux:

* `malc-*.x86_64.rpm`
* `malc_*_amd64.deb`
* `malc-*.linux.amd64.tar.gz`

The `.rpm` and `.deb` packages are built with jpackage, and the `.tar.gz` archive is built with GraalVM Native Image.

If you want command-line completion, you need to install [bash-completion](https://github.com/scop/bash-completion):

**Red Hat Enterprise Linux 8**
```Shell
sudo dnf -y install bash-completion
```

**Ubuntu 20.04**
```Shell
sudo apt-get -y install bash-completion
```

#### RPM

If you use an RPM-based Linux distribution, install the `.rpm` file with the following command:

```Shell
sudo dnf -y install ./malc-*.x86_64.rpm
```

And uninstall it with the following command:

```Shell
sudo dnf -y remove malc
```

#### DEB

If you use a Debian-based Linux distribution, install the `.deb` file with the following command:

```Shell
sudo apt-get -y install ./malc_*_amd64.deb
```

And uninstall it with the following command:

```Shell
sudo apt-get -y remove malc
```

#### TARBALL

Install the `.tar.gz` archive with the following commands:

```Shell
sudo mkdir -p /opt /usr/local/bin /usr/local/share/man/man1 /usr/local/share/bash-completion/completions
sudo tar -xzf malc-*.linux.amd64.tar.gz -C /opt
sudo ln -sf /opt/malc-*.linux.amd64/malc /usr/local/bin/malc
sudo ln -sf /opt/malc-*.linux.amd64/malc.1 /usr/local/share/man/man1/malc.1
sudo ln -sf /opt/malc-*.linux.amd64/malc_completion.sh /usr/local/share/bash-completion/completions/malc
```

### macOS

There are three different builds available for macOS:

* `malc-*.pkg`
* `malc-*.dmg`
* `malc-*.mac.x86_64.tar.gz`

The `.pkg` and `.dmg` packages are built with jpackage, and the `.tar.gz` archive is built with GraalVM Native Image.

#### PKG and DMG

Install either the `.pkg` file or the `.dmg` file normally, and execute the following commands:

```Shell
sudo mkdir -p /usr/local/bin /usr/local/share/man/man1
sudo ln -sf /Applications/malc.app/Contents/MacOS/malc /usr/local/bin/malc
sudo ln -sf /Applications/malc.app/Contents/app/malc.1 /usr/local/share/man/man1/malc.1

# ZSH
echo "[ -f /Applications/malc.app/Contents/app/malc_completion.sh ] && . /Applications/malc.app/Contents/app/malc_completion.sh" >> ~/.zshrc

# Bash
echo "[ -f /Applications/malc.app/Contents/app/malc_completion.sh ] && . /Applications/malc.app/Contents/app/malc_completion.sh" >> ~/.bashrc
```

#### TARBALL

Install the `.tar.gz` archive with the following commands:

```Shell
sudo mkdir -p /opt /usr/local/bin /usr/local/share/man/man1
sudo tar -xzf malc-*.mac.x86_64.tar.gz -C /opt
sudo ln -sf /opt/malc-*.mac.x86_64/malc /usr/local/bin/malc
sudo ln -sf /opt/malc-*.mac.x86_64/malc.1 /usr/local/share/man/man1/malc.1

# ZSH
echo "[ -f /opt/malc-*.mac.x86_64/malc_completion.sh ] && . /opt/malc-*.mac.x86_64/malc_completion.sh" >> ~/.zshrc

# Bash
echo "[ -f /opt/malc-*.mac.x86_64/malc_completion.sh ] && . /opt/malc-*.mac.x86_64/malc_completion.sh" >> ~/.bashrc
```

### Windows

There are three different builds available for Windows:

* `malc-*.exe`
* `malc-*.msi`
* `malc-*.win.amd64.zip`

The `.exe` and `.msi` packages are built with jpackage, and the `.zip` archive is built with GraalVM Native Image.

#### EXE and MSI

Install either the `.exe` file or the `.msi` file normally, and add `C:\Program Files\malc` to the environment variable `Path`.

#### ZIP

Install the `.zip` archive by extracting it somewhere, and add the extracted directory that contains `malc.exe` to the environment variable `Path`.

## Usage

```
Usage: malc [-dhvV] [-i=<dir>] [-l=<file>] [-n=<file>] [-o=<file>] file
A compiler for the Meta Attack Language.
      file               The MAL specification to compile
  -i, --icons=<dir>      Icons directory
  -l, --license=<file>   License file
  -n, --notice=<file>    Notice file
  -o, --output=<file>    Write output to <file>
  -v, --verbose          Print verbose output
  -d, --debug            Print debug output
  -h, --help             Show this help message and exit.
  -V, --version          Print version information and exit.
```

## Build

To build malc, you first need to install a [Java JDK](https://jdk.java.net) (at least version 11) and [Apache Maven](https://maven.apache.org).

Download and build malc with the following commands:

```Shell
git clone git://github.com/mal-lang/malc.git
cd malc
mvn clean verify
```

This will have the following effects:
* The target artifact `target/malc-*.jar` is created
* All runtime dependencies are copied to `target/dependency`
* The application directory `target/app-input` is prepared
* Build scripts are prepared in `target/scripts`

There are two ways to create an executable file for malc, either by using jpackage or by using GraalVM Native Image.

### jpackage

The command `jpackage` was introduced in Java 14, so you need to install a recent Java JDK to use jpackage.

You can verify that jpackage is installed by running the following command:

```Shell
jpackage --version
```

This should output the version of the Java JDK containing jpackage, for example:

```
16.0.1
```

#### Linux

Install prerequisites:

**Red Hat Enterprise Linux 8**
```Shell
sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo subscription-manager repos --enable "codeready-builder-for-rhel-8-$(arch)-rpms"
sudo dnf -y install dpkg fakeroot rpm-build
```

**Ubuntu 20.04**
```Shell
sudo apt-get -y install binutils fakeroot rpm
```

To create an installable package for malc using jpackage targetting Linux, run the following command:

```Shell
./target/scripts/create-jpackage-linux.sh
```

This will create the files `target/malc-*.x86_64.rpm` and `target/malc_*_amd64.deb`.

#### macOS

To create an installable package for malc using jpackage targetting macOS, run the following command:

```Shell
./target/scripts/create-jpackage-mac.sh
```

This will create the files `target/malc-*.pkg` and `target/malc-*.dmg`.

#### Windows

Install prerequisites:

> WiX 3.0 or later

To create an installable package for malc using jpackage targetting Windows, run the following command:

```Batchfile
.\target\scripts\create-jpackage-win.bat
```

This will create the files `target\malc-*.exe` and `target\malc-*.msi`.

### GraalVM Native Image

Install prerequisites:

**Red Hat Enterprise Linux 8**
```Shell
sudo dnf -y install gcc glibc-devel zlib-devel libstdc++-static
```

**Ubuntu 20.04**
```Shell
sudo apt-get -y install build-essential libz-dev zlib1g-dev
```

**macOS**
```Shell
xcode-select --install
```

**Windows**
> Microsoft Visual C++ (MSVC) that comes with Visual Studio 2017 15.5.5 or later

The command `native-image` is part of [GraalVM](https://www.graalvm.org), so you need to install [GraalVM](https://www.graalvm.org/docs/getting-started) and [Native Image](https://www.graalvm.org/reference-manual/native-image) to use GraalVM Native Image.

You can verify that GraalVM Native Image is installed by running the following command:

```Shell
native-image --version
```

This should output the version of the Java JDK containing GraalVM Native Image, for example:

```
GraalVM 21.1.0 Java 11 CE (Java Version 11.0.11+8-jvmci-21.1-b05)
```

You can create a native image on Linux or macOS with the following command:

```Shell
./target/scripts/create-native-image.sh
```

You can create a native image on Windows with the following command in the `x64 Native Tools Command Prompt`:

```Batchfile
.\target\scripts\create-native-image.bat
```

This will create one of the following archives depending on your platform:
* `target/malc-*.linux.amd64.tar.gz`
* `target/malc-*.mac.x86_64.tar.gz`
* `target\malc-*.win.amd64.zip`

## License

Copyright © 2019-2021 [Foreseeti AB](https://foreseeti.com)

Licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0).
