import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FitCoach

Item {
    Theme { id: theme }

    // ── Données collectées ────────────────────
    property string userNom:       ""
    property string userObjectif:  ""
    property string userNiveau:    ""
    property int    userAge:       20
    property double userPoids:     70
    property int    userTaille:    170
    property int    userJours:     3
    property string userEquipement:""

    // ── Étape courante (0 à 5) ────────────────
    property int currentStep: 0
    signal onboardingCompleted()

    Rectangle {
        anchors.fill: parent
        color: theme.bgPrimary

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 0

            // ── Indicateur de progression ─────
            Row {
                Layout.fillWidth: true
                spacing: 6
                Layout.bottomMargin: 40

                Repeater {
                    model: 6
                    Rectangle {
                        width: (parent.width - 30) / 6
                        height: 4
                        radius: 2
                        color: index <= currentStep
                               ? theme.accent
                               : theme.border
                        Behavior on color {
                            ColorAnimation { duration: 300 }
                        }
                    }
                }
            }

            // ── Contenu de chaque étape ───────
            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: currentStep

                // Étape 0 — Prénom
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 16

                        Text {
                            text: "👋"
                            font.pixelSize: 56
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: "Bienvenue !"
                            color: theme.textPrimary
                            font.pixelSize: 28
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: "Comment tu t'appelles ?"
                            color: theme.textSecondary
                            font.pixelSize: theme.fontMD
                            Layout.alignment: Qt.AlignHCenter
                        }
                        TextField {
                            Layout.fillWidth: true
                            Layout.topMargin: 16
                            height: 52
                            placeholderText: "Ton prénom..."
                            font.pixelSize: theme.fontLG
                            color: theme.textPrimary
                            placeholderTextColor: theme.textHint
                            onTextChanged: userNom = text

                            background: Rectangle {
                                radius: theme.radiusMD
                                color: theme.bgCard
                                border.color: theme.border
                                border.width: 1
                            }
                        }
                    }
                }

                // Étape 1 — Objectif
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 16

                        Text {
                            text: "🎯"
                            font.pixelSize: 56
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: "Ton objectif ?"
                            color: theme.textPrimary
                            font.pixelSize: 28
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Repeater {
                            model: [
                                { icon: "🔥", label: "Perdre du poids",    val: "perte_poids"   },
                                { icon: "💪", label: "Prendre du muscle",  val: "prise_muscle"  },
                                { icon: "⚖️", label: "Maintien",           val: "maintien"      },
                                { icon: "🏃", label: "Performance",        val: "performance"   }
                            ]

                            Rectangle {
                                Layout.fillWidth: true
                                height: 60
                                radius: theme.radiusMD
                                color: userObjectif === modelData.val
                                       ? theme.accent
                                       : theme.bgCard
                                border.color: userObjectif === modelData.val
                                              ? theme.accent
                                              : theme.border
                                border.width: 1

                                Behavior on color {
                                    ColorAnimation { duration: 200 }
                                }

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 12

                                    Text {
                                        text: modelData.icon
                                        font.pixelSize: 24
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: modelData.label
                                        color: theme.textPrimary
                                        font.pixelSize: theme.fontMD
                                        font.bold: userObjectif === modelData.val
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: userObjectif = modelData.val
                                }
                            }
                        }
                    }
                }

                // Étape 2 — Niveau
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 16

                        Text {
                            text: "📊"
                            font.pixelSize: 56
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: "Ton niveau ?"
                            color: theme.textPrimary
                            font.pixelSize: 28
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Repeater {
                            model: [
                                { icon: "🌱", label: "Débutant",       desc: "Moins de 6 mois",  val: "debutant"      },
                                { icon: "⚡", label: "Intermédiaire",  desc: "6 mois — 2 ans",   val: "intermediaire" },
                                { icon: "🔱", label: "Avancé",         desc: "Plus de 2 ans",    val: "avance"        }
                            ]

                            Rectangle {
                                Layout.fillWidth: true
                                height: 70
                                radius: theme.radiusMD
                                color: userNiveau === modelData.val
                                       ? theme.accent
                                       : theme.bgCard
                                border.color: userNiveau === modelData.val
                                              ? theme.accent
                                              : theme.border
                                border.width: 1

                                Behavior on color {
                                    ColorAnimation { duration: 200 }
                                }

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 12

                                    Text {
                                        text: modelData.icon
                                        font.pixelSize: 24
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 2
                                        Text {
                                            text: modelData.label
                                            color: theme.textPrimary
                                            font.pixelSize: theme.fontMD
                                            font.bold: true
                                        }
                                        Text {
                                            text: modelData.desc
                                            color: theme.textSecondary
                                            font.pixelSize: theme.fontSM
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: userNiveau = modelData.val
                                }
                            }
                        }
                    }
                }

                // Étape 3 — Infos physiques
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 20

                        Text {
                            text: "📏"
                            font.pixelSize: 56
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: "Tes infos"
                            color: theme.textPrimary
                            font.pixelSize: 28
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Repeater {
                            model: 3

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                property var configs: [
                                    { label: "Âge",    unit: "ans", min: 10,  max: 80,  startVal: 20  },
                                    { label: "Poids",  unit: "kg",  min: 30,  max: 200, startVal: 70  },
                                    { label: "Taille", unit: "cm",  min: 100, max: 220, startVal: 170 }
                                ]

                                property var cfg: configs[index]
                                property real sliderVal: cfg.startVal

                                Row {
                                    Layout.fillWidth: true

                                    Text {
                                        text: cfg.label
                                        color: theme.textSecondary
                                        font.pixelSize: theme.fontSM
                                    }

                                    // NOUVEAU — remplace par un spacer simple
                                    Item {
                                        Layout.fillWidth: true
                                        height: 1
                                    }

                                    Text {
                                        id: valueText
                                        text: Math.round(sliderVal) + " " + cfg.unit
                                        color: theme.accent
                                        font.pixelSize: theme.fontMD
                                        font.bold: true
                                    }
                                }

                                Slider {
                                    Layout.fillWidth: true
                                    from:     cfg.min
                                    to:       cfg.max
                                    value:    cfg.startVal
                                    stepSize: 1

                                    onValueChanged: {
                                        sliderVal = value
                                        if (index === 0) userAge    = Math.round(value)
                                        if (index === 1) userPoids  = Math.round(value)
                                        if (index === 2) userTaille = Math.round(value)
                                    }
                                }
                            }
                        }
                    }
                }

                // Étape 4 — Jours par semaine
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 16

                        Text {
                            text: "📅"
                            font.pixelSize: 56
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: "Combien de jours\npar semaine ?"
                            color: theme.textPrimary
                            font.pixelSize: 28
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Row {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 10

                            Repeater {
                                model: [2, 3, 4, 5, 6]

                                Rectangle {
                                    width: 52
                                    height: 52
                                    radius: theme.radiusMD
                                    color: userJours === modelData
                                           ? theme.accent
                                           : theme.bgCard
                                    border.color: userJours === modelData
                                                  ? theme.accent
                                                  : theme.border
                                    border.width: 1

                                    Behavior on color {
                                        ColorAnimation { duration: 200 }
                                    }

                                    Text {
                                        text: modelData + "j"
                                        color: theme.textPrimary
                                        font.pixelSize: theme.fontMD
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: userJours = modelData
                                    }
                                }
                            }
                        }
                    }
                }

                // Étape 5 — Équipement
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 16

                        Text {
                            text: "🏋️"
                            font.pixelSize: 56
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: "Ton équipement ?"
                            color: theme.textPrimary
                            font.pixelSize: 28
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Repeater {
                            model: [
                                { icon: "🏠", label: "Aucun",          desc: "Poids du corps uniquement", val: "aucun"    },
                                { icon: "🏋️", label: "Haltères",       desc: "Haltères à domicile",       val: "halteres" },
                                { icon: "🏟️", label: "Salle complète", desc: "Accès à une salle de sport", val: "salle"   }
                            ]

                            Rectangle {
                                Layout.fillWidth: true
                                height: 70
                                radius: theme.radiusMD
                                color: userEquipement === modelData.val
                                       ? theme.accent
                                       : theme.bgCard
                                border.color: userEquipement === modelData.val
                                              ? theme.accent
                                              : theme.border
                                border.width: 1

                                Behavior on color {
                                    ColorAnimation { duration: 200 }
                                }

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 12

                                    Text {
                                        text: modelData.icon
                                        font.pixelSize: 24
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 2
                                        Text {
                                            text: modelData.label
                                            color: theme.textPrimary
                                            font.pixelSize: theme.fontMD
                                            font.bold: true
                                        }
                                        Text {
                                            text: modelData.desc
                                            color: theme.textSecondary
                                            font.pixelSize: theme.fontSM
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: userEquipement = modelData.val
                                }
                            }
                        }
                    }
                }
            }

            // ── Bouton Suivant / Terminer ─────
            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 24
                height: 54
                radius: theme.radiusLG
                color: theme.accent

                Text {
                    text: currentStep < 5 ? "Continuer →" : "C'est parti ! 🚀"
                    color: "white"
                    font.pixelSize: theme.fontMD
                    font.bold: true
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    // NOUVEAU
                    onClicked: {
                        if (currentStep < 5) {
                            currentStep++
                        } else {
                            homeVM.completeOnboarding(
                                userNom, userAge, userPoids, userTaille,
                                userObjectif, userNiveau, userJours, userEquipement
                            )
                            onboardingCompleted()    // ← émet le signal
                        }
                    }
                }
            }

            // ── Bouton retour ─────────────────
            Text {
                text: currentStep > 0 ? "← Retour" : ""
                color: theme.textHint
                font.pixelSize: theme.fontSM
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 12

                MouseArea {
                    anchors.fill: parent
                    onClicked: if (currentStep > 0) currentStep--
                }
            }
        }
    }
}