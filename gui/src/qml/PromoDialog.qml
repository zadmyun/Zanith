import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

Popup {
    id: promoDialog
    parent: Overlay.overlay
    modal: true
    dim: true
    focus: true
    closePolicy: Popup.NoAutoClose
    padding: 0
    z: 10000

    property bool decisionMade: false

    // Use the main content item's logical pixel size, not Overlay dimensions.
    // This stays centered as the window/DPI scale changes and avoids the
    // negative coordinates that occurred when Overlay was not laid out yet.
    width: Math.min(1080, Math.max(680, root.width * 0.78), Math.max(320, root.width - 48))
    height: Math.min(660, Math.max(430, root.height * 0.76), Math.max(300, root.height - 48))
    x: Math.max(24, Math.round((root.width - width) / 2))
    y: Math.max(24, Math.round((root.height - height) / 2))

    Material.theme: Material.Dark
    Material.background: root.zanithBackground

    Overlay.modal: Rectangle {
        color: "#B0000712"
    }

    background: Rectangle {
        radius: 20
        border.width: 2
        border.color: root.zanithBlue
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#07101D" }
            GradientStop { position: 1.0; color: "#030914" }
        }
    }

    onOpened: {
        decisionMade = false;
        offersButton.forceActiveFocus(Qt.TabFocusReason);
    }

    onClosed: {
        // Only the three explicit choices are allowed to dismiss this dialog.
        if (!decisionMade)
            Qt.callLater(function() { promoDialog.open(); });
    }

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape) {
            event.accepted = true;
            return;
        }
    }

    contentItem: Item {
        anchors.fill: parent

        RowLayout {
            anchors.fill: parent
            anchors.margins: Math.max(18, Math.min(28, promoDialog.width * 0.025))
            spacing: Math.max(18, Math.min(30, promoDialog.width * 0.025))

            Rectangle {
                Layout.preferredWidth: Math.max(250, Math.min(390, promoDialog.width * 0.38))
                Layout.fillHeight: true
                radius: 18
                color: "#0B1525"
                border.width: 1
                border.color: root.zanithBorder

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 12

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.max(230, Math.min(340, promoDialog.height * 0.52))
                        Layout.minimumHeight: 220
                        radius: 14
                        color: "#F5F6F8"

                        Image {
                            anchors.centerIn: parent
                            width: Math.max(180, Math.min(parent.width - 16, parent.height - 16))
                            height: width
                            fillMode: Image.PreserveAspectFit
                            source: "qrc:/icons/zanith_promo_qr.png"
                            sourceSize: Qt.size(Math.round(width), Math.round(height))
                        }
                    }

                    Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: "t.me/+jLyaJ9nZM1EzOTFh"
                        color: "white"
                        font.pixelSize: 18
                        font.bold: true
                        wrapMode: Text.WrapAnywhere
                    }

                    Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: root.zt("Point your phone camera at the QR code", "Aponte com a câmera do celular")
                        color: root.zanithMuted
                        font.pixelSize: 15
                        wrapMode: Text.WordWrap
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 0
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Image {
                        Layout.preferredWidth: 54
                        Layout.preferredHeight: 54
                        source: "qrc:/icons/zanith-logo.svg"
                        sourceSize: Qt.size(54, 54)
                        fillMode: Image.PreserveAspectFit
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Label {
                            text: "Zanit"
                            color: "white"
                            font.pixelSize: 28
                            font.bold: true
                        }
                        Label {
                            text: root.zt("PROMOTIONS", "PROMOÇÕES")
                            color: "#32C8F1"
                            font.pixelSize: 15
                            font.letterSpacing: 4
                        }
                    }
                }

                Label {
                    Layout.fillWidth: true
                    text: root.zt("All your hardware at the best price", "Todo o seu hardware pelo melhor preço")
                    color: "white"
                    font.pixelSize: Math.max(26, Math.min(38, promoDialog.width * 0.035))
                    font.bold: true
                    wrapMode: Text.WordWrap
                }

                Label {
                    Layout.fillWidth: true
                    Layout.maximumHeight: Math.max(70, Math.min(100, promoDialog.height * 0.16))
                    text: root.zt(
                        "Deals, useful links and hardware opportunities selected to help you spend less and upgrade your setup. Choose one of the options below to continue.",
                        "Ofertas, links úteis e oportunidades de hardware selecionadas para você gastar menos e melhorar seu setup. Escolha uma das opções abaixo para continuar."
                    )
                    color: "#D7E0EF"
                    font.pixelSize: Math.max(14, Math.min(17, promoDialog.height * 0.028))
                    wrapMode: Text.WordWrap
                    lineHeight: 1.08
                }

                Item { Layout.fillHeight: true; Layout.minimumHeight: 4 }

                Button {
                    id: offersButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(46, Math.min(62, promoDialog.height * 0.095))
                    Layout.leftMargin: 6
                    Layout.rightMargin: 6
                    text: root.zt("I WANT THE DEALS", "QUERO AS OFERTAS")
                    font.pixelSize: 20
                    font.bold: true
                    onClicked: {
                        promoDialog.decisionMade = true;
                        Qt.openUrlExternally("https://t.me/+jLyaJ9nZM1EzOTFh");
                        promoDialog.close();
                    }
                    Material.background: "#1C9ED0"
                    Material.foreground: "white"
                }

                Button {
                    id: supportButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(46, Math.min(58, promoDialog.height * 0.09))
                    Layout.leftMargin: 6
                    Layout.rightMargin: 6
                    text: root.zt("SUPPORT THE CHANNEL", "APOIAR O CANAL")
                    font.pixelSize: 19
                    font.bold: true
                    onClicked: {
                        promoDialog.decisionMade = true;
                        Qt.openUrlExternally("https://www.youtube.com/@Zanitzada");
                        promoDialog.close();
                    }
                    Material.background: "#0A1422"
                    Material.foreground: "#31D1F3"

                    Image {
                        anchors.left: parent.left
                        anchors.leftMargin: 18
                        anchors.verticalCenter: parent.verticalCenter
                        width: Math.max(26, Math.min(32, supportButton.height * 0.58))
                        height: width
                        source: "qrc:/icons/youtube-channel-avatar.png"
                        sourceSize: Qt.size(64, 64)
                        fillMode: Image.PreserveAspectCrop
                        opacity: 0.82
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(46, Math.min(58, promoDialog.height * 0.09))
                    Layout.leftMargin: 6
                    Layout.rightMargin: 6
                    text: root.zt("NOT TODAY", "HOJE NÃO")
                    font.pixelSize: 19
                    font.bold: true
                    onClicked: {
                        promoDialog.decisionMade = true;
                        promoDialog.close();
                    }
                    Material.background: "#18A94A"
                    Material.foreground: "white"
                }

                Label {
                    Layout.topMargin: 2
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: root.zt("Zanit App opening...", "Zanit App abrindo...")
                    color: "#71819B"
                    font.pixelSize: 14
                }
            }
        }
    }
}
