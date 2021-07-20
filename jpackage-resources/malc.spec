Summary: APPLICATION_SUMMARY
Name: APPLICATION_PACKAGE
Version: APPLICATION_VERSION
Release: APPLICATION_RELEASE
License: APPLICATION_LICENSE_TYPE
Vendor: APPLICATION_VENDOR

%if "xAPPLICATION_PREFIX" != "x"
Prefix: APPLICATION_PREFIX
%endif

Provides: APPLICATION_PACKAGE

%if "xAPPLICATION_GROUP" != "x"
Group: APPLICATION_GROUP
%endif

Autoprov: 0
Autoreq: 0
%if "xPACKAGE_DEFAULT_DEPENDENCIES" != "x" || "xPACKAGE_CUSTOM_DEPENDENCIES" != "x"
Requires: PACKAGE_DEFAULT_DEPENDENCIES PACKAGE_CUSTOM_DEPENDENCIES
%endif

#comment line below to enable effective jar compression
#it could easily get your package size from 40 to 15Mb but
#build time will substantially increase and it may require unpack200/system java to install
%define __jar_repack %{nil}

%define package_filelist %{_tmppath}/%{name}.files
%define app_filelist %{_tmppath}/%{name}.app.files
%define filesystem_filelist %{_tmppath}/%{name}.filesystem.files

%define default_filesystem / /opt /usr /usr/bin /usr/lib /usr/local /usr/local/bin /usr/local/lib /usr/share /usr/share/bash-completion /usr/share/bash-completion/completions /usr/share/licenses /usr/share/man /usr/share/man/man1

%description
APPLICATION_DESCRIPTION

%prep

%build

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}APPLICATION_DIRECTORY
cp -r %{_sourcedir}APPLICATION_DIRECTORY/* %{buildroot}APPLICATION_DIRECTORY
%if "xAPPLICATION_LICENSE_FILE" != "x"
  %define license_install_file %{_defaultlicensedir}/%{name}-%{version}/%{basename:APPLICATION_LICENSE_FILE}
  install -d -m 755 "%{buildroot}%{dirname:%{license_install_file}}"
  install -m 644 "APPLICATION_LICENSE_FILE" "%{buildroot}%{license_install_file}"
%endif
gzip "%{buildroot}APPLICATION_DIRECTORY/lib/app/%{name}.1"
mkdir -p "%{buildroot}%{_bindir}" "%{buildroot}%{_mandir}/man1" "%{buildroot}%{_datadir}/bash-completion/completions"
ln -sf "APPLICATION_DIRECTORY/bin/%{name}" "%{buildroot}%{_bindir}/%{name}"
ln -sf "APPLICATION_DIRECTORY/lib/app/%{name}.1.gz" "%{buildroot}%{_mandir}/man1/%{name}.1.gz"
ln -sf "APPLICATION_DIRECTORY/lib/app/%{name}_completion.sh" "%{buildroot}%{_datadir}/bash-completion/completions/%{name}"
(cd %{buildroot} && find . -type d) | sed -e 's/^\.//' -e '/^$/d' | sort > %{app_filelist}
{ rpm -ql filesystem || printf "%s\n" %{default_filesystem}; } | sort > %{filesystem_filelist}
comm -23 %{app_filelist} %{filesystem_filelist} > %{package_filelist}
sed -i -e 's/.*/%dir "&"/' %{package_filelist}
(cd %{buildroot} && find . -not -type d) | sed -e 's/^\.//' -e 's/.*/"&"/' >> %{package_filelist}
%if "xAPPLICATION_LICENSE_FILE" != "x"
  sed -i -e 's|"%{license_install_file}"||' -e '/^$/d' %{package_filelist}
%endif

%files -f %{package_filelist}
%if "xAPPLICATION_LICENSE_FILE" != "x"
  %license "%{license_install_file}"
%endif

%post

%preun
UTILITY_SCRIPTS

%clean
