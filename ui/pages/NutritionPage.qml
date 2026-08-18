import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import FitCoach

Item {
    Theme { id: theme }

    property bool showAddMeal:           false
    property bool showEditMeal:          false
    property bool showDeleteMealConfirm: false
    property bool showObjectif:          false
    property bool showPhotoResult:       false
    property int  mealToDelete:          -1
    property string mealToDeleteName:    ""
    property string selectedPhotoPath:   ""
    property string photoMoment:         "Déjeuner"

    property int    editMealId:      -1
    property string editMealNom:     ""
    property int    editMealCal:     0
    property real   editMealProt:    0
    property real   editMealGluc:    0
    property real   editMealLip:     0
    property string editMealMoment:  "Déjeuner"

    // FileDialog pour sélectionner une photo
    FileDialog {
        id: fileDialog
        title: "Choisir une photo de repas"
        nameFilters: ["Images (*.jpg *.jpeg *.png *.webp)"]
        onAccepted: {
            selectedPhotoPath = fileDialog.selectedFile
            coachVM.analyserPhoto(selectedPhotoPath)
            showPhotoResult = true
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
                height: 90
                color: "transparent"

                Row {
                    anchors.fill: parent
                    anchors.margins: 20
                    anchors.rightMargin: 16
                    spacing: 8

                    Column {
                        spacing: 6
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 160

                        Text {
                            text: "Nutrition"
                            color: theme.textPrimary
                            font.pixelSize: theme.fontXL
                            font.bold: true
                        }

                        Row {
                            spacing: 8

                            Rectangle {
                                width: 26
                                height: 26
                                radius: 6
                                color: theme.bgInput
                                border.color: theme.border
                                border.width: 1
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    text: "‹"
                                    color: theme.textPrimary
                                    font.pixelSize: 18
                                    font.bold: true
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: nutritionVM.previousDay()
                                }
                            }

                            Text {
                                text: nutritionVM.currentDateDisplay
                                color: nutritionVM.isToday
                                       ? theme.accent : theme.textSecondary
                                font.pixelSize: theme.fontSM
                                font.bold: nutritionVM.isToday
                                anchors.verticalCenter: parent.verticalCenter

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: nutritionVM.goToToday()
                                }
                            }

                            Rectangle {
                                width: 26
                                height: 26
                                radius: 6
                                color: theme.bgInput
                                border.color: theme.border
                                border.width: 1
                                opacity: nutritionVM.isToday ? 0.3 : 1.0
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    text: "›"
                                    color: theme.textPrimary
                                    font.pixelSize: 18
                                    font.bold: true
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if (!nutritionVM.isToday)
                                            nutritionVM.nextDay()
                                    }
                                }
                            }
                        }
                    }

                    // Bouton photo 📷
                    Rectangle {
                        width: 42
                        height: 38
                        radius: 10
                        color: theme.bgCard
                        border.color: theme.accent
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter
                        visible: nutritionVM.isToday

                        Text {
                            text: "📷"
                            font.pixelSize: 18
                            anchors.centerIn: parent
                        }

                        scale: photoBtn.pressed ? 0.95 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        MouseArea {
                            id: photoBtn
                            anchors.fill: parent
                            onClicked: fileDialog.open()
                        }
                    }

                    // Bouton + Ajouter
                    Rectangle {
                        width: 100
                        height: 38
                        radius: 10
                        color: theme.accent
                        anchors.verticalCenter: parent.verticalCenter
                        visible: nutritionVM.isToday

                        Text {
                            text: "+ Ajouter"
                            color: "white"
                            font.pixelSize: theme.fontSM
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        scale: addBtn.pressed ? 0.95 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        MouseArea {
                            id: addBtn
                            anchors.fill: parent
                            onClicked: showAddMeal = true
                        }
                    }
                }
            }

            // ── Résumé macros ─────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.bottomMargin: 8
                height: 100
                radius: theme.radiusLG
                color: theme.bgCard
                border.color: theme.border
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    Row {
                        width: parent.width
                        spacing: 8

                        Text {
                            text: nutritionVM.totalCalories + " kcal"
                            color: theme.textPrimary
                            font.pixelSize: theme.fontLG
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Item { width: 1; Layout.fillWidth: true }

                        Rectangle {
                            height: 22
                            width: objectifText.implicitWidth + 16
                            radius: 11
                            color: theme.bgInput
                            border.color: theme.accent
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id: objectifText
                                text: "🎯 " + homeVM.caloriesObjectif + " kcal"
                                color: theme.accent
                                font.pixelSize: 10
                                font.bold: true
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: showObjectif = true
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: 0

                        Repeater {
                            model: [
                                { label: "Protéines", val: Math.round(nutritionVM.totalProteines), unit: "g", color: "#00D4AA" },
                                { label: "Glucides",  val: Math.round(nutritionVM.totalGlucides),  unit: "g", color: "#00C896" },
                                { label: "Lipides",   val: Math.round(nutritionVM.totalLipides),   unit: "g", color: "#FF6B6B" }
                            ]

                            Column {
                                width: parent.width / 3
                                spacing: 3

                                Row {
                                    spacing: 4
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    Rectangle {
                                        width: 8; height: 8; radius: 4
                                        color: modelData.color
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: modelData.val + modelData.unit
                                        color: modelData.color
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                }

                                Text {
                                    text: modelData.label
                                    color: theme.textHint
                                    font.pixelSize: 10
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }
                }
            }

            // ── Titre liste ───────────────────
            Item {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.topMargin: 8
                height: 24

                Text {
                    text: "REPAS DU JOUR"
                    color: theme.textHint
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: nutritionVM.totalCalories + " / " + homeVM.caloriesObjectif + " kcal"
                    color: theme.accent
                    font.pixelSize: 10
                    font.bold: true
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // ── Liste repas ───────────────────
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.topMargin: 8
                spacing: 8
                clip: true

                model: nutritionVM.meals

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 72
                    radius: theme.radiusMD
                    color: theme.bgCard
                    border.color: theme.border
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Rectangle {
                            width: 46
                            height: 46
                            radius: theme.radiusSM
                            color: theme.bgInput
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                font.pixelSize: 24
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
                            spacing: 4
                            width: parent.width - 46 - 100 - 24

                            Text {
                                text: nom
                                color: theme.textPrimary
                                font.pixelSize: theme.fontMD
                                font.bold: true
                                elide: Text.ElideRight
                                width: parent.width
                            }
                            Row {
                                spacing: 6

                                Rectangle {
                                    width: 6; height: 6; radius: 3
                                    color: {
                                        if (moment === "Petit-déjeuner") return "#FAC775"
                                        if (moment === "Déjeuner")       return "#89b4fa"
                                        if (moment === "Collation")      return "#a6e3a1"
                                        return "#cba6f7"
                                    }
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: moment + " · " + heure.substring(0, 5)
                                    color: theme.textSecondary
                                    font.pixelSize: theme.fontSM
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4
                            width: 90

                            Text {
                                text: calories + " kcal"
                                color: theme.accent
                                font.pixelSize: theme.fontSM
                                font.bold: true
                                anchors.right: parent.right
                            }

                            Row {
                                spacing: 4
                                anchors.right: parent.right

                                Text { text: Math.round(proteines) + "P"; color: "#00D4AA"; font.pixelSize: 9; font.bold: true }
                                Text { text: Math.round(glucides) + "G";  color: "#00C896"; font.pixelSize: 9; font.bold: true }
                                Text { text: Math.round(lipides) + "L";   color: "#FF6B6B"; font.pixelSize: 9; font.bold: true }
                            }

                            Row {
                                spacing: 6
                                anchors.right: parent.right

                                Rectangle {
                                    width: 24; height: 24; radius: 6
                                    color: "#1a2e1a"
                                    border.color: "#00C89644"; border.width: 1

                                    Text { text: "✏️"; font.pixelSize: 11; anchors.centerIn: parent }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            editMealId     = mealId
                                            editMealNom    = nom
                                            editMealCal    = calories
                                            editMealProt   = proteines
                                            editMealGluc   = glucides
                                            editMealLip    = lipides
                                            editMealMoment = moment
                                            showEditMeal   = true
                                        }
                                    }
                                }

                                Rectangle {
                                    width: 24; height: 24; radius: 6
                                    color: "#2e0d0d"
                                    border.color: "#FF6B6B44"; border.width: 1

                                    Text { text: "🗑️"; font.pixelSize: 11; anchors.centerIn: parent }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            mealToDelete     = mealId
                                            mealToDeleteName = nom
                                            showDeleteMealConfirm = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Item {
                    anchors.centerIn: parent
                    visible: nutritionVM.meals.rowCount() === 0
                    width: parent.width
                    height: 200

                    Column {
                        anchors.centerIn: parent
                        spacing: 12

                        Text {
                            text: "🍽️"
                            font.pixelSize: 56
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            text: nutritionVM.isToday
                                  ? "Aucun repas aujourd'hui"
                                  : "Aucun repas ce jour-là"
                            color: theme.textHint
                            font.pixelSize: theme.fontMD
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            text: nutritionVM.isToday ? "Ajoute ton premier repas !" : ""
                            color: theme.textHint
                            font.pixelSize: theme.fontSM
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }

            Item { height: 16 }
        }

        // ── Popup analyse photo ───────────────
        Rectangle {
            anchors.fill: parent
            color: "#AA000000"
            visible: showPhotoResult
            z: 25

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (!coachVM.analyzing) {
                        showPhotoResult = false
                        coachVM.resetPhoto()
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 580
                radius: theme.radiusXL
                color: theme.bgCard

                MouseArea { anchors.fill: parent }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 16

                    Rectangle {
                        width: 40; height: 4; radius: 2
                        color: theme.border
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "📷 Analyse IA"
                        color: theme.textPrimary
                        font.pixelSize: theme.fontLG
                        font.bold: true
                    }

                    // Photo + chargement
                    Rectangle {
                        Layout.fillWidth: true
                        height: 160
                        radius: theme.radiusMD
                        color: theme.bgInput
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: selectedPhotoPath
                            fillMode: Image.PreserveAspectCrop
                            visible: selectedPhotoPath !== ""
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 12
                            visible: coachVM.analyzing

                            Text {
                                text: "🔍"
                                font.pixelSize: 36
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: "Analyse en cours..."
                                color: theme.textSecondary
                                font.pixelSize: theme.fontSM
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Row {
                                spacing: 6
                                anchors.horizontalCenter: parent.horizontalCenter

                                Repeater {
                                    model: 3
                                    Rectangle {
                                        width: 8; height: 8; radius: 4
                                        color: theme.accent

                                        SequentialAnimation on opacity {
                                            running: coachVM.analyzing
                                            loops: Animation.Infinite
                                            NumberAnimation { to: 1.0; duration: 400 + index * 150 }
                                            NumberAnimation { to: 0.2; duration: 400 + index * 150 }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Résultats
                    Rectangle {
                        Layout.fillWidth: true
                        height: resultCol.implicitHeight + 20
                        radius: theme.radiusMD
                        color: theme.bgInput
                        visible: !coachVM.analyzing && coachVM.photoCal > 0

                        Column {
                            id: resultCol
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 8

                            Text {
                                text: coachVM.photoNom
                                color: theme.textPrimary
                                font.pixelSize: theme.fontMD
                                font.bold: true
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }

                            Text {
                                text: coachVM.photoResult
                                color: theme.textSecondary
                                font.pixelSize: theme.fontSM
                                wrapMode: Text.WordWrap
                                width: parent.width
                                lineHeight: 1.4
                            }

                            // REMPLACE tout ce Row des macros par ça
                            Item {
                                width: parent.width
                                height: 44

                                Row {
                                    anchors.fill: parent
                                    spacing: 0

                                    Repeater {
                                        model: [
                                            { label: "Calories",  val: coachVM.photoCal + " kcal",         color: theme.accent },
                                            { label: "Protéines", val: coachVM.photoProt.toFixed(0) + "g",  color: "#00D4AA"   },
                                            { label: "Glucides",  val: coachVM.photoGluc.toFixed(0) + "g",  color: "#00C896"   },
                                            { label: "Lipides",   val: coachVM.photoLip.toFixed(0)  + "g",  color: "#FF6B6B"   }
                                        ]

                                        Column {
                                            width: parent.width / 4
                                            spacing: 4

                                            Text {
                                                text: modelData.val
                                                color: modelData.color
                                                font.pixelSize: 12
                                                font.bold: true
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                wrapMode: Text.NoWrap
                                            }
                                            Text {
                                                text: modelData.label
                                                color: theme.textHint
                                                font.pixelSize: 9
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Sélecteur moment
                    Row {
                        Layout.fillWidth: true
                        spacing: 8
                        visible: !coachVM.analyzing && coachVM.photoCal > 0

                        Repeater {
                            model: ["Petit-déjeuner", "Déjeuner", "Collation", "Dîner"]

                            Rectangle {
                                width: (parent.width - 24) / 4
                                height: 36
                                radius: theme.radiusSM
                                color: photoMoment === modelData
                                       ? theme.accent : theme.bgInput
                                border.color: photoMoment === modelData
                                              ? theme.accent : theme.border
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: 150 } }

                                Text {
                                    text: modelData === "Petit-déjeuner" ? "Matin" : modelData
                                    color: photoMoment === modelData
                                           ? "white" : theme.textSecondary
                                    font.pixelSize: 10
                                    font.bold: photoMoment === modelData
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: photoMoment = modelData
                                }
                            }
                        }
                    }

                    // Bouton ajouter
                    Rectangle {
                        Layout.fillWidth: true
                        height: 52
                        radius: theme.radiusLG
                        color: coachVM.photoCal > 0 && !coachVM.analyzing
                               ? theme.accent : theme.border
                        visible: !coachVM.analyzing || coachVM.photoCal > 0

                        Behavior on color { ColorAnimation { duration: 200 } }

                        Text {
                            text: coachVM.analyzing
                                  ? "Analyse en cours..."
                                  : coachVM.photoCal > 0
                                    ? "✅ Ajouter ce repas"
                                    : "En attente..."
                            color: "white"
                            font.pixelSize: theme.fontMD
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (coachVM.photoCal > 0 && !coachVM.analyzing) {
                                    nutritionVM.ajouterRepas(
                                        coachVM.photoNom,
                                        coachVM.photoCal,
                                        coachVM.photoProt,
                                        coachVM.photoGluc,
                                        coachVM.photoLip,
                                        photoMoment
                                    )
                                    homeVM.refresh()
                                    showPhotoResult  = false
                                    selectedPhotoPath = ""
                                    photoMoment      = "Déjeuner"
                                    coachVM.resetPhoto()
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Popup confirmation suppression ────
        Rectangle {
            anchors.fill: parent
            color: "#CC000000"
            visible: showDeleteMealConfirm
            z: 30

            MouseArea { anchors.fill: parent }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 64
                height: deleteMealCol.implicitHeight + 40
                radius: theme.radiusLG
                color: theme.bgCard
                border.color: theme.border
                border.width: 1

                ColumnLayout {
                    id: deleteMealCol
                    anchors.centerIn: parent
                    width: parent.width - 40
                    spacing: 16

                    Text { text: "🗑️"; font.pixelSize: 36; Layout.alignment: Qt.AlignHCenter }

                    Text {
                        text: "Supprimer ce repas ?"
                        color: theme.textPrimary
                        font.pixelSize: theme.fontLG
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "\"" + mealToDeleteName + "\"\nsera supprimé définitivement."
                        color: theme.textSecondary
                        font.pixelSize: theme.fontSM
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        lineHeight: 1.4
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

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    showDeleteMealConfirm = false
                                    mealToDelete = -1
                                    mealToDeleteName = ""
                                }
                            }
                        }

                        Rectangle {
                            width: (parent.width - 12) / 2
                            height: 48
                            radius: theme.radiusMD
                            color: "#FF6B6B"

                            Text {
                                text: "Supprimer"
                                color: "white"
                                font.pixelSize: theme.fontMD
                                font.bold: true
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    nutritionVM.supprimerRepas(mealToDelete)
                                    homeVM.refresh()
                                    showDeleteMealConfirm = false
                                    mealToDelete = -1
                                    mealToDeleteName = ""
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Popup modifier repas ──────────────
        Rectangle {
            anchors.fill: parent
            color: "#AA000000"
            visible: showEditMeal
            z: 25

            MouseArea {
                anchors.fill: parent
                onClicked: showEditMeal = false
            }

            Rectangle {
                id: editMealPopup
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 520
                radius: theme.radiusXL
                color: theme.bgCard

                MouseArea { anchors.fill: parent }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 16

                    Rectangle {
                        width: 40; height: 4; radius: 2
                        color: theme.border
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "Modifier le repas"
                        color: theme.textPrimary
                        font.pixelSize: theme.fontLG
                        font.bold: true
                    }

                    TextField {
                        id: editFieldNom
                        Layout.fillWidth: true
                        text: editMealNom
                        color: theme.textPrimary
                        placeholderTextColor: theme.textHint
                        font.pixelSize: theme.fontMD
                        onTextChanged: editMealNom = text
                        background: Rectangle {
                            radius: theme.radiusSM
                            color: theme.bgInput
                            border.color: theme.border
                            border.width: 1
                        }
                    }

                    Row {
                        Layout.fillWidth: true
                        spacing: 8

                        Repeater {
                            model: ["Petit-déjeuner", "Déjeuner", "Collation", "Dîner"]

                            Rectangle {
                                width: (parent.width - 24) / 4
                                height: 36
                                radius: theme.radiusSM
                                color: editMealMoment === modelData
                                       ? theme.accent : theme.bgInput
                                border.color: editMealMoment === modelData
                                              ? theme.accent : theme.border
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: 150 } }

                                Text {
                                    text: modelData === "Petit-déjeuner" ? "Matin" : modelData
                                    color: editMealMoment === modelData
                                           ? "white" : theme.textSecondary
                                    font.pixelSize: 10
                                    font.bold: editMealMoment === modelData
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: editMealMoment = modelData
                                }
                            }
                        }
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 12
                        rowSpacing: 12

                        ColumnLayout {
                            spacing: 4
                            Text { text: "Calories (kcal)"; color: theme.textSecondary; font.pixelSize: theme.fontSM }
                            TextField {
                                id: editFieldCal
                                Layout.fillWidth: true
                                text: editMealCal + ""
                                color: theme.textPrimary
                                placeholderTextColor: theme.textHint
                                font.pixelSize: theme.fontMD
                                inputMethodHints: Qt.ImhDigitsOnly
                                onTextChanged: editMealCal = parseInt(text) || 0
                                background: Rectangle {
                                    radius: theme.radiusSM
                                    color: theme.bgInput
                                    border.color: theme.border
                                    border.width: 1
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: 4
                            Text { text: "Protéines (g)"; color: theme.textSecondary; font.pixelSize: theme.fontSM }
                            TextField {
                                id: editFieldProt
                                Layout.fillWidth: true
                                text: editMealProt + ""
                                color: theme.textPrimary
                                placeholderTextColor: theme.textHint
                                font.pixelSize: theme.fontMD
                                inputMethodHints: Qt.ImhDigitsOnly
                                onTextChanged: editMealProt = parseFloat(text) || 0
                                background: Rectangle {
                                    radius: theme.radiusSM
                                    color: theme.bgInput
                                    border.color: theme.border
                                    border.width: 1
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: 4
                            Text { text: "Glucides (g)"; color: theme.textSecondary; font.pixelSize: theme.fontSM }
                            TextField {
                                id: editFieldGluc
                                Layout.fillWidth: true
                                text: editMealGluc + ""
                                color: theme.textPrimary
                                placeholderTextColor: theme.textHint
                                font.pixelSize: theme.fontMD
                                inputMethodHints: Qt.ImhDigitsOnly
                                onTextChanged: editMealGluc = parseFloat(text) || 0
                                background: Rectangle {
                                    radius: theme.radiusSM
                                    color: theme.bgInput
                                    border.color: theme.border
                                    border.width: 1
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: 4
                            Text { text: "Lipides (g)"; color: theme.textSecondary; font.pixelSize: theme.fontSM }
                            TextField {
                                id: editFieldLip
                                Layout.fillWidth: true
                                text: editMealLip + ""
                                color: theme.textPrimary
                                placeholderTextColor: theme.textHint
                                font.pixelSize: theme.fontMD
                                inputMethodHints: Qt.ImhDigitsOnly
                                onTextChanged: editMealLip = parseFloat(text) || 0
                                background: Rectangle {
                                    radius: theme.radiusSM
                                    color: theme.bgInput
                                    border.color: theme.border
                                    border.width: 1
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 52
                        radius: theme.radiusLG
                        color: theme.accent

                        Text {
                            text: "Enregistrer"
                            color: "white"
                            font.pixelSize: theme.fontMD
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        scale: saveEditBtn.pressed ? 0.97 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        MouseArea {
                            id: saveEditBtn
                            anchors.fill: parent
                            onClicked: {
                                if (editMealNom !== "") {
                                    nutritionVM.modifierRepas(
                                        editMealId, editMealNom,
                                        editMealCal, editMealProt,
                                        editMealGluc, editMealLip,
                                        editMealMoment
                                    )
                                    homeVM.refresh()
                                    showEditMeal = false
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Popup ajout repas ─────────────────
        Rectangle {
            anchors.fill: parent
            color: "#AA000000"
            visible: showAddMeal
            z: 20

            MouseArea {
                anchors.fill: parent
                onClicked: showAddMeal = false
            }

            Rectangle {
                id: addMealPopup
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 520
                radius: theme.radiusXL
                color: theme.bgCard

                property string mNom:    ""
                property int    mCal:    0
                property real   mProt:   0
                property real   mGluc:   0
                property real   mLip:    0
                property string mMoment: "Déjeuner"

                transform: Translate {
                    y: showAddMeal ? 0 : 520
                    Behavior on y {
                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                    }
                }

                MouseArea { anchors.fill: parent }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 16

                    Rectangle {
                        width: 40; height: 4; radius: 2
                        color: theme.border
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "Ajouter un repas"
                        color: theme.textPrimary
                        font.pixelSize: theme.fontLG
                        font.bold: true
                    }

                    TextField {
                        id: fieldNom
                        Layout.fillWidth: true
                        placeholderText: "Nom du repas"
                        color: theme.textPrimary
                        placeholderTextColor: theme.textHint
                        font.pixelSize: theme.fontMD
                        onTextChanged: addMealPopup.mNom = text
                        background: Rectangle {
                            radius: theme.radiusSM
                            color: theme.bgInput
                            border.color: theme.border
                            border.width: 1
                        }
                    }

                    Row {
                        Layout.fillWidth: true
                        spacing: 8

                        Repeater {
                            model: ["Petit-déjeuner", "Déjeuner", "Collation", "Dîner"]

                            Rectangle {
                                width: (parent.width - 24) / 4
                                height: 36
                                radius: theme.radiusSM
                                color: addMealPopup.mMoment === modelData
                                       ? theme.accent : theme.bgInput
                                border.color: addMealPopup.mMoment === modelData
                                              ? theme.accent : theme.border
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: 150 } }

                                Text {
                                    text: modelData === "Petit-déjeuner" ? "Matin" : modelData
                                    color: addMealPopup.mMoment === modelData
                                           ? "white" : theme.textSecondary
                                    font.pixelSize: 10
                                    font.bold: addMealPopup.mMoment === modelData
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: addMealPopup.mMoment = modelData
                                }
                            }
                        }
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 12
                        rowSpacing: 12

                        ColumnLayout {
                            spacing: 4
                            Text { text: "Calories (kcal)"; color: theme.textSecondary; font.pixelSize: theme.fontSM }
                            TextField {
                                id: fieldCal
                                Layout.fillWidth: true
                                placeholderText: "0"
                                color: theme.textPrimary
                                placeholderTextColor: theme.textHint
                                font.pixelSize: theme.fontMD
                                inputMethodHints: Qt.ImhDigitsOnly
                                onTextChanged: addMealPopup.mCal = parseInt(text) || 0
                                background: Rectangle {
                                    radius: theme.radiusSM
                                    color: theme.bgInput
                                    border.color: theme.border
                                    border.width: 1
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: 4
                            Text { text: "Protéines (g)"; color: theme.textSecondary; font.pixelSize: theme.fontSM }
                            TextField {
                                id: fieldProt
                                Layout.fillWidth: true
                                placeholderText: "0"
                                color: theme.textPrimary
                                placeholderTextColor: theme.textHint
                                font.pixelSize: theme.fontMD
                                inputMethodHints: Qt.ImhDigitsOnly
                                onTextChanged: addMealPopup.mProt = parseFloat(text) || 0
                                background: Rectangle {
                                    radius: theme.radiusSM
                                    color: theme.bgInput
                                    border.color: theme.border
                                    border.width: 1
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: 4
                            Text { text: "Glucides (g)"; color: theme.textSecondary; font.pixelSize: theme.fontSM }
                            TextField {
                                id: fieldGluc
                                Layout.fillWidth: true
                                placeholderText: "0"
                                color: theme.textPrimary
                                placeholderTextColor: theme.textHint
                                font.pixelSize: theme.fontMD
                                inputMethodHints: Qt.ImhDigitsOnly
                                onTextChanged: addMealPopup.mGluc = parseFloat(text) || 0
                                background: Rectangle {
                                    radius: theme.radiusSM
                                    color: theme.bgInput
                                    border.color: theme.border
                                    border.width: 1
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: 4
                            Text { text: "Lipides (g)"; color: theme.textSecondary; font.pixelSize: theme.fontSM }
                            TextField {
                                id: fieldLip
                                Layout.fillWidth: true
                                placeholderText: "0"
                                color: theme.textPrimary
                                placeholderTextColor: theme.textHint
                                font.pixelSize: theme.fontMD
                                inputMethodHints: Qt.ImhDigitsOnly
                                onTextChanged: addMealPopup.mLip = parseFloat(text) || 0
                                background: Rectangle {
                                    radius: theme.radiusSM
                                    color: theme.bgInput
                                    border.color: theme.border
                                    border.width: 1
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 52
                        radius: theme.radiusLG
                        color: addMealPopup.mNom !== "" ? theme.accent : theme.border

                        Behavior on color { ColorAnimation { duration: 200 } }

                        Text {
                            text: "Ajouter"
                            color: "white"
                            font.pixelSize: theme.fontMD
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        scale: confirmBtn.pressed ? 0.97 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        MouseArea {
                            id: confirmBtn
                            anchors.fill: parent
                            onClicked: {
                                if (addMealPopup.mNom !== "") {
                                    nutritionVM.ajouterRepas(
                                        addMealPopup.mNom, addMealPopup.mCal,
                                        addMealPopup.mProt, addMealPopup.mGluc,
                                        addMealPopup.mLip, addMealPopup.mMoment
                                    )
                                    homeVM.refresh()
                                    fieldNom.text  = ""
                                    fieldCal.text  = ""
                                    fieldProt.text = ""
                                    fieldGluc.text = ""
                                    fieldLip.text  = ""
                                    addMealPopup.mNom    = ""
                                    addMealPopup.mCal    = 0
                                    addMealPopup.mProt   = 0
                                    addMealPopup.mGluc   = 0
                                    addMealPopup.mLip    = 0
                                    addMealPopup.mMoment = "Déjeuner"
                                    showAddMeal = false
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Popup objectif calorique ──────────
        Rectangle {
            anchors.fill: parent
            color: "#AA000000"
            visible: showObjectif
            z: 25

            MouseArea {
                anchors.fill: parent
                onClicked: showObjectif = false
            }

            Rectangle {
                id: objectifPopup
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 280
                radius: theme.radiusXL
                color: theme.bgCard

                property int mObjectif: homeVM.caloriesObjectif

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
                        text: "🎯 Objectif calorique"
                        color: theme.textPrimary
                        font.pixelSize: theme.fontLG
                        font.bold: true
                    }

                    Row {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 24

                        Rectangle {
                            width: 48; height: 48; radius: 24
                            color: theme.bgInput
                            border.color: theme.border; border.width: 1

                            Text { text: "−"; color: theme.textPrimary; font.pixelSize: 24; font.bold: true; anchors.centerIn: parent }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: objectifPopup.mObjectif = Math.max(500, objectifPopup.mObjectif - 100)
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: objectifPopup.mObjectif
                                color: theme.accent
                                font.pixelSize: 36
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: "kcal / jour"
                                color: theme.textHint
                                font.pixelSize: 11
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        Rectangle {
                            width: 48; height: 48; radius: 24
                            color: theme.bgInput
                            border.color: theme.border; border.width: 1

                            Text { text: "+"; color: theme.textPrimary; font.pixelSize: 24; font.bold: true; anchors.centerIn: parent }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: objectifPopup.mObjectif = Math.min(5000, objectifPopup.mObjectif + 100)
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 52
                        radius: theme.radiusLG
                        color: theme.accent

                        Text {
                            text: "Enregistrer"
                            color: "white"
                            font.pixelSize: theme.fontMD
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        scale: saveObjBtn.pressed ? 0.97 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        MouseArea {
                            id: saveObjBtn
                            anchors.fill: parent
                            onClicked: {
                                homeVM.setCaloriesObjectif(objectifPopup.mObjectif)
                                showObjectif = false
                            }
                        }
                    }
                }
            }
        }
    }
}