import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FitCoach

Item {
    Theme { id: theme }

    property bool showAddPoids: false

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

                        Column {
                            spacing: 4
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 140

                            Text {
                                text: "Progression"
                                color: theme.textPrimary
                                font.pixelSize: theme.fontXL
                                font.bold: true
                            }
                            Text {
                                text: "Ton évolution"
                                color: theme.textSecondary
                                font.pixelSize: theme.fontSM
                            }
                        }

                        Rectangle {
                            width: 120
                            height: 38
                            radius: 10
                            anchors.verticalCenter: parent.verticalCenter

                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "#00D4AA" }
                                GradientStop { position: 1.0; color: "#4FACFE" }
                            }

                            Text {
                                text: "⚖️ Mon poids"
                                color: "white"
                                font.pixelSize: theme.fontSM
                                font.bold: true
                                anchors.centerIn: parent
                            }

                            scale: poidsBtn.pressed ? 0.95 : 1.0
                            Behavior on scale { NumberAnimation { duration: 100 } }

                            MouseArea {
                                id: poidsBtn
                                anchors.fill: parent
                                onClicked: showAddPoids = true
                            }
                        }
                    }
                }

                // ── Stats hero ────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.bottomMargin: 16
                    height: 130
                    radius: theme.radiusLG
                    color: theme.bgCard
                    clip: true

                    Rectangle {
                        anchors.top: parent.top
                        width: parent.width
                        height: 2
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.3; color: "#00D4AA" }
                            GradientStop { position: 0.7; color: "#4FACFE" }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }

                    Row {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 0

                        Column {
                            width: parent.width * 0.45
                            spacing: 6
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: "POIDS ACTUEL"
                                color: theme.textHint
                                font.pixelSize: 9
                                font.bold: true
                                font.letterSpacing: 1
                            }
                            Text {
                                text: progressVM.poidsActuel + " kg"
                                color: theme.textPrimary
                                font.pixelSize: 30
                                font.bold: true
                            }
                            Rectangle {
                                width: 70; height: 22; radius: 11
                                color: progressVM.poidsDiff <= 0 ? "#0d2e1a" : "#2e0d0d"
                                border.color: progressVM.poidsDiff <= 0 ? "#00D4AA" : "#FF6B6B"
                                border.width: 1

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 3

                                    Text {
                                        text: progressVM.poidsDiff <= 0 ? "📉" : "📈"
                                        font.pixelSize: 10
                                    }
                                    Text {
                                        text: (progressVM.poidsDiff >= 0 ? "+" : "") +
                                              progressVM.poidsDiff.toFixed(1) + " kg"
                                        color: progressVM.poidsDiff <= 0 ? "#00D4AA" : "#FF6B6B"
                                        font.pixelSize: 10
                                        font.bold: true
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: 1
                            height: parent.height * 0.6
                            color: theme.border
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            width: parent.width * 0.55
                            spacing: 14
                            anchors.verticalCenter: parent.verticalCenter
                            leftPadding: 16

                            Row {
                                spacing: 10
                                Rectangle {
                                    width: 32; height: 32; radius: 16
                                    color: "#00D4AA22"
                                    Text { text: "💪"; font.pixelSize: 16; anchors.centerIn: parent }
                                }
                                Column {
                                    spacing: 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        text: progressVM.totalSeances + " séances"
                                        color: theme.textPrimary
                                        font.pixelSize: 13; font.bold: true
                                    }
                                    Text { text: "au total"; color: theme.textHint; font.pixelSize: 10 }
                                }
                            }

                            Row {
                                spacing: 10
                                Rectangle {
                                    width: 32; height: 32; radius: 16
                                    color: "#FF6B6B22"
                                    Text { text: "🔥"; font.pixelSize: 16; anchors.centerIn: parent }
                                }
                                Column {
                                    spacing: 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        text: progressVM.streakJours + " jours"
                                        color: progressVM.streakJours > 0 ? "#fab387" : theme.textPrimary
                                        font.pixelSize: 13; font.bold: true
                                    }
                                    Text { text: "de streak"; color: theme.textHint; font.pixelSize: 10 }
                                }
                            }
                        }
                    }
                }

                // ── Top PRs ───────────────────────
                Row {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.bottomMargin: 8

                    Text {
                        text: "🏆 MES RECORDS"
                        color: theme.textHint
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: 50; height: 20; radius: 10
                        color: "#FFD70022"
                        border.color: "#FFD70044"
                        border.width: 1

                        Text {
                            text: "Top 5"
                            color: "#FFD700"
                            font.pixelSize: 10
                            font.bold: true
                            anchors.centerIn: parent
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.bottomMargin: 16
                    height: progressVM.topPRs.length > 0
                            ? progressVM.topPRs.length * 62 + 16
                            : 80
                    radius: theme.radiusLG
                    color: theme.bgCard
                    border.color: theme.border
                    border.width: 1

                    // Glow doré
                    Rectangle {
                        anchors.top: parent.top
                        width: parent.width
                        height: 2
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.3; color: "#FFD700" }
                            GradientStop { position: 0.7; color: "#FFD700" }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }

                    Column {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Repeater {
                            model: progressVM.topPRs

                            Rectangle {
                                width: parent.width
                                height: 54
                                radius: theme.radiusSM
                                color: "#FFD70008"
                                border.color: "#FFD70022"
                                border.width: 1

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10

                                    // Rang
                                    Rectangle {
                                        width: 28; height: 28; radius: 14
                                        color: index === 0 ? "#FFD700" :
                                               index === 1 ? "#C0C0C0" :
                                               index === 2 ? "#CD7F32" : "#1e2a3a"
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            text: (index + 1) + ""
                                            color: index < 3 ? "#0A0E17" : theme.textHint
                                            font.pixelSize: 12
                                            font.bold: true
                                            anchors.centerIn: parent
                                        }
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 3
                                        width: parent.width - 28 - 80 - 20

                                        Text {
                                            text: modelData.nom
                                            color: theme.textPrimary
                                            font.pixelSize: theme.fontSM
                                            font.bold: true
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }
                                        Text {
                                            text: modelData.date
                                            color: theme.textHint
                                            font.pixelSize: 10
                                        }
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 2

                                        Text {
                                            text: modelData.poids + " kg"
                                            color: "#FFD700"
                                            font.pixelSize: 13
                                            font.bold: true
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                        Text {
                                            text: "× " + modelData.reps + " reps"
                                            color: theme.textHint
                                            font.pixelSize: 10
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                }
                            }
                        }

                        // Vide
                        Text {
                            text: "Fais ta première séance pour voir tes records 🏆"
                            color: theme.textHint
                            font.pixelSize: theme.fontSM
                            visible: progressVM.topPRs.length === 0
                            wrapMode: Text.WordWrap
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                // ── Progression des badges ─────────────────────
                Row {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.bottomMargin: 8

                    Text {
                        text: "🏆 PROGRESSION"
                        color: theme.textHint
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: progressVM.progressionBadges.filter(function(b) {
                            return b.debloque
                        }).length + " / " + progressVM.progressionBadges.length
                        color: theme.accent
                        font.pixelSize: 10
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.bottomMargin: 16

                    height: Math.max(
                        120,
                        Math.ceil(progressVM.progressionBadges.length / 2) * 105 + 16
                    )

                    radius: theme.radiusLG
                    color: theme.bgCard
                    border.color: theme.border
                    border.width: 1

                    GridLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        columns: 2
                        columnSpacing: 10
                        rowSpacing: 10

                        Repeater {
                            model: progressVM.progressionBadges

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 95

                                radius: theme.radiusSM

                                color: modelData.debloque
                                       ? "#FFD70010"
                                       : theme.bgInput

                                border.color: modelData.debloque
                                              ? "#FFD70055"
                                              : theme.border
                                border.width: 1

                                opacity: modelData.debloque ? 1.0 : 0.75

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 5

                                    Row {
                                        width: parent.width
                                        spacing: 6

                                        Text {
                                            text: modelData.debloque
                                                  ? modelData.nom
                                                  : "🔒 " + modelData.nom

                                            color: modelData.debloque
                                                   ? theme.textPrimary
                                                   : theme.textSecondary

                                            font.pixelSize: 11
                                            font.bold: true

                                            elide: Text.ElideRight
                                            width: parent.width - 26
                                        }
                                    }

                                    Text {
                                        text: modelData.description
                                        color: theme.textHint
                                        font.pixelSize: 9

                                        wrapMode: Text.WordWrap
                                        width: parent.width
                                        maximumLineCount: 2
                                        elide: Text.ElideRight
                                    }

                                    Item {
                                        width: parent.width
                                        height: 8
                                    }

                                    Rectangle {
                                        width: parent.width
                                        height: 6
                                        radius: 3
                                        color: "#2a2a3a"

                                        Rectangle {
                                            width: parent.width *
                                                   (modelData.pourcentage / 100.0)
                                            height: parent.height
                                            radius: 3

                                            color: modelData.debloque
                                                   ? "#FFD700"
                                                   : theme.accent

                                            Behavior on width {
                                                NumberAnimation {
                                                    duration: 500
                                                    easing.type: Easing.OutCubic
                                                }
                                            }
                                        }
                                    }

                                    Row {
                                        width: parent.width

                                        Text {
                                            text: modelData.progression +
                                                  " / " +
                                                  modelData.objectif

                                            color: theme.textHint
                                            font.pixelSize: 9
                                        }

                                        Item { width: parent.width - 70 }

                                        Text {
                                            text: modelData.debloque
                                                  ? "✅"
                                                  : modelData.pourcentage + "%"

                                            color: modelData.debloque
                                                   ? theme.accent
                                                   : theme.textHint

                                            font.pixelSize: 9
                                            font.bold: true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Répartition musculaire ────────
                Row {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.bottomMargin: 8

                    Text {
                        text: "RÉPARTITION MUSCULAIRE"
                        color: theme.textHint
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "7 derniers jours"
                        color: theme.textHint
                        font.pixelSize: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle {
                    id: repartCard
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.bottomMargin: 16
                    height: 200
                    radius: theme.radiusLG
                    color: theme.bgCard
                    border.color: theme.border
                    border.width: 1

                    property var repartData: []

                    Component.onCompleted: {
                        repartData = progressVM.repartitionMusculaire
                    }

                    Connections {
                        target: progressVM
                        function onDataChanged() {
                            repartCard.repartData = progressVM.repartitionMusculaire
                            donutChart.animProgress = 0
                            donutChart.requestPaint()
                        }
                    }

                    property real totalVolume: {
                        var t = 0
                        for (var i = 0; i < repartData.length; i++) t += repartData[i].volume
                        return t
                    }

                    Row {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 20
                        visible: repartCard.totalVolume > 0

                        // ── Donut chart ──
                        Canvas {
                            id: donutChart
                            width: 130
                            height: 130
                            anchors.verticalCenter: parent.verticalCenter

                            property real animProgress: 0

                            NumberAnimation on animProgress {
                                from: 0; to: 1
                                duration: 900
                                easing.type: Easing.OutCubic
                                running: true
                            }

                            onAnimProgressChanged: requestPaint()

                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)

                                var data = repartCard.repartData
                                var total = repartCard.totalVolume
                                if (total <= 0) return

                                var cx = width / 2
                                var cy = height / 2
                                var radius = Math.min(width, height) / 2 - 4
                                var innerRadius = radius * 0.6

                                var startAngle = -Math.PI / 2

                                for (var i = 0; i < data.length; i++) {
                                    if (data[i].volume <= 0) continue
                                    var sweep = (data[i].volume / total) * Math.PI * 2 * animProgress

                                    ctx.beginPath()
                                    ctx.moveTo(cx + Math.cos(startAngle) * innerRadius,
                                               cy + Math.sin(startAngle) * innerRadius)
                                    ctx.arc(cx, cy, radius, startAngle, startAngle + sweep, false)
                                    ctx.arc(cx, cy, innerRadius, startAngle + sweep, startAngle, true)
                                    ctx.closePath()
                                    ctx.fillStyle = data[i].color
                                    ctx.fill()

                                    startAngle += sweep
                                }
                            }
                        }

                        // ── Légende ──
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10
                            width: parent.width - 130 - 20

                            Repeater {
                                model: repartCard.repartData

                                Row {
                                    width: parent.width
                                    spacing: 8

                                    Rectangle {
                                        width: 10; height: 10; radius: 5
                                        color: modelData.color
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: modelData.emoji + " " + modelData.categorie
                                        color: theme.textPrimary
                                        font.pixelSize: 12
                                        font.bold: true
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 90
                                    }

                                    Text {
                                        text: modelData.pct + "%"
                                        color: theme.textHint
                                        font.pixelSize: 12
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        text: "Fais des séances pour voir ta répartition 🎯"
                        color: theme.textHint
                        font.pixelSize: theme.fontSM
                        anchors.centerIn: parent
                        visible: repartCard.totalVolume === 0
                        wrapMode: Text.WordWrap
                        width: parent.width - 32
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                // ── Calories cette semaine ────────
                Row {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.bottomMargin: 8

                    Text {
                        text: "CALORIES CETTE SEMAINE"
                        color: theme.textHint
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.bottomMargin: 16
                    height: 180
                    radius: theme.radiusLG
                    color: theme.bgCard
                    border.color: theme.border
                    border.width: 1

                    Canvas {
                        id: caloriesChart
                        anchors.fill: parent
                        anchors.margins: 16

                        property var chartData: []
                        property real animProgress: 0

                        NumberAnimation on animProgress {
                            from: 0; to: 1
                            duration: 1000
                            easing.type: Easing.OutCubic
                            running: true
                        }

                        onAnimProgressChanged: requestPaint()

                        Component.onCompleted: {
                            chartData = progressVM.caloriesWeek
                            requestPaint()
                        }

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            if (chartData.length === 0) return

                            var maxCal = 0
                            for (var i = 0; i < chartData.length; i++)
                                if (chartData[i].calories > maxCal)
                                    maxCal = chartData[i].calories
                            if (maxCal === 0) return

                            var barW = (width - (chartData.length - 1) * 8) / chartData.length
                            var maxH = height - 40

                            for (var j = 0; j < chartData.length; j++) {
                                var barH = (chartData[j].calories / maxCal) * maxH * animProgress
                                var x = j * (barW + 8)
                                var y = height - barH - 22
                                var isToday = j === chartData.length - 1

                                var grad = ctx.createLinearGradient(x, y, x, height)
                                if (isToday) {
                                    grad.addColorStop(0, "#4FACFE")
                                    grad.addColorStop(1, "#00D4AA")
                                } else {
                                    grad.addColorStop(0, "#00D4AA44")
                                    grad.addColorStop(1, "#00D4AA22")
                                }

                                ctx.fillStyle = grad
                                ctx.beginPath()
                                if (barH > 6) {
                                    ctx.moveTo(x + 4, y + 6)
                                    ctx.quadraticCurveTo(x, y + 6, x, y + 6)
                                    ctx.arcTo(x, y, x + barW, y, 4)
                                    ctx.arcTo(x + barW, y, x + barW, y + barH, 4)
                                    ctx.lineTo(x + barW, height - 22)
                                    ctx.lineTo(x, height - 22)
                                    ctx.closePath()
                                } else {
                                    ctx.rect(x, y, barH > 0 ? barW : 0, barH)
                                }
                                ctx.fill()

                                if (chartData[j].calories > 0 && animProgress > 0.8) {
                                    ctx.fillStyle = isToday ? "#ffffff" : "#888888"
                                    ctx.font = isToday ? "bold 10px sans-serif" : "9px sans-serif"
                                    ctx.textAlign = "center"
                                    ctx.fillText(chartData[j].calories, x + barW/2, y - 4)
                                }

                                var d = new Date(chartData[j].date)
                                var days = ["Di","Lu","Ma","Me","Je","Ve","Sa"]
                                ctx.fillStyle = isToday ? "#00D4AA" : "#555555"
                                ctx.font = isToday ? "bold 10px sans-serif" : "10px sans-serif"
                                ctx.textAlign = "center"
                                ctx.fillText(days[d.getDay()], x + barW/2, height - 6)
                            }
                        }

                    }

                    Text {
                        text: "Aucune donnée cette semaine"
                        color: theme.textHint
                        font.pixelSize: theme.fontSM
                        anchors.centerIn: parent
                        visible: progressVM.caloriesWeek.length === 0
                    }
                }

                // ── Courbe poids ──────────────────
                Row {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.bottomMargin: 8

                    Text {
                        text: "COURBE DE POIDS"
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
                            text: progressVM.poidsHistory.length + " entrées"
                            color: theme.accent
                            font.pixelSize: 10
                            font.bold: true
                            anchors.centerIn: parent
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.bottomMargin: 24
                    height: 190
                    radius: theme.radiusLG
                    color: theme.bgCard
                    border.color: theme.border
                    border.width: 1
                    clip: true

                    Canvas {
                        id: poidsChart
                        anchors.fill: parent
                        anchors.margins: 16

                        property var chartData: []
                        property real animProgress: 0

                        NumberAnimation on animProgress {
                            id: poidsAnim
                            from: 0; to: 1
                            duration: 1200
                            easing.type: Easing.OutCubic
                            running: true
                        }

                        onAnimProgressChanged: requestPaint()

                        Component.onCompleted: {
                            chartData = progressVM.poidsHistory
                            requestPaint()
                        }

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            if (chartData.length < 2) return

                            var minP = chartData[0].poids
                            var maxP = chartData[0].poids
                            for (var i = 0; i < chartData.length; i++) {
                                if (chartData[i].poids < minP) minP = chartData[i].poids
                                if (chartData[i].poids > maxP) maxP = chartData[i].poids
                            }

                            var range = maxP - minP || 1
                            var padH  = height - 44
                            var totalPoints = Math.max(1, Math.floor(chartData.length * animProgress))

                            var points = []
                            for (var p = 0; p < totalPoints; p++) {
                                points.push({
                                    x: (p / (chartData.length - 1)) * (width - 40) + 20,
                                    y: padH - ((chartData[p].poids - minP) / range) * (padH - 20) + 10,
                                    poids: chartData[p].poids,
                                    date: chartData[p].date
                                })
                            }

                            if (points.length < 2) return

                            ctx.beginPath()
                            ctx.moveTo(points[0].x, points[0].y)
                            for (var a = 1; a < points.length; a++) {
                                var cpx = (points[a-1].x + points[a].x) / 2
                                ctx.bezierCurveTo(cpx, points[a-1].y, cpx, points[a].y, points[a].x, points[a].y)
                            }
                            ctx.lineTo(points[points.length-1].x, padH + 10)
                            ctx.lineTo(points[0].x, padH + 10)
                            ctx.closePath()

                            var fillGrad = ctx.createLinearGradient(0, 0, 0, height)
                            fillGrad.addColorStop(0, "#00D4AA33")
                            fillGrad.addColorStop(1, "#00D4AA05")
                            ctx.fillStyle = fillGrad
                            ctx.fill()

                            var lineGrad = ctx.createLinearGradient(0, 0, width, 0)
                            lineGrad.addColorStop(0, "#4FACFE")
                            lineGrad.addColorStop(1, "#00D4AA")

                            ctx.beginPath()
                            ctx.moveTo(points[0].x, points[0].y)
                            for (var j = 1; j < points.length; j++) {
                                var cpx2 = (points[j-1].x + points[j].x) / 2
                                ctx.bezierCurveTo(cpx2, points[j-1].y, cpx2, points[j].y, points[j].x, points[j].y)
                            }
                            ctx.strokeStyle = lineGrad
                            ctx.lineWidth = 2.5
                            ctx.lineJoin = "round"
                            ctx.stroke()

                            for (var k = 0; k < points.length; k++) {
                                var px = points[k].x
                                var py = points[k].y
                                var isLast = k === points.length - 1

                                ctx.beginPath()
                                ctx.arc(px, py, isLast ? 10 : 7, 0, Math.PI * 2)
                                ctx.fillStyle = isLast ? "#00D4AA33" : "#00D4AA22"
                                ctx.fill()

                                ctx.beginPath()
                                ctx.arc(px, py, isLast ? 5 : 3.5, 0, Math.PI * 2)
                                ctx.fillStyle = isLast ? "#00D4AA" : "#4FACFE"
                                ctx.fill()

                                ctx.beginPath()
                                ctx.arc(px, py, isLast ? 2.5 : 1.5, 0, Math.PI * 2)
                                ctx.fillStyle = "#ffffff"
                                ctx.fill()

                                ctx.fillStyle = isLast ? "#ffffff" : "#AAAAAA"
                                ctx.font = isLast ? "bold 9px sans-serif" : "9px sans-serif"
                                ctx.textAlign = "center"
                                ctx.fillText(points[k].poids + "kg", px, py - 14)

                                if (k === 0 || k === points.length - 1 ||
                                    k === Math.floor(points.length / 2)) {
                                    var parts = points[k].date.split("-")
                                    var label = parts[2] + "/" + parts[1]
                                    ctx.fillStyle = isLast ? "#00D4AA" : "#555555"
                                    ctx.font = isLast ? "bold 9px sans-serif" : "9px sans-serif"
                                    ctx.fillText(label, px, height - 4)
                                }
                            }
                        }

                        Connections {
                            target: progressVM
                            function onDataChanged() {
                                poidsChart.chartData = progressVM.poidsHistory
                                poidsChart.animProgress = 0
                                poidsAnim.restart()
                            }
                        }
                    }

                    Text {
                        text: "Ajoute au moins 2 pesées pour voir ta courbe 📈"
                        color: theme.textHint
                        font.pixelSize: theme.fontSM
                        anchors.centerIn: parent
                        visible: progressVM.poidsHistory.length < 2
                        wrapMode: Text.WordWrap
                        width: parent.width - 32
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Item { height: 20 }
            }
        }

        // ── Popup poids ───────────────────────
        Rectangle {
            anchors.fill: parent
            color: "#AA000000"
            visible: showAddPoids
            z: 20

            MouseArea {
                anchors.fill: parent
                onClicked: showAddPoids = false
            }

            Rectangle {
                id: addPoidsPopup
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 280
                radius: theme.radiusXL
                color: theme.bgCard

                property real mPoids: progressVM.poidsActuel
                MouseArea { anchors.fill: parent }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 20

                    Rectangle {
                        width: 40; height: 4; radius: 2
                        color: theme.border
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "Mon poids aujourd'hui"
                        color: theme.textPrimary
                        font.pixelSize: theme.fontLG
                        font.bold: true
                    }

                    Row {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 28

                        Rectangle {
                            width: 52; height: 52; radius: 26
                            color: theme.bgInput
                            border.color: theme.border; border.width: 1

                            Text {
                                text: "−"; color: theme.textPrimary
                                font.pixelSize: 26; font.bold: true
                                anchors.centerIn: parent
                            }

                            scale: moinsArea.pressed ? 0.9 : 1.0
                            Behavior on scale { NumberAnimation { duration: 80 } }

                            MouseArea {
                                id: moinsArea
                                anchors.fill: parent
                                onClicked: addPoidsPopup.mPoids = Math.max(30, addPoidsPopup.mPoids - 0.5)
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: addPoidsPopup.mPoids.toFixed(1)
                                color: theme.accent
                                font.pixelSize: 40; font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: "kilogrammes"
                                color: theme.textHint; font.pixelSize: 11
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        Rectangle {
                            width: 52; height: 52; radius: 26
                            color: theme.bgInput
                            border.color: theme.border; border.width: 1

                            Text {
                                text: "+"; color: theme.textPrimary
                                font.pixelSize: 26; font.bold: true
                                anchors.centerIn: parent
                            }

                            scale: plusArea.pressed ? 0.9 : 1.0
                            Behavior on scale { NumberAnimation { duration: 80 } }

                            MouseArea {
                                id: plusArea
                                anchors.fill: parent
                                onClicked: addPoidsPopup.mPoids = Math.min(300, addPoidsPopup.mPoids + 0.5)
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 52; radius: theme.radiusLG

                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#00D4AA" }
                            GradientStop { position: 1.0; color: "#4FACFE" }
                        }

                        scale: saveBtn.pressed ? 0.97 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        Text {
                            text: "Enregistrer ✓"
                            color: "white"
                            font.pixelSize: theme.fontMD; font.bold: true
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            id: saveBtn
                            anchors.fill: parent
                            onClicked: {
                                progressVM.ajouterPoids(addPoidsPopup.mPoids)
                                homeVM.refresh()
                                showAddPoids = false
                            }
                        }
                    }
                }
            }
        }
    }
}