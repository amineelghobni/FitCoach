import QtQuick
import FitCoach

Item {
    Theme { id: theme }

    signal splashTermine()

    Rectangle {
        anchors.fill: parent
        color: "#0A0E17"

        // ── Particules flottantes ─────────────
        Repeater {
            model: 12

            Rectangle {
                property real startX: Math.random() * 390
                property real startY: Math.random() * 844
                property real taille: 2 + Math.random() * 4

                x: startX
                y: startY
                width: taille
                height: taille
                radius: taille / 2
                color: index % 3 === 0 ? "#00D4AA" :
                       index % 3 === 1 ? "#4FACFE" : "#FFFFFF"
                opacity: 0.2

                SequentialAnimation on opacity {
                    running: true
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.6; duration: 1200 + index * 200; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 0.1; duration: 1200 + index * 200; easing.type: Easing.InOutSine }
                }

                SequentialAnimation on y {
                    running: true
                    loops: Animation.Infinite
                    NumberAnimation { to: startY - 30; duration: 2500 + index * 300; easing.type: Easing.InOutSine }
                    NumberAnimation { to: startY;      duration: 2500 + index * 300; easing.type: Easing.InOutSine }
                }
            }
        }

        // ── Glow derrière le logo ─────────────
        Item {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -50

            Rectangle {
                anchors.centerIn: parent
                width: 200
                height: 200
                radius: 100
                color: "#00D4AA"
                opacity: 0.06

                SequentialAnimation on width {
                    running: true
                    loops: Animation.Infinite
                    NumberAnimation { to: 220; duration: 1600; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 180; duration: 1600; easing.type: Easing.InOutSine }
                }
                SequentialAnimation on height {
                    running: true
                    loops: Animation.Infinite
                    NumberAnimation { to: 220; duration: 1600; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 180; duration: 1600; easing.type: Easing.InOutSine }
                }
                SequentialAnimation on opacity {
                    running: true
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.12; duration: 1600 }
                    NumberAnimation { to: 0.04; duration: 1600 }
                }
            }

            Rectangle {
                anchors.centerIn: parent
                width: 120
                height: 120
                radius: 60
                color: "#00D4AA"
                opacity: 0.08
            }

            // ── Logo ──────────────────────────
            Rectangle {
                id: logoCard
                width: 96
                height: 96
                radius: 26
                color: "#00D4AA"
                anchors.centerIn: parent
                opacity: 0
                scale: 0.6

                Rectangle {
                    width: parent.width * 0.45
                    height: parent.height
                    color: "white"
                    opacity: 0.1
                    radius: 26
                    anchors.left: parent.left
                }

                Text {
                    text: "💪"
                    font.pixelSize: 48
                    anchors.centerIn: parent
                }

                ParallelAnimation {
                    running: true
                    NumberAnimation {
                        target: logoCard
                        property: "opacity"
                        from: 0; to: 1
                        duration: 700
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: logoCard
                        property: "scale"
                        from: 0.6; to: 1.0
                        duration: 700
                        easing.type: Easing.OutBack
                    }
                }
            }
        }

        // ── Texte ─────────────────────────────
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 70
            spacing: 10
            opacity: 0

            SequentialAnimation on opacity {
                running: true
                PauseAnimation  { duration: 500 }
                NumberAnimation { to: 1; duration: 700; easing.type: Easing.OutCubic }
            }

            Text {
                text: "FitCoach"
                color: "white"
                font.pixelSize: 38
                font.bold: true
                font.letterSpacing: 3
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Row {
                spacing: 6
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 20; height: 2; radius: 1
                    color: "#00D4AA"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "Ton coach IA personnel"
                    color: "#00D4AA"
                    font.pixelSize: 13
                    font.letterSpacing: 1
                }
                Rectangle {
                    width: 20; height: 2; radius: 1
                    color: "#00D4AA"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // ── Barre de progression ──────────────
        Item {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 90
            anchors.horizontalCenter: parent.horizontalCenter
            width: 180
            height: 20
            opacity: 0

            SequentialAnimation on opacity {
                running: true
                PauseAnimation  { duration: 900 }
                NumberAnimation { to: 1; duration: 500; easing.type: Easing.OutCubic }
            }

            Rectangle {
                width: parent.width
                height: 3
                radius: 2
                color: "#1e2e40"
                anchors.centerIn: parent
            }

            Rectangle {
                id: progressBar
                width: 0
                height: 3
                radius: 2
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#4FACFE" }
                    GradientStop { position: 1.0; color: "#00D4AA" }
                }

                SequentialAnimation on width {
                    running: true
                    PauseAnimation  { duration: 900 }
                    NumberAnimation { to: 180; duration: 2000; easing.type: Easing.InOutCubic }
                }

                Rectangle {
                    width: 12; height: 12; radius: 6
                    color: "#00D4AA"
                    opacity: 0.6
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    SequentialAnimation on opacity {
                        running: progressBar.width > 10
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.9; duration: 400 }
                        NumberAnimation { to: 0.3; duration: 400 }
                    }
                }
            }
        }

        // ── Version ───────────────────────────
        Text {
            text: "v1.0.0"
            color: "#2a3a4a"
            font.pixelSize: 11
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    // ── Timer — déclenche le signal ───────────
    Timer {
        interval: 3000
        running: true
        repeat: false
        onTriggered: splashTermine()
    }
}