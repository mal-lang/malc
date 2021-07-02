# malc

A compiler for the Meta Attack Language.

## Build

To build `malc`, you first need to install a [Java JDK](https://jdk.java.net) (at least version 11) and [Apache Maven](https://maven.apache.org).

Download and build `malc` with the following commands:

```Shell
git clone git://github.com/mal-lang/malc.git
cd malc
mvn clean verify
```

This will create the files `target/malc-*.jar`, `target/malc_completion.sh`, and `target/generated-docs/malc.1`.

There are two ways to create an executable file for `malc`, either by using jpackage or by using GraalVM Native Image.

### jpackage

The command `jpackage` was introduced in Java 14, so you need to install a recent Java JDK to use `jpackage`.

You can verify that `jpackage` is installed by running the following command:

```Shell
jpackage --version
```

This should output the version of the Java JDK containing `jpackage`, for example:

```
16.0.1
```

#### Linux

Install prerequisites:

**Red Hat Enterprise Linux 8**
```Shell
sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo subscription-manager repos --enable "codeready-builder-for-rhel-8-$(arch)-rpms"
sudo dnf -y install ed dpkg fakeroot rpm-build
```

**Ubuntu 20.04**
```Shell
sudo apt-get -y install binutils fakeroot rpm
```

To create an installable package for `malc` using `jpackage` targetting Linux, run the following command:

```Shell
./tools/scripts/create-jpackage-linux.sh
```

This will create the files `malc-*.x86_64.rpm` and `malc_*_amd64.deb`.

If you use an RPM-based Linux distribution, install the `.rpm` file with the following command:

```Shell
sudo rpm --install malc-*.x86_64.rpm
```

And uninstall it with the following command:

```Shell
sudo rpm --erase malc
```

If you use a Debian-based Linux distribution, install the `.deb` file with the following command:

```Shell
sudo dpkg --install malc_*_amd64.deb
```

And uninstall it with the following command:

```Shell
sudo dpkg --remove malc
```

Create a symbolic link with the following command:

```Shell
sudo ln -sf /opt/malc/bin/malc /usr/local/bin/malc
```

You can now run `malc` from the command-line:

```Shell
malc --version
```

#### macOS

To create an installable package for `malc` using `jpackage` targetting macOS, run the following command:

```Shell
./tools/scripts/create-jpackage-mac.sh
```

This will create the files `malc-*.pkg` and `malc-*.dmg`.

Install either of these files normally, and create a symbolic link with the following command:

```Shell
sudo ln -sf /Applications/malc.app/Contents/MacOS/malc /usr/local/bin/malc
```

You can now run `malc` from the command-line:

```Shell
malc --version
```

#### Windows

Install prerequisites:

> WiX 3.0 or later

To create an executable file for `malc` using `jpackage` targetting Windows, run the following command:

```Batchfile
.\tools\scripts\create-jpackage-win.bat
```

This will create the files `malc-*.exe` and `malc-*.msi`.

Install either of these files normally, and add the installed executable to PATH with the following command:

```Batchfile
setx /m path "C:\Program Files\malc;%path%"
```

You can now run `malc` from the command-line:

```Batchfile
malc --version
```

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

The command `native-image` is part of [GraalVM](https://www.graalvm.org), so you need to install [GraalVM](https://www.graalvm.org/docs/getting-started) and [Native Image](https://www.graalvm.org/reference-manual/native-image) to use `native-image`.

You can create a native image on Linux or macOS with the following command:

```Shell
./tools/scripts/create-native-image.sh
```

You can create a native image on Windows with the following command in the `x64 Native Tools Command Prompt`:

```Batchfile
.\tools\scripts\create-native-image.bat
```

This will create the executable file `malc` or `malc.exe`.

You can install this file with the following commands:

**Linux and macOS**
```Shell
sudo cp malc /usr/local/bin/
```

**Windows**
```Batchfile
md "C:\Program Files\malc"
copy malc.exe "C:\Program Files\malc"
setx /m path "C:\Program Files\malc;%path%"
```

You can now run `malc` from the command-line:

```Shell
malc --version
```

### Command Line Completion

You can install command line completion for Bash or ZSH on Linux or macOS with the following commands:

**Linux**
```Shell
sudo mkdir -p /etc/bash_completion.d
sudo cp target/malc_completion.sh /etc/bash_completion.d/
```

**macOS**
```Shell
sudo mkdir -p /usr/local/etc/bash_completion.d
sudo cp target/malc_completion.sh /usr/local/etc/bash_completion.d/
```

If you have [bash-completion](https://github.com/scop/bash-completion) installed, this will be enough.
Otherwise, add the following lines to `~/.bashrc` or `~/.zshrc`:

**Linux**
```Shell
for bcfile in /etc/bash_completion.d/*; do
  . "$bcfile"
done
```

**macOS**
```Shell
for bcfile in /usr/local/etc/bash_completion.d/*; do
  . "$bcfile"
done
```

### Man Page

You can install the `man` page for `malc` on Linux or macOS with the following command:

```Shell
sudo mkdir -p /usr/local/share/man/man1
sudo cp target/generated-docs/malc.1 /usr/local/share/man/man1/
```

You might need to run the following command on Linux afterwards:

```Shell
sudo mandb
```

You can now view the `man` page for `malc` from the command-line:

```Shell
man malc
```

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

## License

Copyright © 2019-2021 [Foreseeti AB](https://foreseeti.com)

Licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0).
