#include "ProgressViewModel.h"
#include "../database/DatabaseManager.h"
#include <QDate>
#include <QMap>

ProgressViewModel::ProgressViewModel(QObject* parent)
    : QObject(parent) {}

double ProgressViewModel::poidsActuel() const {
    auto q = DatabaseManager::instance().execQuery(
        "SELECT poids FROM weight_history ORDER BY date DESC LIMIT 1"
        );
    if (q.next()) return q.value(0).toDouble();
    auto q2 = DatabaseManager::instance().execQuery(
        "SELECT poids FROM users LIMIT 1"
        );
    if (q2.next()) return q2.value(0).toDouble();
    return 0;
}

double ProgressViewModel::poidsInitial() const {
    auto q = DatabaseManager::instance().execQuery(
        "SELECT poids FROM weight_history ORDER BY date ASC LIMIT 1"
        );
    if (q.next()) return q.value(0).toDouble();
    auto q2 = DatabaseManager::instance().execQuery(
        "SELECT poids FROM users LIMIT 1"
        );
    if (q2.next()) return q2.value(0).toDouble();
    return 0;
}

double ProgressViewModel::poidsDiff() const {
    auto q1 = DatabaseManager::instance().execQuery(
        "SELECT poids FROM weight_history ORDER BY date ASC LIMIT 1"
        );
    auto q2 = DatabaseManager::instance().execQuery(
        "SELECT poids FROM weight_history ORDER BY date DESC LIMIT 1"
        );
    if (q1.next() && q2.next())
        return q2.value(0).toDouble() - q1.value(0).toDouble();
    return 0.0;
}

int ProgressViewModel::totalSeances() const {
    auto q = DatabaseManager::instance().execQuery(
        "SELECT COUNT(*) FROM workouts"
        );
    if (q.next()) return q.value(0).toInt();
    return 0;
}

int ProgressViewModel::streakJours() const {
    auto q = DatabaseManager::instance().execQuery(
        "SELECT DISTINCT date FROM meals ORDER BY date DESC"
        );
    int streak = 0;
    QDate expected = QDate::currentDate();
    while (q.next()) {
        QDate d = QDate::fromString(q.value(0).toString(), "yyyy-MM-dd");
        if (d == expected) {
            streak++;
            expected = expected.addDays(-1);
        } else break;
    }
    return streak;
}

int ProgressViewModel::totalRepas() const {
    auto q = DatabaseManager::instance().execQuery(
        "SELECT COUNT(*) FROM meals"
        );
    if (q.next()) return q.value(0).toInt();
    return 0;
}

QVariantList ProgressViewModel::poidsHistory() const {
    QVariantList result;
    auto q = DatabaseManager::instance().execQuery(
        "SELECT poids, date FROM weight_history ORDER BY date ASC LIMIT 14"
        );
    while (q.next()) {
        QVariantMap point;
        point["poids"] = q.value(0).toDouble();
        point["date"]  = q.value(1).toString();
        result.append(point);
    }
    return result;
}

QVariantList ProgressViewModel::caloriesWeek() const {
    QVariantList result;
    auto q = DatabaseManager::instance().execQuery(
        "SELECT date, SUM(calories) FROM meals "
        "WHERE date >= date('now', '-6 days') "
        "GROUP BY date ORDER BY date ASC"
        );
    while (q.next()) {
        QVariantMap point;
        point["date"]     = q.value(0).toString();
        point["calories"] = q.value(1).toInt();
        result.append(point);
    }
    return result;
}

QVariantList ProgressViewModel::topPRs() const {
    QVariantList result;
    auto q = DatabaseManager::instance().execQuery(
        "SELECT exercice_nom, poids, reps, volume, date "
        "FROM personal_records "
        "GROUP BY exercice_nom "
        "ORDER BY volume DESC LIMIT 5"
        );
    while (q.next()) {
        QVariantMap pr;
        pr["nom"]    = q.value(0).toString();
        pr["poids"]  = q.value(1).toDouble();
        pr["reps"]   = q.value(2).toInt();
        pr["volume"] = q.value(3).toDouble();
        pr["date"]   = q.value(4).toString();
        result.append(pr);
    }
    return result;
}
QVariantList ProgressViewModel::repartitionMusculaire() const
{

    QVariantList result;

    QStringList categories = {"Push", "Pull", "Legs", "Core"};
    QStringList emojis     = {"💪",   "🔄",   "🦵",   "🎯"};
    QStringList colors     = {"#00D4AA", "#4FACFE", "#FF6B6B", "#FFD700"};

    QMap<QString, double> volumeParCategorie;
    for (const QString& cat : categories)
        volumeParCategorie[cat] = 0;

    auto q = DatabaseManager::instance().execQuery(
        "SELECT "
        "CASE "
        "WHEN LOWER(nom) LIKE '%développé%' THEN 'Push' "
        "WHEN LOWER(nom) LIKE '%ecarte%' THEN 'Push' "
        "WHEN LOWER(nom) LIKE '%écarté%' THEN 'Push' "
        "WHEN LOWER(nom) LIKE '%extension%' THEN 'Push' "

        "WHEN LOWER(nom) LIKE '%curl%' THEN 'Pull' "
        "WHEN LOWER(nom) LIKE '%rowing%' THEN 'Pull' "
        "WHEN LOWER(nom) LIKE '%traction%' THEN 'Pull' "
        "WHEN LOWER(nom) LIKE '%tirage%' THEN 'Pull' "

        "WHEN LOWER(nom) LIKE '%squat%' THEN 'Legs' "
        "WHEN LOWER(nom) LIKE '%fente%' THEN 'Legs' "
        "WHEN LOWER(nom) LIKE '%leg%' THEN 'Legs' "
        "WHEN LOWER(nom) LIKE '%mollet%' THEN 'Legs' "

        "WHEN LOWER(nom) LIKE '%gainage%' THEN 'Core' "
        "WHEN LOWER(nom) LIKE '%abdos%' THEN 'Core' "
        "WHEN LOWER(nom) LIKE '%crunch%' THEN 'Core' "

        "ELSE 'Core' "
        "END AS categorie, "
        "SUM(sets * reps * poids) AS volume "
        "FROM workout_exercises "
        "GROUP BY categorie"
        );

    while (q.next()) {

        QString cat = q.value(0).toString();
        double vol = q.value(1).toDouble();

        if (volumeParCategorie.contains(cat))
            volumeParCategorie[cat] = vol;
    }

    double total = 0;

    for (const QString& cat : categories)
        total += volumeParCategorie[cat];

    for (int i = 0; i < categories.size(); i++) {

        QVariantMap item;

        item["categorie"] = categories[i];
        item["emoji"]     = emojis[i];
        item["color"]     = colors[i];
        item["volume"]    = volumeParCategorie[categories[i]];
        item["pct"]       = total > 0
                          ? qRound(volumeParCategorie[categories[i]] * 100.0 / total)
                          : 0;

        result.append(item);
    }

    return result;
}


void ProgressViewModel::ajouterPoids(double poids) {
    DatabaseManager::instance().execQuery(
        "INSERT OR REPLACE INTO weight_history (poids, date) VALUES (?, date('now'))",
        { poids }
        );
    emit dataChanged();
}

void ProgressViewModel::refresh() {
    emit dataChanged();
}