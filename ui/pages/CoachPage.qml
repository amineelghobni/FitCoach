import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FitCoach

Item {
    Theme { id: theme }

    property bool showClearConfirm: false

    Rectangle {
        anchors.fill: parent
        color: theme.bgPrimary

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ── Header ────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 80
                color: theme.bgPrimary

                // Glow top
                Rectangle {
                    anchors.top: parent.top
                    width: parent.width
                    height: 2
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.3; color: theme.accent }
                        GradientStop { position: 0.7; color: "#4FACFE" }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                Row {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 14

                    // Avatar coach
                    Rectangle {
                        width: 44
                        height: 44
                        radius: 22
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#00D4AA" }
                            GradientStop { position: 1.0; color: "#4FACFE" }
                        }
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: "🤖"
                            font.pixelSize: 22
                            anchors.centerIn: parent
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        width: parent.width - 44 - 42 - 28

                        Text {
                            text: "Coach IA"
                            color: theme.textPrimary
                            font.pixelSize: theme.fontLG
                            font.bold: true
                        }
                        Row {
                            spacing: 6

                            Rectangle {
                                width: 8; height: 8; radius: 4
                                color: theme.accentGreen
                                anchors.verticalCenter: parent.verticalCenter

                                SequentialAnimation on opacity {
                                    running: true
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 0.3; duration: 1000 }
                                    NumberAnimation { to: 1.0; duration: 1000 }
                                }
                            }
                            Text {
                                text: "En ligne"
                                color: theme.accentGreen
                                font.pixelSize: theme.fontSM
                            }
                        }
                    }

                    // Bouton effacer
                    Rectangle {
                        width: 38
                        height: 38
                        radius: 10
                        color: "#2e0d0d"
                        border.color: "#FF6B6B44"
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: "🗑️"
                            font.pixelSize: 16
                            anchors.centerIn: parent
                        }

                        scale: clearBtnArea.pressed ? 0.9 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        MouseArea {
                            id: clearBtnArea
                            anchors.fill: parent
                            onClicked: showClearConfirm = true
                        }
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: theme.border
                }
            }

            // ── Messages ──────────────────────
            ListView {
                id: chatList
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 4
                clip: true
                bottomMargin: 8
                topMargin: 8

                model: coachVM.messages

                onCountChanged: Qt.callLater(() => positionViewAtEnd())

                delegate: Item {
                    width: ListView.view.width
                    height: msgRow.implicitHeight + 12

                    // ── Message Assistant ──────
                    Row {
                        id: msgRow
                        visible: msgRole === "assistant"
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8
                        width: parent.width * 0.85

                        opacity: 0
                        SequentialAnimation on opacity {
                            running: true
                            PauseAnimation  { duration: 50 }
                            NumberAnimation { from: 0; to: 1; duration: 300; easing.type: Easing.OutCubic }
                        }

                        Rectangle {
                            width: 32; height: 32; radius: 16
                            color: theme.accent
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 4

                            Text {
                                text: "🤖"
                                font.pixelSize: 16
                                anchors.centerIn: parent
                            }
                        }

                        Column {
                            spacing: 4

                            Rectangle {
                                width: Math.min(
                                    msgText.implicitWidth + 24,
                                    chatList.width * 0.72
                                )
                                height: msgText.implicitHeight + 16
                                radius: 18
                                topLeftRadius: 4
                                color: theme.bgCard
                                border.color: theme.border
                                border.width: 1

                                Text {
                                    id: msgText
                                    text: contenu
                                    color: theme.textPrimary
                                    font.pixelSize: theme.fontSM
                                    wrapMode: Text.WordWrap
                                    width: Math.min(
                                        implicitWidth,
                                        chatList.width * 0.72 - 24
                                    )
                                    anchors.centerIn: parent
                                    lineHeight: 1.5
                                }
                            }

                            Text {
                                text: heure
                                color: theme.textHint
                                font.pixelSize: 10
                                leftPadding: 4
                            }
                        }
                    }

                    // ── Message User ───────────
                    Row {
                        visible: msgRole === "user"
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        layoutDirection: Qt.RightToLeft
                        spacing: 8

                        opacity: 0
                        SequentialAnimation on opacity {
                            running: true
                            PauseAnimation  { duration: 50 }
                            NumberAnimation { from: 0; to: 1; duration: 300; easing.type: Easing.OutCubic }
                        }

                        Column {
                            spacing: 4

                            Rectangle {
                                width: Math.min(
                                    userText.implicitWidth + 24,
                                    chatList.width * 0.72
                                )
                                height: userText.implicitHeight + 16
                                radius: 18
                                topRightRadius: 4
                                color: theme.accent
                                anchors.right: parent.right

                                Text {
                                    id: userText
                                    text: contenu
                                    color: "white"
                                    font.pixelSize: theme.fontSM
                                    wrapMode: Text.WordWrap
                                    width: Math.min(
                                        implicitWidth,
                                        chatList.width * 0.72 - 24
                                    )
                                    anchors.centerIn: parent
                                    lineHeight: 1.5
                                }
                            }

                            Text {
                                text: heure
                                color: theme.textHint
                                font.pixelSize: 10
                                anchors.right: parent.right
                                rightPadding: 4
                            }
                        }
                    }
                }
            }

            // ── Indicateur chargement ─────────
            Item {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                height: coachVM.loading ? 40 : 0
                visible: coachVM.loading

                Behavior on height {
                    NumberAnimation { duration: 200 }
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Rectangle {
                        width: 32; height: 32; radius: 16
                        color: theme.accent

                        Text {
                            text: "🤖"
                            font.pixelSize: 16
                            anchors.centerIn: parent
                        }
                    }

                    Rectangle {
                        width: 60; height: 32
                        radius: 16
                        color: theme.bgCard
                        border.color: theme.border
                        border.width: 1

                        Row {
                            anchors.centerIn: parent
                            spacing: 4

                            Repeater {
                                model: 3
                                Rectangle {
                                    width: 6; height: 6; radius: 3
                                    color: theme.textHint

                                    SequentialAnimation on y {
                                        running: coachVM.loading
                                        loops: Animation.Infinite
                                        NumberAnimation {
                                            to: -4
                                            duration: 300 + index * 100
                                            easing.type: Easing.OutQuad
                                        }
                                        NumberAnimation {
                                            to: 0
                                            duration: 300 + index * 100
                                            easing.type: Easing.InQuad
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── Suggestions ───────────────────
            ScrollView {
                Layout.fillWidth: true
                height: 52
                visible: true
                clip: true

                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy:   ScrollBar.AlwaysOff

                Row {
                    spacing: 8
                    leftPadding: 16
                    rightPadding: 16

                    Repeater {
                        model: [
                            "Mon programme 💪",
                            "Analyse mes repas 🥗",
                            "Conseils récup 😴",
                            "Objectif semaine 🎯"
                        ]

                        Rectangle {
                            height: 36
                            width: suggText.implicitWidth + 20
                            radius: 18
                            color: theme.bgCard
                            border.color: theme.accent
                            border.width: 1

                            Text {
                                id: suggText
                                text: modelData
                                color: theme.accent
                                font.pixelSize: theme.fontSM
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: coachVM.envoyerMessage(modelData)
                            }
                        }
                    }
                }
            }

            // ── Zone de saisie ────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: 12
                Layout.bottomMargin: 12
                height: 52
                radius: 26
                color: theme.bgCard
                border.color: messageInput.activeFocus
                              ? theme.accent : theme.border
                border.width: 1

                Behavior on border.color {
                    ColorAnimation { duration: 200 }
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 8
                    spacing: 8

                    TextField {
                        id: messageInput
                        width: parent.width - 52
                        height: parent.height
                        placeholderText: "Message..."
                        color: theme.textPrimary
                        placeholderTextColor: theme.textHint
                        font.pixelSize: theme.fontSM
                        background: Rectangle { color: "transparent" }

                        Keys.onReturnPressed: {
                            if (text.trim() !== "") {
                                coachVM.envoyerMessage(text)
                                text = ""
                            }
                        }
                    }

                    Rectangle {
                        width: 40; height: 40; radius: 20
                        anchors.verticalCenter: parent.verticalCenter
                        color: messageInput.text.trim() !== ""
                               ? theme.accent : theme.bgInput

                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            text: "↑"
                            color: "white"
                            font.pixelSize: 18
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        scale: sendArea.pressed ? 0.9 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        MouseArea {
                            id: sendArea
                            anchors.fill: parent
                            onClicked: {
                                if (messageInput.text.trim() !== "") {
                                    coachVM.envoyerMessage(messageInput.text)
                                    messageInput.text = ""
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Popup confirmation effacer ────────
        Rectangle {
            anchors.fill: parent
            color: "#CC000000"
            visible: showClearConfirm
            z: 30

            MouseArea { anchors.fill: parent }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 64
                height: clearCol.implicitHeight + 40
                radius: theme.radiusLG
                color: theme.bgCard
                border.color: theme.border
                border.width: 1

                ColumnLayout {
                    id: clearCol
                    anchors.centerIn: parent
                    width: parent.width - 40
                    spacing: 16

                    Text {
                        text: "🗑️"
                        font.pixelSize: 36
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: "Effacer la conversation ?"
                        color: theme.textPrimary
                        font.pixelSize: theme.fontLG
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        text: "Tous les messages seront supprimés définitivement."
                        color: theme.textSecondary
                        font.pixelSize: theme.fontSM
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    Row {
                        Layout.fillWidth: true
                        spacing: 12

                        Rectangle {
                            width: (parent.width - 12) / 2
                            height: 48
                            radius: theme.radiusMD
                            color: theme.bgInput
                            border.color: theme.border
                            border.width: 1

                            Text {
                                text: "Annuler"
                                color: theme.textPrimary
                                font.pixelSize: theme.fontMD
                                font.bold: true
                                anchors.centerIn: parent
                            }

                            scale: cancelClear.pressed ? 0.97 : 1.0
                            Behavior on scale { NumberAnimation { duration: 100 } }

                            MouseArea {
                                id: cancelClear
                                anchors.fill: parent
                                onClicked: showClearConfirm = false
                            }
                        }

                        Rectangle {
                            width: (parent.width - 12) / 2
                            height: 48
                            radius: theme.radiusMD
                            color: "#FF6B6B"

                            Text {
                                text: "Effacer"
                                color: "white"
                                font.pixelSize: theme.fontMD
                                font.bold: true
                                anchors.centerIn: parent
                            }

                            scale: confirmClear.pressed ? 0.97 : 1.0
                            Behavior on scale { NumberAnimation { duration: 100 } }

                            MouseArea {
                                id: confirmClear
                                anchors.fill: parent
                                onClicked: {
                                    coachVM.clearChat()
                                    showClearConfirm = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}