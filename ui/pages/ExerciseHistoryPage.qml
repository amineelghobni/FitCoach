import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FitCoach

Item {
    id: root

    Theme { id: theme }

    property string exerciceNom: ""
    property var historique: []

    property var statistiques: ({})
    property var progression: []
    property var suggestion: ({})
    property var comparaison: ({})

    function chargerDonnees() {
        if (exerciceNom === "") {
            statistiques = ({})
            progression = []
            comparaison = ({})
            suggestion = ({})
            return
        }

        statistiques = exerciseVM.statistiquesExercice(exerciceNom)
        progression = exerciseVM.progressionExercice(exerciceNom)

        comparaison = ({})

        if (progression.length >= 2) {
            var derniere = progression[progression.length - 1]
            var precedente = progression[progression.length - 2]

            comparaison = {
                poidsDelta: Number(derniere.meilleurPoids) -
                            Number(precedente.meilleurPoids),

                repsDelta: Number(derniere.meilleuresReps) -
                           Number(precedente.meilleuresReps),

                volumeDelta: Number(derniere.volume) -
                             Number(precedente.volume),

                poidsPourcentage: Number(precedente.meilleurPoids) > 0
                                  ? ((Number(derniere.meilleurPoids) -
                                      Number(precedente.meilleurPoids)) /
                                     Number(precedente.meilleurPoids)) * 100
                                  : 0
            }
        }

        suggestion = exerciseVM.suggestionProgression(exerciceNom)
    }
    onExerciceNomChanged: chargerDonnees()

    Component.onCompleted: chargerDonnees()

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
                contentWidth: availableWidth
                clip: true

                ColumnLayout {
                    width: parent.width
                    spacing: 16

                    // ── Résumé progression ─────────────────────
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        Layout.topMargin: 16
                        spacing: 10

                        Text {
                            text: "PROGRESSION"
                            color: theme.textHint
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 1
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: 10
                            rowSpacing: 10

                            // Séances
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 82
                                radius: theme.radiusLG
                                color: theme.bgCard
                                border.color: theme.border
                                border.width: 1

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 4

                                    Text {
                                        text: "📅"
                                        font.pixelSize: 16
                                    }

                                    Text {
                                        text: statistiques.nombreSeances !== undefined
                                              ? statistiques.nombreSeances
                                              : 0
                                        color: theme.textPrimary
                                        font.pixelSize: 22
                                        font.bold: true
                                    }

                                    Text {
                                        text: "séances"
                                        color: theme.textHint
                                        font.pixelSize: 9
                                    }
                                }
                            }

                            // Meilleur poids
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 82
                                radius: theme.radiusLG
                                color: theme.bgCard
                                border.color: Qt.rgba(
                                    theme.accent.r,
                                    theme.accent.g,
                                    theme.accent.b,
                                    0.27
                                )
                                border.width: 1

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 4

                                    Text {
                                        text: "🏆"
                                        font.pixelSize: 16
                                    }

                                    Text {
                                        text: (statistiques.meilleurPoids !== undefined
                                               ? Number(statistiques.meilleurPoids).toFixed(1)
                                               : "0") + " kg"
                                        color: theme.accent
                                        font.pixelSize: 20
                                        font.bold: true
                                    }

                                    Text {
                                        text: "meilleure charge"
                                        color: theme.textHint
                                        font.pixelSize: 9
                                    }
                                }
                            }

                            // Meilleures reps
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 82
                                radius: theme.radiusLG
                                color: theme.bgCard
                                border.color: "#4FACFE44"
                                border.width: 1

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 4

                                    Text {
                                        text: "🔥"
                                        font.pixelSize: 16
                                    }

                                    Text {
                                        text: (statistiques.meilleuresReps !== undefined
                                               ? statistiques.meilleuresReps
                                               : 0) + " reps"
                                        color: theme.accentBlue
                                        font.pixelSize: 20
                                        font.bold: true
                                    }

                                    Text {
                                        text: "meilleur score"
                                        color: theme.textHint
                                        font.pixelSize: 9
                                    }
                                }
                            }

                            // Meilleur volume
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 82
                                radius: theme.radiusLG
                                color: theme.bgCard
                                border.color: "#A78BFA44"
                                border.width: 1

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 4

                                    Text {
                                        text: "📦"
                                        font.pixelSize: 16
                                    }

                                    Text {
                                        text: {
                                            var volume = statistiques.meilleurVolume !== undefined
                                                         ? Number(statistiques.meilleurVolume)
                                                         : 0

                                            if (volume >= 1000)
                                                return (volume / 1000).toFixed(1) + "k kg"

                                            return Math.round(volume) + " kg"
                                        }
                                        color: theme.gold
                                        font.pixelSize: 20
                                        font.bold: true
                                    }

                                    Text {
                                        text: "meilleur volume"
                                        color: theme.textHint
                                        font.pixelSize: 9
                                    }
                                }
                            }
                        }
                    }

                    // ── Graphique progression ─────────────────
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        spacing: 10

                        Text {
                            text: "ÉVOLUTION DE LA CHARGE"
                            color: theme.textHint
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 1
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 230
                            radius: theme.radiusLG
                            color: theme.bgCard
                            border.color: theme.border
                            border.width: 1

                            visible: progression.length > 0

                            Canvas {
                                id: progressionCanvas

                                anchors.fill: parent
                                anchors.margins: 16

                                property var points: progression

                                onPaint: {
                                    var ctx = getContext("2d")
                                    ctx.reset()

                                    if (!points || points.length === 0)
                                        return

                                    var width = progressionCanvas.width
                                    var height = progressionCanvas.height

                                    var values = []
                                    for (var i = 0; i < points.length; ++i)
                                        values.push(Number(points[i].meilleurPoids))

                                    var minValue = Math.min.apply(null, values)
                                    var maxValue = Math.max.apply(null, values)

                                    if (minValue === maxValue) {
                                        minValue -= 5
                                        maxValue += 5
                                    }

                                    var padding = (maxValue - minValue) * 0.15
                                    minValue -= padding
                                    maxValue += padding

                                    var left = 48
                                    var right = 16
                                    var top = 24
                                    var bottom = 34

                                    var chartWidth = width - left - right
                                    var chartHeight = height - top - bottom

                                    function xFor(index) {
                                        if (points.length === 1)
                                            return left + chartWidth / 2

                                        return left +
                                               (index / (points.length - 1)) * chartWidth
                                    }

                                    function yFor(value) {
                                        return top +
                                               (maxValue - value) /
                                               (maxValue - minValue) *
                                               chartHeight
                                    }

                                    // ── Grille + valeurs verticales ─────────────
                                    ctx.font = "10px sans-serif"
                                    ctx.textAlign = "right"
                                    ctx.textBaseline = "middle"

                                    for (var g = 0; g < 4; ++g) {
                                        var ratio = g / 3
                                        var gy = top + ratio * chartHeight
                                        var gridValue = maxValue -
                                                        ratio * (maxValue - minValue)

                                        ctx.beginPath()
                                        ctx.moveTo(left, gy)
                                        ctx.lineTo(left + chartWidth, gy)

                                        ctx.lineWidth = 1
                                        ctx.strokeStyle = Qt.rgba(
                                            theme.textPrimary.r,
                                            theme.textPrimary.g,
                                            theme.textPrimary.b,
                                            0.07
                                        )
                                        ctx.stroke()

                                        ctx.fillStyle = theme.textHint
                                        ctx.fillText(
                                            gridValue.toFixed(1),
                                            left - 8,
                                            gy
                                        )
                                    }

                                    // ── Courbe ─────────────────────────────────
                                    ctx.beginPath()

                                    for (var p = 0; p < points.length; ++p) {
                                        var px = xFor(p)
                                        var py = yFor(values[p])

                                        if (p === 0)
                                            ctx.moveTo(px, py)
                                        else
                                            ctx.lineTo(px, py)
                                    }

                                    ctx.lineWidth = 3
                                    ctx.strokeStyle = theme.accent
                                    ctx.lineJoin = "round"
                                    ctx.lineCap = "round"
                                    ctx.stroke()

                                    // ── Points + valeurs ───────────────────────
                                    ctx.textAlign = "center"
                                    ctx.textBaseline = "bottom"

                                    for (var j = 0; j < points.length; ++j) {
                                        var pointX = xFor(j)
                                        var pointY = yFor(values[j])

                                        ctx.beginPath()
                                        ctx.arc(pointX, pointY, 5, 0, Math.PI * 2)
                                        ctx.fillStyle = theme.bgPrimary
                                        ctx.fill()

                                        ctx.beginPath()
                                        ctx.arc(pointX, pointY, 3, 0, Math.PI * 2)
                                        ctx.fillStyle = theme.accent
                                        ctx.fill()

                                        ctx.fillStyle = theme.textPrimary
                                        ctx.font = "10px sans-serif"

                                        ctx.fillText(
                                            values[j].toFixed(1) + " kg",
                                            pointX,
                                            pointY - 9
                                        )
                                    }

                                    // ── Dates ──────────────────────────────────
                                    ctx.textBaseline = "top"
                                    ctx.fillStyle = theme.textHint
                                    ctx.font = "9px sans-serif"

                                    var maxLabels = 5
                                    var step = Math.max(
                                        1,
                                        Math.ceil(points.length / maxLabels)
                                    )

                                    for (var d = 0; d < points.length; d += step) {
                                        var dateText = String(points[d].date)

                                        if (dateText.length >= 10)
                                            dateText = dateText.substring(5)

                                        ctx.fillText(
                                            dateText,
                                            xFor(d),
                                            top + chartHeight + 10
                                        )
                                    }
                                }

                                Connections {
                                    target: root

                                    function onProgressionChanged() {
                                        progressionCanvas.requestPaint()
                                    }
                                }

                                Component.onCompleted: requestPaint()
                            }

                            // ── Dernière valeur ─────────────────
                            Text {
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.margins: 14

                                visible: progression.length > 0

                                text: {
                                    var last = progression[progression.length - 1]
                                    return Number(last.meilleurPoids).toFixed(1) + " kg"
                                }

                                color: theme.accent
                                font.pixelSize: 16
                                font.bold: true
                            }
                        }

                        // État sans données suffisantes
                        Rectangle {
                            Layout.fillWidth: true
                            height: 150
                            radius: theme.radiusLG
                            color: theme.bgCard
                            border.color: theme.border
                            border.width: 1

                            visible: progression.length === 0

                            Column {
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: "📈"
                                    font.pixelSize: 30
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    text: "Pas encore assez de données"
                                    color: theme.textPrimary
                                    font.pixelSize: theme.fontMD
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    text: "Ton évolution apparaîtra après tes premières séances."
                                    color: theme.textHint
                                    font.pixelSize: theme.fontSM
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }
                    // ── Comparaison dernière séance ─────────────
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        spacing: 10

                        Text {
                            text: "COMPARAISON"
                            color: theme.textHint
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 1
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: comparaisonExiste ? 132 : 110

                            radius: theme.radiusLG
                            color: theme.bgCard
                            border.color: theme.border
                            border.width: 1

                            property bool comparaisonExiste: progression.length >= 2

                            visible: true

                            // ── Avec au moins 2 séances ─────────────
                            Column {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 12
                                visible: comparaisonExiste

                                Row {
                                    width: parent.width
                                    spacing: 10

                                    Text {
                                        text: "📊"
                                        font.pixelSize: 18
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 2

                                        Text {
                                            text: "Dernière séance"
                                            color: theme.textPrimary
                                            font.pixelSize: theme.fontMD
                                            font.bold: true
                                        }

                                        Text {
                                            text: "vs séance précédente"
                                            color: theme.textHint
                                            font.pixelSize: 9
                                        }
                                    }
                                }

                                Row {
                                    width: parent.width
                                    spacing: 8

                                    // Poids
                                    Rectangle {
                                        width: (parent.width - 16) / 3
                                        height: 48
                                        radius: theme.radiusMD
                                        color: theme.bgInput

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 2

                                            Text {
                                                text: "CHARGE"
                                                color: theme.textHint
                                                font.pixelSize: 8
                                                font.bold: true
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }

                                            Text {
                                                text: {
                                                    var delta = Number(comparaison.poidsDelta)

                                                    if (Math.abs(delta) < 0.01)
                                                        return "—"

                                                    return (delta > 0 ? "+" : "") +
                                                           delta.toFixed(1) + " kg"
                                                }

                                                color: comparaison.poidsDelta > 0
                                                       ? theme.accentGreen
                                                       : comparaison.poidsDelta < 0
                                                         ? theme.accentRed
                                                         : theme.textSecondary

                                                font.pixelSize: 14
                                                font.bold: true
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }
                                    }

                                    // Reps
                                    Rectangle {
                                        width: (parent.width - 16) / 3
                                        height: 48
                                        radius: theme.radiusMD
                                        color: theme.bgInput

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 2

                                            Text {
                                                text: "REPS"
                                                color: theme.textHint
                                                font.pixelSize: 8
                                                font.bold: true
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }

                                            Text {
                                                text: {
                                                    var delta = Number(comparaison.repsDelta)

                                                    if (delta === 0)
                                                        return "—"

                                                    return (delta > 0 ? "+" : "") +
                                                           delta + " reps"
                                                }

                                                color: comparaison.repsDelta > 0
                                                       ? theme.accentGreen
                                                       : comparaison.repsDelta < 0
                                                         ? theme.accentRed
                                                         : theme.textSecondary

                                                font.pixelSize: 14
                                                font.bold: true
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }
                                    }

                                    // Volume
                                    Rectangle {
                                        width: (parent.width - 16) / 3
                                        height: 48
                                        radius: theme.radiusMD
                                        color: theme.bgInput

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 2

                                            Text {
                                                text: "VOLUME"
                                                color: theme.textHint
                                                font.pixelSize: 8
                                                font.bold: true
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }

                                            Text {
                                                text: {
                                                    var delta = Number(comparaison.volumeDelta)

                                                    if (Math.abs(delta) < 0.01)
                                                        return "—"

                                                    if (Math.abs(delta) >= 1000)
                                                        return (delta > 0 ? "+" : "") +
                                                               (delta / 1000).toFixed(1) + "k"

                                                    return (delta > 0 ? "+" : "") +
                                                           Math.round(delta)
                                                }

                                                color: comparaison.volumeDelta > 0
                                                       ? theme.accentGreen
                                                       : comparaison.volumeDelta < 0
                                                         ? theme.accentRed
                                                         : theme.textSecondary

                                                font.pixelSize: 14
                                                font.bold: true
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }
                                    }
                                }
                            }

                            // ── Pas encore assez de séances ─────────
                            Column {
                                anchors.centerIn: parent
                                spacing: 7
                                visible: !comparaisonExiste

                                Text {
                                    text: "📈"
                                    font.pixelSize: 26
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    text: "Encore une séance pour comparer"
                                    color: theme.textPrimary
                                    font.pixelSize: theme.fontSM
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    text: "La progression apparaîtra ici."
                                    color: theme.textHint
                                    font.pixelSize: 9
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }
                    // ── Recommandation progression ─────────────────
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        spacing: 10

                        Text {
                            text: "PROCHAINE SÉANCE"
                            color: theme.textHint
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 1
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 112
                            radius: theme.radiusLG
                            color: theme.bgCard
                            border.color: suggestion.type === "charge"
                                          ? Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.30)
                                          : theme.border
                            border.width: 1

                            Row {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 14

                                Rectangle {
                                    width: 46
                                    height: 46
                                    radius: 14
                                    color: suggestion.type === "charge"
                                           ? Qt.rgba(theme.accent.r, theme.accent.g, theme.accent.b, 0.12)
                                           : theme.bgInput
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        text: suggestion.type === "charge"
                                              ? "🚀"
                                              : suggestion.type === "reps"
                                                ? "🔥"
                                                : "💡"
                                        font.pixelSize: 22
                                        anchors.centerIn: parent
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 5
                                    width: parent.width - 60

                                    Text {
                                        text: suggestion.titre !== undefined
                                              ? suggestion.titre
                                              : "Continue ta progression"
                                        color: theme.textPrimary
                                        font.pixelSize: theme.fontMD
                                        font.bold: true
                                        width: parent.width
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: suggestion.message !== undefined
                                              ? suggestion.message
                                              : "Tes performances permettront bientôt une recommandation."
                                        color: theme.textSecondary
                                        font.pixelSize: 10
                                        width: parent.width
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 2
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        visible: suggestion.chargeProposee !== undefined &&
                                                 suggestion.chargeProposee > 0

                                        text: "Objectif : " +
                                              Number(suggestion.chargeProposee).toFixed(1) +
                                              " kg" +
                                              (suggestion.repsProposees !== undefined
                                               ? " × " + suggestion.repsProposees + " reps"
                                               : "")

                                        color: theme.accent
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
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
                                    border.color: Qt.rgba(
                                        theme.accent.r,
                                        theme.accent.g,
                                        theme.accent.b,
                                        0.27
                                    )

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