import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: devPage

    property string deviceId
    property bool   encrypted
    property string name
    property string recoveryPassword
    property int    freePasswordSlots
    property int    usedPasswordSlots

    SilicaFlickable {
        anchors.fill: parent

        Column {
            spacing: Theme.paddingLarge
            width: parent.width

            PageHeader {
                title: qsTr("Encryption: %1").arg(name)
            }

            Label {
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
                text: encrypted ? qsTr("Your device is encrypted.") : qsTr("Your device is not encrypted.")
                wrapMode: Text.WordWrap
            }

            Column {
                spacing: Theme.paddingLarge
                visible: encrypted && recoveryPassword
                width: parent.width

                SectionHeader {
                    text: qsTr("Recovery password")
                }

                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.horizontalPageMargin
                    color: Theme.highlightColor
                    text: qsTr("Your recovery password is stored on the device. Please write it down and remove its copy from the filesystem.")
                    wrapMode: Text.WordWrap
                }

                TextSwitch {
                    id: recoveryShow
                    checked: false
                    text: qsTr("Show recovery password")
                }

                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.horizontalPageMargin
                    color: Theme.highlightColor
                    text: qsTr("Your recovery password: %1").arg(recoveryPassword)
                    visible: recoveryShow.checked
                    wrapMode: Text.WordWrap
                }

                ButtonLayout {
                    Button {
                        text: qsTr("Copy to clipboard")
                        onClicked: Clipboard.text = recoveryPassword
                    }

                    Button {
                        text: qsTr("Remove password copy")
                        onClicked: {
                            app.dbus.call("RemoveRecoveryPasswordCopy", deviceId,
                                          function(result) {
                                              refreshRecoveryPassword();
                                              Notices.show(result ? qsTr("Recovery password copy removed successfully") :
                                                                    qsTr("Failed to remove recovery password copy") );
                                          },
                                          function(error) {
                                              app.error(qsTr('Failed to remove recovery password copy'),  qsTr('Error while removing device %1 recovery password copy.').arg(deviceId));
                                          });
                        }
                    }
                }
            }

            Column {
                spacing: Theme.paddingLarge
                visible: encrypted
                width: parent.width

                SectionHeader {
                    text: qsTr("Passwords")
                }

                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.horizontalPageMargin
                    color: Theme.secondaryHighlightColor
                    text: qsTr("Defined: %1\nFree slots: %2").arg(usedPasswordSlots).arg(freePasswordSlots)
                    wrapMode: Text.WordWrap
                }

                ListItem {
                    contentHeight: Theme.itemSizeMedium
                    visible: freePasswordSlots > 0

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("Add password")
                        truncationMode: TruncationMode.Fade
                        width: parent.width - 2*Theme.horizontalPageMargin
                        x: Theme.horizontalPageMargin
                    }
                }

            }
        }

        VerticalScrollDecorator { flickable: parent }
    }

    Component.onCompleted: {
        if (!encrypted) return;
        refreshPasswordSlots();
        refreshRecoveryPassword();
    }

    function refreshPasswordSlots() {
        app.dbus.call("FreePasswordSlots", deviceId,
                      function(result) {
                          freePasswordSlots = result;
                      },
                      function(error) {
                          app.error(qsTr('Update failed'),  qsTr('Error while asking for number of free password slots.'));
                      });
        app.dbus.call("UsedPasswordSlots", deviceId,
                      function(result) {
                          usedPasswordSlots = result;
                      },
                      function(error) {
                          app.error(qsTr('Update failed'),  qsTr('Error while asking for number of used password slots.'));
                      });
    }

    function refreshRecoveryPassword() {
        app.dbus.call("RecoveryPassword", deviceId,
                      function(result) {
                          recoveryPassword = result;
                      },
                      function(error) {
                          app.error(qsTr('Update failed'),  qsTr('Error while asking for device %1 recovery password.').arg(deviceId));
                      });
    }
}
