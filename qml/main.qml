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
    property var passwordTypes

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
                       },
                       function(error) {
                           app.error(qsTr('Update failed'),  qsTr('Failed to establish connection with Device Encryption Service.'));
                       })
        }

        function getPasswordTypes() {
            app.dbus.call("PasswordTypes", undefined,
                          function(result) {
                              passwordTypes = result;
                          },
                          function(error) {
                              app.error(qsTr('Update failed'),  qsTr('Error while asking for supported password types.'));
                          });
        }
    }

    Component.onCompleted: {
        dbus.getDevices();
        dbus.getPasswordTypes();
    }

    function error(mainText, description) {
        pageStack.completeAnimation();
        console.log("Error: " + mainText + " / " + description);
        pageStack.push(Qt.resolvedUrl("MessagePage.qml"),
                       {
                           "title": qsTr("Error"),
                           "mainText": mainText,
                           "description": description
                       });
    }
}
