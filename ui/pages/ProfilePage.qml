import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FitCoach

Item {
    Theme { id: theme }

    signal fermer()

    // Données locales
    property string mNom:        profileVM.nom
    property int    mAge:        profileVM.age
    property double mPoids:      profileVM.poids
    property int    mTaille:     profileVM.taille
    property string mObjectif:   profileVM.objectif
    property string mNiveau:     profileVM.niveau
    property int    mJours:      profileVM.joursSemaine
    property string mEquipement: profileVM.equipement

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

                // ── Header ────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    height: 80
                    color: "transparent"

                    Row {
                        anchors.fill: parent
                        anchors.margins: 20
                        anchors.rightMargin: 16

                        // Bouton retour
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

                        Item { width: 12 }

                        Column {
                            spacing: 4
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: "Mon profil"
                                color: theme.textPrimary
                                font.pixelSize: theme.fontXL
                                font.bold: true
                            }
                            Text {
                                text: "Modifier tes informations"
                                color: theme.textSecondary
                                font.pixelSize: theme.fontSM
                            }
                        }
                    }
                }

                // ── Avatar + nom ──────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.margins: 16
                    height: 100
                    radius: theme.radiusLG
                    color: theme.bgCard
                    border.color: theme.border
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16

                        Rectangle {
                            width: 68
                            height: 68
                            radius: 34
                            color: theme.accent
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: mNom.length > 0 ? mNom[0].toUpperCase() : "?"
                                color: "white"
                                font.pixelSize: 28
                                font.bold: true
                                anchors.centerIn: parent
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4

                            Text {
                                text: mNom
                                color: theme.textPrimary
                                font.pixelSize: theme.fontLG
                                font.bold: true
                            }
                            Text {
                                text: mAge + " ans · " + mPoids + " kg · " + mTaille + " cm"
                                color: theme.textSecondary
                                font.pixelSize: theme.fontSM
                            }
                            Rectangle {
                                height: 20
                                width: objectifLabel.implicitWidth + 16
                                radius: 10
                                color: theme.accent + "22"
                                border.color: theme.accent + "44"
                                border.width: 1

                                Text {
                                    id: objectifLabel
                                    text: {
                                        if (mObjectif === "prise_muscle")  return "💪 Prise de muscle"
                                        if (mObjectif === "perte_poids")   return "🔥 Perte de poids"
                                        if (mObjectif === "maintien")      return "⚖️ Maintien"
                                        return "🏃 Performance"
                                    }
                                    color: theme.accent
                                    font.pixelSize: 9
                                    font.bold: true
                                    anchors.centerIn: parent
                                }
                            }
                        }
                    }
                }

                // ── Section infos ─────────────────
                Text {
                    text: "INFORMATIONS"
                    color: theme.textHint
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1
                    Layout.leftMargin: 16
                    Layout.topMargin: 16
                    Layout.bottomMargin: 8
                }

                // Nom
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.bottomMargin: 8
                    height: 56
                    radius: theme.radiusMD
                    color: theme.bgCard
                    border.color: theme.border
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 12

                        Text {
                            text: "👤"
                            font.pixelSize: 20
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            width: parent.width - 32 - 12

                            Text {
                                text: "Prénom"
                                color: theme.textHint
                                font.pixelSize: 10
                            }
                            TextField {
                                width: parent.width
                                text: mNom
                                color: theme.textPrimary
                                font.pixelSize: theme.fontMD
                                font.bold: true
                                placeholderTextColor: theme.textHint
                                onTextChanged: mNom = text
                                background: Rectangle { color: "transparent" }
                            }
                        }
                    }
                }

                // Age / Poids / Taille
                GridLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.bottomMargin: 8
                    columns: 3
                    columnSpacing: 8

                    Repeater {
                        model: [
                            { icon: "🎂", label: "Âge",    unit: "ans", val: mAge,    min: 10, max: 80  },
                            { icon: "⚖️", label: "Poids",  unit: "kg",  val: mPoids,  min: 30, max: 200 },
                            { icon: "📏", label: "Taille", unit: "cm",  val: mTaille, min: 100,max: 220 }
                        ]

                        Rectangle {
                            Layout.fillWidth: true
                            height: 70
                            radius: theme.radiusMD
                            color: theme.bgCard
                            border.color: theme.border
                            border.width: 1

                            Column {
                                anchors.centerIn: parent
                                spacing: 4

                                Row {
                                    spacing: 4
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    Text {
                                        text: modelData.icon
                                        font.pixelSize: 14
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: modelData.label
                                        color: theme.textHint
                                        font.pixelSize: 10
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Text {
                                    text: {
                                        if (modelData.label === "Âge")    return mAge    + " " + modelData.unit
                                        if (modelData.label === "Poids")  return mPoids  + " " + modelData.unit
                                        return mTaille + " " + modelData.unit
                                    }
                                    color: theme.accent
                                    font.pixelSize: 16
                                    font.bold: true
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
                                                if (modelData.label === "Âge")
                                                    mAge = Math.max(modelData.min, mAge - 1)
                                                else if (modelData.label === "Poids")
                                                    mPoids = Math.max(modelData.min, mPoids - 0.5)
                                                else
                                                    mTaille = Math.max(modelData.min, mTaille - 1)
                                            }
                                        }
                                    }
                                    Text {
                                        text: "+"
                                        color: theme.textSecondary
                                        font.pixelSize: 16
                                        font.bold: true

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                if (modelData.label === "Âge")
                                                    mAge = Math.min(modelData.max, mAge + 1)
                                                else if (modelData.label === "Poids")
                                                    mPoids = Math.min(modelData.max, mPoids + 0.5)
                                                else
                                                    mTaille = Math.min(modelData.max, mTaille + 1)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Objectif ──────────────────────
                Text {
                    text: "OBJECTIF"
                    color: theme.textHint
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1
                    Layout.leftMargin: 16
                    Layout.topMargin: 8
                    Layout.bottomMargin: 8
                }

                GridLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.bottomMargin: 8
                    columns: 2
                    columnSpacing: 8
                    rowSpacing: 8

                    Repeater {
                        model: [
                            { icon: "🔥", label: "Perdre du poids",   val: "perte_poids"  },
                            { icon: "💪", label: "Prendre du muscle", val: "prise_muscle" },
                            { icon: "⚖️", label: "Maintien",          val: "maintien"     },
                            { icon: "🏃", label: "Performance",       val: "performance"  }
                        ]

                        Rectangle {
                            Layout.fillWidth: true
                            height: 48
                            radius: theme.radiusMD
                            color: mObjectif === modelData.val
                                   ? theme.accent : theme.bgCard
                            border.color: mObjectif === modelData.val
                                          ? theme.accent : theme.border
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: 200 } }

                            Row {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 8

                                Text {
                                    text: modelData.icon
                                    font.pixelSize: 18
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: modelData.label
                                    color: theme.textPrimary
                                    font.pixelSize: theme.fontSM
                                    font.bold: mObjectif === modelData.val
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: mObjectif = modelData.val
                            }
                        }
                    }
                }

                // ── Niveau ────────────────────────
                Text {
                    text: "NIVEAU"
                    color: theme.textHint
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1
                    Layout.leftMargin: 16
                    Layout.topMargin: 8
                    Layout.bottomMargin: 8
                }

                Row {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.bottomMargin: 8
                    spacing: 8

                    Repeater {
                        model: [
                            { label: "🌱 Débutant",      val: "debutant"      },
                            { label: "⚡ Intermédiaire", val: "intermediaire" },
                            { label: "🔱 Avancé",        val: "avance"        }
                        ]

                        Rectangle {
                            width: (parent.width - 16) / 3
                            height: 44
                            radius: theme.radiusMD
                            color: mNiveau === modelData.val
                                   ? theme.accent : theme.bgCard
                            border.color: mNiveau === modelData.val
                                          ? theme.accent : theme.border
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: 200 } }

                            Text {
                                text: modelData.label
                                color: theme.textPrimary
                                font.pixelSize: 10
                                font.bold: mNiveau === modelData.val
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: mNiveau = modelData.val
                            }
                        }
                    }
                }

                // ── Jours par semaine ─────────────
                Text {
                    text: "JOURS D'ENTRAÎNEMENT"
                    color: theme.textHint
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1
                    Layout.leftMargin: 16
                    Layout.topMargin: 8
                    Layout.bottomMargin: 8
                }

                Row {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.bottomMargin: 8
                    spacing: 8

                    Repeater {
                        model: [2, 3, 4, 5, 6]

                        Rectangle {
                            width: (parent.width - 32) / 5
                            height: 44
                            radius: theme.radiusMD
                            color: mJours === modelData
                                   ? theme.accent : theme.bgCard
                            border.color: mJours === modelData
                                          ? theme.accent : theme.border
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: 200 } }

                            Text {
                                text: modelData + "j"
                                color: theme.textPrimary
                                font.pixelSize: theme.fontSM
                                font.bold: mJours === modelData
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: mJours = modelData
                            }
                        }
                    }
                }

                // ── Équipement ────────────────────
                Text {
                    text: "ÉQUIPEMENT"
                    color: theme.textHint
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1
                    Layout.leftMargin: 16
                    Layout.topMargin: 8
                    Layout.bottomMargin: 8
                }

                Column {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.bottomMargin: 16
                    spacing: 8

                    Repeater {
                        model: [
                            { icon: "🏠", label: "Aucun",          desc: "Poids du corps", val: "aucun"    },
                            { icon: "🏋️", label: "Haltères",       desc: "À domicile",     val: "halteres" },
                            { icon: "🏟️", label: "Salle complète", desc: "Salle de sport", val: "salle"    }
                        ]

                        Rectangle {
                            width: parent.width
                            height: 56
                            radius: theme.radiusMD
                            color: mEquipement === modelData.val
                                   ? theme.accent : theme.bgCard
                            border.color: mEquipement === modelData.val
                                          ? theme.accent : theme.border
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: 200 } }

                            Row {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 12

                                Text {
                                    text: modelData.icon
                                    font.pixelSize: 22
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
                                onClicked: mEquipement = modelData.val
                            }
                        }
                    }
                }

                // ── Bouton sauvegarder ────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.margins: 16
                    Layout.bottomMargin: 32
                    height: 52
                    radius: theme.radiusLG
                    color: theme.accent

                    Text {
                        text: "💾 Sauvegarder"
                        color: "white"
                        font.pixelSize: theme.fontMD
                        font.bold: true
                        anchors.centerIn: parent
                    }

                    scale: saveBtn.pressed ? 0.97 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100 } }

                    MouseArea {
                        id: saveBtn
                        anchors.fill: parent
                        onClicked: {
                            profileVM.sauvegarder(
                                mNom, mAge, mPoids, mTaille,
                                mObjectif, mNiveau, mJours, mEquipement
                            )
                            homeVM.refresh()
                            fermer()
                        }
                    }
                }
            }
        }
    }
}