import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import FitCoach

Window {
    width: 390
    height: 844
    visible: true
    title: "FitCoach"

    Theme { id: theme }
    color: "#0A0E17"

    property bool showOnboarding:  homeVM.isFirstLaunch
    property bool showProfile:     false
    property bool showProgramme:   false
    property int  currentPage:     0
    property int  previousPage:    0
    property bool showSplash:      true

    // ── Onboarding ────────────────────────────
    OnboardingPage {
        anchors.fill: parent
        visible: showOnboarding
        z: 10
        onOnboardingCompleted: showOnboarding = false
    }

    // ── Page Profil ───────────────────────────
    ProfilePage {
        anchors.fill: parent
        z: 15
        visible: showProfile

        x: showProfile ? 0 : parent.width
        Behavior on x {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        onFermer: showProfile = false
    }

    // ── Page Programme ────────────────────────
    ProgrammePage {
        anchors.fill: parent
        z: 15
        visible: showProgramme

        x: showProgramme ? 0 : parent.width
        Behavior on x {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        onFermer: showProgramme = false
        onSeanceAdoptee: exerciseVM.refresh()
    }
    // ── Page Session ──────────────────────────
    WorkoutSessionPage {
        anchors.fill: parent
        z: 20
        visible: sessionVM.actif

        onFermer: sessionVM.actif ? sessionVM.annulerSession() : {}
        onSeanceTerminee: {
            exerciseVM.refresh()
            homeVM.refresh()
        }
    }

    // ── App principale ────────────────────────
    Item {
        id: mainApp
        anchors.fill: parent
        visible: !showOnboarding

        Item {
            id: pageContainer
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: tabBarRect.top

            HomePage {
                id: page0
                anchors.fill: parent
            }
            NutritionPage {
                id: page1
                anchors.fill: parent
            }
            ExercisePage {
                id: page2
                anchors.fill: parent
                onOuvrirProgramme: showProgramme = true
                onSeanceTerminee:  page2.showCaloriesPopup = true
            }
            CoachPage {
                id: page3
                anchors.fill: parent
            }
            ProgressPage {
                id: page4
                anchors.fill: parent
            }

            states: []

            function showPage(index) {
                var pages = [page0, page1, page2, page3, page4]
                var direction = index > previousPage ? 1 : -1

                for (var i = 0; i < pages.length; i++) {
                    if (i !== currentPage && i !== index) {
                        pages[i].visible = false
                        pages[i].x = 0
                    }
                }

                pages[currentPage].visible = true
                slideOutX.target           = pages[currentPage]
                slideOutX.to               = -direction * width
                slideOutOpacity.target     = pages[currentPage]
                slideOut.start()

                pages[index].visible       = true
                pages[index].x             = direction * width
                pages[index].opacity       = 0
                slideInX.target            = pages[index]
                slideInOpacity.target      = pages[index]
                slideIn.start()

                previousPage = currentPage
                currentPage  = index
            }
        }

        // ── Animations pages ──────────────────
        ParallelAnimation {
            id: slideOut
            NumberAnimation {
                id: slideOutX
                property: "x"
                duration: 320
                easing.type: Easing.InOutCubic
            }
            NumberAnimation {
                id: slideOutOpacity
                target: slideOutX.target
                property: "opacity"
                to: 0
                duration: 320
                easing.type: Easing.InOutCubic
            }
            onFinished: {
                var pages = [page0, page1, page2, page3, page4]
                pages[previousPage].visible = false
                pages[previousPage].x = 0
                pages[previousPage].opacity = 1
            }
        }

        ParallelAnimation {
            id: slideIn
            NumberAnimation {
                id: slideInX
                property: "x"
                to: 0
                duration: 320
                easing.type: Easing.InOutCubic
            }
            NumberAnimation {
                id: slideInOpacity
                target: slideInX.target
                property: "opacity"
                from: 0
                to: 1
                duration: 320
                easing.type: Easing.InOutCubic
            }
        }

        // ── TabBar ────────────────────────────
        Rectangle {
            id: tabBarRect
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 72
            color: theme.bgPrimary
            border.color: theme.border
            border.width: 1

            Row {
                anchors.fill: parent

                Repeater {
                    model: [
                        { icon: "🏠", label: "Accueil"   },
                        { icon: "🥗", label: "Nutrition" },
                        { icon: "💪", label: "Exercices" },
                        { icon: "🤖", label: "Coach"     },
                        { icon: "📈", label: "Progrès"   }
                    ]

                    Item {
                        width: parent.width / 5
                        height: parent.height

                        Column {
                            spacing: 3
                            anchors.centerIn: parent

                            Text {
                                text: modelData.icon
                                font.pixelSize: currentPage === index ? 22 : 20
                                anchors.horizontalCenter: parent.horizontalCenter

                                Behavior on font.pixelSize {
                                    NumberAnimation { duration: 150 }
                                }
                            }
                            Text {
                                text: modelData.label
                                font.pixelSize: 10
                                color: currentPage === index
                                       ? theme.accent : theme.textHint
                                anchors.horizontalCenter: parent.horizontalCenter

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }
                        }

                        Rectangle {
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: currentPage === index ? 20 : 0
                            height: 3
                            radius: 2
                            color: theme.accent

                            Behavior on width {
                                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (index !== currentPage)
                                    pageContainer.showPage(index)
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Splash Screen ─────────────────────────
    SplashScreen {
        id: splashItem
        anchors.fill: parent
        z: 100

        opacity: showSplash ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation { duration: 800; easing.type: Easing.InCubic }
        }

        onSplashTermine: showSplash = false
    }

    // ── Initialisation ────────────────────────
    Component.onCompleted: {
        page1.visible = false
        page2.visible = false
        page3.visible = false
        page4.visible = false
        showProfile   = false
        showProgramme = false
    }
}