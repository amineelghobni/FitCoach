#include "HomeViewModel.h"
#include "../database/DatabaseManager.h"
#include <QDate>

HomeViewModel::HomeViewModel(QObject* parent)
    : QObject(parent) {}

bool HomeViewModel::isFirstLaunch() const
{
    return DatabaseManager::instance().isFirstLaunch();
}

QString HomeViewModel::userNom() const
{
    auto q = DatabaseManager::instance().execQuery(
        "SELECT nom FROM users LIMIT 1"
        );
    if (q.next()) return q.value(0).toString();
    return "Utilisateur";
}

int HomeViewModel::calories() const
{
    auto q = DatabaseManager::instance().execQuery(
        "SELECT COALESCE(SUM(calories), 0) FROM meals WHERE date = ?",
        { QDate::currentDate().toString("yyyy-MM-dd") }
        );
    if (q.next()) return q.value(0).toInt();
    return 0;
}

int HomeViewModel::caloriesMax() const
{
    QString saved = DatabaseManager::instance()
    .getSetting("calories_objectif", "");
    if (!saved.isEmpty()) return saved.toInt();

    auto q = DatabaseManager::instance().execQuery(
        "SELECT poids, objectif FROM users LIMIT 1"
        );
    if (q.next()) {
        double  poids    = q.value(0).toDouble();
        QString objectif = q.value(1).toString();
        int base = static_cast<int>(poids * 30);
        if (objectif == "prise_muscle") return base + 300;
        if (objectif == "perte_poids")  return base - 300;
        return base;
    }
    return 2200;
}

double HomeViewModel::proteines() const
{
    auto q = DatabaseManager::instance().execQuery(
        "SELECT COALESCE(SUM(proteines), 0) FROM meals WHERE date = ?",
        { QDate::currentDate().toString("yyyy-MM-dd") }
        );
    if (q.next()) return q.value(0).toDouble();
    return 0;
}

double HomeViewModel::glucides() const
{
    auto q = DatabaseManager::instance().execQuery(
        "SELECT COALESCE(SUM(glucides), 0) FROM meals WHERE date = ?",
        { QDate::currentDate().toString("yyyy-MM-dd") }
        );
    if (q.next()) return q.value(0).toDouble();
    return 0;
}

double HomeViewModel::lipides() const
{
    auto q = DatabaseManager::instance().execQuery(
        "SELECT COALESCE(SUM(lipides), 0) FROM meals WHERE date = ?",
        { QDate::currentDate().toString("yyyy-MM-dd") }
        );
    if (q.next()) return q.value(0).toDouble();
    return 0;
}

void HomeViewModel::completeOnboarding(const QString& nom, int age,
                                       double poids, int taille,
                                       const QString& objectif,
                                       const QString& niveau,
                                       int joursSemaine,
                                       const QString& equipement)
{
    DatabaseManager::instance().completeOnboarding(
        nom, age, poids, taille, objectif, niveau, joursSemaine, equipement
        );
    emit userNomChanged();
    emit dataChanged();
}

void HomeViewModel::refresh()
{
    emit dataChanged();
    emit userNomChanged();
}

int HomeViewModel::caloriesObjectif() const
{
    return DatabaseManager::instance()
    .getSetting("calories_objectif", "2200").toInt();
}

void HomeViewModel::setCaloriesObjectif(int objectif)
{
    DatabaseManager::instance()
    .setSetting("calories_objectif", QString::number(objectif));
    emit dataChanged();
}
int HomeViewModel::caloriesBrulees() const
{
    auto q = DatabaseManager::instance().execQuery(
        "SELECT COALESCE(SUM(calories_brulees), 0) FROM workouts WHERE date = ?",
        { QDate::currentDate().toString("yyyy-MM-dd") }
        );
    if (q.next()) return q.value(0).toInt();
    return 0;
}