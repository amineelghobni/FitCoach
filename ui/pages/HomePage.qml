import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FitCoach

Item {
    Theme { id: theme }

    Rectangle {
        anchors.fill: parent
        color: theme.bgPrimary

        ScrollView {
            anchors.fill: parent
            contentWidth: parent.width
            clip: true

            ColumnLayout {
                width: parent.parent.width
                spacing: 0

                // ── Hero Header ───────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    color: theme.bgCard
                    height: heroCol.implicitHeight + 32
                    border.color: theme.border
                    border.width: 1

                    // Glow accent top
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

                    ColumnLayout {
                        id: heroCol
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 16

                        // ── Ligne top ──
                        Row {
                            Layout.fillWidth: true

                            Column {
                                spacing: 4
                                width: parent.width - 52

                                Text {
                                    text: Qt.formatDate(new Date(), "dddd dd MMMM yyyy")
                                    color: theme.textHint
                                    font.pixelSize: theme.fontSM
                                }
                                Text {
                                    text: homeVM.userNom + " 👋"
                                    color: theme.textPrimary
                                    font.pixelSize: 22
                                    font.bold: true
                                }
                            }

                            Rectangle {
                                width: 44
                                height: 44
                                radius: 22
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: "#00D4AA" }
                                    GradientStop { position: 1.0; color: "#4FACFE" }
                                }

                                Text {
                                    text: homeVM.userNom.length > 0
                                          ? homeVM.userNom[0].toUpperCase() : "?"
                                    color: "white"
                                    font.pixelSize: 18
                                    font.bold: true
                                    anchors.centerIn: parent
                                }

                                scale: avatarArea.pressed ? 0.9 : 1.0
                                Behavior on scale { NumberAnimation { duration: 100 } }

                                MouseArea {
                                    id: avatarArea
                                    anchors.fill: parent
                                    onClicked: showProfile = true
                                }
                            }
                        }

                        // ── Ring + Macros ────────────────
                        Row {
                            Layout.fillWidth: true
                            spacing: 16

                            // Ring calories animé
                            Item {
                                width: 90
                                height: 90
                                anchors.verticalCenter: parent.verticalCenter

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 70; height: 70; radius: 35
                                    color: theme.accent
                                    opacity: 0.06
                                }

                                Canvas {
                                    id: caloriesCanvas
                                    anchors.fill: parent

                                    property real progress: 0
                                    property real targetProgress: Math.min(
                                        homeVM.calories / Math.max(homeVM.caloriesMax, 1), 1.0)

                                    NumberAnimation on progress {
                                        id: progressAnim
                                        from: 0
                                        to: caloriesCanvas.targetProgress
                                        duration: 1000
                                        easing.type: Easing.OutCubic
                                        running: true
                                    }

                                    onProgressChanged: requestPaint()
                                    onTargetProgressChanged: {
                                        progressAnim.from = 0
                                        progressAnim.to = targetProgress
                                        progressAnim.restart()
                                    }

                                    Component.onCompleted: requestPaint()

                                    onPaint: {
                                        var ctx = getContext("2d")
                                        ctx.clearRect(0, 0, width, height)
                                        var cx = width / 2
                                        var cy = height / 2
                                        var r  = 36

                                        // Track
                                        ctx.beginPath()
                                        ctx.arc(cx, cy, r, 0, Math.PI * 2)
                                        ctx.strokeStyle = "#1e2a3a"
                                        ctx.lineWidth = 8
                                        ctx.stroke()

                                        if (progress > 0) {
                                            var grad = ctx.createLinearGradient(0, 0, width, height)
                                            grad.addColorStop(0, "#4FACFE")
                                            grad.addColorStop(1, "#00D4AA")

                                            ctx.beginPath()
                                            ctx.arc(cx, cy, r,
                                                    -Math.PI / 2,
                                                    -Math.PI / 2 + progress * Math.PI * 2)
                                            ctx.strokeStyle = progress >= 1.0 ? "#FF6B6B" : grad
                                            ctx.lineWidth = 8
                                            ctx.lineCap = "round"
                                            ctx.stroke()
                                        }
                                    }

                                    Connections {
                                        target: homeVM
                                        function onDataChanged() {
                                            caloriesCanvas.targetProgress = Math.min(
                                                homeVM.calories / Math.max(homeVM.caloriesMax, 1), 1.0)
                                        }
                                    }
                                }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 1

                                    Text {
                                        text: homeVM.calories
                                        color: homeVM.calories >= homeVM.caloriesMax
                                               ? "#FF6B6B" : theme.textPrimary
                                        font.pixelSize: 17
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "kcal"
                                        color: theme.textHint
                                        font.pixelSize: 9
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }

                            // Macros
                            Column {
                                spacing: 8
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 90 - 16

                                Column {
                                    spacing: 2
                                    width: parent.width

                                    Text {
                                        text: homeVM.calories + " / " + homeVM.caloriesMax + " kcal"
                                        color: theme.textPrimary
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                    Text {
                                        text: homeVM.calories < homeVM.caloriesMax
                                              ? "Il te reste " + (homeVM.caloriesMax - homeVM.calories) + " kcal"
                                              : "Objectif atteint ! 🎉"
                                        color: homeVM.calories >= homeVM.caloriesMax
                                               ? theme.accent : theme.textSecondary
                                        font.pixelSize: 11
                                    }
                                }

                                // Calories brûlées
                                Row {
                                    spacing: 4
                                    visible: homeVM.caloriesBrulees > 0

                                    Text {
                                        text: "🔥"
                                        font.pixelSize: 11
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: homeVM.caloriesBrulees + " kcal brûlées"
                                        color: "#FF6B6B"
                                        font.pixelSize: 11
                                        font.bold: true
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                // Barres macros
                                Column {
                                    spacing: 5
                                    width: parent.width

                                    Repeater {
                                        model: [
                                            { label: "P", value: homeVM.proteines,
                                              max: homeVM.caloriesMax * 0.3 / 4, color: "#00D4AA" },
                                            { label: "G", value: homeVM.glucides,
                                              max: homeVM.caloriesMax * 0.5 / 4, color: "#4FACFE" },
                                            { label: "L", value: homeVM.lipides,
                                              max: homeVM.caloriesMax * 0.2 / 9, color: "#FF6B6B" }
                                        ]

                                        Row {
                                            width: parent.width
                                            spacing: 6

                                            Rectangle {
                                                width: parent.width - 36
                                                height: 4
                                                radius: 2
                                                color: "#1e2a3a"
                                                anchors.verticalCenter: parent.verticalCenter

                                                Rectangle {
                                                    width: Math.min(parent.width,
                                                           (modelData.value / Math.max(modelData.max, 1))
                                                           * parent.width)
                                                    height: parent.height
                                                    radius: 2
                                                    color: modelData.color

                                                    Behavior on width {
                                                        NumberAnimation { duration: 800; easing.type: Easing.OutCubic }
                                                    }
                                                }
                                            }
                                            Text {
                                                text: Math.round(modelData.value) + "g " + modelData.label
                                                color: modelData.color
                                                font.pixelSize: 10
                                                font.bold: true
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Bulle coach ───────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.margins: 16
                    Layout.topMargin: 16
                    radius: theme.radiusLG
                    height: coachRow.implicitHeight + 24
                    clip: true
                    border.color: "#00D4AA33"
                    border.width: 1

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#0d2e24" }
                        GradientStop { position: 1.0; color: "#0d1f2e" }
                    }

                    Row {
                        id: coachRow
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 12

                        Rectangle {
                            width: 36; height: 36; radius: 18
                            color: "#00D4AA22"
                            border.color: "#00D4AA44"
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: "🤖"
                                font.pixelSize: 18
                                anchors.centerIn: parent
                            }
                        }

                        Column {
                            spacing: 3
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 36 - 12

                            Text {
                                text: "COACH IA"
                                color: theme.accent
                                font.pixelSize: 9
                                font.bold: true
                                font.letterSpacing: 1.5
                            }
                            Text {
                                text: {
                                    var h = new Date().getHours()
                                    var cal = homeVM.calories
                                    var calMax = homeVM.caloriesMax
                                    var reste = calMax - cal
                                    var brules = homeVM.caloriesBrulees

                                    if (cal === 0) {
                                        if (h < 10) return "Bonjour " + homeVM.userNom + " ! Commence ta journée avec un bon petit-déjeuner 🌅"
                                        if (h < 14) return "Tu n'as pas encore mangé aujourd'hui. N'oublie pas de te nourrir ! 🍽️"
                                        return "La journée avance… pense à logger tes repas 📝"
                                    }
                                    if (brules > 0)
                                        return "Tu as brûlé " + brules + " kcal à l'entraînement 🔥 " +
                                               (reste > 0 ? "Il te reste " + reste + " kcal." : "Objectif atteint !")
                                    if (cal >= calMax)
                                        return "Tu as atteint ton objectif calorique aujourd'hui ! Bravo 🎉"
                                    return "Tu as consommé " + cal + " kcal. Il te reste " + reste + " kcal. Continue ! 💪"
                                }
                                color: theme.textSecondary
                                font.pixelSize: 12
                                wrapMode: Text.WordWrap
                                width: parent.width
                                lineHeight: 1.4
                            }
                        }
                    }
                }

                // ── Titre repas ───────────────────────
                Row {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.topMargin: 20

                    Text {
                        text: "REPAS D'AUJOURD'HUI"
                        color: theme.textHint
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: 60; height: 20; radius: 10
                        color: "#00D4AA22"
                        border.color: "#00D4AA44"
                        border.width: 1

                        Text {
                            text: nutritionVM.meals.rowCount() + " repas"
                            color: theme.accent
                            font.pixelSize: 10
                            font.bold: true
                            anchors.centerIn: parent
                        }
                    }
                }

                // ── Liste repas ───────────────────────
                ListView {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.topMargin: 10
                    height: contentHeight
                    interactive: false
                    spacing: 8
                    clip: true

                    model: nutritionVM.meals

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 68
                        radius: theme.radiusMD
                        color: theme.bgCard
                        border.color: theme.border
                        border.width: 1

                        opacity: 0
                        x: 20

                        SequentialAnimation on opacity {
                            running: true
                            PauseAnimation  { duration: index * 80 }
                            NumberAnimation { from: 0; to: 1; duration: 400; easing.type: Easing.OutCubic }
                        }
                        SequentialAnimation on x {
                            running: true
                            PauseAnimation  { duration: index * 80 }
                            NumberAnimation { from: 20; to: 0; duration: 400; easing.type: Easing.OutCubic }
                        }

                        Row {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            Rectangle {
                                width: 42; height: 42
                                radius: theme.radiusSM
                                color: theme.bgInput
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    font.pixelSize: 20
                                    text: {
                                        if (moment === "Petit-déjeuner") return "🌅"
                                        if (moment === "Déjeuner")       return "☀️"
                                        if (moment === "Collation")      return "🍎"
                                        if (moment === "Dîner")          return "🌙"
                                        return "🍽️"
                                    }
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 3
                                width: parent.width - 42 - 80 - 24

                                Text {
                                    text: nom
                                    color: theme.textPrimary
                                    font.pixelSize: theme.fontMD
                                    font.bold: true
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                                Text {
                                    text: moment + " · " + heure.substring(0, 5)
                                    color: theme.textSecondary
                                    font.pixelSize: theme.fontSM
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2

                                Text {
                                    text: calories + " kcal"
                                    color: theme.accent
                                    font.pixelSize: 12
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Text {
                                    text: Math.round(proteines) + "P · " +
                                          Math.round(glucides)  + "G · " +
                                          Math.round(lipides)   + "L"
                                    color: theme.textHint
                                    font.pixelSize: 9
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }

                    Item {
                        anchors.centerIn: parent
                        visible: nutritionVM.meals.rowCount() === 0
                        height: 80
                        width: parent.width

                        Column {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: "🍽️"
                                font.pixelSize: 32
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: "Aucun repas aujourd'hui"
                                color: theme.textHint
                                font.pixelSize: theme.fontSM
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }

                // ── Bouton ajouter ────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.margins: 16
                    Layout.topMargin: 14
                    height: 52
                    radius: theme.radiusLG

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#00D4AA" }
                        GradientStop { position: 1.0; color: "#4FACFE" }
                    }

                    scale: addArea.pressed ? 0.97 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }

                    Text {
                        text: "+ Ajouter un repas"
                        color: "white"
                        font.pixelSize: theme.fontMD
                        font.bold: true
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: addArea
                        anchors.fill: parent
                        onClicked: pageContainer.showPage(1)
                    }
                }

                Item { height: 24 }
            }
        }
    }
}