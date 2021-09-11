import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: dialog

    canNavigateForward: passwordAction.length > 1 && passwordControl.length > 1 &&
                        (!repeatActionPassword || action.text === actionRepeated.text) &&
                        passwordAction !== passwordControl

    property alias  acceptText: header.acceptText
    property string actionTitle
    property string controlTitle: qsTr("Current password")
    property string description
    property alias  passwordAction: action.text
    property string passwordActionType: actionType.currentItem ? actionType.currentItem.text : ""
    property alias  passwordControl: control.text
    property string passwordControlType: controlType.currentItem ? controlType.currentItem.text : ""
    property bool   repeatActionPassword: true
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
                EnterKey.onClicked: action.focus = true
            }

            // action password
            SectionHeader {
                text: actionTitle
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
            }

            PasswordField {
                id: action
                errorHighlight: action.text && action.text == control.text &&
                                passwordActionType == passwordControlType
                label: errorHighlight ?
                           qsTr("Cannot have the same %1 and %2").arg(controlTitle).arg(actionTitle) :
                           actionTitle
                text: ""
                EnterKey.onClicked: actionRepeated.focus = true
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
                EnterKey.onClicked: if (canNavigateForward) dialog.accept();
            }
        }

        VerticalScrollDecorator { flickable: parent }
    }
}
