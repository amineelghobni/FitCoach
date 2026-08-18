import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FitCoach

Item {
    Theme { id: theme }

    signal fermer()
    signal seanceAdoptee()

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
                color: "transparent"

                Row {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12

                    Rectangle {
                        width: 38
                        height: 38
                        radius: 10
                        color: theme.bgCard
                        border.color: theme.border
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: "←"
                            color: theme.textPrimary
                            font.pixelSize: 18
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: fermer()
                        }
                    }

                    Column {
                        spacing: 4
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: "Programme IA"
                            color: theme.textPrimary
                            font.pixelSize: theme.fontXL
                            font.bold: true
                        }
                        Text {
                            text: "Séance générée pour toi"
                            color: theme.textSecondary
                            font.pixelSize: theme.fontSM
                        }
                    }
                }
            }

            // ── Contenu ───────────────────────
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: parent.width
                clip: true

                ColumnLayout {
                    width: parent.parent.width
                    spacing: 12

                    // ── État chargement ───────
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.margins: 16
                        height: 120
                        radius: theme.radiusLG
                        color: theme.bgCard
                        border.color: theme.border
                        border.width: 1
                        visible: programmeVM.loading

                        Column {
                            anchors.centerIn: parent
                            spacing: 16

                            Row {
                                spacing: 8
                                anchors.horizontalCenter: parent.horizontalCenter

                                Repeater {
                                    model: 3
                                    Rectangle {
                                        width: 10; height: 10; radius: 5
                                        color: theme.accent

                                        SequentialAnimation on opacity {
                                            running: programmeVM.loading
                                            loops: Animation.Infinite
                                            PauseAnimation { duration: index * 200 }
                                            NumberAnimation { to: 1.0; duration: 400 }
                                            NumberAnimation { to: 0.2; duration: 400 }
                                        }
                                    }
                                }
                            }

                            Text {
                                text: "Génération de ta séance..."
                                color: theme.textSecondary
                                font.pixelSize: theme.fontSM
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    // ── Pas encore de programme ──
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.margins: 16
                        height: 200
                        radius: theme.radiusLG
                        color: theme.bgCard
                        border.color: theme.border
                        border.width: 1
                        visible: !programmeVM.loading && !programmeVM.hasProgramme

                        Column {
                            anchors.centerIn: parent
                            spacing: 16

                            Text {
                                text: "🤖"
                                font.pixelSize: 56
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: "Génère ta séance du jour"
                                color: theme.textPrimary
                                font.pixelSize: theme.fontLG
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: "L'IA analyse tes séances précédentes\net propose la prochaine séance optimale"
                                color: theme.textSecondary
                                font.pixelSize: theme.fontSM
                                horizontalAlignment: Text.AlignHCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                lineHeight: 1.4
                            }
                        }
                    }

                    // ── Programme généré ──────
                    Column {
                        Layout.fillWidth: true
                        Layout.margins: 16
                        spacing: 12
                        visible: !programmeVM.loading && programmeVM.hasProgramme

                        // Card titre séance
                        Rectangle {
                            width: parent.width
                            height: 90
                            radius: theme.radiusLG
                            color: theme.accent

                            // Effet dégradé
                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: "#00D4AA" }
                                    GradientStop { position: 1.0; color: "#4FACFE" }
                                }
                            }

                            Row {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 14

                                Text {
                                    text: {
                                        var cat = programmeVM.categorieSeance
                                        if (cat === "Push") return "💪"
                                        if (cat === "Pull") return "🔄"
                                        if (cat === "Legs") return "🦵"
                                        if (cat === "Core") return "🎯"
                                        return "🏋️"
                                    }
                                    font.pixelSize: 36
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 4

                                    Text {
                                        text: programmeVM.nomSeance
                                        color: "white"
                                        font.pixelSize: theme.fontLG
                                        font.bold: true
                                    }

                                    Row {
                                        spacing: 12

                                        Text {
                                            text: programmeVM.exercices.length + " exercices"
                                            color: "white"
                                            font.pixelSize: theme.fontSM
                                            opacity: 0.85
                                        }

                                        Text {
                                            text: "🔥 ~" + programmeVM.caloriesEstimees + " kcal"
                                            color: "white"
                                            font.pixelSize: theme.fontSM
                                            opacity: 0.85
                                        }
                                    }
                                }
                            }
                        }

                        // Liste exercices
                        Text {
                            text: "EXERCICES"
                            color: theme.textHint
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 1
                        }

                        Repeater {
                            model: programmeVM.exercices

                            Rectangle {
                                width: parent.width
                                height: exCol.implicitHeight + 24
                                radius: theme.radiusMD
                                color: theme.bgCard
                                border.color: theme.border
                                border.width: 1

                                Column {
                                    id: exCol
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.margins: 14
                                    spacing: 10

                                    // Nom + muscle
                                    Row {
                                        width: parent.width
                                        spacing: 10

                                        Rectangle {
                                            width: 40
                                            height: 40
                                            radius: theme.radiusSM
                                            color: theme.bgInput
                                            anchors.verticalCenter: parent.verticalCenter

                                            Text {
                                                text: {
                                                    var m = modelData.muscle
                                                    if (m === "Poitrine") return "💪"
                                                    if (m === "Dos")      return "🔄"
                                                    if (m === "Épaules")  return "🏋️"
                                                    if (m === "Biceps")   return "💪"
                                                    if (m === "Triceps")  return "💪"
                                                    if (m === "Quadriceps" || m === "Ischio" || m === "Fessiers") return "🦵"
                                                    if (m === "Abdos" || m === "Obliques") return "🎯"
                                                    return "⚡"
                                                }
                                                font.pixelSize: 20
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 3
                                            width: parent.width - 50 - 80

                                            Text {
                                                text: modelData.nom
                                                color: theme.textPrimary
                                                font.pixelSize: theme.fontMD
                                                font.bold: true
                                                elide: Text.ElideRight
                                                width: parent.width
                                            }
                                            Text {
                                                text: modelData.muscle
                                                color: theme.textHint
                                                font.pixelSize: 10
                                            }
                                        }

                                        // Bouton supprimer
                                        Rectangle {
                                            width: 28
                                            height: 28
                                            radius: 7
                                            color: "#2e0d0d"
                                            border.color: "#FF6B6B44"
                                            border.width: 1
                                            anchors.verticalCenter: parent.verticalCenter

                                            Text {
                                                text: "🗑️"
                                                font.pixelSize: 12
                                                anchors.centerIn: parent
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: programmeVM.supprimerExercice(index)
                                            }
                                        }
                                    }

                                    // Sets / Reps / Poids modifiables
                                    Row {
                                        width: parent.width
                                        spacing: 8

                                        Repeater {
                                            model: [
                                                { label: "Séries",  val: modelData.sets,  min: 1, max: 10, step: 1    },
                                                { label: "Reps",    val: modelData.reps,  min: 1, max: 30, step: 1    },
                                                { label: "Poids kg",val: modelData.poids, min: 0, max: 300, step: 2.5 }
                                            ]

                                            Rectangle {
                                                width: (parent.width - 16) / 3
                                                height: 64
                                                radius: theme.radiusSM
                                                color: theme.bgInput
                                                border.color: theme.border
                                                border.width: 1

                                                property real currentVal: modelData.val

                                                Column {
                                                    anchors.centerIn: parent
                                                    spacing: 4

                                                    Text {
                                                        text: modelData.label
                                                        color: theme.textHint
                                                        font.pixelSize: 9
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                    }

                                                    Row {
                                                        spacing: 8
                                                        anchors.horizontalCenter: parent.horizontalCenter

                                                        Text {
                                                            text: "−"
                                                            color: theme.textSecondary
                                                            font.pixelSize: 16
                                                            font.bold: true

                                                            MouseArea {
                                                                anchors.fill: parent
                                                                onClicked: {
                                                                    var newVal = Math.max(modelData.min,
                                                                        parent.parent.parent.currentVal - modelData.step)
                                                                    parent.parent.parent.currentVal = newVal
                                                                    // Met à jour selon le type
                                                                    var exIdx = index  // index du Repeater parent
                                                                    var ex = programmeVM.exercices[exIdx]
                                                                    if (modelData.label === "Séries")
                                                                        programmeVM.modifierExercice(exIdx, newVal, ex.reps, ex.poids)
                                                                    else if (modelData.label === "Reps")
                                                                        programmeVM.modifierExercice(exIdx, ex.sets, newVal, ex.poids)
                                                                    else
                                                                        programmeVM.modifierExercice(exIdx, ex.sets, ex.reps, newVal)
                                                                }
                                                            }
                                                        }

                                                        Text {
                                                            text: parent.parent.currentVal % 1 === 0
                                                                  ? parent.parent.currentVal + ""
                                                                  : parent.parent.currentVal.toFixed(1)
                                                            color: theme.accent
                                                            font.pixelSize: 15
                                                            font.bold: true
                                                        }

                                                        Text {
                                                            text: "+"
                                                            color: theme.textSecondary
                                                            font.pixelSize: 16
                                                            font.bold: true

                                                            MouseArea {
                                                                anchors.fill: parent
                                                                onClicked: {
                                                                    var newVal = Math.min(modelData.max,
                                                                        parent.parent.parent.currentVal + modelData.step)
                                                                    parent.parent.parent.currentVal = newVal
                                                                    var exIdx = index
                                                                    var ex = programmeVM.exercices[exIdx]
                                                                    if (modelData.label === "Séries")
                                                                        programmeVM.modifierExercice(exIdx, newVal, ex.reps, ex.poids)
                                                                    else if (modelData.label === "Reps")
                                                                        programmeVM.modifierExercice(exIdx, ex.sets, newVal, ex.poids)
                                                                    else
                                                                        programmeVM.modifierExercice(exIdx, ex.sets, ex.reps, newVal)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Item { height: 8 }
                    }

                    Item { height: 100 }
                }
            }

            // ── Boutons bas ───────────────────
            Rectangle {
                Layout.fillWidth: true
                height: programmeVM.hasProgramme ? 130 : 80
                color: theme.bgPrimary
                border.color: theme.border
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    // Bouton regénérer
                    Rectangle {
                        width: parent.width
                        height: 46
                        radius: theme.radiusLG
                        color: theme.bgCard
                        border.color: theme.accent
                        border.width: 1
                        visible: programmeVM.hasProgramme

                        Text {
                            text: "🔄 Regénérer une autre séance"
                            color: theme.accent
                            font.pixelSize: theme.fontSM
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        scale: regenBtn.pressed ? 0.97 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        MouseArea {
                            id: regenBtn
                            anchors.fill: parent
                            onClicked: programmeVM.genererProgramme()
                        }
                    }

                    // Bouton générer / adopter
                    Rectangle {
                        width: parent.width
                        height: 52
                        radius: theme.radiusLG
                        color: theme.accent

                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#00D4AA" }
                            GradientStop { position: 1.0; color: "#4FACFE" }
                        }

                        Text {
                            text: programmeVM.hasProgramme
                                  ? "✅ Adopter cette séance"
                                  : programmeVM.loading
                                    ? "Génération en cours..."
                                    : "✨ Générer ma séance"
                            color: "white"
                            font.pixelSize: theme.fontMD
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        scale: mainBtn.pressed ? 0.97 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        MouseArea {
                            id: mainBtn
                            anchors.fill: parent
                            onClicked: {
                                if (programmeVM.hasProgramme) {
                                    programmeVM.adopterSeance()
                                    exerciseVM.refresh()
                                    seanceAdoptee()
                                    fermer()
                                } else if (!programmeVM.loading) {
                                    programmeVM.genererProgramme()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}