import QtQuick 2.0
import Sailfish.Silica 1.0

import Nemo.DBus 2.0

ApplicationWindow
{
    id: app

    initialPage: Component { MainPage { } }
    cover: undefined

    property var dbus
    property var devices

    DBusInterface {
        id: dbusI
        bus: DBus.SystemBus
        service: "org.sailfishos.open.device.encryption"
        path: "/"
        iface: "device.encryption.Service"

        Component.onCompleted: app.dbus = dbusI

        function getDevices() {
            dbusI.call("Devices", undefined,
                       function(result) {
                           devices = result;
            })
        }
    }

    Component.onCompleted: {
        dbus.getDevices();
    }

    function error(mainText, description) {
        pageStack.push(Qt.resolvedUrl("ErrorPage.qml"),
                       {
                           "mainText": mainText,
                           "description": description
                       });
    }
}
