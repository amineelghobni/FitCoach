#include "ProfileViewModel.h"
#include "../database/DatabaseManager.h"

ProfileViewModel::ProfileViewModel(QObject* parent)
    : QObject(parent) {}

QString ProfileViewModel::nom() const {
    auto q = DatabaseManager::instance().execQuery(
        "SELECT nom FROM users LIMIT 1"
        );
    if (q.next()) return q.value(0).toString();
    return "";
}

int ProfileViewModel::age() const {
    auto q = DatabaseManager::instance().execQuery(
        "SELECT age FROM users LIMIT 1"
        );
    if (q.next()) return q.value(0).toInt();
    return 0;
}

double ProfileViewModel::poids() const {
    auto q = DatabaseManager::instance().execQuery(
        "SELECT poids FROM users LIMIT 1"
        );
    if (q.next()) return q.value(0).toDouble();
    return 0;
}

int ProfileViewModel::taille() const {
    auto q = DatabaseManager::instance().execQuery(
        "SELECT taille FROM users LIMIT 1"
        );
    if (q.next()) return q.value(0).toInt();
    return 0;
}

QString ProfileViewModel::objectif() const {
    auto q = DatabaseManager::instance().execQuery(
        "SELECT objectif FROM users LIMIT 1"
        );
    if (q.next()) return q.value(0).toString();
    return "";
}

QString ProfileViewModel::niveau() const {
    auto q = DatabaseManager::instance().execQuery(
        "SELECT niveau FROM users LIMIT 1"
        );
    if (q.next()) return q.value(0).toString();
    return "";
}

int ProfileViewModel::joursSemaine() const {
    auto q = DatabaseManager::instance().execQuery(
        "SELECT jours_semaine FROM users LIMIT 1"
        );
    if (q.next()) return q.value(0).toInt();
    return 3;
}

QString ProfileViewModel::equipement() const {
    auto q = DatabaseManager::instance().execQuery(
        "SELECT equipement FROM users LIMIT 1"
        );
    if (q.next()) return q.value(0).toString();
    return "";
}

void ProfileViewModel::sauvegarder(const QString& nom, int age,
                                   double poids, int taille,
                                   const QString& objectif,
                                   const QString& niveau,
                                   int joursSemaine,
                                   const QString& equipement)
{
    DatabaseManager::instance().execQuery(
        "UPDATE users SET nom=?, age=?, poids=?, taille=?, "
        "objectif=?, niveau=?, jours_semaine=?, equipement=? "
        "WHERE id = (SELECT id FROM users LIMIT 1)",
        { nom, age, poids, taille, objectif, niveau, joursSemaine, equipement }
        );
    emit dataChanged();
}