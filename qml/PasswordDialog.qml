import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: dialog

    canNavigateForward: {
        if (singlePassword) return passwordControl.length;
        return passwordAction.length > 1 && passwordControl.length > 1 &&
                (!repeatActionPassword || action.text === actionRepeated.text) &&
                passwordAction !== passwordControl;
    }

    property alias  acceptText: header.acceptText
    property string actionTitle
    property string controlTitle: qsTr("Current password")
    property string description
    property alias  passwordAction: action.text
    property string passwordActionType: actionType.currentItem ? actionType.currentItem.text : ""
    property alias  passwordControl: control.text
    property string passwordControlType: controlType.currentItem ? controlType.currentItem.text : ""
    property bool   repeatActionPassword: true
    property bool   singlePassword: false
    property string title

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column
            spacing: Theme.paddingLarge
            width: dialog.width

            DialogHeader {
                id: header
                title: title
            }

            Label {
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin

                color: Theme.highlightColor
                height: implicitHeight + 2*Theme.paddingLarge
                text: description
                wrapMode: Text.WordWrap
            }

            // control password
            SectionHeader {
                text: controlTitle
            }


            ComboBox {
                id: controlType
                label: qsTr("Password type")
                menu: ContextMenu {
                    Repeater {
                        delegate: MenuItem { text: modelData }
                        model: app.passwordTypes
                    }
                }
            }

            PasswordField {
                id: control
                label: controlTitle
                text: ""
                EnterKey.onClicked: {
                    if (singlePassword) {
                        if (canNavigateForward) dialog.accept();
                        return;
                    }
                    action.focus = true;
                }
            }

            // action password
            SectionHeader {
                text: actionTitle
                visible: !singlePassword
            }


            ComboBox {
                id: actionType
                label: qsTr("Password type")
                menu: ContextMenu {
                    Repeater {
                        delegate: MenuItem { text: modelData }
                        model: app.passwordTypes
                    }
                }
                visible: !singlePassword
            }

            PasswordField {
                id: action
                errorHighlight: action.text && action.text == control.text &&
                                passwordActionType == passwordControlType
                label: errorHighlight ?
                           qsTr("Cannot have the same %1 and %2").arg(controlTitle).arg(actionTitle) :
                           actionTitle
                text: ""
                visible: !singlePassword
                EnterKey.onClicked: {
                    if (repeatActionPassword) actionRepeated.focus = true;
                    else if (canNavigateForward) dialog.accept();
                }
            }

            PasswordField {
                id: actionRepeated
                errorHighlight: text && action.text != text
                label: {
                    if (!text) return qsTr("Repeat password");
                    if (action.text != text)
                        return qsTr("Passwords do not match");
                    return qsTr("Passwords match");
                }
                text: ""
                visible: !singlePassword && repeatActionPassword
                EnterKey.onClicked: if (canNavigateForward) dialog.accept();
            }
        }

        VerticalScrollDecorator { flickable: parent }
    }
}
