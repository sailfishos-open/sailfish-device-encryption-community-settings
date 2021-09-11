import QtQuick 2.0
import Sailfish.Silica 1.0

import Nemo.DBus 2.0

Page {
    id: app

    property var dbus
    property var devices
    property var passwordTypes

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column
            spacing: Theme.paddingLarge
            width: parent.width

            PageHeader {
                title: qsTr("Encryption")
            }

            Label {
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                color: Theme.highlightColor
                text: qsTr("This device supports encrytion of your personal data. Here you can change encryption passwords and change the settings.")
                wrapMode: Text.WordWrap
            }

            Repeater {
                delegate: ListItem {
                    id: item
                    contentHeight: itemsCol.height + Theme.paddingLarge
                    enabled: initialized

                    property var    encrypted: undefined
                    property string name
                    property bool   initialized: name && encrypted !== undefined

                    Column {
                        id: itemsCol

                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.paddingMedium
                        width: app.width - 2*Theme.horizontalPageMargin
                        x: Theme.horizontalPageMargin

                        Label {
                            text: item.initialized ? item.name : qsTr("Loading ...")
                            truncationMode: TruncationMode.Fade
                            width: parent.width
                        }

                        Label {
                            color: Theme.secondaryColor
                            horizontalAlignment: Text.AlignRight
                            text: item.encrypted ? qsTr("Encrypted") : qsTr("Not encrypted")
                            truncationMode: TruncationMode.Fade
                            visible: item.initialized
                            width: parent.width
                        }
                    }

                    Component.onCompleted: {
                        app.dbus.call("DeviceName", modelData,
                                      function(result) {
                                          item.name = result;
                                      },
                                      function(error) {
                                          item.name = qsTr("Error");
                                          app.error(qsTr('Name unknown'),  qsTr('Error while asking for device %1 name.').arg(modelData));
                                      });
                        app.dbus.call("DeviceEncrypted", modelData,
                                      function(result) {
                                          item.encrypted = result;
                                      },
                                      function(error) {
                                          app.error(qsTr('Encryption unknown'),  qsTr('Error while asking for device %1 encryption state.').arg(modelData));
                                      });
                    }


                    onClicked: {
                        if (!initialized) return;
                        pageStack.push(Qt.resolvedUrl("DevicePage.qml"),
                                       {
                                           "app": app,
                                           "deviceId": modelData,
                                           "name": item.name,
                                           "encrypted": item.encrypted
                                       });
                    }
                }

                model: app.devices
            }
        }

        VerticalScrollDecorator { flickable: parent }
    }

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
