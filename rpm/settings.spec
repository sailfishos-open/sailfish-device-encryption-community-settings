Name:       sailfish-device-encryption-community-settings

Summary:    Settings for Sailfish Device Encryption
Version:    0.1
Release:    1
Group:      Qt/Qt
License:    GPLv2
URL:        https://github.com/sailfishos-open/sailfish-device-encryption-community-settings
Source0:    %{name}-%{version}.tar.bz2
Requires:   sailfishsilica-qt5 >= 0.10.9
Requires:   sailfish-device-encryption-community-service
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils
BuildRequires:  cmake

%description
%summary

%prep
%setup -q -n %{name}-%{version}

%build

%cmake . 
make %{?_smp_mflags}

%install
rm -rf %{buildroot}
%make_install

# move to Jolla Settings
mkdir -p %{buildroot}%{_datadir}/jolla-settings/pages/community-encryption
cp %{buildroot}%{_datadir}/%{name}/qml/*.qml \
   %{buildroot}%{_datadir}/jolla-settings/pages/community-encryption

mkdir -p %{buildroot}%{_datadir}/jolla-settings/entries
cp jolla-settings/*.json %{buildroot}%{_datadir}/jolla-settings/entries

mkdir -p %{buildroot}%{_datadir}/translations
for i in %{buildroot}%{_datadir}/%{name}/translations/*.qm; do
    cp $i %{buildroot}%{_datadir}/translations/community-encryption-`basename $i`
done
cp %{buildroot}%{_datadir}/%{name}/translations/en.qm %{buildroot}%{_datadir}/translations/community-encryption_eng_en.qm


%files
%defattr(-,root,root,-)
%exclude %{_bindir}
%exclude %{_datadir}/%{name}
%{_datadir}/translations
%{_datadir}/jolla-settings
