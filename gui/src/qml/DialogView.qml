import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

Item {
    id: dialog
    property alias header: headerLabel.text
    property alias title: titleLabel.text
    property alias buttonText: okButton.text
    property alias buttonEnabled: okButton.enabled
    property alias buttonVisible: okButton.visible
    property Item restoreFocusItem
    default property Item mainItem: null

    signal accepted()
    signal rejected()

    function close() { root.closeDialog(); }

    Keys.onEscapePressed: close()
    Keys.onMenuPressed: {
        if (okButton.enabled)
            okButton.clicked()
    }

    StackView.onDeactivating: {
        restoreFocusItem = Window.window.activeFocusItem;
    }

    StackView.onActivated: {
        if (!restoreFocusItem) {
            let item = mainItem ? mainItem.nextItemInFocusChain() : null;
            if (item)
                item.forceActiveFocus(Qt.TabFocusReason);
        } else {
            restoreFocusItem.forceActiveFocus(Qt.TabFocusReason);
            restoreFocusItem = null;
        }
    }

    onMainItemChanged: {
        if (mainItem) {
            mainItem.parent = contentItem;
            mainItem.anchors.fill = contentItem;
        }
    }

    Rectangle {
        anchors.fill: parent
        color: root.zanitBackground
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0D1628" }
            GradientStop { position: 1.0; color: "#080E18" }
        }
    }

    Rectangle {
        id: toolBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 104
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "#18349C" }
            GradientStop { position: 0.55; color: "#0D6EF3" }
            GradientStop { position: 1.0; color: "#153AA9" }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 26
            anchors.rightMargin: 26
            spacing: 14

            Button {
                Layout.preferredWidth: 58
                Layout.preferredHeight: 58
                flat: true
                text: "‹"
                font.pixelSize: 44
                focusPolicy: Qt.NoFocus
                Material.foreground: "white"
                onClicked: {
                    dialog.rejected();
                    dialog.close();
                }
            }

            Image {
                Layout.preferredWidth: 42
                Layout.preferredHeight: 42
                source: "qrc:/icons/zanit-logo.svg"
                sourceSize: Qt.size(42, 42)
            }

            ColumnLayout {
                spacing: 0
                Label {
                    text: "Zanit"
                    color: "white"
                    font.bold: true
                    font.pixelSize: 23
                }
                Label {
                    text: root.zt("Remote Play your way", "Remote Play do seu jeito")
                    color: "#D4E3FF"
                    font.pixelSize: 13
                }
            }

            Item { Layout.fillWidth: true }

            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: 1
                Label {
                    id: titleLabel
                    Layout.alignment: Qt.AlignRight
                    horizontalAlignment: Text.AlignRight
                    color: "white"
                    font.bold: true
                    font.pixelSize: 22
                }
                Label {
                    id: headerLabel
                    Layout.alignment: Qt.AlignRight
                    horizontalAlignment: Text.AlignRight
                    color: "#C8DAFF"
                    font.pixelSize: 12
                    visible: text.length > 0
                }
            }

            Button {
                id: okButton
                Layout.preferredHeight: 54
                visible: true
                flat: false
                padding: 18
                focusPolicy: Qt.NoFocus
                onClicked: dialog.accepted()
                icon.source: "qrc:/icons/options.svg"
                icon.width: 28
                icon.height: 28
                Material.background: "#2879F6"
                Material.foreground: "white"
            }
        }
    }

    Item {
        id: contentItem
        anchors.top: toolBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 18
    }
}
