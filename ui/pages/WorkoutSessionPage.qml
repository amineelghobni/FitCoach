import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FitCoach

Item {
    Theme { id: theme }

    property bool showHistorique: false

    signal fermer()
    signal seanceTerminee()

    // Son bip via Timer
    Timer {
        id: bipTimer
        interval: 100
        repeat: false
        onTriggered: bipRect.visible = false
    }

    Rectangle {
        id: bipRect
        anchors.fill: parent
        color: "#00D4AA"
        opacity: 0.15
        visible: false
        z: 50
    }

    Connections {
        target: sessionVM
        function onTimerTermine() {
            // Flash vert quand le timer se termine
            bipRect.visible = true
            bipTimer.start()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: theme.bgPrimary

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ── Header ────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 72
                color: theme.bgCard
                border.color: theme.border
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    // Bouton annuler
                    Rectangle {
                        width: 38; height: 38; radius: 10
                        color: "#2e0d0d"
                        border.color: "#FF6B6B44"
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: "✕"
                            color: "#FF6B6B"
                            font.pixelSize: 16
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: showAnnulerConfirm = true
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 3
                        width: parent.width - 38 - 80 - 24

                        Text {
                            text: "Séance en cours"
                            color: theme.textPrimary
                            font.pixelSize: theme.fontMD
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
                                    NumberAnimation { to: 0.2; duration: 800 }
                                    NumberAnimation { to: 1.0; duration: 800 }
                                }
                            }

                            Text {
                                text: {
                                    var s = sessionVM.dureeSeance
                                    var m = Math.floor(s / 60)
                                    var sec = s % 60
                                    return (m < 10 ? "0" : "") + m + ":" +
                                           (sec < 10 ? "0" : "") + sec
                                }
                                color: theme.accentGreen
                                font.pixelSize: theme.fontSM
                                font.bold: true
                            }
                        }
                    }

                    // Progression exercices
                    Rectangle {
                        width: 72; height: 32; radius: 16
                        color: "#00D4AA22"
                        border.color: "#00D4AA44"
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: (sessionVM.exerciceIndex + 1) + " / " + sessionVM.totalExercices
                            color: theme.accent
                            font.pixelSize: 12
                            font.bold: true
                            anchors.centerIn: parent
                        }
                    }
                }
            }

            // ── Barre progression globale ──────
            Rectangle {
                Layout.fillWidth: true
                height: 4
                color: "#1e2a3a"

                Rectangle {
                    width: sessionVM.totalExercices > 0
                           ? parent.width * ((sessionVM.exerciceIndex + 1) / sessionVM.totalExercices)
                           : 0
                    height: parent.height
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#4FACFE" }
                        GradientStop { position: 1.0; color: "#00D4AA" }
                    }

                    Behavior on width {
                        NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
                    }
                }
            }

            // ── Contenu principal ──────────────
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20

                    // ── Nom exercice ──────────
                    Column {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "EXERCICE " + (sessionVM.exerciceIndex + 1)
                            color: theme.textHint
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 1
                        }

                        Text {
                            text: sessionVM.nomExercice
                            color: theme.textPrimary
                            font.pixelSize: 26
                            font.bold: true
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        Row {
                            spacing: 12

                            Rectangle {
                                height: 28; radius: 14
                                width: poidsTag.implicitWidth + 16
                                color: "#00D4AA22"
                                border.color: "#00D4AA44"
                                border.width: 1
                                visible: sessionVM.poids > 0

                                Text {
                                    id: poidsTag
                                    text: sessionVM.poids + " kg"
                                    color: theme.accent
                                    font.pixelSize: 12
                                    font.bold: true
                                    anchors.centerIn: parent
                                }
                            }

                            Rectangle {
                                height: 28; radius: 14
                                width: repsTag.implicitWidth + 16
                                color: "#4FACFE22"
                                border.color: "#4FACFE44"
                                border.width: 1

                                Text {
                                    id: repsTag
                                    text: sessionVM.reps + " reps"
                                    color: "#4FACFE"
                                    font.pixelSize: 12
                                    font.bold: true
                                    anchors.centerIn: parent
                                }
                            }
                        }
                    }
                    // ── Dernière performance ─────────────────────
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: sessionVM.aHistorique ? 92 : 72

                        radius: theme.radiusLG
                        color: theme.bgCard
                        border.color: theme.border
                        border.width: 1

                        visible: sessionVM.aHistorique

                        Row {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 12

                            Rectangle {
                                width: 42
                                height: 42
                                radius: 12
                                color: "#4FACFE18"
                                border.color: "#4FACFE44"
                                border.width: 1
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    text: "📈"
                                    font.pixelSize: 19
                                    anchors.centerIn: parent
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4
                                width: parent.width - 54

                                Text {
                                    text: "DERNIÈRE SÉANCE"
                                    color: theme.textHint
                                    font.pixelSize: 9
                                    font.bold: true
                                    font.letterSpacing: 1
                                }

                                Text {
                                    text: sessionVM.dernierPoids + " kg × " +
                                          sessionVM.dernieresReps + " reps × " +
                                          sessionVM.dernierSets + " séries"

                                    color: theme.textPrimary
                                    font.pixelSize: 14
                                    font.bold: true
                                    elide: Text.ElideRight
                                    width: parent.width
                                }

                                Text {
                                    text: "Utilise cette performance comme référence"
                                    color: theme.textSecondary
                                    font.pixelSize: 10
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.alignment: Qt.AlignLeft
                        width: 120
                        height: 34
                        radius: 17

                        color: theme.bgCard
                        border.color: theme.border
                        border.width: 1

                        visible: sessionVM.historiqueExercice.length > 0

                        Row {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: "📊"
                                font.pixelSize: 13
                            }

                            Text {
                                text: "Historique"
                                color: theme.textSecondary
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                showHistorique = true
                            }
                        }
                    }

                    // ── Comparaison avec la dernière séance ─────────────
                    Row {
                        Layout.fillWidth: true
                        visible: sessionVM.aHistorique
                        spacing: 6

                        Text {
                            text: {
                                var delta = sessionVM.poids - sessionVM.dernierPoids

                                if (Math.abs(delta) < 0.01)
                                    return "🎯 Même charge programmée"

                                if (delta > 0)
                                    return "🎯 +" + delta.toFixed(1) +
                                           " kg vs dernière séance"

                                return "🎯 " + delta.toFixed(1) +
                                       " kg vs dernière séance"
                            }

                            color: sessionVM.poids > sessionVM.dernierPoids
                                   ? theme.accentGreen
                                   : sessionVM.poids < sessionVM.dernierPoids
                                     ? "#FF6B6B"
                                     : theme.textSecondary

                            font.pixelSize: 10
                            font.bold: true
                        }
                    }
                    // ── Séries ────────────────
                    Column {
                        Layout.fillWidth: true
                        spacing: 12

                        Text {
                            text: "SÉRIES"
                            color: theme.textHint
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 1
                        }

                        Row {
                            spacing: 10

                            Repeater {
                                model: sessionVM.seriesFaites

                                Rectangle {
                                    width: 52; height: 52; radius: 12
                                    color: modelData ? "#0d2e1a" : theme.bgCard
                                    border.color: modelData ? theme.accentGreen : theme.border
                                    border.width: modelData ? 2 : 1

                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    Behavior on border.color { ColorAnimation { duration: 200 } }

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 2

                                        Text {
                                            text: modelData ? "✓" : (index + 1) + ""
                                            color: modelData ? theme.accentGreen : theme.textSecondary
                                            font.pixelSize: modelData ? 20 : 16
                                            font.bold: true
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                        Text {
                                            text: modelData ? "fait" : "série"
                                            color: modelData ? theme.accentGreen : theme.textHint
                                            font.pixelSize: 9
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                }
                            }
                        }

                        // Compteur séries
                        Text {
                            text: sessionVM.setsFaits + " / " + sessionVM.setsTotal + " séries complétées"
                            color: theme.textSecondary
                            font.pixelSize: theme.fontSM
                        }
                    }

                    // ── Timer repos ───────────
                    Rectangle {
                        Layout.fillWidth: true
                        height: 110
                        radius: theme.radiusLG
                        visible: sessionVM.timerActif
                        color: theme.bgCard
                        border.color: "#00D4AA44"
                        border.width: 1

                        // Barre progression timer
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            width: sessionVM.timerDuree > 0
                                   ? parent.width * (1 - sessionVM.timerRestant / sessionVM.timerDuree)
                                   : 0
                            height: 4
                            radius: 2
                            color: sessionVM.timerRestant <= 10 ? "#FF6B6B" : theme.accent

                            Behavior on width {
                                NumberAnimation { duration: 900; easing.type: Easing.Linear }
                            }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: "⏱ REPOS"
                                color: theme.textHint
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: {
                                    var m = Math.floor(sessionVM.timerRestant / 60)
                                    var s = sessionVM.timerRestant % 60
                                    return (m < 10 ? "0" : "") + m + ":" +
                                           (s < 10 ? "0" : "") + s
                                }
                                color: sessionVM.timerRestant <= 10 ? "#FF6B6B" : theme.accent
                                font.pixelSize: 38
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter

                                Behavior on color { ColorAnimation { duration: 300 } }
                            }

                            // Bouton passer le timer
                            Rectangle {
                                width: 100; height: 26; radius: 13
                                color: "#1e2a3a"
                                border.color: theme.border
                                border.width: 1
                                anchors.horizontalCenter: parent.horizontalCenter

                                Text {
                                    text: "Passer →"
                                    color: theme.textHint
                                    font.pixelSize: 11
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: sessionVM.stopperTimer()
                                }
                            }
                        }
                    }

                    // ── Sélecteur durée timer ─
                    Row {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 10
                        visible: !sessionVM.timerActif

                        Text {
                            text: "Repos :"
                            color: theme.textHint
                            font.pixelSize: theme.fontSM
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Repeater {
                            model: [
                                { label: "45s",  val: 45  },
                                { label: "60s",  val: 60  },
                                { label: "90s",  val: 90  },
                                { label: "2min", val: 120 }
                            ]

                            Rectangle {
                                width: 52; height: 30; radius: 15
                                color: sessionVM.timerDuree === modelData.val
                                       ? theme.accent : theme.bgCard
                                border.color: sessionVM.timerDuree === modelData.val
                                              ? theme.accent : theme.border
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: 150 } }

                                Text {
                                    text: modelData.label
                                    color: sessionVM.timerDuree === modelData.val
                                           ? "white" : theme.textSecondary
                                    font.pixelSize: 11
                                    font.bold: sessionVM.timerDuree === modelData.val
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: sessionVM.setTimerDuree(modelData.val)
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            // ── Boutons navigation + action ────
            Rectangle {
                Layout.fillWidth: true
                height: 140
                color: theme.bgCard
                border.color: theme.border
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    // Navigation exos
                    Row {
                        Layout.fillWidth: true
                        spacing: 10

                        // Précédent
                        Rectangle {
                            width: (parent.width - 10) / 2
                            height: 44
                            radius: theme.radiusMD
                            color: theme.bgInput
                            border.color: theme.border
                            border.width: 1
                            opacity: sessionVM.exerciceIndex > 0 ? 1.0 : 0.3

                            Row {
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: "←"
                                    color: theme.textSecondary
                                    font.pixelSize: 16
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: "Précédent"
                                    color: theme.textSecondary
                                    font.pixelSize: theme.fontSM
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: if (sessionVM.exerciceIndex > 0)
                                               sessionVM.exercicePrecedent()
                            }
                        }

                        // Suivant
                        Rectangle {
                            width: (parent.width - 10) / 2
                            height: 44
                            radius: theme.radiusMD
                            color: theme.bgInput
                            border.color: theme.border
                            border.width: 1
                            opacity: sessionVM.exerciceIndex < sessionVM.totalExercices - 1 ? 1.0 : 0.3

                            Row {
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: "Suivant"
                                    color: theme.textSecondary
                                    font.pixelSize: theme.fontSM
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: "→"
                                    color: theme.textSecondary
                                    font.pixelSize: 16
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: if (sessionVM.exerciceIndex < sessionVM.totalExercices - 1)
                                               sessionVM.exerciceSuivant()
                            }
                        }
                    }

                    // Bouton série faite / terminer
                    Rectangle {
                        Layout.fillWidth: true
                        height: 52
                        radius: theme.radiusLG

                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop {
                                position: 0.0
                                color: sessionVM.setsFaits >= sessionVM.setsTotal
                                       ? "#4FACFE" : "#00D4AA"
                            }
                            GradientStop {
                                position: 1.0
                                color: sessionVM.setsFaits >= sessionVM.setsTotal
                                       ? "#a78bfa" : "#4FACFE"
                            }
                        }

                        Behavior on gradient { }

                        scale: serieBtn.pressed ? 0.97 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        Row {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: sessionVM.setsFaits >= sessionVM.setsTotal
                                      ? (sessionVM.exerciceIndex < sessionVM.totalExercices - 1
                                         ? "➡️" : "🏁")
                                      : "✅"
                                font.pixelSize: 18
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: {
                                    if (sessionVM.setsFaits >= sessionVM.setsTotal) {
                                        if (sessionVM.exerciceIndex < sessionVM.totalExercices - 1)
                                            return "Exercice suivant"
                                        else
                                            return "Terminer la séance"
                                    }
                                    return "Série " + (sessionVM.setsFaits + 1) + " terminée !"
                                }
                                color: "white"
                                font.pixelSize: theme.fontMD
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: serieBtn
                            anchors.fill: parent
                            onClicked: {
                                if (sessionVM.setsFaits >= sessionVM.setsTotal) {
                                    if (sessionVM.exerciceIndex < sessionVM.totalExercices - 1) {
                                        sessionVM.exerciceSuivant()
                                    } else {
                                        // Terminer la séance
                                        var wid = sessionVM.workoutId
                                        var exVM = exerciseVM
                                        sessionVM.terminerSession()
                                        exVM.setDernieresCalories(exVM.calculerCaloriesBrulees(wid))
                                        exVM.selectWorkout(-1)
                                        exVM.refresh()
                                        homeVM.refresh()
                                        progressVM.refresh()
                                        exVM.setSeanceTerminee(true)
                                        fermer()
                                    }
                                } else {
                                    // Vérifie PR avant de terminer la série
                                    exerciseVM.verifierEtSauvegarderPR(
                                        sessionVM.workoutId,
                                        sessionVM.nomExercice,
                                        sessionVM.reps,
                                        sessionVM.poids
                                    )
                                    sessionVM.terminerSerie()
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Popup annuler ─────────────────────
        Rectangle {
            anchors.fill: parent
            color: "#CC000000"
            visible: showAnnulerConfirm
            z: 30

            MouseArea { anchors.fill: parent }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 64
                height: annulCol.implicitHeight + 40
                radius: theme.radiusLG
                color: theme.bgCard
                border.color: theme.border
                border.width: 1

                ColumnLayout {
                    id: annulCol
                    anchors.centerIn: parent
                    width: parent.width - 40
                    spacing: 16

                    Text {
                        text: "⚠️"
                        font.pixelSize: 36
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: "Abandonner la séance ?"
                        color: theme.textPrimary
                        font.pixelSize: theme.fontLG
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: "Ta progression ne sera pas sauvegardée."
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
                                text: "Continuer"
                                color: theme.textPrimary
                                font.pixelSize: theme.fontMD
                                font.bold: true
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: showAnnulerConfirm = false
                            }
                        }

                        Rectangle {
                            width: (parent.width - 12) / 2
                            height: 48
                            radius: theme.radiusMD
                            color: "#FF6B6B"

                            Text {
                                text: "Abandonner"
                                color: "white"
                                font.pixelSize: theme.fontMD
                                font.bold: true
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    sessionVM.annulerSession()
                                    showAnnulerConfirm = false
                                    fermer()
                                }
                            }
                        }
                    }
                }
            }
        }
        // ── Popup PR ─────────────────────────────
        Rectangle {
            anchors.fill: parent
            color: "#CC000000"
            visible: exerciseVM.nouveauPR
            z: 40

            MouseArea { anchors.fill: parent }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 48
                height: prCol.implicitHeight + 48
                radius: theme.radiusLG
                color: theme.bgCard
                border.color: "#FFD700"
                border.width: 2

                // Glow doré
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "#FFD70008"
                }

                ColumnLayout {
                    id: prCol
                    anchors.centerIn: parent
                    width: parent.width - 40
                    spacing: 16

                    Text {
                        text: "🏆"
                        font.pixelSize: 56
                        Layout.alignment: Qt.AlignHCenter

                        SequentialAnimation on scale {
                            running: exerciseVM.nouveauPR
                            loops: Animation.Infinite
                            NumberAnimation { to: 1.2; duration: 400; easing.type: Easing.OutBack }
                            NumberAnimation { to: 1.0; duration: 400; easing.type: Easing.InBack }
                        }
                    }

                    Text {
                        text: "Nouveau Record !"
                        color: "#FFD700"
                        font.pixelSize: theme.fontXL
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: exerciseVM.nomPR
                        color: theme.textPrimary
                        font.pixelSize: theme.fontLG
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 60
                        radius: theme.radiusLG
                        color: "#FFD70022"
                        border.color: "#FFD70066"
                        border.width: 1

                        Row {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: exerciseVM.poidsPR + " kg"
                                color: "#FFD700"
                                font.pixelSize: 24
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: "×"
                                color: theme.textHint
                                font.pixelSize: 20
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: sessionVM.reps + " reps"
                                color: "#FFD700"
                                font.pixelSize: 24
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 52
                        radius: theme.radiusLG
                        color: "#FFD700"

                        Text {
                            text: "Continuer 💪"
                            color: "#0A0E17"
                            font.pixelSize: theme.fontMD
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        scale: prBtn.pressed ? 0.97 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        MouseArea {
                            id: prBtn
                            anchors.fill: parent
                            onClicked: exerciseVM.resetPR()
                        }
                    }
                }
            }
        }
    }

    property bool showAnnulerConfirm: false

       // ── Page historique exercice ─────────────────────
       ExerciseHistoryPage {
           id: exerciseHistoryPage

           anchors.fill: parent
           z: 100

           visible: showHistorique

           exerciceNom: sessionVM.nomExercice
           historique: sessionVM.historiqueExercice

           onFermer: {
               showHistorique = false
           }
       }
}