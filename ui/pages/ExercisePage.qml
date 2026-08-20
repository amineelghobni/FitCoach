import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import FitCoach

Item {
    id: rootItem
    Theme { id: theme }

    property bool showAddWorkout:     false
        property bool showAddExercice:    false

    property bool showBadgeNotification: false
    property int badgeNotificationCount: 0
    property string badgeNotificationText: ""

    property bool showDeleteConfirm:  false
    property int  workoutToDelete:    -1
    property string workoutToDeleteName: ""

    property bool showEditExercice:   false
    property bool showDeleteExercice: false
    property int  exerciceToDelete:   -1
    property int  editExerciceId:     -1
    property string editExNom:        ""
    property int    editExSets:       3
    property int    editExReps:       10
    property real   editExPoids:      0
    property bool showCaloriesPopup: false
    property int  caloriesBrulees:   0

    signal ouvrirProgramme()
    signal seanceTerminee()

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
                    anchors.rightMargin: 16
                    spacing: 8

                    Column {
                        spacing: 4
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 170

                        Text {
                            text: "Exercices"
                            color: theme.textPrimary
                            font.pixelSize: theme.fontXL
                            font.bold: true
                        }
                        Text {
                            text: exerciseVM.workouts.rowCount() + " séances"
                            color: theme.textSecondary
                            font.pixelSize: theme.fontSM
                        }
                    }

                    Rectangle {
                        width: 48
                        height: 38
                        radius: 10
                        color: theme.bgCard
                        border.color: theme.accent
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: "✨"
                            font.pixelSize: 18
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: ouvrirProgramme()
                        }
                    }

                    Rectangle {
                        width: 110
                        height: 38
                        radius: 10
                        color: theme.accent
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: "+ Nouvelle"
                            color: "white"
                            font.pixelSize: theme.fontSM
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        scale: newBtn.pressed ? 0.95 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        MouseArea {
                            id: newBtn
                            anchors.fill: parent
                            onClicked: showAddWorkout = true
                        }
                    }
                }
            }

            // ── Stats rapides ─────────────────
            Row {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.bottomMargin: 12
                spacing: 8

                Repeater {
                    model: [
                        { label: "Séances",       val: exerciseVM.totalSeances + "" },
                        { label: "Cette semaine", val: exerciseVM.seancesSemaine + "" },
                        { label: "Streak",        val: exerciseVM.streakExercices > 0 ? exerciseVM.streakExercices + "j 🔥" : "0j" }
                    ]

                    Rectangle {
                        width: (parent.width - 16) / 3
                        height: 60
                        radius: theme.radiusMD
                        color: theme.bgCard
                        border.color: theme.border
                        border.width: 1

                        Column {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: modelData.val
                                color: theme.textPrimary
                                font.pixelSize: theme.fontLG
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
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

            // ── Liste workouts ────────────────
            ListView {
                id: workoutList
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                spacing: 10
                clip: true

                section.property: "date"
                section.criteria: ViewSection.FullString
                section.delegate: Rectangle {
                    width: ListView.view.width
                    height: 36
                    color: "transparent"

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 4
                        spacing: 8

                        Rectangle {
                            width: 8; height: 8; radius: 4
                            color: theme.accent
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: exerciseVM.labelDate(section).toUpperCase()
                            color: theme.accent
                            font.pixelSize: 11
                            font.bold: true
                            font.letterSpacing: 1
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                model: exerciseVM.workouts

                delegate: Rectangle {
                    width: ListView.view.width
                    radius: theme.radiusLG
                    color: theme.bgCard
                    border.color: exerciseVM.currentWorkoutId === workoutId
                                  ? theme.accent : theme.border
                    border.width: exerciseVM.currentWorkoutId === workoutId ? 2 : 1
                    height: wkCol.implicitHeight + 20

                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (exerciseVM.currentWorkoutId === workoutId)
                                exerciseVM.selectWorkout(-1)
                            else
                                exerciseVM.selectWorkout(workoutId)
                        }
                    }

                    Column {
                        id: wkCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 14
                        spacing: 10

                        // ── Titre + boutons ──
                        Row {
                            width: parent.width
                            spacing: 6

                            Column {
                                spacing: 3
                                width: parent.width - 120
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    text: "💪 " + nom
                                    color: theme.textPrimary
                                    font.pixelSize: theme.fontMD
                                    font.bold: true
                                    elide: Text.ElideRight
                                    width: parent.width
                                }

                                Text {
                                    text: date + " · " +
                                          (exerciseVM.currentWorkoutId === workoutId
                                           ? exerciseVM.exercises.rowCount() + " exercice(s)"
                                           : "Appuie pour voir")
                                    color: theme.textHint
                                    font.pixelSize: 10
                                }

                                // Volume total
                                Row {
                                    spacing: 4
                                    visible: exerciseVM.calculerVolume(workoutId) > 0

                                    Text {
                                        text: "📦"
                                        font.pixelSize: 10
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: {
                                            var vol = exerciseVM.calculerVolume(workoutId)
                                            if (vol >= 1000)
                                                return (vol / 1000).toFixed(1) + " tonnes soulevées"
                                            return vol + " kg soulevés"
                                        }
                                        color: "#4FACFE"
                                        font.pixelSize: 10
                                        font.bold: true
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }

                            // Bouton ▶ Début OU badge ✅
                            Item {
                                width: 70
                                height: 32
                                anchors.verticalCenter: parent.verticalCenter

                                Rectangle {
                                    width: 70
                                    height: 32
                                    radius: 16
                                    visible: exerciseVM.currentWorkoutId !== workoutId
                                    anchors.centerIn: parent

                                    gradient: Gradient {
                                        orientation: Gradient.Horizontal
                                        GradientStop { position: 0.0; color: "#00D4AA" }
                                        GradientStop { position: 1.0; color: "#4FACFE" }
                                    }

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 5

                                        Text {
                                            text: "▶"
                                            color: "white"
                                            font.pixelSize: 10
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        Text {
                                            text: "Début"
                                            color: "white"
                                            font.pixelSize: 12
                                            font.bold: true
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    scale: debutArea.pressed ? 0.95 : 1.0
                                    Behavior on scale { NumberAnimation { duration: 100 } }

                                    MouseArea {
                                        id: debutArea
                                        anchors.fill: parent
                                        onClicked: (mouse) => {
                                            mouse.accepted = true
                                            sessionVM.demarrerSession(workoutId)
                                        }
                                    }
                                }

                                Rectangle {
                                    width: 50
                                    height: 22
                                    radius: 11
                                    color: "#00D4AA22"
                                    border.color: theme.accent
                                    border.width: 1
                                    visible: exerciseVM.currentWorkoutId === workoutId
                                    anchors.centerIn: parent

                                    Text {
                                        text: "✅"
                                        font.pixelSize: 12
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            // Poubelle
                            Rectangle {
                                width: 32
                                height: 32
                                radius: 8
                                color: "#2e0d0d"
                                border.color: "#FF6B6B44"
                                border.width: 1
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    text: "🗑️"
                                    font.pixelSize: 14
                                    anchors.centerIn: parent
                                }

                                scale: deleteArea.pressed ? 0.9 : 1.0
                                Behavior on scale { NumberAnimation { duration: 100 } }

                                MouseArea {
                                    id: deleteArea
                                    anchors.fill: parent
                                    onClicked: (mouse) => {
                                        mouse.accepted = true
                                        workoutToDelete = workoutId
                                        workoutToDeleteName = nom
                                        showDeleteConfirm = true
                                    }
                                }
                            }
                        }

                        // ── Barre progression ──
                        Column {
                            width: parent.width
                            spacing: 6
                            visible: exerciseVM.currentWorkoutId === workoutId &&
                                     exerciseVM.exercises.rowCount() > 0

                            Row {
                                width: parent.width

                                Text {
                                    text: "Progression"
                                    color: theme.textHint
                                    font.pixelSize: 10
                                }

                                Item { Layout.fillWidth: true }

                                Text {
                                    text: exerciseVM.nombreExercicesFaits + " / " +
                                          exerciseVM.exercises.rowCount() + " faits"
                                    color: theme.accent
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 6
                                radius: 3
                                color: "#2a2a3a"

                                Rectangle {
                                    width: exerciseVM.exercises.rowCount() > 0
                                           ? parent.width * (exerciseVM.nombreExercicesFaits / exerciseVM.exercises.rowCount())
                                           : 0
                                    height: parent.height
                                    radius: 3
                                    color: theme.accentGreen

                                    Behavior on width {
                                        NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
                                    }
                                }
                            }
                        }

                        // ── Liste exercices ────
                        ListView {
                            width: parent.width
                            height: contentHeight
                            interactive: false
                            spacing: 6
                            visible: exerciseVM.currentWorkoutId === workoutId
                            model: exerciseVM.currentWorkoutId === workoutId
                                   ? exerciseVM.exercises : null

                            delegate: Rectangle {
                                width: ListView.view ? ListView.view.width : 0
                                height: 48
                                radius: theme.radiusSM
                                color: fait ? "#0d1f0d" : theme.bgInput
                                border.color: fait ? "#00C89644" : "transparent"
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: 300 } }

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10

                                    Rectangle {
                                        width: 24; height: 24; radius: 12
                                        color: fait ? theme.accentGreen : "transparent"
                                        border.color: fait ? theme.accentGreen : "#444"
                                        border.width: 2
                                        anchors.verticalCenter: parent.verticalCenter

                                        Behavior on color { ColorAnimation { duration: 200 } }

                                        Text {
                                            text: "✓"
                                            color: "white"
                                            font.pixelSize: 12
                                            font.bold: true
                                            anchors.centerIn: parent
                                            opacity: fait ? 1 : 0
                                            Behavior on opacity { NumberAnimation { duration: 200 } }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: (mouse) => {
                                                mouse.accepted = true
                                                exerciseVM.toggleFait(exerciceId)
                                            }
                                        }
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 2
                                        width: parent.width - 24 - 60 - 50 - 30

                                        Text {
                                            text: nom
                                            color: fait ? theme.textSecondary : theme.textPrimary
                                            font.pixelSize: theme.fontSM
                                            font.bold: true
                                            font.strikeout: fait
                                        }
                                        Text {
                                            text: sets + " séries × " + reps + " reps"
                                            color: theme.textHint
                                            font.pixelSize: 10
                                        }
                                    }

                                    Rectangle {
                                        visible: poids > 0
                                        width: 50; height: 22; radius: 11
                                        color: "#00D4AA22"
                                        border.color: "#00D4AA44"
                                        border.width: 1
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            text: poids + "kg"
                                            color: theme.accent
                                            font.pixelSize: 10
                                            font.bold: true
                                            anchors.centerIn: parent
                                        }
                                    }

                                    Rectangle {
                                        width: 26; height: 26; radius: 6
                                        color: "#1a2e1a"
                                        border.color: "#00C89644"
                                        border.width: 1
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            text: "✏️"
                                            font.pixelSize: 11
                                            anchors.centerIn: parent
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: (mouse) => {
                                                mouse.accepted = true
                                                editExerciceId = exerciceId
                                                editExNom      = nom
                                                editExSets     = sets
                                                editExReps     = reps
                                                editExPoids    = poids
                                                showEditExercice = true
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: 26; height: 26; radius: 6
                                        color: "#2e0d0d"
                                        border.color: "#FF6B6B44"
                                        border.width: 1
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            text: "🗑️"
                                            font.pixelSize: 11
                                            anchors.centerIn: parent
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: (mouse) => {
                                                mouse.accepted = true
                                                exerciceToDelete = exerciceId
                                                showDeleteExercice = true
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // ── Bouton ajouter exo ─
                        Rectangle {
                            width: parent.width
                            height: 36
                            radius: theme.radiusSM
                            color: "transparent"
                            border.color: "#00D4AA44"
                            border.width: 1
                            visible: exerciseVM.currentWorkoutId === workoutId

                            Text {
                                text: "+ Ajouter un exercice"
                                color: theme.accent
                                font.pixelSize: theme.fontSM
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: (mouse) => {
                                    mouse.accepted = true
                                    showAddExercice = true
                                }
                            }
                        }

                        // ── Bouton terminer séance ─
                        Rectangle {
                            width: parent.width
                            height: 42
                            radius: theme.radiusSM
                            visible: exerciseVM.currentWorkoutId === workoutId

                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "#00D4AA" }
                                GradientStop { position: 1.0; color: "#4FACFE" }
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: 8

                                Text {
                                    text: "🏁"
                                    font.pixelSize: 16
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: "Terminer la séance"
                                    color: "white"
                                    font.pixelSize: theme.fontSM
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: (mouse) => {
                                    mouse.accepted = true
                                    var wid = workoutId
                                    var exVM = exerciseVM
                                    var progVM = programmeVM
                                    var pVM = progressVM
                                    progVM.terminerSeance(wid, 45)
                                    exVM.setDernieresCalories(exVM.calculerCaloriesBrulees(wid))
                                    Qt.callLater(function() {
                                        exVM.selectWorkout(-1)
                                        exVM.refresh()
                                        pVM.refresh()
                                        exVM.setSeanceTerminee(true)
                                    })
                                }
                            }
                        }
                    }
                }

                Item {
                    anchors.centerIn: parent
                    visible: exerciseVM.workouts.rowCount() === 0
                    width: parent.width
                    height: 200

                    Column {
                        anchors.centerIn: parent
                        spacing: 12

                        Text {
                            text: "💪"
                            font.pixelSize: 56
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            text: "Aucune séance pour l'instant"
                            color: theme.textHint
                            font.pixelSize: theme.fontMD
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            text: "Crée ta première séance !"
                            color: theme.textHint
                            font.pixelSize: theme.fontSM
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }

            Item { height: 16 }
        }
        // ── Notification badge ─────────────────
        Rectangle {
            id: badgeNotification

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 18

            width: Math.min(parent.width - 32, 360)
            height: 58

            radius: theme.radiusLG
            color: theme.bgCard

            border.color: "#FFD700"
            border.width: 1

            z: 100

            visible: showBadgeNotification

            opacity: showBadgeNotification ? 1 : 0
            y: showBadgeNotification ? 0 : -20

            Behavior on opacity {
                NumberAnimation { duration: 220 }
            }

            Behavior on y {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            Row {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Text {
                    text: "🏆"
                    font.pixelSize: 24
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: badgeNotificationText
                        color: theme.textPrimary
                        font.pixelSize: 12
                        font.bold: true
                        elide: Text.ElideRight
                        width: parent.width
                    }

                    Text {
                        text: badgeNotificationCount === 1
                              ? "Nouveau badge débloqué"
                              : badgeNotificationCount + " nouveaux badges débloqués"

                        color: theme.textSecondary
                        font.pixelSize: 10
                    }
                }
            }

            Timer {
                id: badgeNotificationTimer

                interval: 3000
                repeat: false

                onTriggered: {
                    showBadgeNotification = false
                }
            }
        }

        // ── Popup confirmation suppression ────
        Rectangle {
            anchors.fill: parent
            color: "#CC000000"
            visible: showDeleteConfirm
            z: 30

            MouseArea { anchors.fill: parent }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 64
                height: confirmCol.implicitHeight + 40
                radius: theme.radiusLG
                color: theme.bgCard
                border.color: theme.border
                border.width: 1

                ColumnLayout {
                    id: confirmCol
                    anchors.centerIn: parent
                    width: parent.width - 40
                    spacing: 16

                    Text { text: "🗑️"; font.pixelSize: 36; Layout.alignment: Qt.AlignHCenter }
                    Text {
                        text: "Supprimer cette séance ?"
                        color: theme.textPrimary
                        font.pixelSize: theme.fontLG
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        text: "\"" + workoutToDeleteName + "\" et tous ses exercices\nseront supprimés définitivement."
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
                            height: 48; radius: theme.radiusMD
                            color: theme.bgInput
                            border.color: theme.border; border.width: 1

                            Text {
                                text: "Annuler"
                                color: theme.textPrimary
                                font.pixelSize: theme.fontMD; font.bold: true
                                anchors.centerIn: parent
                            }

                            scale: cancelArea.pressed ? 0.97 : 1.0
                            Behavior on scale { NumberAnimation { duration: 100 } }

                            MouseArea {
                                id: cancelArea
                                anchors.fill: parent
                                onClicked: {
                                    showDeleteConfirm = false
                                    workoutToDelete = -1
                                    workoutToDeleteName = ""
                                }
                            }
                        }

                        Rectangle {
                            width: (parent.width - 12) / 2
                            height: 48; radius: theme.radiusMD
                            color: "#FF6B6B"

                            Text {
                                text: "Supprimer"
                                color: "white"
                                font.pixelSize: theme.fontMD; font.bold: true
                                anchors.centerIn: parent
                            }

                            scale: confirmArea.pressed ? 0.97 : 1.0
                            Behavior on scale { NumberAnimation { duration: 100 } }

                            MouseArea {
                                id: confirmArea
                                anchors.fill: parent
                                onClicked: {
                                    exerciseVM.supprimerWorkout(workoutToDelete)
                                    progressVM.refresh()
                                    showDeleteConfirm = false
                                    workoutToDelete = -1
                                    workoutToDeleteName = ""
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Popup nouvelle séance ─────────────
        Rectangle {
            anchors.fill: parent
            color: "#AA000000"
            visible: showAddWorkout
            z: 20

            MouseArea {
                anchors.fill: parent
                onClicked: showAddWorkout = false
            }

            Rectangle {
                id: addWorkoutPopup
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 220
                radius: theme.radiusXL
                color: theme.bgCard

                property string mNom: ""
                MouseArea { anchors.fill: parent }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 16

                    Text {
                        text: "Nouvelle séance"
                        color: theme.textPrimary
                        font.pixelSize: theme.fontLG
                        font.bold: true
                    }

                    TextField {
                        id: fieldWorkoutNom
                        Layout.fillWidth: true
                        placeholderText: "Ex: Push day, Jambes, Full body..."
                        color: theme.textPrimary
                        placeholderTextColor: theme.textHint
                        font.pixelSize: theme.fontMD
                        onTextChanged: addWorkoutPopup.mNom = text
                        background: Rectangle {
                            radius: theme.radiusSM
                            color: theme.bgInput
                            border.color: theme.border; border.width: 1
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 52; radius: theme.radiusLG
                        color: theme.accent

                        Text {
                            text: "Créer la séance"
                            color: "white"
                            font.pixelSize: theme.fontMD; font.bold: true
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (addWorkoutPopup.mNom !== "") {
                                    exerciseVM.ajouterWorkout(addWorkoutPopup.mNom)
                                    fieldWorkoutNom.text = ""
                                    addWorkoutPopup.mNom = ""
                                    showAddWorkout = false
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Popup ajouter exercice ────────────
        Rectangle {
            anchors.fill: parent
            color: "#AA000000"
            visible: showAddExercice
            z: 20

            MouseArea {
                anchors.fill: parent
                onClicked: showAddExercice = false
            }

            Rectangle {
                id: addExercicePopup
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 380
                radius: theme.radiusXL
                color: theme.bgCard

                property string mNom:   ""
                property int    mSets:  3
                property int    mReps:  10
                property real   mPoids: 0

                MouseArea { anchors.fill: parent }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 16

                    Text {
                        text: "Ajouter un exercice"
                        color: theme.textPrimary
                        font.pixelSize: theme.fontLG
                        font.bold: true
                    }

                    TextField {
                        id: fieldExNom
                        Layout.fillWidth: true
                        placeholderText: "Nom de l'exercice"
                        color: theme.textPrimary
                        placeholderTextColor: theme.textHint
                        font.pixelSize: theme.fontMD
                        onTextChanged: addExercicePopup.mNom = text
                        background: Rectangle {
                            radius: theme.radiusSM
                            color: theme.bgInput
                            border.color: theme.border; border.width: 1
                        }
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 3
                        columnSpacing: 12

                        ColumnLayout {
                            spacing: 4
                            Text { text: "Séries"; color: theme.textSecondary; font.pixelSize: theme.fontSM }
                            TextField {
                                id: fieldSets
                                Layout.fillWidth: true
                                placeholderText: "3"
                                color: theme.textPrimary
                                placeholderTextColor: theme.textHint
                                font.pixelSize: theme.fontMD
                                inputMethodHints: Qt.ImhDigitsOnly
                                onTextChanged: addExercicePopup.mSets = parseInt(text) || 3
                                background: Rectangle {
                                    radius: theme.radiusSM
                                    color: theme.bgInput
                                    border.color: theme.border; border.width: 1
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: 4
                            Text { text: "Répétitions"; color: theme.textSecondary; font.pixelSize: theme.fontSM }
                            TextField {
                                id: fieldReps
                                Layout.fillWidth: true
                                placeholderText: "10"
                                color: theme.textPrimary
                                placeholderTextColor: theme.textHint
                                font.pixelSize: theme.fontMD
                                inputMethodHints: Qt.ImhDigitsOnly
                                onTextChanged: addExercicePopup.mReps = parseInt(text) || 10
                                background: Rectangle {
                                    radius: theme.radiusSM
                                    color: theme.bgInput
                                    border.color: theme.border; border.width: 1
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: 4
                            Text { text: "Poids (kg)"; color: theme.textSecondary; font.pixelSize: theme.fontSM }
                            TextField {
                                id: fieldPoids
                                Layout.fillWidth: true
                                placeholderText: "0"
                                color: theme.textPrimary
                                placeholderTextColor: theme.textHint
                                font.pixelSize: theme.fontMD
                                inputMethodHints: Qt.ImhDigitsOnly
                                onTextChanged: addExercicePopup.mPoids = parseFloat(text) || 0
                                background: Rectangle {
                                    radius: theme.radiusSM
                                    color: theme.bgInput
                                    border.color: theme.border; border.width: 1
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 52; radius: theme.radiusLG
                        color: addExercicePopup.mNom !== "" ? theme.accent : theme.border

                        Text {
                            text: "Ajouter"
                            color: "white"
                            font.pixelSize: theme.fontMD; font.bold: true
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (addExercicePopup.mNom !== "" &&
                                    exerciseVM.currentWorkoutId !== -1) {
                                    exerciseVM.ajouterExercice(
                                        exerciseVM.currentWorkoutId,
                                        addExercicePopup.mNom,
                                        addExercicePopup.mSets,
                                        addExercicePopup.mReps,
                                        addExercicePopup.mPoids
                                    )
                                    progressVM.refresh()
                                    fieldExNom.text  = ""
                                    fieldSets.text   = ""
                                    fieldReps.text   = ""
                                    fieldPoids.text  = ""
                                    addExercicePopup.mNom   = ""
                                    addExercicePopup.mSets  = 3
                                    addExercicePopup.mReps  = 10
                                    addExercicePopup.mPoids = 0
                                    showAddExercice = false
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Popup modifier exercice ───────────
        Rectangle {
            anchors.fill: parent
            color: "#AA000000"
            visible: showEditExercice
            z: 25

            MouseArea {
                anchors.fill: parent
                onClicked: showEditExercice = false
            }

            Rectangle {
                id: editExPopup
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 340
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
                        text: "Modifier l'exercice"
                        color: theme.textPrimary
                        font.pixelSize: theme.fontLG
                        font.bold: true
                    }

                    TextField {
                        id: editExFieldNom
                        Layout.fillWidth: true
                        text: editExNom
                        color: theme.textPrimary
                        placeholderTextColor: theme.textHint
                        font.pixelSize: theme.fontMD
                        onTextChanged: editExNom = text
                        background: Rectangle {
                            radius: theme.radiusSM
                            color: theme.bgInput
                            border.color: theme.border; border.width: 1
                        }
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 3
                        columnSpacing: 12

                        ColumnLayout {
                            spacing: 4
                            Text { text: "Séries"; color: theme.textSecondary; font.pixelSize: theme.fontSM }
                            TextField {
                                id: editExFieldSets
                                Layout.fillWidth: true
                                text: editExSets + ""
                                color: theme.textPrimary
                                placeholderTextColor: theme.textHint
                                font.pixelSize: theme.fontMD
                                inputMethodHints: Qt.ImhDigitsOnly
                                onTextChanged: editExSets = parseInt(text) || 3
                                background: Rectangle {
                                    radius: theme.radiusSM
                                    color: theme.bgInput
                                    border.color: theme.border; border.width: 1
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: 4
                            Text { text: "Répétitions"; color: theme.textSecondary; font.pixelSize: theme.fontSM }
                            TextField {
                                id: editExFieldReps
                                Layout.fillWidth: true
                                text: editExReps + ""
                                color: theme.textPrimary
                                placeholderTextColor: theme.textHint
                                font.pixelSize: theme.fontMD
                                inputMethodHints: Qt.ImhDigitsOnly
                                onTextChanged: editExReps = parseInt(text) || 10
                                background: Rectangle {
                                    radius: theme.radiusSM
                                    color: theme.bgInput
                                    border.color: theme.border; border.width: 1
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: 4
                            Text { text: "Poids (kg)"; color: theme.textSecondary; font.pixelSize: theme.fontSM }
                            TextField {
                                id: editExFieldPoids
                                Layout.fillWidth: true
                                text: editExPoids + ""
                                color: theme.textPrimary
                                placeholderTextColor: theme.textHint
                                font.pixelSize: theme.fontMD
                                inputMethodHints: Qt.ImhDigitsOnly
                                onTextChanged: editExPoids = parseFloat(text) || 0
                                background: Rectangle {
                                    radius: theme.radiusSM
                                    color: theme.bgInput
                                    border.color: theme.border; border.width: 1
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 52; radius: theme.radiusLG
                        color: theme.accent

                        Text {
                            text: "Enregistrer"
                            color: "white"
                            font.pixelSize: theme.fontMD; font.bold: true
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (editExNom !== "") {
                                    exerciseVM.modifierExercice(
                                        editExerciceId, editExNom,
                                        editExSets, editExReps, editExPoids
                                    )
                                    showEditExercice = false
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Popup confirmation suppr exercice ─
        Rectangle {
            anchors.fill: parent
            color: "#CC000000"
            visible: showDeleteExercice
            z: 30

            MouseArea { anchors.fill: parent }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 64
                height: delExCol.implicitHeight + 40
                radius: theme.radiusLG
                color: theme.bgCard
                border.color: theme.border; border.width: 1

                ColumnLayout {
                    id: delExCol
                    anchors.centerIn: parent
                    width: parent.width - 40
                    spacing: 16

                    Text { text: "🗑️"; font.pixelSize: 36; Layout.alignment: Qt.AlignHCenter }
                    Text {
                        text: "Supprimer cet exercice ?"
                        color: theme.textPrimary
                        font.pixelSize: theme.fontLG; font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: "Cette action est irréversible."
                        color: theme.textSecondary
                        font.pixelSize: theme.fontSM
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Row {
                        Layout.fillWidth: true
                        spacing: 12

                        Rectangle {
                            width: (parent.width - 12) / 2
                            height: 48; radius: theme.radiusMD
                            color: theme.bgInput
                            border.color: theme.border; border.width: 1

                            Text {
                                text: "Annuler"
                                color: theme.textPrimary
                                font.pixelSize: theme.fontMD; font.bold: true
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: { showDeleteExercice = false; exerciceToDelete = -1 }
                            }
                        }

                        Rectangle {
                            width: (parent.width - 12) / 2
                            height: 48; radius: theme.radiusMD
                            color: "#FF6B6B"

                            Text {
                                text: "Supprimer"
                                color: "white"
                                font.pixelSize: theme.fontMD; font.bold: true
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    exerciseVM.supprimerExercice(exerciceToDelete)
                                    progressVM.refresh()
                                    showDeleteExercice = false
                                    exerciceToDelete = -1
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Popup calories brûlées ────────────
        Rectangle {
            anchors.fill: parent
            color: "#CC000000"
            visible: showCaloriesPopup
            z: 30

            MouseArea { anchors.fill: parent }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 48
                height: caloriesCol.implicitHeight + 48
                radius: theme.radiusLG
                color: theme.bgCard
                border.color: theme.border; border.width: 1

                ColumnLayout {
                    id: caloriesCol
                    anchors.centerIn: parent
                    width: parent.width - 40
                    spacing: 20

                    Text {
                        text: "🔥"
                        font.pixelSize: 56
                        Layout.alignment: Qt.AlignHCenter

                        SequentialAnimation on scale {
                            running: showCaloriesPopup
                            loops: Animation.Infinite
                            NumberAnimation { to: 1.15; duration: 600; easing.type: Easing.InOutSine }
                            NumberAnimation { to: 1.0;  duration: 600; easing.type: Easing.InOutSine }
                        }
                    }

                    Text {
                        text: "Séance terminée !"
                        color: theme.textPrimary
                        font.pixelSize: theme.fontXL; font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 80; radius: theme.radiusLG
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#00D4AA22" }
                            GradientStop { position: 1.0; color: "#4FACFE22" }
                        }
                        border.color: theme.accent; border.width: 1

                        Column {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: exerciseVM.dernieresCalories + " kcal"
                                color: theme.accent
                                font.pixelSize: 28; font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: "calories brûlées 💪"
                                color: theme.textSecondary
                                font.pixelSize: theme.fontSM
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    Text {
                        text: "Excellent travail ! Continue comme ça."
                        color: theme.textSecondary
                        font.pixelSize: theme.fontSM
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 52; radius: theme.radiusLG
                        color: theme.accent

                        Text {
                            text: "Super ! 🎉"
                            color: "white"
                            font.pixelSize: theme.fontMD; font.bold: true
                            anchors.centerIn: parent
                        }

                        scale: closeBtn.pressed ? 0.97 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        MouseArea {
                            id: closeBtn
                            anchors.fill: parent
                            onClicked: showCaloriesPopup = false
                        }
                    }
                }
            }
        }

        Connections {
            target: exerciseVM

            function onSeanceTermineeChanged() {
                if (exerciseVM.seanceTerminee) {
                    showCaloriesPopup = true
                    exerciseVM.setSeanceTerminee(false)

                    var cal = exerciseVM.dernieresCalories

                    coachVM.envoyerMessageAuto(
                        "Je viens de terminer ma séance ! J'ai brûlé " +
                        cal +
                        " kcal 💪 Donne-moi des conseils de récupération."
                    )
                }
            }

            function onBadgesDebloques(badges) {
                badgeNotificationCount = badges.length

                if (badges.length === 1) {
                    badgeNotificationText = badges[0].nom
                } else {
                    badgeNotificationText = "Nouveaux badges débloqués !"
                }

                showBadgeNotification = true
                badgeNotificationTimer.restart()
            }
        }
    }
}