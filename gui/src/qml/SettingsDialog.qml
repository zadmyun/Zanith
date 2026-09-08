import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Dialogs

import org.streetpea.chiaking

import "controls" as C

DialogView {
    enum Console {
        PS4,
        PS5
    }
    property int selectedConsole: SettingsDialog.Console.PS5
    property bool quitControllerMapping: true
    id: dialog
    title: root.zt("Settings", "Configurações")
    header: root.zt("Advanced settings", "Configurações avançadas")
    buttonVisible: false
    function flickContainsItem(flick, item) {
        let current = item;
        while (current) {
            if (current === flick || current === flick.contentItem)
                return true;
            current = current.parent;
        }
        return false;
    }
    function flickVisibilityTarget(flick, item) {
        let current = item;
        while (current && current !== flick && current !== flick.contentItem) {
            if (current.parent === flick.contentItem)
                return current;
            if (current.parent && current.parent.parent === flick.contentItem)
                return current;
            current = current.parent;
        }
        return item;
    }
    function ensureItemVisibleInFlick(flick, item) {
        if (!flick || !item || !flickContainsItem(flick, item))
            return;
        const target = flickVisibilityTarget(flick, item);
        const top = target.mapToItem(flick.contentItem, 0, 0).y;
        const bottom = top + target.height;
        if (top < flick.contentY)
            flick.contentY = top;
        else if (bottom > flick.contentY + flick.height)
            flick.contentY = bottom - flick.height;
    }
    function itemIsInsideNestedScrollable(flick, item) {
        let current = item ? item.parent : null;
        while (current && current !== flick && current !== flick.contentItem) {
            if (current.contentY !== undefined && current.contentHeight !== undefined && current !== flick)
                return true;
            current = current.parent;
        }
        return false;
    }
    function nestedScrollableTarget(flick, item) {
        let current = item;
        while (current && current !== flick && current !== flick.contentItem) {
            if (current.contentY !== undefined && current.contentHeight !== undefined && current !== flick)
                return current;
            current = current.parent;
        }
        return item;
    }
    function ensureActiveFocusVisible() {
        const flick = activeSettingsFlick();
        const window = dialog.Window.window;
        if (!flick || !window || !window.activeFocusItem)
            return;
        const target = itemIsInsideNestedScrollable(flick, window.activeFocusItem)
            ? nestedScrollableTarget(flick, window.activeFocusItem)
            : window.activeFocusItem;
        ensureItemVisibleInFlick(flick, target);
    }
    function scrollFlickKeepingItemVisible(flick, item, delta) {
        if (!flick || !item)
            return;
        const maxContentY = Math.max(0, flick.contentHeight - flick.height);
        if (maxContentY <= 0)
            return;
        flick.contentY = Math.max(0, Math.min(maxContentY, flick.contentY + delta));
    }
    function focusCurrentTabFirstItem() {
        let item = null;
        switch (bar.currentIndex) {
        case 0: item = disconnectAction; break;
        case 1: item = hwDecoderCombo; break;
        case 2: item = consoleSelection; break;
        case 3: item = audioOutDevice; break;
        case 4: item = registerNewButton; break;
        case 5: item = resetAllKeys; break;
        case 6: item = controllerMappingChange; break;
        case 7: item = firstRemoteFocusableItem(); break;
        case 8: item = profile; break;
        }
        if (item)
            item.forceActiveFocus(Qt.TabFocusReason);
    }
    function activeSettingsFlick() {
        switch (bar.currentIndex) {
        case 0: return generalFlick;
        case 1: return videoFlick;
        case 2: return streamFlick;
        case 3: return audiowifiFlick;
        case 4: return consolesFlick;
        case 5: return keysFlick;
        case 6: return controllersFlick;
        case 7: return remoteFlick;
        case 8: return configFlick;
        default: return null;
        }
    }

    function translateButtonName(name) {
        if (root.language !== "pt_BR")
            return name;
        const names = {
            "Cross": "X",
            "Moon": "Círculo",
            "Box": "Quadrado",
            "Pyramid": "Triângulo",
            "Dpad Left": "Direcional para a esquerda",
            "D-Pad Left": "Direcional para a esquerda",
            "Dpad Right": "Direcional para a direita",
            "D-Pad Right": "Direcional para a direita",
            "Dpad Up": "Direcional para cima",
            "D-Pad Up": "Direcional para cima",
            "Dpad Down": "Direcional para baixo",
            "D-Pad Down": "Direcional para baixo",
            "Options": "Options",
            "Share": "Share",
            "Touchpad": "Touchpad",
            "Left Stick Up": "Analógico esquerdo para cima",
            "Left Stick Down": "Analógico esquerdo para baixo",
            "Left Stick Left": "Analógico esquerdo para a esquerda",
            "Left Stick Right": "Analógico esquerdo para a direita",
            "Right Stick Up": "Analógico direito para cima",
            "Right Stick Down": "Analógico direito para baixo",
            "Right Stick Left": "Analógico direito para a esquerda",
            "Right Stick Right": "Analógico direito para a direita",
            "Left Stick X": "Eixo X do analógico esquerdo",
            "Left Stick Y": "Eixo Y do analógico esquerdo",
            "Right Stick X": "Eixo X do analógico direito",
            "Right Stick Y": "Eixo Y do analógico direito",
            "MIC": "Microfone",
            "Unknown": "Desconhecido",
            "L2": "L2",
            "R2": "R2",
            "L3": "L3",
            "R3": "R3",
            "L1": "L1",
            "R1": "R1",
            "PS": "PS"
        };
        return names[name] || name;
    }

    function translateShortcutString(value) {
        if (root.language !== "pt_BR" || !value)
            return value;
        let out = value;
        const replacements = [
            ["D-Pad Left", "Direcional para a esquerda"],
            ["D-Pad Right", "Direcional para a direita"],
            ["D-Pad Up", "Direcional para cima"],
            ["D-Pad Down", "Direcional para baixo"],
            ["Dpad Left", "Direcional para a esquerda"],
            ["Dpad Right", "Direcional para a direita"],
            ["Dpad Up", "Direcional para cima"],
            ["Dpad Down", "Direcional para baixo"],
            ["Cross", "X"],
            ["Moon", "Círculo"],
            ["Box", "Quadrado"],
            ["Pyramid", "Triângulo"]
        ];
        for (let i = 0; i < replacements.length; ++i)
            out = out.split(replacements[i][0]).join(replacements[i][1]);
        return out;
    }

    function translateKeyName(name) {
        if (root.language !== "pt_BR")
            return name;
        const names = {
            "Return": "Enter",
            "Backspace": "Backspace",
            "Left": "Seta esquerda",
            "Right": "Seta direita",
            "Up": "Seta para cima",
            "Down": "Seta para baixo",
            "PgUp": "Page Up",
            "PgDown": "Page Down",
            "Del": "Delete",
            "Ins": "Insert",
            "Space": "Espaço"
        };
        return names[name] || name;
    }

    function firstRemoteFocusableItem() {
        if (openPsnLogin.visible)
            return openPsnLogin;
        if (resetPsnTokens.visible)
            return resetPsnTokens;
        if (holePunchGuessingCheckbox.visible)
            return holePunchGuessingCheckbox;
        if (portGuessCountSlider.visible)
            return portGuessCountSlider;
        if (portGuessSocketSlider.visible)
            return portGuessSocketSlider;
        return remoteFlick;
    }
    Keys.onPressed: (event) => {
        if (event.modifiers)
            return;
        switch (event.key) {
        case Qt.Key_PageUp:
            bar.decrementCurrentIndex();
            event.accepted = true;
            break;
        case Qt.Key_PageDown:
            bar.incrementCurrentIndex();
            event.accepted = true;
            break;
        case Qt.Key_Up:
        {
            const flick = activeSettingsFlick();
            if (!flick || flick.contentHeight <= flick.height || flick.contentY <= 0.001)
                return;
            flick.flick(0, 500);
            event.accepted = true;
            break;
        }
        case Qt.Key_Down:
        {
            const flick = activeSettingsFlick();
            if (!flick || flick.contentHeight <= flick.height || flick.contentY >= flick.contentHeight - flick.height - 0.001)
                return;
            flick.flick(0, -500);
            event.accepted = true;
            break;
        }
        }
    }

    Item {
        TabBar {
            id: bar
            visible: false
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 5
            }
            TabButton {
                id: general
                text: root.zt("General", "Geral")
                focusPolicy: Qt.NoFocus
                Image {
                    anchors {
                        left: general.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: -15
                    }
                    width: 28
                    height: 28
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/icons/l1.svg"
                    visible: bar.currentIndex == 1
                }
            }

            TabButton {
                id: video
                text: root.zt("Video", "Vídeo")
                focusPolicy: Qt.NoFocus
                Image {
                    anchors {
                        right: video.left
                        verticalCenter: parent.verticalCenter
                        rightMargin: -15
                    }
                    width: 28
                    height: 28
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/icons/r1.svg"
                    visible: bar.currentIndex == 0
                }
                Image {
                    anchors {
                        left: video.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: -15
                    }
                    width: 28
                    height: 28
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/icons/l1.svg"
                    visible: bar.currentIndex == 2
                }
            }

            TabButton {
                id: stream
                text: root.zt("Stream", "Stream")
                focusPolicy: Qt.NoFocus
                Image {
                    anchors {
                        right: stream.left
                        verticalCenter: parent.verticalCenter
                        rightMargin: -15
                    }
                    width: 28
                    height: 28
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/icons/r1.svg"
                    visible: bar.currentIndex == 1
                }
                Image {
                    anchors {
                        left: stream.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: -15
                    }
                    width: 28
                    height: 28
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/icons/l1.svg"
                    visible: bar.currentIndex == 3
                }
            }

            TabButton {
                text: root.zt("Audio & Network", "Áudio & Rede")
                id: audio
                focusPolicy: Qt.NoFocus
                Image {
                    anchors {
                        right: audio.left
                        verticalCenter: parent.verticalCenter
                        rightMargin: -15
                    }
                    width: 28
                    height: 28
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/icons/r1.svg"
                    visible: bar.currentIndex == 2
                }
                Image {
                    anchors {
                        left: audio.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: -15
                    }
                    width: 28
                    height: 28
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/icons/l1.svg"
                    visible: bar.currentIndex == 4
                }
            }

            TabButton {
                text: root.zt("Consoles", "Consoles")
                id: consoles
                focusPolicy: Qt.NoFocus
                Image {
                    anchors {
                        right: consoles.left
                        verticalCenter: parent.verticalCenter
                        rightMargin: -15
                    }
                    width: 28
                    height: 28
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/icons/r1.svg"
                    visible: bar.currentIndex == 3
                }
                Image {
                    anchors {
                        left: consoles.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: -15
                    }
                    width: 28
                    height: 28
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/icons/l1.svg"
                    visible: bar.currentIndex == 5
                }
            }

            TabButton {
                text: root.zt("Keys", "Teclas")
                id: keys
                focusPolicy: Qt.NoFocus
                Image {
                    anchors {
                        right: keys.left
                        verticalCenter: parent.verticalCenter
                        rightMargin: -15
                    }
                    width: 28
                    height: 28
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/icons/r1.svg"
                    visible: bar.currentIndex == 4
                }
                Image {
                    anchors {
                        left: keys.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: -15
                    }
                    width: 28
                    height: 28
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/icons/l1.svg"
                    visible: bar.currentIndex == 6
                }
            }

            TabButton {
                text: root.zt("Controllers", "Controles")
                id: controllers
                focusPolicy: Qt.NoFocus
                Image {
                    anchors {
                        right: controllers.left
                        verticalCenter: parent.verticalCenter
                        rightMargin: -15
                    }
                    width: 28
                    height: 28
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/icons/r1.svg"
                    visible: bar.currentIndex == 5
                }
                Image {
                    anchors {
                        left: controllers.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: -15
                    }
                    width: 28
                    height: 28
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/icons/l1.svg"
                    visible: bar.currentIndex == 7
                }
            }

            TabButton {
                text: root.zt("Remote", "Remoto")
                id: remote
                focusPolicy: Qt.NoFocus
                Image {
                    anchors {
                        right: remote.left
                        verticalCenter: parent.verticalCenter
                        rightMargin: -15
                    }
                    width: 28
                    height: 28
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/icons/r1.svg"
                    visible: bar.currentIndex == 6
                }
                Image {
                    anchors {
                        left: remote.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: -15
                    }
                    width: 28
                    height: 28
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/icons/l1.svg"
                    visible: bar.currentIndex == 8
                }
            }

            TabButton {
                text: root.zt("Profiles", "Perfis")
                id: config
                focusPolicy: Qt.NoFocus
                Image {
                    anchors {
                        left: config.left
                        verticalCenter: parent.verticalCenter
                        leftMargin: -15
                    }
                    width: 28
                    height: 28
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/icons/r1.svg"
                    visible: bar.currentIndex == 7
                }
            }
        }

        Rectangle {
            id: settingsSidebar
            anchors {
                top: parent.top
                left: parent.left
                bottom: parent.bottom
            }
            width: Math.min(270, parent.width * 0.23)
            radius: 18
            color: "#0F192A"
            border.width: 1
            border.color: root.zanithBorder

            ColumnLayout {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    bottom: languageBox.top
                    margins: 12
                    bottomMargin: 8
                }
                spacing: 5

                Repeater {
                    model: [
                        { label: root.zt("General", "Geral"), icon: "qrc:/icons/settings-20px.svg", page: 0 },
                        { label: root.zt("Video", "Vídeo"), icon: "qrc:/icons/tab-video.svg", page: 1 },
                        { label: "Stream", icon: "qrc:/icons/tab-stream.svg", page: 2 },
                        { label: root.zt("Audio & Network", "Áudio e Rede"), icon: "qrc:/icons/tab-network.svg", page: 3 },
                        { label: root.zt("Consoles", "Consoles"), icon: "qrc:/icons/tab-console.svg", page: 4 },
                        { label: root.zt("Keys", "Teclas"), icon: "qrc:/icons/tab-keys.svg", page: 5 },
                        { label: root.zt("Controllers", "Controles"), icon: "qrc:/icons/tab-controller.svg", page: 6 },
                        { label: root.zt("Remote", "Remoto"), icon: "qrc:/icons/tab-remote.svg", page: 7 },
                        { label: root.zt("Profiles", "Perfis"), icon: "qrc:/icons/tab-profile.svg", page: 8 }
                    ]
                    delegate: Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 52
                        focusPolicy: Qt.NoFocus
                        onClicked: bar.currentIndex = modelData.page
                        leftPadding: 14
                        rightPadding: 14
                        Material.background: bar.currentIndex === modelData.page ? "#173F9C" : "transparent"
                        Material.foreground: bar.currentIndex === modelData.page ? "#FFFFFF" : root.zanithMuted

                        contentItem: RowLayout {
                            spacing: 11
                            Image {
                                Layout.preferredWidth: 22
                                Layout.preferredHeight: 22
                                Layout.alignment: Qt.AlignVCenter
                                source: modelData.icon
                                sourceSize: Qt.size(22, 22)
                                fillMode: Image.PreserveAspectFit
                                opacity: bar.currentIndex === modelData.page ? 1.0 : 0.72
                            }
                            Label {
                                text: modelData.label
                                font.pixelSize: 16
                                font.bold: bar.currentIndex === modelData.page
                                color: bar.currentIndex === modelData.page ? "#FFFFFF" : root.zanithMuted
                                Layout.alignment: Qt.AlignVCenter
                            }
                            Item { Layout.fillWidth: true }
                        }
                    }
                }
                Item { Layout.fillHeight: true }
            }

            ColumnLayout {
                id: languageBox
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    margins: 14
                }
                spacing: 5
                Label {
                    text: root.zt("Language", "Idioma")
                    color: root.zanithMuted
                    font.pixelSize: 13
                }
                ComboBox {
                    Layout.fillWidth: true
                    model: ["English", "Português (Brasil)"]
                    currentIndex: root.language === "pt_BR" ? 1 : 0
                    onActivated: (index) => root.language = index === 1 ? "pt_BR" : "en_US"
                    Material.background: root.zanithSurfaceAlt
                }
            }
        }

        Rectangle {
            id: settingsContentCard
            anchors {
                top: parent.top
                left: settingsSidebar.right
                right: parent.right
                bottom: parent.bottom
                leftMargin: 16
            }
            radius: 18
            color: "#0F192A"
            border.width: 1
            border.color: root.zanithBorder
        }

        StackLayout {
            anchors {
                top: parent.top
                left: settingsSidebar.right
                right: parent.right
                bottom: parent.bottom
                leftMargin: 24
                rightMargin: 8
                topMargin: 8
                bottomMargin: 8
            }
            currentIndex: bar.currentIndex
            onCurrentIndexChanged: {
                dialog.focusCurrentTabFirstItem()
                Qt.callLater(dialog.ensureActiveFocusVisible)
            }

            Item {
                // General
                Flickable {
                    id: generalFlick
                    anchors {
                        fill: parent
                        topMargin: 20
                        bottomMargin: 20
                    }
                    clip: true
                    contentWidth: width
                    contentHeight: generalLayout.implicitHeight
                    flickableDirection: Flickable.VerticalFlick
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    ColumnLayout {
                        id: generalLayout
                        x: 20
                        width: Math.max(0, generalFlick.width - 40)
                        spacing: 8

                        property real labelColumnWidth: Math.max(210, Math.min(300, width * 0.24))
                        property real stateColumnWidth: Math.max(150, Math.min(220, width * 0.18))
                        property var streamShortcutOptions: [root.zt("Not Used", "Não usado"), root.zt("Cross", "X"), root.zt("Moon", "Círculo"), root.zt("Box", "Quadrado"), root.zt("Pyramid", "Triângulo"), root.zt("Dpad Left", "Direcional para a esquerda"), root.zt("Dpad Right", "Direcional para a direita"), root.zt("Dpad Up", "Direcional para cima"), root.zt("Dpad Down", "Direcional para baixo"), "L1", "R1", "L3", "R3", "Options", "Share", "Touchpad", "PS"]

                        GridLayout {
                            id: generalGrid
                            Layout.fillWidth: true
                            columns: 3
                            rowSpacing: 8
                            columnSpacing: 16

                            Label {
                                Layout.preferredWidth: generalLayout.labelColumnWidth
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                                text: root.zt("Action On Disconnect:", "Ação ao desconectar:")
                            }

                            C.ComboBox {
                                id: disconnectAction
                                Layout.fillWidth: true
                                Layout.minimumWidth: 260
                                firstInFocusChain: true
                                model: [root.zt("Do Nothing", "Não fazer nada"), root.zt("Enter Sleep Mode", "Colocar em repouso"), root.zt("Ask", "Perguntar")]
                                currentIndex: Chiaki.settings.disconnectAction
                                onActivated: index => Chiaki.settings.disconnectAction = index
                            }

                            Label {
                                Layout.preferredWidth: generalLayout.stateColumnWidth
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                color: root.zanithMuted
                                text: "(" + disconnectAction.currentText + ")"
                            }

                            Label {
                                Layout.preferredWidth: generalLayout.labelColumnWidth
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                                text: root.zt("Action On Suspend:", "Ação ao suspender:")
                            }

                            C.ComboBox {
                                id: suspendActionCombo
                                Layout.fillWidth: true
                                Layout.minimumWidth: 260
                                model: [root.zt("Do Nothing", "Não fazer nada"), root.zt("Enter Sleep Mode", "Colocar em repouso")]
                                currentIndex: Chiaki.settings.suspendAction
                                onActivated: index => Chiaki.settings.suspendAction = index
                            }

                            Label {
                                Layout.preferredWidth: generalLayout.stateColumnWidth
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                color: root.zanithMuted
                                text: "(" + suspendActionCombo.currentText + ")"
                            }

                            Label {
                                Layout.preferredWidth: generalLayout.labelColumnWidth
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                                text: root.zt("Steam Deck Haptics:", "Haptics do Steam Deck:")
                                visible: typeof Chiaki.settings.steamDeckHaptics !== "undefined"
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                visible: typeof Chiaki.settings.steamDeckHaptics !== "undefined"
                                spacing: 8
                                C.CheckBox {
                                    checked: typeof Chiaki.settings.steamDeckHaptics !== "undefined" ? Chiaki.settings.steamDeckHaptics : false
                                    onToggled: Chiaki.settings.steamDeckHaptics = checked
                                }
                                Label {
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    wrapMode: Text.WordWrap
                                    text: root.zt("True haptics for SteamDeck, better quality but noisier", "Haptics reais no Steam Deck, melhor qualidade, mas com mais ruído")
                                }
                            }

                            Label {
                                Layout.preferredWidth: generalLayout.stateColumnWidth
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                color: root.zanithMuted
                                text: Chiaki.settings.steamDeckHaptics ? root.zt("(Checked)", "(Marcado)") : root.zt("(Unchecked)", "(Desmarcado)")
                                visible: typeof Chiaki.settings.steamDeckHaptics !== "undefined"
                            }

                            Label {
                                Layout.preferredWidth: generalLayout.labelColumnWidth
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                                text: root.zt("Steam Deck Vertical:", "Steam Deck na vertical:")
                                visible: typeof Chiaki.settings.verticalDeck !== "undefined"
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                visible: typeof Chiaki.settings.verticalDeck !== "undefined"
                                spacing: 8
                                C.CheckBox {
                                    checked: typeof Chiaki.settings.verticalDeck !== "undefined" ? Chiaki.settings.verticalDeck : false
                                    onToggled: Chiaki.settings.verticalDeck = checked
                                }
                                Label {
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    wrapMode: Text.WordWrap
                                    text: root.zt("Use Steam Deck in vertical orientation (motion controls)", "Usar o Steam Deck na vertical (controles por movimento)")
                                }
                            }

                            Label {
                                Layout.preferredWidth: generalLayout.stateColumnWidth
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                color: root.zanithMuted
                                text: Chiaki.settings.verticalDeck ? root.zt("(Checked)", "(Marcado)") : root.zt("(Unchecked)", "(Desmarcado)")
                                visible: typeof Chiaki.settings.verticalDeck !== "undefined"
                            }

                            Label {
                                Layout.preferredWidth: generalLayout.labelColumnWidth
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                                text: root.zt("Audio/Video:", "Áudio/Vídeo:")
                            }

                            C.ComboBox {
                                id: audioVideoModeCombo
                                Layout.fillWidth: true
                                Layout.minimumWidth: 260
                                model: [root.zt("Audio and Video Enabled", "Áudio e vídeo ativados"), root.zt("Audio Disabled", "Áudio desativado"), root.zt("Video Disabled", "Vídeo desativado"), root.zt("Audio and Video Disabled", "Áudio e vídeo desativados")]
                                currentIndex: Chiaki.settings.audioVideoDisabled
                                onActivated: index => Chiaki.settings.audioVideoDisabled = index
                            }

                            Label {
                                Layout.preferredWidth: generalLayout.stateColumnWidth
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                color: root.zanithMuted
                                text: "(" + audioVideoModeCombo.currentText + ")"
                                wrapMode: Text.WordWrap
                            }

                            Label {
                                Layout.preferredWidth: generalLayout.labelColumnWidth
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                                text: root.zt("Log Directory:", "Pasta de logs:")
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Label {
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    text: Chiaki.settings.logDirectory
                                    elide: Text.ElideMiddle
                                    verticalAlignment: Text.AlignVCenter
                                    ToolTip.visible: ma.containsMouse
                                    ToolTip.text: text
                                    MouseArea {
                                        id: ma
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        acceptedButtons: Qt.NoButton
                                    }
                                }

                                C.Button {
                                    id: openButton
                                    text: root.zt("Open Folder", "Abrir pasta")
                                    onClicked: Chiaki.settings.openLogDirectory()
                                    Material.roundedScale: Material.SmallScale
                                }
                            }

                            Item { Layout.preferredWidth: generalLayout.stateColumnWidth }

                            Label {
                                Layout.preferredWidth: generalLayout.labelColumnWidth
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                                text: root.zt("Streamer Mode (Hides Info)", "Modo Streamer (oculta informações)")
                            }

                            C.CheckBox {
                                id: streamerMode
                                checked: Chiaki.settings.streamerMode
                                onToggled: Chiaki.settings.streamerMode = !Chiaki.settings.streamerMode
                            }

                            Label {
                                Layout.preferredWidth: generalLayout.stateColumnWidth
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                color: root.zanithMuted
                                text: streamerMode.checked ? root.zt("(Checked)", "(Marcado)") : root.zt("(Unchecked)", "(Desmarcado)")
                            }

                            Label {
                                Layout.preferredWidth: generalLayout.labelColumnWidth
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                                text: root.zt("Stream Menu Shortcut Enabled", "Atalho do menu de stream ativado")
                            }

                            C.CheckBox {
                                id: streamMenu
                                checked: Chiaki.settings.streamMenuEnabled
                                onToggled: Chiaki.settings.streamMenuEnabled = !Chiaki.settings.streamMenuEnabled
                                KeyNavigation.priority: KeyNavigation.BeforeItem
                                KeyNavigation.up: streamerMode
                                KeyNavigation.left: streamMenu
                                KeyNavigation.right: streamMenu
                                KeyNavigation.down: Chiaki.settings.streamMenuEnabled ? streamMenuShortcut1 : streamMenu
                            }

                            Label {
                                Layout.preferredWidth: generalLayout.stateColumnWidth
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                color: root.zanithMuted
                                text: streamMenu.checked ? root.zt("(Checked)", "(Marcado)") : root.zt("(Unchecked)", "(Desmarcado)")
                            }

                            Label {
                                Layout.preferredWidth: generalLayout.labelColumnWidth
                                Layout.alignment: Qt.AlignRight | Qt.AlignTop
                                horizontalAlignment: Text.AlignRight
                                text: root.zt("Stream Menu Combo:", "Combinação do menu de stream:")
                                visible: Chiaki.settings.streamMenuEnabled
                            }

                            GridLayout {
                                id: streamMenuShortcutGrid
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                columns: width >= 620 ? 4 : 2
                                columnSpacing: 8
                                rowSpacing: 8
                                visible: Chiaki.settings.streamMenuEnabled

                                C.ComboBox {
                                    id: streamMenuShortcut1
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 110
                                    implicitContentWidthPolicy: ComboBox.ContentItemImplicitWidth
                                    model: generalLayout.streamShortcutOptions
                                    currentIndex: Chiaki.settings.streamMenuShortcut1
                                    onActivated: index => Chiaki.settings.streamMenuShortcut1 = index
                                    KeyNavigation.up: streamMenu
                                    KeyNavigation.right: streamMenuShortcut2
                                }

                                C.ComboBox {
                                    id: streamMenuShortcut2
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 110
                                    implicitContentWidthPolicy: ComboBox.ContentItemImplicitWidth
                                    model: generalLayout.streamShortcutOptions
                                    currentIndex: Chiaki.settings.streamMenuShortcut2
                                    onActivated: index => Chiaki.settings.streamMenuShortcut2 = index
                                    KeyNavigation.up: streamMenu
                                    KeyNavigation.left: streamMenuShortcut1
                                    KeyNavigation.right: streamMenuShortcut3
                                }

                                C.ComboBox {
                                    id: streamMenuShortcut3
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 110
                                    implicitContentWidthPolicy: ComboBox.ContentItemImplicitWidth
                                    model: generalLayout.streamShortcutOptions
                                    currentIndex: Chiaki.settings.streamMenuShortcut3
                                    onActivated: index => Chiaki.settings.streamMenuShortcut3 = index
                                    KeyNavigation.up: streamMenu
                                    KeyNavigation.left: streamMenuShortcut2
                                    KeyNavigation.right: streamMenuShortcut4
                                }

                                C.ComboBox {
                                    id: streamMenuShortcut4
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 110
                                    implicitContentWidthPolicy: ComboBox.ContentItemImplicitWidth
                                    model: generalLayout.streamShortcutOptions
                                    currentIndex: Chiaki.settings.streamMenuShortcut4
                                    onActivated: index => Chiaki.settings.streamMenuShortcut4 = index
                                    KeyNavigation.up: streamMenu
                                    KeyNavigation.left: streamMenuShortcut3
                                }
                            }

                            Label {
                                Layout.preferredWidth: generalLayout.stateColumnWidth
                                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                                color: root.zanithMuted
                                wrapMode: Text.WordWrap
                                text: {
                                    const a = Chiaki.settings.streamMenuShortcut1;
                                    const b = Chiaki.settings.streamMenuShortcut2;
                                    const c = Chiaki.settings.streamMenuShortcut3;
                                    const d = Chiaki.settings.streamMenuShortcut4;
                                    return "(" + translateShortcutString(Chiaki.settings.stringForStreamMenuShortcut()) + ")";
                                }
                                visible: Chiaki.settings.streamMenuEnabled
                            }
                        }
                    }
                }
            }

            Item {
                // Video
                Flickable {
                    id: videoFlick
                    anchors {
                        fill: parent
                        topMargin: 20
                        bottomMargin: 20
                    }
                    clip: true
                    contentWidth: Math.max(width, videoGrid.width)
                    contentHeight: videoGrid.height
                    flickableDirection: Flickable.AutoFlickIfNeeded
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AlwaysOn
                        visible: videoFlick.contentHeight > videoFlick.height
                    }
                    GridLayout {
                        id: videoGrid
                        anchors {
                            top: parent.top
                            horizontalCenter: parent.horizontalCenter
                        }
                        columns: 3
                        rowSpacing: 10
                        columnSpacing: 20

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("Hardware Decoder:", "Decodificador por hardware:")
                        }

                    RowLayout {
                        Layout.preferredWidth: 400
                        spacing: 12

                        C.ComboBox {
                            id: hwDecoderCombo
                            Layout.preferredWidth: 220
                            model: Chiaki.settings.availableDecoders
                            currentIndex: Math.max(0, model.indexOf(Chiaki.settings.decoder))
                            KeyNavigation.priority: KeyNavigation.BeforeItem
                            KeyNavigation.up: hwDecoderCombo
                            KeyNavigation.right: zeroCopyCheck
                            KeyNavigation.down: windowTypeCombo
                            onActivated: (index) => Chiaki.settings.decoder = index ? model[index] : ""
                        }

                        Label {
                            text: root.zt("Zero-Copy", "Zero-Copy")
                        }

                        C.CheckBox {
                            id: zeroCopyCheck
                            KeyNavigation.priority: KeyNavigation.BeforeItem
                            KeyNavigation.up: zeroCopyCheck
                            KeyNavigation.left: hwDecoderCombo
                            KeyNavigation.down: windowTypeCombo
                            checked: Chiaki.settings.useZeroCopy
                            onToggled: Chiaki.settings.useZeroCopy = checked
                        }
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("(Auto)", "(Automático)")
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("Window Type:", "Modo da janela:")
                    }

                    C.ComboBox {
                        id: windowTypeCombo
                        Layout.preferredWidth: 400
                        popup.width: 500
                        model: [root.zt("Stream Resolution", "Resolução da stream"), root.zt("Custom Resolution", "Resolução customizada"), root.zt("Adjust Resolution Manually", "Ajustar resolução manualmente"), root.zt("Fullscreen", "Tela cheia"), root.zt("Zoom [adjust zoom using slider in stream menu]", "Zoom [ajuste pelo controle deslizante no menu de stream]"), root.zt("Stretch", "Esticar")]
                        currentIndex: Chiaki.settings.windowType
                        onActivated: (index) => Chiaki.settings.windowType = index;
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("(Fullscreen)", "(Tela cheia)")
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("Custom Resolution Width", "Largura customizada")
                        visible: Chiaki.settings.windowType == 1
                    }

                    C.TextField {
                        id: customResolutionWidth
                        Layout.preferredWidth: 400
                        visible: Chiaki.settings.windowType == 1
                        text: Chiaki.settings.customResolutionWidth
                        Material.accent: text && !validate() ? Material.Red : undefined
                        onEditingFinished: {
                            if (validate()) {
                                Chiaki.settings.customResolutionWidth = parseInt(text);
                            } else {
                                Chiaki.settings.customResolutionWidth = 0;
                                text = "";
                            }
                        }
                        function validate() {
                            var num = parseInt(text);
                            return num >= 0 && num <= 9999;
                        }
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("(1920)", "(1920)")
                        visible: Chiaki.settings.windowType == 1
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("Custom Resolution Height", "Altura customizada")
                        visible: Chiaki.settings.windowType == 1
                    }

                    C.TextField {
                        id: customResolutionHeight
                        Layout.preferredWidth: 400
                        visible: Chiaki.settings.windowType == 1
                        text: Chiaki.settings.customResolutionHeight
                        Material.accent: text && !validate() ? Material.Red : undefined
                        onEditingFinished: {
                            if (validate()) {
                                Chiaki.settings.customResolutionHeight = parseInt(text);
                            } else {
                                Chiaki.settings.customResolutionHeight = 0;
                                text = "";
                            }
                        }
                        function validate() {
                            var num = parseInt(text);
                            return num >= 0 && num <= 9999;
                        }
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("(1080)", "(1080)")
                        visible: Chiaki.settings.windowType == 1
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("Toggle Fullscreen on Double-click:", "Tela cheia com duplo clique:")
                    }

                    C.CheckBox {
                        checked: Chiaki.settings.fullscreenDoubleClick
                        onToggled: Chiaki.settings.fullscreenDoubleClick = checked
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("(Unchecked)", "(Desmarcado)")
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("Hide Cursor during Stream", "Ocultar cursor durante Stream")
                    }
                    C.CheckBox {
                        checked: Chiaki.settings.hideCursor
                        onToggled: Chiaki.settings.hideCursor = !Chiaki.settings.hideCursor
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("(Checked)", "(Marcado)")
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("Vertical Sync:", "Sincronização vertical:")
                    }

                    C.CheckBox {
                        checked: Chiaki.settings.vSyncEnabled
                        onClicked: {
                            Chiaki.settings.vSyncEnabled = checked
                            if (Chiaki.window.runtimeRendererBackend === 1 && Chiaki.settings.restartApplication())
                                Qt.quit()
                        }
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("(Unchecked)", "(Desmarcado)")
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("Render Preset:", "Preset de renderização:")
                    }

                    C.ComboBox {
                        Layout.preferredWidth: 520
                        model: [root.zt("Fast", "Rápido"), root.zt("Default", "Padrão"), root.zt("High Quality", "Alta qualidade"), root.zt("High Quality + Spatial Upscaling", "Alta qualidade + upscale espacial"), root.zt("High Quality + Advanced Spatial Upscaling", "Alta qualidade + upscale espacial avançado"), root.zt("Custom", "Personalizado")]
                        currentIndex: Chiaki.settings.videoPreset
                        onActivated: (index) => {
                            Chiaki.settings.videoPreset = index;
                            switch (index) {
                            case 0: Chiaki.window.videoPreset = ChiakiWindow.VideoPreset.Fast; break;
                            case 1: Chiaki.window.videoPreset = ChiakiWindow.VideoPreset.Default; break;
                            case 2: Chiaki.window.videoPreset = ChiakiWindow.VideoPreset.HighQuality; break;
                            case 3: Chiaki.window.videoPreset = ChiakiWindow.VideoPreset.HighQualitySpatial; break;
                            case 4: Chiaki.window.videoPreset = ChiakiWindow.VideoPreset.HighQualityAdvancedSpatial; break;
                            case 5: Chiaki.window.videoPreset = ChiakiWindow.VideoPreset.Custom; break;
                            }
                        }
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("(High Quality)", "(Alta qualidade)")
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("Frame Mixer:", "Misturador de quadros:")
                    }

                    C.ComboBox {
                        Layout.preferredWidth: 400
                        model: [root.zt("None", "Nenhum"), root.zt("Oversample", "Oversample"), root.zt("Hermite", "Hermite"), root.zt("Linear", "Linear"), root.zt("Cubic", "Cúbico")]
                        currentIndex: Chiaki.settings.placeboFrameMixer
                        onActivated: index => Chiaki.settings.placeboFrameMixer = index
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("(None)", "(Nenhum)")
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("Renderer Backend:", "Backend do renderizador:")
                    }

                    C.ComboBox {
                        Layout.preferredWidth: 400
                        model: [root.zt("Vulkan", "Vulkan"), root.zt("OpenGL", "OpenGL")]
                        currentIndex: Chiaki.settings.rendererBackend
                        onActivated: (index) => {
                            if (index === Chiaki.settings.rendererBackend)
                                return;
                            Chiaki.settings.rendererBackend = index;
                            if (Chiaki.settings.restartApplication())
                                Qt.quit();
                        }
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("(Vulkan)", "(Vulkan)")
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("Vulkan Deferred Swap:", "Troca adiada do Vulkan:")
                        visible: Chiaki.settings.rendererBackend == 0
                    }

                    C.CheckBox {
                        checked: Chiaki.settings.vulkanDeferredSwap
                        onToggled: Chiaki.settings.vulkanDeferredSwap = checked
                        visible: Chiaki.settings.rendererBackend == 0
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("(Unchecked)", "(Desmarcado)")
                        visible: Chiaki.settings.rendererBackend == 0
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("Custom Renderer Settings", "Configurações personalizadas do renderizador")
                        visible: Chiaki.window.videoPreset == ChiakiWindow.VideoPreset.Custom
                    }

                    C.Button {
                        id: customRendererSettings
                        text: root.zt("Open", "Abrir")
                        onClicked: root.showPlaceboSettingsDialog()
                        Material.roundedScale: Material.SmallScale
                        visible: Chiaki.window.videoPreset == ChiakiWindow.VideoPreset.Custom
                    }

                    Label { visible: Chiaki.window.videoPreset == ChiakiWindow.VideoPreset.Custom }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("Display Settings", "Configurações de imagem")
                    }

                    C.Button {
                        id: displaySettings
                        text: root.zt("Open", "Abrir")
                        onClicked: root.showDisplaySettingsDialog()
                        Material.roundedScale: Material.SmallScale
                        lastInFocusChain: true
                    }

                    Label {}
                    }
                }
            }

            Item {
                // Stream
                Flickable {
                    id: streamFlick
                    anchors {
                        fill: parent
                        topMargin: 20
                        bottomMargin: 20
                    }
                    clip: true
                    contentWidth: Math.max(width, streamGrid.width)
                    contentHeight: streamGrid.height
                    flickableDirection: Flickable.AutoFlickIfNeeded
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AlwaysOn
                        visible: streamFlick.contentHeight > streamFlick.height
                    }
                    GridLayout {
                        id: streamGrid
                        anchors {
                            top: parent.top
                            horizontalCenter: parent.horizontalCenter
                        }
                        columns: 3
                        rowSpacing: 10
                        columnSpacing: 20

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("Settings for:", "Configurações para:")
                        }


                    C.ComboBox {
                        id: consoleSelection
                        Layout.preferredWidth: 400
                        Layout.alignment: Qt.AlignLeft
                        model: [root.zt("PS4", "PS4"), root.zt("PS5", "PS5")]
                        currentIndex: selectedConsole
                        onActivated: (index) => selectedConsole = index
                        firstInFocusChain: true
                        KeyNavigation.priority: {
                            if(!popup.visible)
                                KeyNavigation.BeforeItem
                            else
                                KeyNavigation.AfterItem
                        }
                        KeyNavigation.down: {
                            if(selectedConsole == SettingsDialog.Console.PS4)
                                resolutionLocalPS4
                            else
                                resolutionLocalPS5

                        }

                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: qsTr("")
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: qsTr("")
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: qsTr("")
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: qsTr("")
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: qsTr("")
                    }

                    Label {
                        Layout.alignment: Qt.AlignCenter
                        text: root.zt("Local", "Local")
                    }

                    Label {
                        Layout.alignment: Qt.AlignCenter
                        text: root.zt("Remote", "Remoto")
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("Resolution:", "Resolução:")
                    }

                    C.ComboBox {
                        id: resolutionLocalPS4
                        Layout.preferredWidth: 400
                        model: [root.zt("360p", "360p"), root.zt("540p", "540p"), root.zt("720p (Default)", "720p (Padrão)"), root.zt("1080p (PS5 and PS4 Pro)", "1080p (PS5 e PS4 Pro)")]
                        currentIndex: Chiaki.settings.resolutionLocalPS4 - 1
                        onActivated: (index) => {
                            Chiaki.settings.resolutionLocalPS4 = index + 1
                            Chiaki.settings.bitrateLocalPS4 = 0
                        }
                        visible: selectedConsole == SettingsDialog.Console.PS4
                        KeyNavigation.right: resolutionRemotePS4
                        KeyNavigation.down: fpsLocalPS4
                        KeyNavigation.up: consoleSelection
                        KeyNavigation.priority: {
                            if(!popup.visible)
                                KeyNavigation.BeforeItem
                            else
                                KeyNavigation.AfterItem
                        }
                    }

                    C.ComboBox {
                        id: resolutionRemotePS4
                        Layout.preferredWidth: 400
                        model: [root.zt("360p", "360p"), root.zt("540p", "540p"), root.zt("720p (Default)", "720p (Padrão)"), root.zt("1080p (PS5 and PS4 Pro)", "1080p (PS5 e PS4 Pro)")]
                        currentIndex: Chiaki.settings.resolutionRemotePS4 - 1
                        onActivated: (index) => {
                            Chiaki.settings.resolutionRemotePS4 = index + 1
                            Chiaki.settings.bitrateRemotePS4 = 0
                        }
                        visible: selectedConsole == SettingsDialog.Console.PS4
                        KeyNavigation.left: resolutionLocalPS4
                        KeyNavigation.down: fpsRemotePS4
                        KeyNavigation.up: consoleSelection
                        KeyNavigation.priority: {
                            if(!popup.visible)
                                KeyNavigation.BeforeItem
                            else
                                KeyNavigation.AfterItem
                        }
                    }

                    C.ComboBox {
                        id: resolutionLocalPS5
                        Layout.preferredWidth: 400
                        model: [root.zt("360p", "360p"), root.zt("540p", "540p"), root.zt("720p", "720p"), root.zt("1080p (Default)", "1080p (Padrão)")]
                        currentIndex: Chiaki.settings.resolutionLocalPS5 - 1
                        onActivated: (index) => {
                            Chiaki.settings.resolutionLocalPS5 = index + 1
                            Chiaki.settings.bitrateLocalPS5 = 0
                        }
                        visible: selectedConsole == SettingsDialog.Console.PS5
                        KeyNavigation.right: resolutionRemotePS5
                        KeyNavigation.up: consoleSelection
                        KeyNavigation.down: fpsLocalPS5
                        KeyNavigation.priority: {
                            if(!popup.visible)
                                KeyNavigation.BeforeItem
                            else
                                KeyNavigation.AfterItem
                        }
                    }

                    C.ComboBox {
                        id: resolutionRemotePS5
                        Layout.preferredWidth: 400
                        model: [root.zt("360p", "360p"), root.zt("540p", "540p"), root.zt("720p (Default)", "720p (Padrão)"), root.zt("1080p", "1080p")]
                        currentIndex: Chiaki.settings.resolutionRemotePS5 - 1
                        onActivated: (index) => {
                            Chiaki.settings.resolutionRemotePS5 = index + 1
                            Chiaki.settings.bitrateRemotePS5 = 0
                        }
                        visible: selectedConsole == SettingsDialog.Console.PS5
                        KeyNavigation.left: resolutionLocalPS5
                        KeyNavigation.up: consoleSelection
                        KeyNavigation.down: fpsRemotePS5
                        KeyNavigation.priority: {
                            if(!popup.visible)
                                KeyNavigation.BeforeItem
                            else
                                KeyNavigation.AfterItem
                        }
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("FPS:", "FPS:")
                    }

                    C.ComboBox {
                        id: fpsLocalPS4
                        Layout.preferredWidth: 400
                        model: [root.zt("30 fps", "30 fps"), root.zt("60 fps (Default)", "60 fps (Padrão)")]
                        currentIndex: (Chiaki.settings.fpsLocalPS4 / 30) - 1
                        onActivated: (index) => Chiaki.settings.fpsLocalPS4 = (index + 1) * 30
                        visible: selectedConsole == SettingsDialog.Console.PS4
                        KeyNavigation.up: resolutionLocalPS4
                        KeyNavigation.right: fpsRemotePS4
                        KeyNavigation.down: bitrateLocalPS4
                        KeyNavigation.priority: {
                            if(!popup.visible)
                                KeyNavigation.BeforeItem
                            else
                                KeyNavigation.AfterItem
                        }
                    }

                    C.ComboBox {
                        id: fpsRemotePS4
                        Layout.preferredWidth: 400
                        model: [root.zt("30 fps", "30 fps"), root.zt("60 fps (Default)", "60 fps (Padrão)")]
                        currentIndex: (Chiaki.settings.fpsRemotePS4 / 30) - 1
                        onActivated: (index) => Chiaki.settings.fpsRemotePS4 = (index + 1) * 30
                        visible: selectedConsole == SettingsDialog.Console.PS4
                        KeyNavigation.up: resolutionRemotePS4
                        KeyNavigation.left: fpsLocalPS4
                        KeyNavigation.down: bitrateRemotePS4
                        KeyNavigation.priority: {
                            if(!popup.visible)
                                KeyNavigation.BeforeItem
                            else
                                KeyNavigation.AfterItem
                        }
                    }

                    C.ComboBox {
                        id: fpsLocalPS5
                        Layout.preferredWidth: 400
                        model: [root.zt("30 fps", "30 fps"), root.zt("60 fps (Default)", "60 fps (Padrão)")]
                        currentIndex: (Chiaki.settings.fpsLocalPS5 / 30) - 1
                        onActivated: (index) => Chiaki.settings.fpsLocalPS5 = (index + 1) * 30
                        visible: selectedConsole == SettingsDialog.Console.PS5
                        KeyNavigation.up: resolutionLocalPS5
                        KeyNavigation.right: fpsRemotePS5
                        KeyNavigation.down: bitrateLocalPS5
                        KeyNavigation.priority: {
                            if(!popup.visible)
                                KeyNavigation.BeforeItem
                            else
                                KeyNavigation.AfterItem
                        }
                    }

                    C.ComboBox {
                        id: fpsRemotePS5
                        Layout.preferredWidth: 400
                        model: [root.zt("30 fps", "30 fps"), root.zt("60 fps (Default)", "60 fps (Padrão)")]
                        currentIndex: (Chiaki.settings.fpsRemotePS5 / 30) - 1
                        onActivated: (index) => Chiaki.settings.fpsRemotePS5 = (index + 1) * 30
                        visible: selectedConsole == SettingsDialog.Console.PS5
                        KeyNavigation.up: resolutionRemotePS5
                        KeyNavigation.left: fpsLocalPS5
                        KeyNavigation.down: bitrateRemotePS5
                        KeyNavigation.priority: {
                            if(!popup.visible)
                                KeyNavigation.BeforeItem
                            else
                                KeyNavigation.AfterItem
                        }
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("Bitrate:", "Bitrate:")
                    }

                    C.Slider {
                        id: bitrateLocalPS4
                        visible: selectedConsole == SettingsDialog.Console.PS4
                        property var bitrate: {
                            var rate = 0;
                            switch (Chiaki.settings.resolutionLocalPS4) {
                            case 1: rate = 2; break; // 360p
                            case 2: rate = 6; break; // 540p
                            case 3: rate = 10; break; // 720p
                            case 4: rate = 15; break; // 1080p
                            }
                            return rate;
                        }
                        Layout.preferredWidth: 200
                        from: 2
                        to: 100
                        stepSize: 1
                        value: Chiaki.settings.bitrateLocalPS4 / 1000 ? (Chiaki.settings.bitrateLocalPS4 / 1000) : bitrate
                        onMoved: Chiaki.settings.bitrateLocalPS4 = value * 1000;
                        KeyNavigation.up: fpsLocalPS4
                        KeyNavigation.down: bitrateLocalPS4
                        KeyNavigation.priority: KeyNavigation.BeforeItem
                        Label {
                            anchors {
                                left: parent.right
                                verticalCenter: parent.verticalCenter
                                leftMargin: 10
                            }
                            text: (parent.value) + root.zt(" Mbps", " Mbps") + root.zt(" (%1 Mbps)", " (%1 Mbps)").arg(parent.bitrate.toFixed(0))
                        }
                    }

                    C.Slider {
                        id: bitrateRemotePS4
                        visible: selectedConsole == SettingsDialog.Console.PS4
                        property var bitrate: {
                            var rate = 0;
                            switch (Chiaki.settings.resolutionRemotePS4) {
                            case 1: rate = 2; break; // 360p
                            case 2: rate = 6; break; // 540p
                            case 3: rate = 10; break; // 720p
                            case 4: rate = 15; break; // 1080p
                            }
                            return rate;
                        }
                        Layout.preferredWidth: 200
                        from: 2
                        to: 100
                        stepSize: 1
                        value: Chiaki.settings.bitrateRemotePS4 / 1000 ? (Chiaki.settings.bitrateRemotePS4 / 1000) : bitrate
                        onMoved: Chiaki.settings.bitrateRemotePS4 = value * 1000;
                        KeyNavigation.up: fpsRemotePS4
                        KeyNavigation.down: bitrateRemotePS4
                        KeyNavigation.priority: KeyNavigation.BeforeItem
                        lastInFocusChain: true

                        Label {
                            anchors {
                                left: parent.right
                                verticalCenter: parent.verticalCenter
                                leftMargin: 10
                            }
                            text: (parent.value) + root.zt(" Mbps", " Mbps") + root.zt(" (%1 Mbps)", " (%1 Mbps)").arg(parent.bitrate.toFixed(0))
                        }
                    }

                    C.Slider {
                        id: bitrateLocalPS5
                        visible: selectedConsole == SettingsDialog.Console.PS5
                        property var bitrate: {
                            var rate = 0;
                            switch (Chiaki.settings.resolutionLocalPS5) {
                            case 1: rate = 2; break; // 360p
                            case 2: rate = 6; break; // 540p
                            case 3: rate = 10; break; // 720p
                            case 4: rate = 15; break; // 1080p
                            }
                            return rate;
                        }
                        Layout.preferredWidth: 200
                        from: 2
                        to: 100
                        stepSize: 1
                        value: Chiaki.settings.bitrateLocalPS5 / 1000 ? (Chiaki.settings.bitrateLocalPS5 / 1000) : bitrate
                        onMoved: Chiaki.settings.bitrateLocalPS5 = value * 1000;
                        KeyNavigation.up: fpsLocalPS5
                        KeyNavigation.down: codecLocalPS5
                        KeyNavigation.priority: KeyNavigation.BeforeItem

                        Label {
                            anchors {
                                left: parent.right
                                verticalCenter: parent.verticalCenter
                                leftMargin: 10
                            }
                            text: (parent.value) + root.zt(" Mbps", " Mbps") + root.zt(" (%1 Mbps)", " (%1 Mbps)").arg(parent.bitrate.toFixed(0))
                        }
                    }

                    C.Slider {
                        id: bitrateRemotePS5
                        visible: selectedConsole == SettingsDialog.Console.PS5
                        property var bitrate: {
                            var rate = 0;
                            switch (Chiaki.settings.resolutionRemotePS5) {
                            case 1: rate = 2; break; // 360p
                            case 2: rate = 6; break; // 540p
                            case 3: rate = 10; break; // 720p
                            case 4: rate = 15; break; // 1080p
                            }
                            return rate;
                        }
                        Layout.preferredWidth: 200
                        from: 2
                        to: 100
                        stepSize: 1
                        value: Chiaki.settings.bitrateRemotePS5 / 1000 ? (Chiaki.settings.bitrateRemotePS5 / 1000) : bitrate
                        onMoved: Chiaki.settings.bitrateRemotePS5 = value * 1000;
                        KeyNavigation.up: fpsRemotePS5
                        KeyNavigation.down: codecRemotePS5
                        KeyNavigation.priority: KeyNavigation.BeforeItem
                        lastInFocusChain: true

                        Label {
                            anchors {
                                left: parent.right
                                verticalCenter: parent.verticalCenter
                                leftMargin: 10
                            }
                            text: (parent.value) + root.zt(" Mbps", " Mbps") + root.zt(" (%1 Mbps)", " (%1 Mbps)").arg(parent.bitrate.toFixed(0))
                        }
                    }

                    Label {
                        Layout.alignment: Qt.AlignRight
                        text: root.zt("Codec:", "Codec:")
                        visible: selectedConsole == SettingsDialog.Console.PS5
                    }

                    C.ComboBox {
                        id: codecLocalPS5
                        Layout.preferredWidth: 400
                        property bool openGlBackend: Chiaki.settings.rendererBackend === 1
						model: openGlBackend ? [root.zt("H264", "H264"), root.zt("H265 (Default)", "H265 (Padrão)")] : [root.zt("H264", "H264"), root.zt("H265 (Default)", "H265 (Padrão)"), root.zt("H265 HDR", "H265 HDR")]
                        currentIndex: Chiaki.settings.codecLocalPS5
                        onActivated: (index) => Chiaki.settings.codecLocalPS5 = index
                        visible: selectedConsole == SettingsDialog.Console.PS5
                        Keys.onReturnPressed: {
                            if (popup.visible) {
                                activated(highlightedIndex);
                                popup.close();
                            } else
                                popup.open();
                        }
                        KeyNavigation.up: bitrateLocalPS5
                        KeyNavigation.right: codecRemotePS5
                        KeyNavigation.down: codecLocalPS5
                        KeyNavigation.priority: {
                            if(!popup.visible)
                                KeyNavigation.BeforeItem
                            else
                                KeyNavigation.AfterItem
                        }
                    }

                        C.ComboBox {
                            id: codecRemotePS5
                            Layout.preferredWidth: 400
                        property bool openGlBackend: Chiaki.settings.rendererBackend === 1
                        model: openGlBackend ? [root.zt("H264", "H264"), root.zt("H265 (Default)", "H265 (Padrão)")] : [root.zt("H264", "H264"), root.zt("H265 (Default)", "H265 (Padrão)"), root.zt("H265 HDR", "H265 HDR")]
                            currentIndex: Chiaki.settings.codecRemotePS5
                            onActivated: (index) => Chiaki.settings.codecRemotePS5 = index
                            visible: selectedConsole == SettingsDialog.Console.PS5
                            lastInFocusChain: true
                            Keys.onReturnPressed: {
                                if (popup.visible) {
                                    activated(highlightedIndex);
                                    popup.close();
                                } else
                                    popup.open();
                            }
                            KeyNavigation.up: bitrateRemotePS5
                            KeyNavigation.left: codecLocalPS5
                            KeyNavigation.priority: {
                                if(!popup.visible)
                                    KeyNavigation.BeforeItem
                                else
                                    KeyNavigation.AfterItem
                            }
                        }
                    }
                }
            }

            Item {
                // Audio and Wifi
                Flickable {
                    id: audiowifiFlick
                    anchors {
                        fill: parent
                        topMargin: 20
                        bottomMargin: 20
                    }
                    clip: true
                    contentWidth: Math.max(width, audiowifigrid.width)
                    contentHeight: audiowifigrid.height
                    flickableDirection: Flickable.AutoFlickIfNeeded
                    ScrollBar.vertical: ScrollBar {
                        id: audiowifiScrollbar
                        policy: ScrollBar.AlwaysOn
                        visible: audiowifiFlick.contentHeight > audiowifiFlick.height
                    }
                    GridLayout {
                        id: audiowifigrid
                        columns: 3
                        rowSpacing: 10
                        columnSpacing: 20
                        onVisibleChanged: if (visible) Chiaki.settings.refreshAudioDevices()

                        anchors {
                            top: parent.top
                            horizontalCenter: parent.horizontalCenter
                        }
                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("Output Device:", "Dispositivo de saída:")
                        }

                        C.ComboBox {
                            id: audioOutDevice
                            Layout.preferredWidth: 400
                            popup.x: (width - popup.width) / 2
                            popup.width: 700
                            popup.font.pixelSize: 16
                            firstInFocusChain: true
                            model: [root.zt("Auto", "Automático")].concat(Chiaki.settings.availableAudioOutDevices)
                            currentIndex: Math.max(0, model.indexOf(Chiaki.settings.audioOutDevice))
                            onActivated: (index) => Chiaki.settings.audioOutDevice = index ? model[index] : ""
                            KeyNavigation.down: audioInDevice
                            KeyNavigation.priority: popup.visible ? KeyNavigation.AfterItem : KeyNavigation.BeforeItem
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("(Auto)", "(Automático)")
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("Input Device:", "Dispositivo de entrada:")
                        }

                        C.ComboBox {
                            id: audioInDevice
                            Layout.preferredWidth: 400
                            popup.x: (width - popup.width) / 2
                            popup.width: 700
                            popup.font.pixelSize: 16
                            model: [root.zt("Auto", "Automático")].concat(Chiaki.settings.availableAudioInDevices)
                            currentIndex: Math.max(0, model.indexOf(Chiaki.settings.audioInDevice))
                            onActivated: (index) => Chiaki.settings.audioInDevice = index ? model[index] : ""
                            KeyNavigation.up: audioOutDevice
                            KeyNavigation.down: audioBufferSizeSlider
                            KeyNavigation.priority: popup.visible ? KeyNavigation.AfterItem : KeyNavigation.BeforeItem
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("(Auto)", "(Automático)")
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("Audio Buffer Size:", "Buffer de áudio:")
                        }

                        C.Slider {
                            id: audioBufferSizeSlider
                            Layout.preferredWidth: 250
                            from: 1
                            to: 10
                            stepSize: 1
                            value: Chiaki.settings.audioBufferSize / 1920 ? (Chiaki.settings.audioBufferSize / 1920) : 5
                            onMoved: Chiaki.settings.audioBufferSize = value * 1920;
                            KeyNavigation.up: audioInDevice

                            Label {
                                anchors {
                                    left: parent.right
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 10
                                }
                                text: {
                                    (parent.value * 10).toFixed(0) + root.zt(" ms", " ms")
                                }
                            }
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("(50 ms)", "(50 ms)")
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("Audio Volume:", "Volume:")
                        }

                        C.Slider {
                            Layout.preferredWidth: 250
                            from: 0
                            to: 128
                            stepSize: 1
                            value: Chiaki.settings.audioVolume
                            onMoved: Chiaki.settings.audioVolume = value

                            Label {
                                anchors {
                                    left: parent.right
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 10
                                }
                                text: {
                                    ((parent.value / 128.0) * 100).toFixed(0) + root.zt("% volume", "% de volume")
                                }
                            }
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("(100%)", "(100%)")
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("Start Mic Unmuted:", "Iniciar microfone sem mute:")
                        }

                        C.CheckBox {
                            checked: Chiaki.settings.startMicUnmuted
                            onToggled: Chiaki.settings.startMicUnmuted = checked
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("(Unchecked)", "(Desmarcado)")
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("Speech Processing:", "Processamento de voz:")
                            visible: typeof Chiaki.settings.speechProcessing !== "undefined"
                        }

                        C.CheckBox {
                            text: root.zt("Noise suppression + echo cancellation", "Supressão de ruído + cancelamento de eco")
                            checked: Chiaki.settings.speechProcessing
                            onToggled: Chiaki.settings.speechProcessing = !Chiaki.settings.speechProcessing
                            visible: typeof Chiaki.settings.speechProcessing !== "undefined"
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("(Unchecked)", "(Desmarcado)")
                            visible: typeof Chiaki.settings.speechProcessing !== "undefined"
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("Noise To Suppress:", "Ruído a suprimir:")
                            visible: if (typeof Chiaki.settings.speechProcessing !== "undefined") {Chiaki.settings.speechProcessing} else {false}
                        }

                        C.Slider {
                            Layout.preferredWidth: 250
                            from: 0
                            to: 60
                            stepSize: 1
                            visible: if (typeof Chiaki.settings.speechProcessing !== "undefined") {Chiaki.settings.speechProcessing} else {false}
                            value: Chiaki.settings.noiseSuppressLevel
                            onMoved: Chiaki.settings.noiseSuppressLevel = value

                            Label {
                                anchors {
                                    left: parent.right
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 10
                                }
                                text: root.zt("%1 dB", "%1 dB").arg(parent.value)
                            }
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("(6 dB)", "(6 dB)")
                            visible: if (typeof Chiaki.settings.speechProcessing !== "undefined") {Chiaki.settings.speechProcessing} else {false}
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("Echo To Suppress:", "Eco a suprimir:")
                            visible: if (typeof Chiaki.settings.speechProcessing !== "undefined") {Chiaki.settings.speechProcessing} else {false}
                        }

                        C.Slider {
                            Layout.preferredWidth: 250
                            from: 0
                            to: 60
                            stepSize: 1
                            value: Chiaki.settings.echoSuppressLevel
                            visible: if (typeof Chiaki.settings.speechProcessing !== "undefined") {Chiaki.settings.speechProcessing} else {false}
                            onMoved: Chiaki.settings.echoSuppressLevel = value

                            Label {
                                anchors {
                                    left: parent.right
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 10
                                }
                                text: root.zt("%1 dB", "%1 dB").arg(parent.value)
                            }
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("(30 dB)", "(30 dB)")
                            visible: if (typeof Chiaki.settings.speechProcessing !== "undefined") {Chiaki.settings.speechProcessing} else {false}
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("Weak Wi-Fi Notification:", "Aviso de Wi-Fi fraco:")
                        }

                        C.Slider {
                            Layout.preferredWidth: 250
                            from: 0
                            to: 100
                            stepSize: 1
                            value: Chiaki.settings.wifiDroppedNotif
                            onMoved: Chiaki.settings.wifiDroppedNotif = value

                            Label {
                                anchors {
                                    left: parent.right
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 10
                                }
                                text: root.zt(">= %1% dropped packets", ">= %1% de pacotes perdidos").arg(parent.value)
                            }
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("(3%)", "(3%)")
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("Packet Loss Reported Max:", "Perda máxima de pacotes reportada:")
                        }

                        C.Slider {
                            Layout.preferredWidth: 250
                            from: 0
                            to: 100
                            stepSize: 1
                            value: Chiaki.settings.packetLossReportedMax
                            onMoved: Chiaki.settings.packetLossReportedMax = value

                            Label {
                                anchors {
                                    left: parent.right
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 10
                                }
                                text: root.zt("%1% packet loss", "%1% de perda de pacotes").arg(parent.value)
                            }
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("(5%)", "(5%)")
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("Request IDR Frame on FEC Failure", "Solicitar quadro IDR em falha de FEC")
                        }

                        C.CheckBox {
                            checked: Chiaki.settings.iDROnFECFailureEnabled
                            onToggled: Chiaki.settings.iDROnFECFailureEnabled = !Chiaki.settings.iDROnFECFailureEnabled
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("(Unchecked)", "(Desmarcado)")
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("Show Stream Stats During Gameplay", "Mostrar estatísticas durante o jogo")
                        }

                        C.CheckBox {
                            lastInFocusChain: true
                            checked: Chiaki.settings.showStreamStats
                            onToggled: Chiaki.settings.showStreamStats = !Chiaki.settings.showStreamStats
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("(Unchecked)", "(Desmarcado)")
                        }
                    }
                }
            }

            Item {
                // Consoles
                Flickable {
                    id: consolesFlick
                    anchors {
                        fill: parent
                        topMargin: 20
                        bottomMargin: 20
                    }
                    clip: true
                    contentWidth: Math.max(width, consolesLayout.width)
                    contentHeight: consolesLayout.height
                    flickableDirection: Flickable.AutoFlickIfNeeded
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AlwaysOn
                        visible: consolesFlick.contentHeight > consolesFlick.height
                    }
                    ColumnLayout {
                        id: consolesLayout
                        anchors {
                            top: parent.top
                            horizontalCenter: parent.horizontalCenter
                        }
                        spacing: 10

                        Label {
                            text: ""
                        }

                        Label {
                            text: ""
                        }

                        C.Button {
                            id: registerNewButton
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: 10
                            topPadding: 26
                            leftPadding: 30
                            rightPadding: 30
                            bottomPadding: 26
                            firstInFocusChain: true
                            text: root.zt("Register New", "Registrar novo")
                            onClicked: root.showRegistDialog("255.255.255.255", true)
                            Material.roundedScale: Material.SmallScale
                        }

                        Label {
                            id: consolesLabel
                            Layout.alignment: Qt.AlignHCenter
                            text: root.zt("Registered Consoles", "Consoles registrados")
                            font.bold: true
                        }

                        ListView {
                            id: consolesView
                            Layout.alignment: Qt.AlignHCenter
                            height: 170
                            onCountChanged: {
                                consolesView.contentHeight = consolesView.count * 80 + consolesView.anchors.topMargin;
                            }
                            keyNavigationEnabled: false
                            width: 700
                            ScrollBar.vertical: ScrollBar {
                                id: consolesScrollbar
                                policy: ScrollBar.AlwaysOn
                                visible: consolesView.contentHeight > consolesView.height
                            }
                            clip: true
                            model: Chiaki.settings.registeredHosts
                            delegate: ItemDelegate {
                                text: "%1 (%2, %3)".arg(Chiaki.settings.streamerMode ? "hidden" : modelData.mac).arg(modelData.ps5 ? "PS5" : "PS4").arg(modelData.name)
                                height: 80
                                width: parent ? parent.width : 0
                                leftPadding: autoConnectButton.width + 40

                                CheckBox {
                                    property bool firstInFocusChain: false
                                    property bool lastInFocusChain: false
                                    property bool lastDownInFocusChain: index > consolesView.count + hiddenConsolesView.count - 2

                                    id: autoConnectButton
                                    anchors {
                                        left: parent.left
                                        verticalCenter: parent.verticalCenter
                                        leftMargin: 20
                                    }
                                    text: root.zt("Auto-Connect", "Conexão automática")
                                    checked: Chiaki.settings.autoConnectMac == modelData.mac
                                    onToggled: Chiaki.settings.autoConnectMac = checked ? modelData.mac : "";

                                    Keys.onPressed: (event) => {
                                        switch (event.key) {
                                        case Qt.Key_Right:
                                            if (!lastInFocusChain) {
                                                let item = nextItemInFocusChain();
                                                if (item)
                                                    item.forceActiveFocus(Qt.TabFocusReason);
                                                event.accepted = true;
                                            }
                                            break;
                                        case Qt.Key_Up:
                                            if (!firstInFocusChain) {
                                                let item = nextItemInFocusChain(false);
                                                if (item) {
                                                    item.forceActiveFocus(Qt.TabFocusReason);
                                                    dialog.ensureItemVisibleInFlick(consolesView, item);
                                                }
                                                let count = index > 0 ? 2: 0;
                                                for(var i = 0; i < count; i++)
                                                {
                                                    let item2 = item.nextItemInFocusChain(false);
                                                    if (item)
                                                    {
                                                        item.forceActiveFocus(Qt.TabFocusReason);
                                                        dialog.ensureItemVisibleInFlick(consolesView, item);
                                                        item = item2;
                                                    }
                                                }
                                                event.accepted = true;
                                            }
                                            break;
                                        case Qt.Key_Down:
                                            if (!lastDownInFocusChain) {
                                                let item = nextItemInFocusChain();
                                                if (item) {
                                                    item.forceActiveFocus(Qt.TabFocusReason);
                                                    dialog.ensureItemVisibleInFlick(consolesView, item);
                                                }
                                                let count = 2;
                                                for(var i = 0; i < count; i++)
                                                {
                                                    let item2 = item.nextItemInFocusChain();
                                                    if (item)
                                                    {
                                                        item.forceActiveFocus(Qt.TabFocusReason);
                                                        dialog.ensureItemVisibleInFlick(consolesView, item);
                                                        item = item2;
                                                    }
                                                }
                                                event.accepted = true;
                                            }
                                            break;
                                        case Qt.Key_Return:
                                            if (visualFocus) {
                                                toggle();
                                                toggled();
                                            }
                                            event.accepted = true;
                                            break;
                                        }
                                    }
                                }

                                Button {
                                    property bool firstInFocusChain: false
                                    property bool lastInFocusChain: index > consolesView.count + hiddenConsolesView.count - 2
                                    Material.background: visualFocus ? Material.accent : undefined

                                    Component.onDestruction: {
                                        if (visualFocus) {
                                            let item = nextItemInFocusChain();
                                            if (item)
                                                item.forceActiveFocus(Qt.TabFocusReason);
                                        }
                                    }
                                    Keys.onPressed: (event) => {
                                        switch (event.key) {
                                            case Qt.Key_Left:
                                                if (!firstInFocusChain) {
                                                    let item = nextItemInFocusChain(false);
                                                    if (item)
                                                        item.forceActiveFocus(Qt.TabFocusReason);
                                                    event.accepted = true;
                                                }
                                                break;
                                            case Qt.Key_Up:
                                                if (!firstInFocusChain)
                                                {
                                                    let item = nextItemInFocusChain(false);
                                                    if (item) {
                                                        item.forceActiveFocus(Qt.TabFocusReason);
                                                        dialog.ensureItemVisibleInFlick(consolesView, item);
                                                    }
                                                    let count = 2;
                                                    for(var i = 0; i < count; i++)
                                                    {
                                                        let item2 = item.nextItemInFocusChain(false);
                                                        if (item)
                                                        {
                                                            item.forceActiveFocus(Qt.TabFocusReason);
                                                            dialog.ensureItemVisibleInFlick(consolesView, item);
                                                            item = item2;
                                                        }
                                                    }
                                                    event.accepted = true;
                                                }
                                                break;
                                            case Qt.Key_Down:
                                                if (!lastInFocusChain) {
                                                    let item = nextItemInFocusChain();
                                                    if (item) {
                                                        item.forceActiveFocus(Qt.TabFocusReason);
                                                        dialog.ensureItemVisibleInFlick(consolesView, item);
                                                    }
                                                    let count = index < consolesView.count - 1 ? 2: 0;
                                                    for(var i = 0; i < count; i++)
                                                    {
                                                        let item2 = item.nextItemInFocusChain();
                                                        if (item)
                                                        {
                                                            item.forceActiveFocus(Qt.TabFocusReason);
                                                            dialog.ensureItemVisibleInFlick(consolesView, item);
                                                            item = item2;
                                                        }
                                                    }
                                                    event.accepted = true;
                                                }
                                                break;
                                            case Qt.Key_Return:
                                                if (visualFocus) {
                                                    clicked();
                                                }
                                                event.accepted = true;
                                                break;
                                        }
                                    }
                                    anchors {
                                        right: parent.right
                                        verticalCenter: parent.verticalCenter
                                        rightMargin: 20
                                    }
                                    text: root.zt("Delete", "Excluir")
                                    onClicked: root.showConfirmDialog(root.zt("Delete Console", "Excluir console"), root.zt("Are you sure you want to delete this console?", "Tem certeza de que deseja excluir este console?"), () => Chiaki.settings.deleteRegisteredHost(index));
                                    Material.roundedScale: Material.SmallScale
                                    Material.accent: Material.Red
                                }
                            }
                        }

                        Label {
                            id: hiddenConsolesLabel
                            Layout.alignment: Qt.AlignHCenter
                            text: root.zt("Hidden Consoles", "Consoles ocultos")
                            font.bold: true
                        }
                        ListView {
                            id: hiddenConsolesView
                            Layout.alignment: Qt.AlignHCenter
                            keyNavigationEnabled: false
                            height: 170
                            onCountChanged: {
                                hiddenConsolesView.contentHeight = hiddenConsolesView.count * 80 + hiddenConsolesView.anchors.topMargin;
                            }
                            clip: true
                            width: 500
                            ScrollBar.vertical: ScrollBar {
                                id: hiddenConsolesScrollbar
                                policy: ScrollBar.AlwaysOn
                                visible: hiddenConsolesView.contentHeight > hiddenConsolesView.height
                            }
                            model: Chiaki.hiddenHosts
                            delegate: ItemDelegate {
                                text: "%1 (%2)".arg(Chiaki.settings.streamerMode ? "hidden" : modelData.mac).arg(modelData.name)
                                height: 80
                                width: parent ? parent.width : 0

                                Button {
                                    property bool firstInFocusChain: false
                                    property bool lastInFocusChain: index > hiddenConsolesView.count - 2
                                    Material.background: visualFocus ? Material.accent : undefined

                                    Component.onDestruction: {
                                        if (visualFocus) {
                                            let item = nextItemInFocusChain();
                                            if (item)
                                                item.forceActiveFocus(Qt.TabFocusReason);
                                        }
                                    }
                                    Keys.onPressed: (event) => {
                                        switch (event.key) {
                                            case Qt.Key_Up:
                                                if (!firstInFocusChain)
                                                {
                                                    let item = nextItemInFocusChain(false);
                                                    if (item) {
                                                        item.forceActiveFocus(Qt.TabFocusReason);
                                                        dialog.ensureItemVisibleInFlick(hiddenConsolesView, item);
                                                    }
                                                    event.accepted = true;
                                                }
                                                break;
                                            case Qt.Key_Down:
                                                if (!lastInFocusChain) {
                                                    let item = nextItemInFocusChain();
                                                    if (item) {
                                                        item.forceActiveFocus(Qt.TabFocusReason);
                                                        dialog.ensureItemVisibleInFlick(hiddenConsolesView, item);
                                                    }
                                                    event.accepted = true;
                                                }
                                                break;
                                            case Qt.Key_Return:
                                                if (visualFocus) {
                                                    clicked();
                                                }
                                                event.accepted = true;
                                                break;
                                        }
                                    }
                                    anchors {
                                        right: parent.right
                                        verticalCenter: parent.verticalCenter
                                        rightMargin: 20
                                    }
                                    text: root.zt("Unhide", "Reexibir")
                                    onClicked: root.showConfirmDialog(root.zt("Unhide Console", "Reexibir console"), root.zt("Are you sure you want to unhide this console?", "Tem certeza de que deseja reexibir este console?"), () => Chiaki.unhideHost(modelData.mac));
                                    Material.roundedScale: Material.SmallScale
                                    Material.accent: Material.Red
                                }
                            }
                        }
                    }
                }
            }

            Item {
                // Keys
                id: controllerMapping

                Flickable {
                    id: keysFlick
                    anchors {
                        fill: parent
                        topMargin: 20
                        bottomMargin: 20
                    }
                    clip: true
                    contentWidth: width
                    contentHeight: keysGrid.implicitHeight
                    flickableDirection: Flickable.VerticalFlick

                    function ensureItemVisible(item) {
                        if (!item)
                            return;
                        const top = item.mapToItem(keysGrid, 0, 0).y;
                        const bottom = top + item.height;
                        if (top < contentY)
                            contentY = Math.max(0, top - 10);
                        else if (bottom > contentY + height)
                            contentY = Math.min(Math.max(0, contentHeight - height), bottom - height + 10);
                    }

                    function moveFocus(item, steps) {
                        let target = item;
                        const forward = steps > 0;
                        const count = Math.abs(steps);
                        for (let i = 0; i < count; ++i) {
                            const next = target ? target.nextItemInFocusChain(forward) : null;
                            if (!next || next === target)
                                break;
                            target = next;
                        }
                        if (target && target !== item) {
                            target.forceActiveFocus(Qt.TabFocusReason);
                            ensureItemVisible(target);
                        }
                    }

                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                    ColumnLayout {
                        id: keysGrid
                        x: 24
                        width: Math.max(0, keysFlick.width - 48)
                        spacing: 14

                        GridLayout {
                            id: keysHeaderGrid
                            Layout.fillWidth: true
                            columns: width >= 900 ? 3 : 1
                            columnSpacing: 18
                            rowSpacing: 8

                            Button {
                                id: resetAllKeys
                                Layout.fillWidth: true
                                Layout.maximumWidth: 260
                                Layout.alignment: Qt.AlignHCenter
                                text: root.zt("Reset All Keys", "Redefinir todas as teclas")
                                property bool firstInFocusChain: true
                                property bool lastInFocusChain: false
                                onClicked: Chiaki.settings.clearKeyMapping()
                                Material.roundedScale: Material.SmallScale
                                Material.background: visualFocus ? Material.accent : undefined
                                onActiveFocusChanged: if (activeFocus) keysFlick.ensureItemVisible(this)
                                Keys.onDownPressed: keysFlick.moveFocus(this, 3)
                                Keys.onRightPressed: keysFlick.moveFocus(this, 1)
                                Keys.onReturnPressed: clicked()
                            }

                            CheckBox {
                                Layout.fillWidth: true
                                text: root.zt("Keyboard as controller", "Teclado como controle")
                                checked: Chiaki.settings.keyboardEnabled
                                onToggled: Chiaki.settings.keyboardEnabled = checked
                                Material.roundedScale: Material.SmallScale
                                Material.background: visualFocus ? Material.accent : undefined
                                onActiveFocusChanged: if (activeFocus) keysFlick.ensureItemVisible(this)
                                Keys.onLeftPressed: keysFlick.moveFocus(this, -1)
                                Keys.onRightPressed: keysFlick.moveFocus(this, 1)
                                Keys.onDownPressed: keysFlick.moveFocus(this, 2)
                            }

                            CheckBox {
                                Layout.fillWidth: true
                                text: root.zt("Enable Mouse Touchpad", "Ativar touchpad pelo mouse")
                                checked: Chiaki.settings.mouseTouchEnabled
                                onToggled: Chiaki.settings.mouseTouchEnabled = checked
                                Material.roundedScale: Material.SmallScale
                                Material.background: visualFocus ? Material.accent : undefined
                                onActiveFocusChanged: if (activeFocus) keysFlick.ensureItemVisible(this)
                                Keys.onLeftPressed: keysFlick.moveFocus(this, -1)
                                Keys.onDownPressed: keysFlick.moveFocus(this, 1)
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: root.zanithBorder
                            opacity: 0.7
                        }

                        GridLayout {
                            id: keyMappingsGrid
                            Layout.fillWidth: true
                            columns: width >= 900 ? 2 : 1
                            columnSpacing: 28
                            rowSpacing: 8

                            Repeater {
                                id: chiakiKeys
                                model: Chiaki.settings.controllerMapping

                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    Layout.preferredHeight: Math.max(52, commandLabel.implicitHeight + 12)
                                    spacing: 12

                                    Label {
                                        id: commandLabel
                                        Layout.fillWidth: true
                                        Layout.minimumWidth: 0
                                        horizontalAlignment: Text.AlignRight
                                        verticalAlignment: Text.AlignVCenter
                                        wrapMode: Text.WordWrap
                                        text: translateButtonName(modelData.buttonName)
                                    }

                                    Button {
                                        property bool firstInFocusChain: false
                                        property bool lastInFocusChain: index === chiakiKeys.count - 1
                                        Layout.preferredWidth: 160
                                        Layout.minimumWidth: 140
                                        Layout.preferredHeight: 46
                                        text: translateKeyName(modelData.keyName)
                                        Material.roundedScale: Material.SmallScale
                                        Material.background: visualFocus ? Material.accent : undefined
                                        onActiveFocusChanged: if (activeFocus) keysFlick.ensureItemVisible(this)
                                        onClicked: {
                                            keyDialog.show({
                                                value: modelData.buttonValue,
                                                mappingIndex: index,
                                                callback: (name) => { },
                                            });
                                        }
                                        Keys.onPressed: (event) => {
                                            const cols = keyMappingsGrid.columns;
                                            switch (event.key) {
                                            case Qt.Key_Left:
                                                if ((index % cols) > 0) {
                                                    keysFlick.moveFocus(this, -1);
                                                    event.accepted = true;
                                                }
                                                break;
                                            case Qt.Key_Right:
                                                if ((index % cols) < cols - 1 && index + 1 < chiakiKeys.count) {
                                                    keysFlick.moveFocus(this, 1);
                                                    event.accepted = true;
                                                }
                                                break;
                                            case Qt.Key_Up:
                                                if (index >= cols) {
                                                    keysFlick.moveFocus(this, -cols);
                                                    event.accepted = true;
                                                }
                                                break;
                                            case Qt.Key_Down:
                                                if (index + cols < chiakiKeys.count) {
                                                    keysFlick.moveFocus(this, cols);
                                                    event.accepted = true;
                                                }
                                                break;
                                            case Qt.Key_Return:
                                                clicked();
                                                event.accepted = true;
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item {
                // Controllers
                Flickable {
                    id: controllersFlick
                    anchors {
                        fill: parent
                        topMargin: 20
                        bottomMargin: 20
                    }
                    clip: true
                    contentWidth: width
                    contentHeight: controllersLayout.implicitHeight
                    flickableDirection: Flickable.VerticalFlick
                    ScrollBar.vertical: ScrollBar {
                        id: controllersScrollbar
                        policy: ScrollBar.AsNeeded
                    }

                    ColumnLayout {
                        id: controllersLayout
                        x: 20
                        width: Math.max(0, controllersFlick.width - 40)
                        spacing: 12

                        property real labelColumnWidth: Math.max(230, Math.min(330, width * 0.27))
                        property real stateColumnWidth: Math.max(150, Math.min(220, width * 0.18))
                        property var dpadShortcutOptions: [root.zt("Not Used", "Não usado"), root.zt("Cross", "X"), root.zt("Moon", "Círculo"), root.zt("Box", "Quadrado"), root.zt("Pyramid", "Triângulo"), root.zt("Dpad Left", "Direcional para a esquerda"), root.zt("Dpad Right", "Direcional para a direita"), root.zt("Dpad Up", "Direcional para cima"), root.zt("Dpad Down", "Direcional para baixo"), "L1", "R1", "L3", "R3", "Options", "Share", "Touchpad", "PS"]

                        GridLayout {
                            Layout.alignment: Qt.AlignHCenter
                            columns: width >= 620 ? 2 : 1
                            columnSpacing: 12
                            rowSpacing: 8

                            C.Button {
                                id: controllerMappingChange
                                Layout.preferredWidth: 300
                                firstInFocusChain: true
                                text: root.zt("Change Controller Mapping", "Alterar mapeamento do controle")
                                onClicked: controllerMappingDialog.show({ reset: false })
                            }

                            C.Button {
                                id: controllerMappingReset
                                Layout.preferredWidth: 300
                                text: root.zt("Reset Controller Mapping", "Redefinir mapeamento do controle")
                                onClicked: controllerMappingDialog.show({ reset: true })
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: root.zanithBorder
                            opacity: 0.7
                        }

                        GridLayout {
                            id: controllerOptionsGrid
                            Layout.fillWidth: true
                            columns: 3
                            rowSpacing: 10
                            columnSpacing: 16

                            Label {
                                Layout.preferredWidth: controllersLayout.labelColumnWidth
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                                text: root.zt("Background Controller Events:", "Eventos do controle em segundo plano:")
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                C.CheckBox {
                                    id: backgroundController
                                    checked: Chiaki.settings.allowJoystickBackgroundEvents
                                    onToggled: Chiaki.settings.allowJoystickBackgroundEvents = checked
                                }
                                Label {
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    wrapMode: Text.WordWrap
                                    text: root.zt("Process controller input when application is in background", "Processar entrada do controle quando o app estiver em segundo plano")
                                }
                            }

                            Label {
                                Layout.preferredWidth: controllersLayout.stateColumnWidth
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                color: root.zanithMuted
                                text: backgroundController.checked ? root.zt("(Checked)", "(Marcado)") : root.zt("(Unchecked)", "(Desmarcado)")
                            }

                            Label {
                                Layout.preferredWidth: controllersLayout.labelColumnWidth
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                                text: root.zt("Dpad Touchpad Emulation", "Emulação de touchpad pelo direcional")
                            }

                            C.CheckBox {
                                id: dpadTouch
                                checked: Chiaki.settings.dpadTouchEnabled
                                onToggled: Chiaki.settings.dpadTouchEnabled = !Chiaki.settings.dpadTouchEnabled
                                KeyNavigation.up: backgroundController
                                KeyNavigation.down: Chiaki.settings.dpadTouchEnabled ? touchIncrement : posButtons
                            }

                            Label {
                                Layout.preferredWidth: controllersLayout.stateColumnWidth
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                color: root.zanithMuted
                                text: dpadTouch.checked ? root.zt("(Checked)", "(Marcado)") : root.zt("(Unchecked)", "(Desmarcado)")
                            }

                            Label {
                                Layout.preferredWidth: controllersLayout.labelColumnWidth
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                                text: root.zt("Dpad Touch Increment:", "Incremento do touch pelo direcional:")
                                visible: Chiaki.settings.dpadTouchEnabled
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                visible: Chiaki.settings.dpadTouchEnabled
                                spacing: 12

                                C.Slider {
                                    id: touchIncrement
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 220
                                    from: 1
                                    to: 1079
                                    stepSize: 1
                                    value: Chiaki.settings.dpadTouchIncrement
                                    onMoved: Chiaki.settings.dpadTouchIncrement = value
                                    KeyNavigation.up: dpadTouch
                                    KeyNavigation.down: dpadShortcut1
                                }

                                Label {
                                    Layout.preferredWidth: 85
                                    horizontalAlignment: Text.AlignRight
                                    text: root.zt("%1 mm", "%1 mm").arg((touchIncrement.value / 100).toFixed(2))
                                }
                            }

                            Label {
                                Layout.preferredWidth: controllersLayout.stateColumnWidth
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                color: root.zanithMuted
                                text: root.zt("(0.3 mm)", "(0,3 mm)")
                                visible: Chiaki.settings.dpadTouchEnabled
                            }

                            Label {
                                Layout.preferredWidth: controllersLayout.labelColumnWidth
                                Layout.alignment: Qt.AlignRight | Qt.AlignTop
                                horizontalAlignment: Text.AlignRight
                                text: root.zt("Dpad Regular/Touch Combo:", "Combinação do direcional/touch:")
                                visible: Chiaki.settings.dpadTouchEnabled
                            }

                            GridLayout {
                                id: dpadShortcutGrid
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                columns: width >= 620 ? 4 : 2
                                columnSpacing: 8
                                rowSpacing: 8
                                visible: Chiaki.settings.dpadTouchEnabled

                                C.ComboBox {
                                    id: dpadShortcut1
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 110
                                    implicitContentWidthPolicy: ComboBox.ContentItemImplicitWidth
                                    model: controllersLayout.dpadShortcutOptions
                                    currentIndex: Chiaki.settings.dpadTouchShortcut1
                                    onActivated: index => Chiaki.settings.dpadTouchShortcut1 = index
                                    KeyNavigation.up: touchIncrement
                                    KeyNavigation.down: posButtons
                                    KeyNavigation.right: dpadShortcut2
                                }

                                C.ComboBox {
                                    id: dpadShortcut2
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 110
                                    implicitContentWidthPolicy: ComboBox.ContentItemImplicitWidth
                                    model: controllersLayout.dpadShortcutOptions
                                    currentIndex: Chiaki.settings.dpadTouchShortcut2
                                    onActivated: index => Chiaki.settings.dpadTouchShortcut2 = index
                                    KeyNavigation.up: touchIncrement
                                    KeyNavigation.down: posButtons
                                    KeyNavigation.left: dpadShortcut1
                                    KeyNavigation.right: dpadShortcut3
                                }

                                C.ComboBox {
                                    id: dpadShortcut3
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 110
                                    implicitContentWidthPolicy: ComboBox.ContentItemImplicitWidth
                                    model: controllersLayout.dpadShortcutOptions
                                    currentIndex: Chiaki.settings.dpadTouchShortcut3
                                    onActivated: index => Chiaki.settings.dpadTouchShortcut3 = index
                                    KeyNavigation.up: touchIncrement
                                    KeyNavigation.down: posButtons
                                    KeyNavigation.left: dpadShortcut2
                                    KeyNavigation.right: dpadShortcut4
                                }

                                C.ComboBox {
                                    id: dpadShortcut4
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 110
                                    implicitContentWidthPolicy: ComboBox.ContentItemImplicitWidth
                                    model: controllersLayout.dpadShortcutOptions
                                    currentIndex: Chiaki.settings.dpadTouchShortcut4
                                    onActivated: index => Chiaki.settings.dpadTouchShortcut4 = index
                                    KeyNavigation.up: touchIncrement
                                    KeyNavigation.down: posButtons
                                    KeyNavigation.left: dpadShortcut3
                                }
                            }

                            Label {
                                Layout.preferredWidth: controllersLayout.stateColumnWidth
                                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                                color: root.zanithMuted
                                wrapMode: Text.WordWrap
                                text: {
                                    const a = Chiaki.settings.dpadTouchShortcut1;
                                    const b = Chiaki.settings.dpadTouchShortcut2;
                                    const c = Chiaki.settings.dpadTouchShortcut3;
                                    const d = Chiaki.settings.dpadTouchShortcut4;
                                    const value = Chiaki.settings.stringForDpadShortcut();
                                    return "(" + translateShortcutString(value) + ")";
                                }
                                visible: Chiaki.settings.dpadTouchEnabled
                            }

                            Label {
                                Layout.preferredWidth: controllersLayout.labelColumnWidth
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                                text: root.zt("Buttons By Position:", "Botões por posição:")
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                C.CheckBox {
                                    id: posButtons
                                    checked: Chiaki.settings.buttonsByPosition
                                    onToggled: Chiaki.settings.buttonsByPosition = checked
                                    KeyNavigation.up: Chiaki.settings.dpadTouchEnabled ? dpadShortcut1 : dpadTouch
                                    KeyNavigation.down: rumbleHaptics
                                }
                                Label {
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    wrapMode: Text.WordWrap
                                    text: root.zt("Use buttons by position instead of by label", "Usar botões pela posição em vez do nome")
                                }
                            }

                            Label {
                                Layout.preferredWidth: controllersLayout.stateColumnWidth
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                color: root.zanithMuted
                                text: posButtons.checked ? root.zt("(Checked)", "(Marcado)") : root.zt("(Unchecked)", "(Desmarcado)")
                            }

                            Label {
                                Layout.preferredWidth: controllersLayout.labelColumnWidth
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                                text: root.zt("Rumble Haptics:", "Vibração/Haptics:")
                            }

                            C.ComboBox {
                                id: rumbleHaptics
                                Layout.fillWidth: true
                                Layout.minimumWidth: 260
                                Layout.maximumWidth: 440
                                model: [root.zt("Off", "Desligado"), root.zt("Very Weak", "Muito fraco"), root.zt("Weak", "Fraco"), root.zt("Normal", "Normal"), root.zt("Strong", "Forte"), root.zt("Very Strong", "Muito forte")]
                                currentIndex: Chiaki.settings.rumbleHapticsIntensity
                                onActivated: index => Chiaki.settings.rumbleHapticsIntensity = index
                            }

                            Label {
                                Layout.preferredWidth: controllersLayout.stateColumnWidth
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                color: root.zanithMuted
                                text: "(" + rumbleHaptics.currentText + ")"
                            }

                            Label {
                                Layout.preferredWidth: controllersLayout.labelColumnWidth
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                                text: root.zt("True Haptics Intensity:", "Intensidade dos haptics reais:")
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                spacing: 12

                                C.Slider {
                                    id: hapticOverride
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 220
                                    from: 0
                                    to: 2
                                    stepSize: 0.1
                                    value: Chiaki.settings.hapticOverride
                                    onMoved: Chiaki.settings.hapticOverride = value
                                    lastInFocusChain: true
                                }

                                Label {
                                    Layout.preferredWidth: 190
                                    wrapMode: Text.WordWrap
                                    text: {
                                        if (hapticOverride.value > 0.99 && hapticOverride.value < 1.01)
                                            return root.zt("console setting", "configuração do console");
                                        return (hapticOverride.value * 100).toFixed(0) + root.zt(" % console setting", " % da configuração do console");
                                    }
                                }
                            }

                            Label {
                                Layout.preferredWidth: controllersLayout.stateColumnWidth
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                color: root.zanithMuted
                                wrapMode: Text.WordWrap
                                text: root.zt("(console setting)", "(configuração do console)")
                            }
                        }
                    }
                }
            }

            Item {
                // Remote (PSN and Hole Punching)
                Flickable {
                    id: remoteFlick
                    anchors {
                        fill: parent
                        topMargin: 20
                        bottomMargin: 20
                    }
                    clip: true
                    contentWidth: Math.max(width, remoteGrid.width)
                    contentHeight: remoteGrid.y + remoteGrid.height
                    flickableDirection: Flickable.AutoFlickIfNeeded
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AlwaysOn
                        visible: remoteFlick.contentHeight > remoteFlick.height
                    }
                    GridLayout {
                        id: remoteGrid
                        anchors {
                            top: parent.top
                            horizontalCenter: parent.horizontalCenter
                            topMargin: 30
                        }
                        columns: 3
                        rowSpacing: 20
                        columnSpacing: 10

                        C.Button {
                            id: openPsnLogin
                            firstInFocusChain: visible
                            Layout.alignment: Qt.AlignHCenter
                            Layout.columnSpan: 3

                            text: root.zt("Login to PSN", "Entrar na PSN")
                            onClicked: {
                                root.showPSNTokenDialog(false)
                            }
                            Material.roundedScale: Material.SmallScale
                            visible: !Chiaki.settings.psnRefreshToken || !Chiaki.settings.psnAuthToken || !Chiaki.settings.psnAuthTokenExpiry || !Chiaki.settings.psnAccountId
                        }

                        C.Button {
                            id: resetPsnTokens
                            topPadding: 26
                            leftPadding: 30
                            rightPadding: 30
                            bottomPadding: 26
                            text: root.zt("Clear PSN Token", "Limpar token da PSN")
                            firstInFocusChain: !openPsnLogin.visible
                            Layout.alignment: Qt.AlignHCenter
                            Layout.columnSpan: 3
                            onClicked: {
                                Chiaki.settings.psnRefreshToken = ""
                                Chiaki.settings.psnAuthToken = ""
                                Chiaki.settings.psnAuthTokenExpiry = ""
                                Chiaki.settings.psnAccountId = ""
                                openPsnLogin.forceActiveFocus(Qt.TabFocusReason);
                            }
                            Material.roundedScale: Material.SmallScale
                            visible: Chiaki.settings.psnRefreshToken && Chiaki.settings.psnAuthToken && Chiaki.settings.psnAuthTokenExpiry && Chiaki.settings.psnAccountId
                        }


                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("Hole Punching Port Guessing:", "Tentativa de portas para Hole Punching:")
                        }

                        C.CheckBox {
                            id: holePunchGuessingCheckbox
                            text: root.zt("Force STUN port guessing", "Forçar tentativa de portas STUN")
                            checked: Chiaki.settings.portGuessingEnabled
                            onToggled: Chiaki.settings.portGuessingEnabled = checked
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("(Unchecked)", "(Desmarcado)")
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("Port Guess Count:", "Quantidade de portas testadas:")
                        }

                        C.Slider {
                            id: portGuessCountSlider
                            Layout.preferredWidth: 250
                            from: 0
                            to: 75
                            stepSize: 1
                            value: Chiaki.settings.portGuessCount
                            onMoved: Chiaki.settings.portGuessCount = value

                            Label {
                                anchors {
                                    left: parent.right
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 10
                                }
                                text: parent.value + root.zt(" guesses", " tentativas")
                            }
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            Layout.leftMargin: 100
                            text: root.zt("(75)", "(75)")
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("Port Guess Socket Count:", "Quantidade de sockets testados:")
                        }

                        C.Slider {
                            id: portGuessSocketSlider
                            Layout.preferredWidth: 250
                            from: 0
                            to: 500
                            stepSize: 1
                            value: Chiaki.settings.portGuessSocketCount
                            onMoved: Chiaki.settings.portGuessSocketCount = value
                            lastInFocusChain: true

                            Label {
                                anchors {
                                    left: parent.right
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 10
                                }
                                text: parent.value + root.zt(" sockets", " sockets")
                            }
                        }

                        Label {
                            Layout.alignment: Qt.AlignRight
                            text: root.zt("(250)", "(250)")
                            Layout.leftMargin: 100
                        }
                    }
                }
            }

            Item {
                // Config (Options such as Import/Export and Logging)
                Flickable {
                    id: configFlick
                    anchors {
                        fill: parent
                        topMargin: 20
                        bottomMargin: 20
                    }
                    clip: true
                    contentWidth: Math.max(width, configGrid.width)
                    contentHeight: configGrid.y + configGrid.height
                    flickableDirection: Flickable.AutoFlickIfNeeded
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AlwaysOn
                        visible: configFlick.contentHeight > configFlick.height
                    }
                    GridLayout {
                        id: configGrid
                        anchors {
                            top: parent.top
                            horizontalCenter: parent.horizontalCenter
                            topMargin: 30
                        }
                        columns: 1
                        rowSpacing: 20
                        columnSpacing: 10

                        Label {
                            text: {
                                if(Chiaki.settings.currentProfile)
                                    root.zt("Current Profile: ", "Perfil atual: ") + Chiaki.settings.currentProfile
                                else
                                    root.zt("Current Profile: default", "Perfil atual: padrão")
                            }
                        }

                        C.Button {
                            id: profile
                            firstInFocusChain: true
                            text: root.zt("Manage Profiles", "Gerenciar perfis")
                            onClicked: {
                                root.showProfileDialog()
                            }
                            Material.roundedScale: Material.SmallScale
                        }

                    C.Button {
                        id: exportButton
                        text: root.zt("Export settings to file", "Exportar configurações")
                        onClicked: {
                            Chiaki.settings.exportSettings();
                        }
                        Material.roundedScale: Material.SmallScale
                    }

                    C.Button {
                        id: importButton
                        text: root.zt("Import settings from file", "Importar configurações")
                        onClicked: {
                            Chiaki.settings.importSettings();
                        }
                        Material.roundedScale: Material.SmallScale
                    }

                    C.Button {
                        id: aboutButton
                        text: root.zt("About Zanith", "Sobre o Zanith")
                        onClicked: aboutDialog.open()
                        Material.roundedScale: Material.SmallScale
                    }

                    C.CheckBox {
                        text: root.zt("Sanitize Logs (checked)", "Sanitizar logs (marcado)")
                        checked: Chiaki.settings.logSanitize
                        onToggled: Chiaki.settings.logSanitize = checked
                    }

                        C.CheckBox {
                            text: root.zt("Verbose Logging (unchecked)", "Log detalhado (desmarcado)")
                            checked: Chiaki.settings.logVerbose
                            lastInFocusChain: true
                            onToggled: Chiaki.settings.logVerbose = checked
                        }
                    }
                }
            }
        }

        Connections {
            target: dialog.Window.window
            function onActiveFocusItemChanged() {
                dialog.ensureActiveFocusVisible()
            }
        }

        Item {
            Timer {
                id: openTimer
                interval: 100
                running: false
                onTriggered: {
                    if(controllerMappingDialog.resetMapping)
                    {
                        if(!Chiaki.controllerMappingDefaultMapping)
                        {
                            quitControllerMapping = false;
                            Chiaki.controllerMappingReset();
                        }
                        controllerMappingDialog.close();
                    }
                    else
                    {
                        controllerMappingChange.forceActiveFocus(Qt.TabFocusReason);
                        root.showControllerMappingDialog();
                        quitControllerMapping = false;
                        controllerMappingDialog.resetFocus = false;
                        controllerMappingDialog.close();
                    }
                }
            }
        }

        Dialog {
            id: aboutDialog
            parent: Overlay.overlay
            x: Math.round((root.width - width) / 2)
            y: Math.round((root.height - height) / 2)
            title: root.zt("About Zanith", "Sobre o Zanith")
            modal: true
            standardButtons: Dialog.Ok
            Material.roundedScale: Material.MediumScale
            onAboutToHide: aboutButton.forceActiveFocus(Qt.TabFocusReason)

            RowLayout {
                spacing: 50
                onVisibleChanged: if (visible) forceActiveFocus(Qt.TabFocusReason)
                Keys.onReturnPressed: aboutDialog.close()
                Keys.onEscapePressed: aboutDialog.close()

                Image {
                    Layout.preferredWidth: 200
                    fillMode: Image.PreserveAspectFit
                    verticalAlignment: Image.AlignTop
                    source: "qrc:/icons/zanith-logo.svg"
                }

                Label {
                    Layout.preferredWidth: 400
                    verticalAlignment: Text.AlignTop
                    wrapMode: Text.Wrap
                    text: root.zt(
                        "<h1>Zanith</h1> version %1" +
                        "<p>Modified user interface based on <b>chiaki-ng</b> by Street Pea, itself based on Chiaki by Florian Märkl.</p>" +
                        "<p>This modified build is distributed under the GNU Affero General Public License v3. " +
                        "Original copyright and license notices are preserved in the source package.</p>" +
                        "<p>This project is not endorsed by Sony Interactive Entertainment.</p>",
                        "<h1>Zanith</h1> versão %1" +
                        "<p>Interface modificada baseada no <b>chiaki-ng</b> de Street Pea, que por sua vez é baseado no Chiaki de Florian Märkl.</p>" +
                        "<p>Esta versão modificada é distribuída sob a GNU Affero General Public License v3. " +
                        "Os avisos originais de copyright e licença são preservados no pacote do código-fonte.</p>" +
                        "<p>Este projeto não é endossado pela Sony Interactive Entertainment.</p>").arg(Qt.application.version)
                }
            }
        }

        Dialog {
            id: keyDialog
            focus: false
            property int buttonValue
            property var buttonCallback
            property var keysIndex
            parent: Overlay.overlay
            x: Math.round((root.width - width) / 2)
            y: Math.round((root.height - height) / 2)
            title: root.zt("Key Capture", "Captura de tecla")
            modal: true
            standardButtons: Dialog.Close
            closePolicy: Popup.CloseOnPressOutside
            onOpened: keyLabel.forceActiveFocus(Qt.TabFocusReason)
            onClosed: {
                let item = chiakiKeys.itemAt(keysIndex)
                if(item)
                {
                    let item2 = item.children[1];
                    if(item2)
                        item2.forceActiveFocus(Qt.TabFocusReason);
                }
                keyLabel.focus = false;
                focus = false;
            }
            Material.roundedScale: Material.MediumScale

            function show(opts) {
                buttonValue = opts.value;
                buttonCallback = opts.callback;
                keysIndex = opts.mappingIndex;
                open();
            }

            Label {
                id: keyLabel
                focus: true
                text: root.zt("Press any key to configure button or click close", "Pressione qualquer tecla para configurar o botão ou clique em fechar")
                Keys.onReleased: (event) => {
                    var name = Chiaki.settings.changeControllerKey(keyDialog.buttonValue, event.key);
                    keyDialog.buttonCallback(name);
                    keyDialog.close();
                }
            }
        }

        Dialog {
            id: controllerMappingDialog
            property bool resetFocus: true
            property bool resetMapping: false
            parent: Overlay.overlay
            x: Math.round((root.width - width) / 2)
            y: Math.round((root.height - height) / 2)
            title: root.zt("Controller Capture", "Captura do controle")
            modal: true
            standardButtons: Dialog.Close
            closePolicy: Popup.CloseOnPressOutside
            onOpened: {
                controllerLabel.forceActiveFocus(Qt.TabFocusReason);
                Chiaki.beginControllerMapping(resetMapping);
            }
            onClosed: {
                if(resetFocus)
                {
                    if(resetMapping)
                        controllerMappingReset.forceActiveFocus(Qt.TabFocusReason);
                    else
                        controllerMappingChange.forceActiveFocus(Qt.TabFocusReason);
                    focus = false;
                }
                else
                {
                    resetFocus = true;
                    focus = false;
                }
                if(quitControllerMapping)
                    Chiaki.controllerMappingQuit();
                else
                    quitControllerMapping = true;
            }
            Material.roundedScale: Material.MediumScale

            function show(opts) {
                resetMapping = opts.reset;
                open();
            }
            Label {
                id: controllerLabel
                text: root.zt("Choose the controller by pressing any button on the controller", "Escolha o controle pressionando qualquer botão nele")
            }
        }

        Dialog {
            id: steamControllerMappingDialog
            property bool resetMapping: false
            parent: Overlay.overlay
            x: Math.round((root.width - width) / 2)
            y: Math.round((root.height - height) / 2)
            title: root.zt("Controller Managed by Steam", "Controle gerenciado pelo Steam")
            modal: true
            standardButtons: Dialog.Close
            closePolicy: Popup.NoAutoClose
            onOpened: {
                steamLabel.forceActiveFocus(Qt.TabFocusReason);
            }
            onClosed: {
                if(resetMapping)
                    controllerMappingReset.forceActiveFocus(Qt.TabFocusReason);
                else
                    controllerMappingChange.forceActiveFocus(Qt.TabFocusReason);
                focus = false;
            }
            Material.roundedScale: Material.MediumScale

            Label {
                id: steamLabel
                wrapMode: TextEdit.Wrap
                text: root.zt("This controller is managed by Steam.\nPlease use Steam to map controller or disable Steam Input for the controller before mapping here.", "Este controle é gerenciado pela Steam.\nUse a Steam para mapear o controle ou desative o Steam Input para esse controle antes de mapear aqui.")
                Keys.onReturnPressed: steamControllerMappingDialog.close();
                Keys.onEscapePressed: steamControllerMappingDialog.close();
            }
        }

        Connections {
            target: Chiaki

            function onControllerMappingInProgressChanged()
            {
                if(Chiaki.controllerMappingInProgress)
                    openTimer.start();
            }

            function onControllerMappingSteamControllerSelected()
            {
                controllerMappingDialog.resetFocus = false;
                quitControllerMapping = false;
                steamControllerMappingDialog.resetMapping = controllerMappingDialog.resetMapping;
                controllerMappingDialog.close();
                steamControllerMappingDialog.open();
            }
        }
    }
}
