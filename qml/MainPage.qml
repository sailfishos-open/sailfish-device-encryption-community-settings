import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: main

    SilicaFlickable {
        anchors.fill: parent

        Column {
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
                text: qsTr("This device supports encrytion of your personal data. Here you can change encryption passwords and reset the settings.")
                wrapMode: Text.WordWrap
            }

            Repeater {
                delegate: ListItem {
                    id: item
                    contentHeight: itemsCol.height + Theme.paddingLarge
                    enabled: initialized

                    property string name
                    property var    encrypted: undefined
                    property bool   initialized: name && encrypted !== undefined

                    Column {
                        id: itemsCol

                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.paddingMedium
                        width: main.width - 2*Theme.horizontalPageMargin
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
}
