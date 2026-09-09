import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import org.streetpea.chiaking

Pane {
    id: consolePane
    padding: 0

    StackView.onActivated: {
        forceActiveFocus(Qt.TabFocusReason);
        if(!Chiaki.autoConnect && !root.initialAsk && !Chiaki.window.directStream)
        {
            root.initialAsk = true;
            if(Chiaki.settings.addSteamShortcutAsk && (typeof Chiaki.createSteamShortcut === "function"))
                root.showRemindDialog(root.zt("Official Steam artwork + controller layout", "Arte oficial do Steam + layout do controle"), root.zt("Would you like to either create a new non-Steam game for Zanit or update an existing non-Steam game with the official artwork and controller layout?\n\n(Note: If you select no now and want to do this later, use the menu on the main screen.)", "Deseja criar um novo jogo não-Steam para o Zanit ou atualizar um existente com a arte e o layout de controle?\n\n(Se escolher não agora, você poderá fazer isso depois pelo menu da tela principal.)"), false, () => root.showSteamShortcutDialog(true));
            else if(Chiaki.settings.remotePlayAsk)
            {
                if(!Chiaki.settings.psnRefreshToken || !Chiaki.settings.psnAuthToken || !Chiaki.settings.psnAuthTokenExpiry || !Chiaki.settings.psnAccountId)
                    root.showRemindDialog(root.zt("Remote Play via PSN", "Remote Play via PSN"), root.zt("Would you like to connect to PSN?\nThis enables:\n- Automatic registration\n- Playing outside of your home network without port forwarding?\n\n(Note: You can configure this later in Remote settings.)", "Deseja conectar à PSN?\nIsso habilita:\n- Registro automático\n- Jogar fora da sua rede local sem port forwarding\n\n(Você pode configurar isso depois em Remoto.)"), true, () => root.showPSNTokenDialog(false));
                else
                    Chiaki.settings.remotePlayAsk = false;
            }
        }
    }

    Keys.onUpPressed: {
        if(hostsView.currentItem && hostsView.currentItem.visible) {
            hostsView.decrementCurrentIndex();
            while(hostsView.currentItem && !hostsView.currentItem.visible)
                hostsView.decrementCurrentIndex();
        }
    }
    Keys.onDownPressed: {
        if(hostsView.currentItem && hostsView.currentItem.visible) {
            hostsView.incrementCurrentIndex();
            while(hostsView.currentItem && !hostsView.currentItem.visible)
                hostsView.incrementCurrentIndex();
        }
    }
    Keys.onMenuPressed: settingsButton.clicked()
    Keys.onReturnPressed: if (hostsView.currentItem) hostsView.currentItem.connectToHost()
    Keys.onYesPressed: if (hostsView.currentItem) hostsView.currentItem.wakeUpHost()
    Keys.onNoPressed: if (hostsView.currentItem) hostsView.currentItem.deleteHost()
    Keys.onEscapePressed: root.showConfirmDialog(root.zt("Quit", "Sair"), root.zt("Are you sure you want to quit?", "Tem certeza de que deseja sair?"), () => Qt.quit())
    Keys.onPressed: (event) => {
        if (event.modifiers)
            return;
        switch (event.key) {
        case Qt.Key_PageUp:
            if (hostsView.currentItem) hostsView.currentItem.setConsolePin();
            event.accepted = true;
            break;
        case Qt.Key_PageDown:
            if (Chiaki.settings.psnAuthToken) Chiaki.refreshPsnToken();
            event.accepted = true;
            break;
        case Qt.Key_F1:
            if (typeof Chiaki.createSteamShortcut === "function") root.showSteamShortcutDialog(false);
            event.accepted = true;
            break;
        case Qt.Key_F2:
            root.showManualHostDialog();
            event.accepted = true;
            break;
        }
    }

    background: Rectangle {
        color: root.zanitBackground
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0D1628" }
            GradientStop { position: 1.0; color: "#080E18" }
        }
    }

    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 112
        radius: 0
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "#18349C" }
            GradientStop { position: 0.55; color: "#0D6EF3" }
            GradientStop { position: 1.0; color: "#153AA9" }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 34
            anchors.rightMargin: 28
            spacing: 18

            Image {
                Layout.preferredWidth: 50
                Layout.preferredHeight: 50
                source: "qrc:/icons/zanit-logo.svg"
                sourceSize: Qt.size(50, 50)
                fillMode: Image.PreserveAspectFit
            }

            ColumnLayout {
                spacing: 0
                Label {
                    text: "Zanit"
                    color: "white"
                    font.bold: true
                    font.pixelSize: 27
                }
                Label {
                    text: root.zt("Remote Play your way", "Remote Play do seu jeito")
                    color: "#D3E2FF"
                    font.pixelSize: 15
                }
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                id: youtubeButton
                Layout.preferredWidth: dlss5Status.width
                Layout.preferredHeight: dlss5Status.height
                radius: height / 2
                color: youtubeMouse.pressed ? "#C9140C" : (youtubeMouse.containsMouse ? "#FF352D" : "#F3261D")
                border.width: 2
                border.color: "#111111"
                clip: true

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 9
                    anchors.rightMargin: 9
                    spacing: 5

                    Rectangle {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        Layout.alignment: Qt.AlignVCenter
                        radius: 14
                        color: "#16233A"
                        border.width: 1
                        border.color: "#111111"
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: "qrc:/icons/youtube-channel-avatar.png"
                            sourceSize: Qt.size(28, 28)
                            fillMode: Image.PreserveAspectCrop
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 14
                        Layout.alignment: Qt.AlignVCenter
                        radius: 4
                        color: "white"

                        Canvas {
                            anchors.centerIn: parent
                            width: 8
                            height: 10
                            onPaint: {
                                const ctx = getContext("2d");
                                ctx.clearRect(0, 0, width, height);
                                ctx.fillStyle = "#F3261D";
                                ctx.beginPath();
                                ctx.moveTo(1, 0);
                                ctx.lineTo(width, height / 2);
                                ctx.lineTo(1, height);
                                ctx.closePath();
                                ctx.fill();
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: -2

                        Label {
                            Layout.fillWidth: true
                            text: "YouTube"
                            color: "white"
                            font.bold: true
                            font.pixelSize: 12
                            elide: Text.ElideRight
                        }
                        Label {
                            Layout.fillWidth: true
                            text: root.zt("SUBSCRIBE TO THE CHANNEL", "INSCREVA-SE NO CANAL")
                            color: "white"
                            font.bold: true
                            font.pixelSize: 6
                            elide: Text.ElideRight
                        }
                    }
                }

                MouseArea {
                    id: youtubeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Qt.openUrlExternally("https://www.youtube.com/@Zanitzada")
                }

                ToolTip.visible: youtubeMouse.containsMouse
                ToolTip.text: root.zt("Open Zanit channel on YouTube", "Abrir o canal do Zanit no YouTube")
            }

            Rectangle {
                id: dlss5Status
                Layout.preferredWidth: dlss5StatusRow.implicitWidth + 28
                Layout.preferredHeight: 42
                radius: 21
                color: Chiaki.window.dlss5RuntimeLoaded ? "#123F57" : "#493B20"
                border.width: 1
                border.color: Chiaki.window.dlss5RuntimeLoaded ? "#39D98A" : "#FFB13B"

                Row {
                    id: dlss5StatusRow
                    anchors.centerIn: parent
                    spacing: 8

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 9
                        height: 9
                        radius: 5
                        color: Chiaki.window.dlss5RuntimeLoaded ? "#39D98A" : "#FFB13B"
                    }

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Chiaki.window.dlss5RuntimeLoaded
                              ? root.zt("DLSS 5 READY", "DLSS 5 PRONTO")
                              : root.zt("DLSS 5 OFF", "DLSS 5 DESLIGADO")
                        color: "white"
                        font.bold: true
                        font.pixelSize: 13
                    }
                }

                ToolTip.visible: dlss5StatusMouse.containsMouse
                ToolTip.text: Chiaki.window.dlss5RuntimeStatus
                MouseArea {
                    id: dlss5StatusMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                }
            }

            RoundButton {
                id: addHostButton
                Layout.preferredWidth: 62
                Layout.preferredHeight: 62
                display: AbstractButton.IconOnly
                icon.source: "qrc:/icons/add-24px.svg"
                icon.width: 26
                icon.height: 26
                focusPolicy: Qt.NoFocus
                onClicked: root.showManualHostDialog()
                ToolTip.visible: hovered
                ToolTip.text: root.zt("Add console manually", "Adicionar console manualmente")
                Material.background: "#2879F6"
                Material.foreground: "white"
            }

            RoundButton {
                id: settingsButton
                Layout.preferredWidth: 62
                Layout.preferredHeight: 62
                icon.source: "qrc:/icons/settings-20px.svg"
                icon.width: 34
                icon.height: 34
                focusPolicy: Qt.NoFocus
                onClicked: root.showSettingsDialog()
                ToolTip.visible: hovered
                ToolTip.text: root.zt("Settings", "Configurações")
                Material.background: "#2879F6"
                Material.foreground: "white"
            }

            RoundButton {
                id: moreButton
                Layout.preferredWidth: 54
                Layout.preferredHeight: 54
                text: "⋮"
                font.pixelSize: 30
                focusPolicy: Qt.NoFocus
                onClicked: overflowMenu.popup()
                Material.background: "transparent"
                Material.foreground: "white"
            }
        }
    }

    Menu {
        id: overflowMenu
        MenuItem {
            text: root.zt("Create Steam Shortcut", "Criar atalho no Steam")
            visible: typeof Chiaki.createSteamShortcut === "function"
            onTriggered: root.showSteamShortcutDialog(false)
        }
        MenuItem {
            text: root.zt("Refresh PSN Hosts", "Atualizar consoles PSN")
            visible: !!Chiaki.settings.psnAuthToken
            onTriggered: Chiaki.refreshPsnToken()
        }
        MenuSeparator { }
        MenuItem {
            text: root.zt("Zanit on YouTube", "Zanit no YouTube")
            onTriggered: Qt.openUrlExternally("https://www.youtube.com/@Zanitzada")
        }
        MenuItem {
            text: root.zt("More information about Zanit", "Mais informações sobre o Zanit")
            onTriggered: promoDialog.open()
        }
        MenuSeparator { }
        MenuItem {
            text: root.zt("Quit", "Sair")
            onTriggered: root.showConfirmDialog(root.zt("Quit", "Sair"), root.zt("Are you sure you want to quit?", "Tem certeza de que deseja sair?"), () => Qt.quit())
        }
    }

    ListView {
        id: hostsView
        keyNavigationWraps: true
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footerStatus.top
        anchors.topMargin: 24
        anchors.leftMargin: 28
        anchors.rightMargin: 28
        anchors.bottomMargin: 20
        spacing: 14
        clip: true
        model: Chiaki.hosts

        onCountChanged: {
            if(!hostsView.currentItem)
                hostsView.incrementCurrentIndex();
            if(!hostsView.currentItem)
                return;
            if(!hostsView.currentItem.visible) {
                for(var i = 0; i < hostsView.count; i++) {
                    hostsView.incrementCurrentIndex();
                    if(hostsView.currentItem && hostsView.currentItem.visible)
                        break;
                }
            }
        }

        delegate: ItemDelegate {
            id: delegate
            visible: modelData.display
            width: hostsView.width
            height: modelData.display ? 214 : 0
            highlighted: ListView.isCurrentItem
            padding: 0
            onClicked: connectToHost()

            background: Rectangle {
                radius: 22
                color: delegate.highlighted ? "#172A48" : root.zanitSurface
                border.width: delegate.highlighted ? 2 : 1
                border.color: delegate.highlighted ? root.zanitBlue : root.zanitBorder
            }

            function connectToHost() {
                if(modelData.discovered)
                    Chiaki.connectToHost(index, modelData.name);
                else
                    Chiaki.connectToHost(index);
            }

            function wakeUpHost() {
                if(!modelData.discovered && !modelData.duid)
                    Chiaki.wakeUpHost(index);
            }

            function deleteHost() {
                if (modelData.manual)
                    root.showConfirmDialog(root.zt("Delete Console", "Excluir console"), root.zt("Are you sure you want to delete this console?", "Tem certeza de que deseja excluir este console?"), () => {Chiaki.deleteHost(index)});
                else if (modelData.discovered && !modelData.registered)
                    root.showConfirmDialog(root.zt("Hide Console", "Ocultar console"), root.zt("Are you sure you want to hide this console?\n\nYou can unhide it later from Settings > Consoles.", "Tem certeza de que deseja ocultar este console?\n\nVocê pode reexibi-lo depois em Configurações > Consoles."), () => Chiaki.hideHost(modelData.mac, modelData.name));
            }

            function setConsolePin() {
                root.showConsolePinDialog(index);
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 26
                anchors.rightMargin: 24
                anchors.topMargin: 20
                anchors.bottomMargin: 20
                spacing: 24

                Item {
                    Layout.preferredWidth: 260
                    Layout.fillHeight: true

                    Rectangle {
                        anchors.centerIn: parent
                        width: 230
                        height: 86
                        radius: 44
                        color: "#081222"
                        opacity: 0.55
                    }

                    Image {
                        id: consoleImage
                        anchors.centerIn: parent
                        width: 246
                        height: 116
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                        source: modelData.ps5
                            ? "qrc:/icons/ps5-horizontal.png"
                            : "image://svg/console-ps4" + (modelData.state == "standby" ? "#light_standby" : "#light_on")
                        sourceSize: Qt.size(Math.round(width * 2), Math.round(height * 2))
                        opacity: modelData.state === "standby" ? 0.78 : 1.0
                        transform: Scale {
                            origin.x: consoleImage.width / 2
                            origin.y: consoleImage.height / 2
                            xScale: modelData.ps5 ? -1 : 1
                            yScale: modelData.ps5 ? -1 : 1
                        }
                    }

                    Canvas {
                        id: consoleLed
                        visible: modelData.ps5 && (modelData.state === "ready" || modelData.state === "standby")
                        x: 18
                        y: 51
                        width: 225
                        height: 66
                        property bool standbyLed: modelData.state === "standby"
                        onStandbyLedChanged: requestPaint()

                        function traceLedEdges(ctx) {
                            ctx.beginPath()
                            ctx.moveTo(8, 30)
                            ctx.bezierCurveTo(69, 30, 157, 24, 219, 15)
                            ctx.moveTo(8, 40)
                            ctx.bezierCurveTo(73, 41, 157, 48, 219, 60)
                        }

                        function ledGradient(ctx, leftAlpha, rightAlpha) {
                            var gradient = ctx.createLinearGradient(8, 0, 219, 0)
                            var rgb = standbyLed ? "255,177,59" : "30,105,235"
                            gradient.addColorStop(0.0, "rgba(" + rgb + "," + leftAlpha + ")")
                            gradient.addColorStop(0.35, "rgba(" + rgb + "," + (rightAlpha * 0.42) + ")")
                            gradient.addColorStop(0.72, "rgba(" + rgb + "," + (rightAlpha * 0.72) + ")")
                            gradient.addColorStop(1.0, "rgba(" + rgb + "," + rightAlpha + ")")
                            return gradient
                        }

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            ctx.lineCap = "round"
                            ctx.globalCompositeOperation = "lighter"

                            traceLedEdges(ctx)
                            ctx.strokeStyle = ledGradient(ctx, 0.018, 0.16)
                            ctx.lineWidth = 18
                            ctx.stroke()

                            traceLedEdges(ctx)
                            ctx.strokeStyle = ledGradient(ctx, 0.045, 0.32)
                            ctx.lineWidth = 11
                            ctx.stroke()

                            traceLedEdges(ctx)
                            ctx.strokeStyle = ledGradient(ctx, 0.12, 0.62)
                            ctx.lineWidth = 5.5
                            ctx.stroke()

                            traceLedEdges(ctx)
                            ctx.strokeStyle = ledGradient(ctx, 0.32, 1.0)
                            ctx.lineWidth = 2.0
                            ctx.stroke()

                            ctx.globalCompositeOperation = "source-over"
                        }
                    }
                }

                ColumnLayout {
                    Layout.preferredWidth: 420
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 7

                    Label {
                        text: modelData.name || root.zt("PlayStation Console", "Console PlayStation")
                        color: root.zanitText
                        font.bold: true
                        font.pixelSize: 25
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Label {
                        visible: !!modelData.address
                        text: root.zt("Address: ", "Endereço: ") + (Chiaki.settings.streamerMode ? root.zt("hidden", "oculto") : modelData.address)
                        color: root.zanitMuted
                        font.pixelSize: 17
                    }

                    Label {
                        visible: !!modelData.mac
                        text: "ID: " + (Chiaki.settings.streamerMode ? root.zt("hidden", "oculto") : modelData.mac) + " (" + (modelData.registered ? root.zt("registered", "registrado") : root.zt("unregistered", "não registrado")) + ")"
                        color: root.zanitMuted
                        font.pixelSize: 17
                    }

                    Label {
                        text: {
                            if (modelData.duid)
                                return modelData.discovered ? root.zt("Automatic registration available", "Registro automático disponível") : "Remote Connection via PSN";
                            if (modelData.discovered && modelData.manual)
                                return root.zt("discovered + manual", "detectado + manual");
                            if (modelData.discovered)
                                return root.zt("discovered", "detectado");
                            return root.zt("manual", "manual");
                        }
                        color: "#8FA8CF"
                        font.pixelSize: 15
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 118
                    Layout.alignment: Qt.AlignVCenter
                    color: "#31415D"
                }

                RowLayout {
                    Layout.preferredWidth: 250
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 14

                    Item {
                        width: 30
                        height: 30
                        Rectangle {
                            anchors.centerIn: parent
                            width: 30
                            height: 30
                            radius: 15
                            color: root.zanitGreen
                            opacity: modelData.state === "ready" ? 0.16 : 0.0
                        }
                        Rectangle {
                            anchors.centerIn: parent
                            width: 18
                            height: 18
                            radius: 9
                            color: modelData.state === "ready" ? root.zanitGreen : (modelData.state === "standby" ? "#FFB13B" : "#7F8EA8")
                        }
                    }

                    Label {
                        text: root.language === "pt_BR" ? "Status:" : "State:"
                        color: root.zanitText
                        font.pixelSize: 18
                    }
                    Label {
                        text: root.prettyState(modelData.state)
                        color: modelData.state === "ready" ? root.zanitGreen : root.zanitText
                        font.bold: modelData.state === "ready"
                        font.pixelSize: 19
                    }
                }

                Item { Layout.fillWidth: true }

                ColumnLayout {
                    Layout.preferredWidth: 290
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 9

                    Button {
                        Layout.fillWidth: true
                        visible: modelData.registered
                        text: root.zt("Update Console Pin", "Atualizar PIN do console")
                        icon.source: "qrc:/icons/l1.svg"
                        icon.width: 24
                        icon.height: 24
                        focusPolicy: Qt.NoFocus
                        onClicked: delegate.setConsolePin()
                        Material.background: "#202D43"
                        Material.foreground: root.zanitText
                    }

                    Button {
                        Layout.fillWidth: true
                        visible: modelData.registered && !modelData.duid && !modelData.discovered
                        text: root.zt("Wake Up", "Ligar console")
                        focusPolicy: Qt.NoFocus
                        onClicked: delegate.wakeUpHost()
                        Material.background: "#202D43"
                    }

                    Button {
                        Layout.fillWidth: true
                        visible: modelData.manual || (modelData.discovered && !modelData.registered)
                        text: modelData.manual ? root.zt("Delete", "Excluir") : root.zt("Hide", "Ocultar")
                        focusPolicy: Qt.NoFocus
                        onClicked: delegate.deleteHost()
                        Material.background: "#202D43"
                    }
                }
            }
        }
    }

    Item {
        id: footerStatus
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 98

        RowLayout {
            anchors.left: parent.left
            anchors.leftMargin: 30
            anchors.verticalCenter: parent.verticalCenter
            spacing: 14

            RoundButton {
                id: discoveryButton
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64
                icon.source: "qrc:/icons/discover-" + (checked ? "" : "off-") + "24px.svg"
                icon.width: 35
                icon.height: 35
                focusPolicy: Qt.NoFocus
                checkable: true
                checked: Chiaki.discoveryEnabled
                onToggled: Chiaki.discoveryEnabled = !Chiaki.discoveryEnabled
                Material.background: checked ? "#17243A" : "#202838"
                Material.foreground: root.zanitBlue
                ToolTip.visible: hovered
                ToolTip.text: root.zt("Toggle local console discovery", "Ativar/desativar descoberta de consoles na rede")
            }

            ColumnLayout {
                spacing: 0
                Label {
                    text: root.zt("PS5 on network", "PS5 na rede")
                    color: root.zanitText
                    font.bold: true
                    font.pixelSize: 17
                }
                Label {
                    text: Chiaki.discoveryEnabled ? root.zt("Connected", "Conectado") : root.zt("Discovery off", "Descoberta desativada")
                    color: Chiaki.discoveryEnabled ? "#36A6FF" : root.zanitMuted
                    font.pixelSize: 16
                }
            }
        }

        Column {
            anchors.right: parent.right
            anchors.rightMargin: 34
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Label {
                anchors.right: parent.right
                text: "v" + Qt.application.version
                color: "#9AAAC2"
                font.pixelSize: 16
            }

            Label {
                anchors.right: parent.right
                text: "by Enzo"
                color: "#7F92B2"
                font.pixelSize: 13
            }
        }
    }
}
