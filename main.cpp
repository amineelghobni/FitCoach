#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtQuickControls2/QQuickStyle>
#include "database/DatabaseManager.h"
#include "viewmodels/HomeViewModel.h"
#include "viewmodels/NutritionViewModel.h"
#include "viewmodels/ExerciseViewModel.h"
#include "viewmodels/ProgressViewModel.h"
#include "viewmodels/CoachViewModel.h"
#include "viewmodels/ProfileViewModel.h"
#include "viewmodels/ProgrammeViewModel.h"
#include "viewmodels/SessionViewModel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("FitCoach");
    app.setApplicationName("FitCoach");

    DatabaseManager::instance();
    QQuickStyle::setStyle("Basic");

    QQmlApplicationEngine engine;

    HomeViewModel      homeVM;
    NutritionViewModel nutritionVM;
    ExerciseViewModel  exerciseVM;
    ProgressViewModel  progressVM;
    CoachViewModel     coachVM;
    ProfileViewModel   profileVM;
    ProgrammeViewModel programmeVM;
    SessionViewModel sessionVM;

    engine.rootContext()->setContextProperty("homeVM",      &homeVM);
    engine.rootContext()->setContextProperty("nutritionVM", &nutritionVM);
    engine.rootContext()->setContextProperty("exerciseVM",  &exerciseVM);
    engine.rootContext()->setContextProperty("progressVM",  &progressVM);
    engine.rootContext()->setContextProperty("coachVM",     &coachVM);
    engine.rootContext()->setContextProperty("profileVM",   &profileVM);
    engine.rootContext()->setContextProperty("programmeVM", &programmeVM); 
    engine.rootContext()->setContextProperty("sessionVM", &sessionVM);

    engine.addImportPath("qrc:/qt/qml");
    engine.loadFromModule("FitCoach", "Main");
    return QCoreApplication::exec();
}