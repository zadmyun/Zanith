import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import org.streetpea.chiaking

import "controls" as C

DialogView {
    id: dialog
    property bool opening: false
    property bool succeeded: false
    property bool fromReminder
    title: root.zt("Create Non-Steam Game", "Criar jogo não-Steam")
    buttonText: root.zt("Create", "Criar")
    buttonEnabled: name.text.trim() && !opening
    function close() {
        root.closeDialog();
        if(dialog.fromReminder && Chiaki.settings.remotePlayAsk)
        {
            if(!Chiaki.settings.psnRefreshToken || !Chiaki.settings.psnAuthToken || !Chiaki.settings.psnAuthTokenExpiry || !Chiaki.settings.psnAccountId)
                root.showRemindDialog(root.zt("Remote Play via PSN", "Remote Play via PSN"), root.zt("Would you like to connect to PSN?\nThis enables:\n- Automatic registration\n- Playing outside of your home network without port forwarding?\n\n(Note: If you select no now and want to do this later, go to the Config section of the settings.)", "Deseja conectar à PSN?\nIsso habilita:\n- Registro automático\n- Jogar fora da sua rede local sem port forwarding\n\n(Se escolher não agora, poderá fazer isso depois na aba Perfis/configurações.)"), true, () => root.showPSNTokenDialog(false));
            else
                Chiaki.settings.remotePlayAsk = false;
        }
    }
    onAccepted: {
        opening = true;
        logDialog.open();
        Chiaki.createSteamShortcut(name.text.trim(), options.text.trim(), function(msg, ok, done) {
            if(ok)
            {
                succeeded = true;
                Chiaki.settings.addSteamShortcutAsk = false;
            }
            if (!done)
                logArea.text += msg + "\n";
            else
            {
                logArea.text += msg + "\n";
                logDialog.standardButtons = Dialog.Close;
                opening = false;
            }
        }, shortcutGrid.steamBasePath);
    }

    Item {
        GridLayout {
            id: shortcutGrid
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                topMargin: 20
            }
            columns: 2
            rowSpacing: 40
            columnSpacing: 20
            property var steamBasePath: ""

            Label {
                Layout.alignment: Qt.AlignRight
                text: root.zt("Steam Game Name", "Nome do jogo na Steam")
            }

            C.TextField {
                id: name
                Layout.preferredWidth: 400
                text: Chiaki.settings.currentProfile ? "Zanith " + Chiaki.settings.currentProfile: "Zanith"
                firstInFocusChain: true
            }

            Label {
                Layout.alignment: Qt.AlignRight
                text: root.zt("Launch Options [Optional]", "Opções de inicialização [Opcional]")
            }

            C.TextField {
                id: options
                text: Chiaki.settings.currentProfile ? root.zt("--profile=", "--profile=") + Chiaki.settings.currentProfile : ""
                Layout.preferredWidth: 400
            }

            Label {
                Layout.alignment: Qt.AlignRight
                text: root.zt("Custom Steam Base Path (Optional)", "Caminho base personalizado da Steam (Opcional)")
            }

            Label {
                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: 400
                text: shortcutGrid.steamBasePath
            }

            Label {
            }

            C.Button {
                id: choosePathButton
                text: root.zt("Choose new steam base path", "Escolher novo caminho base da Steam")
                onClicked: {
                    shortcutGrid.steamBasePath = Chiaki.settings.chooseSteamBasePath();
                }
                Material.roundedScale: Material.SmallScale
            }
        }

        Item {
            Dialog {
                id: logDialog
                parent: Overlay.overlay
                x: Math.round((root.width - width) / 2)
                y: Math.round((root.height - height) / 2)
                title: root.zt("Create non-Steam game", "Criar jogo não-Steam")
                modal: true
                closePolicy: Popup.NoAutoClose
                standardButtons: Dialog.Cancel
                Material.roundedScale: Material.MediumScale
                onOpened: logArea.forceActiveFocus(Qt.TabFocusReason)
                onClosed: if(succeeded) { restartDialog.open(); }

                Flickable {
                    id: logFlick
                    implicitWidth: 600
                    implicitHeight: 400
                    clip: true
                    contentWidth: logArea.contentWidth
                    contentHeight: logArea.contentHeight
                    flickableDirection: Flickable.AutoFlickIfNeeded
                    ScrollBar.vertical: ScrollBar {
                        id: logScrollbar
                        policy: ScrollBar.AlwaysOn
                        visible: logFlick.contentHeight > logFlick.implicitHeight
                    }

                    Label {
                        id: logArea
                        width: logFlick.width
                        height: logFlick.height
                        wrapMode: Text.Wrap
                        Keys.onReturnPressed: if (logDialog.standardButtons == Dialog.Close) logDialog.close()
                        Keys.onEscapePressed: logDialog.close()
                        Keys.onPressed: (event) => {
                            switch (event.key) {
                            case Qt.Key_Up:
                                if(logScrollbar.position > 0.001)
                                    logFlick.flick(0, 500);
                                event.accepted = true;
                                break;
                            case Qt.Key_Down:
                                if(logScrollbar.position < 1.0 - logScrollbar.size - 0.001)
                                    logFlick.flick(0, -500);
                                event.accepted = true;
                                break;
                            }
                        }
                    }
                }
            }
        }

        Dialog {
            id: restartDialog
            parent: Overlay.overlay
            x: Math.round((root.width - width) / 2)
            y: Math.round((root.height - height) / 2)
            title: root.zt("Please Restart Steam", "Reinicie a Steam")
            modal: true
            closePolicy: Popup.NoAutoClose
            standardButtons: Dialog.Close
            Material.roundedScale: Material.MediumScale
            onOpened: restartArea.forceActiveFocus(Qt.TabFocusReason)
            onClosed: dialog.close()

            Flickable {
                id: restartFlick
                implicitWidth: 600
                implicitHeight: 50
                clip: true
                contentWidth: restartArea.contentWidth
                contentHeight: restartArea.contentHeight
                flickableDirection: Flickable.AutoFlickIfNeeded
                ScrollIndicator.vertical: ScrollIndicator { }

                Label {
                    id: restartArea
                    text: "In order for " + name.text.trim() + " to appear in Steam,\nSteam must be restarted!"
                    wrapMode: Text.Wrap
                    Keys.onReturnPressed: if (restartDialog.standardButtons == Dialog.Close) restartDialog.close()
                    Keys.onEscapePressed: restartDialog.close()
                }
            }
        }
    }
}