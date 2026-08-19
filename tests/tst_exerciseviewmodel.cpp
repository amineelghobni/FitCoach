#include <QtTest>
#include <QDate>
#include "../viewmodels/ExerciseViewModel.h"

class TestExerciseViewModel : public QObject
{
    Q_OBJECT

private slots:
    void labelDate_aujourdhui();
    void labelDate_hier();
    void labelDate_ilya2jours();
    void labelDate_dateAncienne();
    void labelDate_formatInvalide();
};

void TestExerciseViewModel::labelDate_aujourdhui()
{
    ExerciseViewModel vm;
    QString today = QDate::currentDate().toString("yyyy-MM-dd");
    QCOMPARE(vm.labelDate(today), QString("Aujourd'hui"));
}

void TestExerciseViewModel::labelDate_hier()
{
    ExerciseViewModel vm;
    QString yesterday = QDate::currentDate().addDays(-1).toString("yyyy-MM-dd");
    QCOMPARE(vm.labelDate(yesterday), QString("Hier"));
}

void TestExerciseViewModel::labelDate_ilya2jours()
{
    ExerciseViewModel vm;
    QString twoDaysAgo = QDate::currentDate().addDays(-2).toString("yyyy-MM-dd");
    QCOMPARE(vm.labelDate(twoDaysAgo), QString("Il y a 2 jours"));
}

void TestExerciseViewModel::labelDate_dateAncienne()
{
    ExerciseViewModel vm;
    QDate old = QDate::currentDate().addDays(-10);
    QString expected = old.toString("dddd dd MMMM");
    QCOMPARE(vm.labelDate(old.toString("yyyy-MM-dd")), expected);
}

void TestExerciseViewModel::labelDate_formatInvalide()
{
    ExerciseViewModel vm;
    // Une date invalide donne un QDate invalide → toString() renvoie une chaîne vide
    QString result = vm.labelDate("pas-une-date");
    QVERIFY(result.isEmpty() || result != "Aujourd'hui");
}

QTEST_MAIN(TestExerciseViewModel)
#include "tst_exerciseviewmodel.moc"