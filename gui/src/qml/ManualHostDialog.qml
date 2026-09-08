import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import org.streetpea.chiaking

import "controls" as C

DialogView {
    title: root.zt("Add Manual Console", "Adicionar console manualmente")
    buttonText: root.zt("Add", "Adicionar")
    buttonEnabled: hostField.text.trim() && (consoleCombo.model[consoleCombo.currentIndex].index != -1)
    onAccepted: {
        Chiaki.addManualHost(consoleCombo.model[consoleCombo.currentIndex].index, hostField.text.trim());
        close();
    }

    Item {
        GridLayout {
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                topMargin: 20
            }
            columns: 2
            rowSpacing: 20
            columnSpacing: 20

            Label {
                Layout.alignment: Qt.AlignRight
                text: root.zt("Host:", "Host:")
            }

            C.TextField {
                id: hostField
                echoMode: Chiaki.settings.streamerMode ? TextInput.Password : TextInput.Normal
                Layout.preferredWidth: 400
                firstInFocusChain: true
            }

            Label {
                Layout.alignment: Qt.AlignRight
                text: root.zt("Registered Consoles:", "Consoles registrados:")
            }

            C.ComboBox {
                id: consoleCombo
                Layout.preferredWidth: 400
                lastInFocusChain: true
                textRole: "name"
                model: {
                    let m = [];
                    if(Chiaki.settings.registeredHosts.length > 0)
                    {
                        m.push({
                            name: root.zt("Select an Option", "Selecione uma opção"),
                            index: -1,
                        });
                    }
                    let i = 0;
                    for (; i < Chiaki.settings.registeredHosts.length; ++i) {
                        let host = Chiaki.settings.registeredHosts[i];
                        m.push({
                            name: "%1 (%2)".arg(Chiaki.settings.streamerMode ? "hidden" : host.mac).arg(host.name),
                            index: i,
                        });
                    }
                    m.push({
                        name: root.zt("Register on first Connection", "Registrar na primeira conexão"),
                        index: i,
                    });
                    return m;
                }
            }
        }
    }
}
