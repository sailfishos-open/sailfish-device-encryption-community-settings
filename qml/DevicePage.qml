import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: devPage

    // set by page initialization
    property string deviceId
    property bool   encrypted
    property string name

    // local properties
    property bool   busy: busyText
    property string busyText
    property string recoveryPassword
    property int    freePasswordSlots
    property int    usedPasswordSlots

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column
            spacing: Theme.paddingLarge
            visible: !busy
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

            /////////////////////////////////////////////
            // Recovery password
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
                            setBusy(qsTr("Removing recovery password copy"))
                            app.dbus.call("RemoveRecoveryPasswordCopy", deviceId,
                                          function(result) {
                                              clearBusy();
                                              refreshRecoveryPassword();
                                              Notices.show(result ? qsTr("Recovery password copy removed successfully") :
                                                                    qsTr("Failed to remove recovery password copy") );
                                          },
                                          function(error) {
                                              clearBusy();
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
                    text: qsTr("Set: %1 password(s)\nFree slots: %2").arg(usedPasswordSlots).arg(freePasswordSlots)
                    wrapMode: Text.WordWrap
                }

                /////////////////////////////////////////////
                // Add password
                ListItem {
                    contentHeight: Theme.itemSizeSmall
                    visible: freePasswordSlots > 0

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("Add password")
                        truncationMode: TruncationMode.Fade
                        width: parent.width - 2*Theme.horizontalPageMargin
                        x: Theme.horizontalPageMargin
                    }

                    onClicked: {
                        var dialog = pageStack.push(Qt.resolvedUrl("PasswordDialog.qml"),
                                                    {
                                                        "acceptText": qsTr("Add"),
                                                        "actionTitle": qsTr("New password"),
                                                        "title": qsTr("Add password"),
                                                        "description": qsTr("Add a new password for unlocking your encrypted device. " +
                                                                            "You have to specify one of the current passwords and a new password.")
                                                    });
                        dialog.accepted.connect(function() {
                            setBusy(qsTr("Adding new password"));
                            app.dbus.call("AddPassword",
                                          [deviceId,
                                           dialog.passwordControl, dialog.passwordControlType,
                                           dialog.passwordAction, dialog.passwordActionType],
                                          function(result) {
                                              clearBusy();
                                              refreshPasswordSlots();
                                              if (result) Notices.show(qsTr("Password added"));
                                          },
                                          function(error, message) {
                                              clearBusy();
                                              app.error(qsTr('Failed to add password'),  message);
                                              refreshPasswordSlots();
                                          });
                        });
                    }
                }

                /////////////////////////////////////////////
                // Test password
                ListItem {
                    contentHeight: Theme.itemSizeSmall
                    visible: usedPasswordSlots > 0

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("Test password")
                        truncationMode: TruncationMode.Fade
                        width: parent.width - 2*Theme.horizontalPageMargin
                        x: Theme.horizontalPageMargin
                    }

                    onClicked: {
                        var dialog = pageStack.push(Qt.resolvedUrl("PasswordDialog.qml"),
                                                    {
                                                        "acceptText": qsTr("Test"),
                                                        "controlTitle": qsTr("Tested password"),
                                                        "title": qsTr("Test password"),
                                                        "description": qsTr("Test whether a password can by used for unlocking your encrypted device. "),
                                                        "singlePassword": true
                                                    });
                        dialog.accepted.connect(function() {
                            setBusy(qsTr("Testing password"));
                            app.dbus.call("TestPassword",
                                          [deviceId,
                                           dialog.passwordControl, dialog.passwordControlType],
                                          function(result) {
                                              clearBusy();
                                              pageStack.completeAnimation();
                                              pageStack.push(Qt.resolvedUrl("MessagePage.qml"),
                                                             {
                                                                 "title": qsTr("Password testing"),
                                                                 "mainText": result ? qsTr("Provided password can unlock encrypted device") :
                                                                                      qsTr("Provided password failed to unlock encrypted device")
                                                             });
                                          },
                                          function(error, message) {
                                              clearBusy();
                                              app.error(qsTr('Testing password failed'),  message);
                                          });
                        });
                    }
                }

                /////////////////////////////////////////////
                // Remove password
                ListItem {
                    contentHeight: Theme.itemSizeSmall
                    visible: usedPasswordSlots > 1

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr("Remove password")
                        truncationMode: TruncationMode.Fade
                        width: parent.width - 2*Theme.horizontalPageMargin
                        x: Theme.horizontalPageMargin
                    }

                    onClicked: {
                        var dialog = pageStack.push(Qt.resolvedUrl("PasswordDialog.qml"),
                                                    {
                                                        "acceptText": qsTr("Remove"),
                                                        "actionTitle": qsTr("Removed password"),
                                                        "controlTitle": qsTr("Remaining password"),
                                                        "title": qsTr("Remove password"),
                                                        "description": qsTr("Remove a password used for unlocking your encrypted device. " +
                                                                            "You have to specify password to remove as well as one " +
                                                                            "of the remaining passwords to ensure that you can unlock your device later."),
                                                        "repeatActionPassword": false
                                                    });
                        dialog.accepted.connect(function() {
                            setBusy(qsTr("Removing password"));
                            app.dbus.call("RemovePassword",
                                          [deviceId,
                                           dialog.passwordControl, dialog.passwordControlType,
                                           dialog.passwordAction, dialog.passwordActionType],
                                          function(result) {
                                              clearBusy();
                                              refreshPasswordSlots();
                                              if (result) Notices.show(qsTr("Password removed"));
                                          },
                                          function(error, message) {
                                              clearBusy();
                                              app.error(qsTr('Failed to remove password'),  message);
                                              refreshPasswordSlots();
                                          });
                        });
                    }
                }
            }
        }

        VerticalScrollDecorator { flickable: parent }
    }

    BusyLabel {
        text: busyText
        running: busy
    }

    Component.onCompleted: {
        if (!encrypted) return;
        refreshPasswordSlots();
        refreshRecoveryPassword();
    }

    function clearBusy() {
        busyText = "";
    }

    function setBusy(txt) {
        busyText = txt;
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
