import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FitCoach

Item {
    id: root

    Theme { id: theme }

    property string exerciceNom: ""
    property var historique: []

    signal fermer()

    Rectangle {
        anchors.fill: parent
        color: theme.bgPrimary

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ── Header ─────────────────────────────
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

                    Rectangle {
                        width: 38
                        height: 38
                        radius: 10
                        color: theme.bgInput
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
                            onClicked: root.fermer()
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        width: parent.width - 60

                        Text {
                            text: "Historique"
                            color: theme.textPrimary
                            font.pixelSize: theme.fontLG
                            font.bold: true
                        }

                        Text {
                            text: root.exerciceNom
                            color: theme.textSecondary
                            font.pixelSize: theme.fontSM
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }
                }
            }

            // ── Contenu ────────────────────────────
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ColumnLayout {
                    width: parent.width
                    spacing: 16

                    // ── Résumé ─────────────────────
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        Layout.topMargin: 16
                        height: 110

                        radius: theme.radiusLG
                        color: theme.bgCard
                        border.color: theme.border
                        border.width: 1

                        Row {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 12

                            Column {
                                width: (parent.width - 24) / 2
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4

                                Text {
                                    text: "SÉANCES"
                                    color: theme.textHint
                                    font.pixelSize: 9
                                    font.bold: true
                                    font.letterSpacing: 1
                                }

                                Text {
                                    text: root.historique.length
                                    color: theme.textPrimary
                                    font.pixelSize: 28
                                    font.bold: true
                                }

                                Text {
                                    text: "enregistrées"
                                    color: theme.textSecondary
                                    font.pixelSize: 10
                                }
                            }

                            Rectangle {
                                width: 1
                                height: 55
                                color: theme.border
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                width: (parent.width - 24) / 2
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4

                                Text {
                                    text: "DERNIÈRE SÉANCE"
                                    color: theme.textHint
                                    font.pixelSize: 9
                                    font.bold: true
                                    font.letterSpacing: 1
                                }

                                Text {
                                    text: root.historique.length > 0
                                          ? root.historique[0].date
                                          : "—"
                                    color: theme.accent
                                    font.pixelSize: 16
                                    font.bold: true
                                }

                                Text {
                                    text: root.historique.length > 0
                                          ? root.historique[0].series.length + " séries"
                                          : "Aucune donnée"
                                    color: theme.textSecondary
                                    font.pixelSize: 10
                                }
                            }
                        }
                    }

                    // ── Historique ─────────────────
                    Row {
                        Layout.fillWidth: true
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16

                        Text {
                            text: "HISTORIQUE"
                            color: theme.textHint
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 1
                        }
                    }

                    Repeater {
                        model: root.historique

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.leftMargin: 16
                            Layout.rightMargin: 16
                            Layout.preferredHeight: 76

                            radius: theme.radiusLG
                            color: theme.bgCard
                            border.color: theme.border
                            border.width: 1

                            Row {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 12

                                Rectangle {
                                    width: 42
                                    height: 42
                                    radius: 12
                                    color: "#00D4AA18"
                                    border.color: "#00D4AA44"
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        text: "💪"
                                        font.pixelSize: 18
                                        anchors.centerIn: parent
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 4
                                    width: parent.width - 54

                                    Text {
                                        text: modelData.date
                                        color: theme.textPrimary
                                        font.pixelSize: 12
                                        font.bold: true
                                    }

                                    Text {
                                        text: {
                                            var series = modelData.series
                                            var values = []

                                            for (var i = 0; i < series.length; ++i) {
                                                values.push(
                                                    series[i].poids +
                                                    " × " +
                                                    series[i].reps
                                                )
                                            }

                                            return values.join("   ·   ")
                                        }

                                        color: theme.textSecondary
                                        font.pixelSize: 10
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }
                                }
                            }
                        }
                    }

                    // ── État vide ──────────────────
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        Layout.bottomMargin: 24
                        height: 140

                        radius: theme.radiusLG
                        color: theme.bgCard
                        border.color: theme.border
                        border.width: 1

                        visible: root.historique.length === 0

                        Column {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: "📊"
                                font.pixelSize: 34
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "Pas encore d'historique"
                                color: theme.textPrimary
                                font.pixelSize: theme.fontMD
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "Tes prochaines séances apparaîtront ici."
                                color: theme.textHint
                                font.pixelSize: theme.fontSM
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    Item {
                        Layout.preferredHeight: 20
                    }
                }
            }
        }
    }
}