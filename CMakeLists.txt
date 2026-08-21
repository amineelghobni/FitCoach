cmake_minimum_required(VERSION 3.16)
project(FitCoach VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Sql QuickControls2 Network)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appFitCoach
    main.cpp
)

qt_add_resources(appFitCoach "conf"
    PREFIX "/"
    FILES qtquickcontrols2.conf
)

qt_add_qml_module(appFitCoach
    URI FitCoach
    QML_FILES
        Main.qml
        ui/theme/Theme.qml
        ui/pages/HomePage.qml
        ui/pages/NutritionPage.qml
        ui/pages/ExercisePage.qml
        ui/pages/CoachPage.qml
        ui/pages/ProgressPage.qml
        ui/pages/OnboardingPage.qml
        ui/pages/ProfilePage.qml
        ui/pages/SplashScreen.qml
        ui/pages/ProgrammePage.qml
        ui/pages/WorkoutSessionPage.qml
        ui/pages/ExerciseHistoryPage.qml
    SOURCES
        database/DatabaseManager.h
        database/DatabaseManager.cpp
        viewmodels/HomeViewModel.h
        viewmodels/HomeViewModel.cpp
        viewmodels/NutritionViewModel.h
        viewmodels/NutritionViewModel.cpp
        viewmodels/ExerciseViewModel.h
        viewmodels/ExerciseViewModel.cpp
        viewmodels/ProgressViewModel.h
        viewmodels/ProgressViewModel.cpp
        viewmodels/CoachViewModel.h
        viewmodels/CoachViewModel.cpp
        viewmodels/ProfileViewModel.h
        viewmodels/ProfileViewModel.cpp
        viewmodels/ProgrammeViewModel.h
        viewmodels/ProgrammeViewModel.cpp
        viewmodels/SessionViewModel.h
        viewmodels/SessionViewModel.cpp
        services/NutritionService.h
        services/NutritionService.cpp
        services/ExerciseService.h
        services/ExerciseService.cpp
        services/AICoachService.h
        services/AICoachService.cpp
)

target_link_libraries(appFitCoach
    PRIVATE
        Qt6::Quick
        Qt6::Sql
        Qt6::QuickControls2
        Qt6::Network
)

set_target_properties(appFitCoach PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

install(TARGETS appFitCoach
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
# ── Tests ──────────────────────────────────────────────────
enable_testing()
find_package(Qt6 REQUIRED COMPONENTS Test)

qt_add_executable(tst_exerciseviewmodel
    tests/tst_exerciseviewmodel.cpp
    viewmodels/ExerciseViewModel.cpp
    viewmodels/ExerciseViewModel.h
    services/ExerciseService.cpp
    services/ExerciseService.h
    database/DatabaseManager.cpp
    database/DatabaseManager.h
)
target_link_libraries(tst_exerciseviewmodel
    PRIVATE
        Qt6::Test
        Qt6::Sql
        Qt6::Quick
)

add_test(NAME tst_exerciseviewmodel COMMAND tst_exerciseviewmodel)

qt_add_executable(tst_sessionviewmodel
    tests/tst_sessionviewmodel.cpp

    viewmodels/SessionViewModel.cpp
    viewmodels/SessionViewModel.h

    services/ExerciseService.cpp
    services/ExerciseService.h

    database/DatabaseManager.cpp
    database/DatabaseManager.h
)

target_link_libraries(tst_sessionviewmodel
    PRIVATE
        Qt6::Test
        Qt6::Sql
        Qt6::Core
)

add_test(
    NAME tst_sessionviewmodel
    COMMAND tst_sessionviewmodel
)

qt_add_executable(tst_exerciseservice
    tests/tst_exerciseservice.cpp
    services/ExerciseService.cpp
    services/ExerciseService.h
    database/DatabaseManager.cpp
    database/DatabaseManager.h
)

target_link_libraries(tst_exerciseservice
    PRIVATE
        Qt6::Test
        Qt6::Sql
        Qt6::Core
)

add_test(
    NAME tst_exerciseservice
    COMMAND tst_exerciseservice
)

# ── Code Coverage ──────────────────────────────────────────
option(ENABLE_COVERAGE "Enable code coverage" OFF)

if(ENABLE_COVERAGE AND CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    message(STATUS "Code coverage enabled")

    target_compile_options(tst_exerciseviewmodel
        PRIVATE
            --coverage
            -O0
            -g
    )

    target_link_options(tst_exerciseviewmodel
        PRIVATE
            --coverage
    )
endif()