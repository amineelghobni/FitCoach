#include "ProgressViewModel.h"
#include "../database/DatabaseManager.h"
#include <QDate>
#include <QMap>
#include <numeric>

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
QVariantList ProgressViewModel::badges() const
{
    QVariantList result;

    auto q = DatabaseManager::instance().execQuery(
        "SELECT code, nom, description, date_obtention "
        "FROM badges "
        "ORDER BY date_obtention DESC"
        );

    while (q.next()) {
        QVariantMap badge;

        badge["code"] = q.value(0).toString();
        badge["nom"] = q.value(1).toString();
        badge["description"] = q.value(2).toString();
        badge["date"] = q.value(3).toString();

        result.append(badge);
    }

    return result;
}
QVariantList ProgressViewModel::repartitionMusculaire() const
{
    QVariantList result;

    QStringList categories = {"Push", "Pull", "Legs", "Core"};
    QStringList emojis     = {"💪", "🔄", "🦵", "🎯"};
    QStringList colors     = {"#00D4AA", "#4FACFE", "#FF6B6B", "#FFD700"};

    QMap<QString, double> volumeParCategorie;
    for (const QString& cat : categories)
        volumeParCategorie[cat] = 0;

    auto q = DatabaseManager::instance().execQuery(
        "SELECT we.categorie, "
        "SUM(we.sets * we.reps * we.poids) "
        "FROM workout_exercises we "
        "JOIN workouts w ON w.id = we.workout_id "
        "WHERE we.categorie IS NOT NULL "
        "AND we.categorie != '' "
        "AND w.date >= date('now', '-6 days') "
        "GROUP BY we.categorie"
        );

    while (q.next()) {
        QString cat = q.value(0).toString();
        double vol = q.value(1).toDouble();

        qDebug() << "CAT =" << cat << "VOL =" << vol;

        if (volumeParCategorie.contains(cat))
            volumeParCategorie[cat] = vol;
    }

    double total = std::accumulate(
        categories.cbegin(),
        categories.cend(),
        0.0,
        [&volumeParCategorie](double somme, const QString& cat) {
            return somme + volumeParCategorie[cat];
        }
    );

    qDebug() << "TOTAL =" << total;

    for (int i = 0; i < categories.size(); i++) {
        QVariantMap item;
        item["categorie"] = categories[i];
        item["emoji"] = emojis[i];
        item["color"] = colors[i];
        item["volume"] = volumeParCategorie[categories[i]];
        item["pct"] = total > 0
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

QVariantList ProgressViewModel::progressionBadges() const
{
    QVariantList result;

    // Nombre total de séances
    int nombreSeances = 0;

    auto qSeances = DatabaseManager::instance().execQuery(
        "SELECT COUNT(*) FROM workouts"
        );

    if (qSeances.next())
        nombreSeances = qSeances.value(0).toInt();

    // Nombre total de PR
    int totalPR = 0;

    auto qPR = DatabaseManager::instance().execQuery(
        "SELECT COUNT(*) FROM personal_records"
        );

    if (qPR.next())
        totalPR = qPR.value(0).toInt();

    // Streak actuel basé sur les séances
    int streak = 0;

    auto qStreak = DatabaseManager::instance().execQuery(
        "SELECT DISTINCT date FROM workouts ORDER BY date DESC"
        );

    QDate expected = QDate::currentDate();

    while (qStreak.next()) {
        const QDate date = QDate::fromString(
            qStreak.value(0).toString(),
            "yyyy-MM-dd"
            );

        if (date == expected) {
            ++streak;
            expected = expected.addDays(-1);
        } else {
            break;
        }
    }

    struct BadgeProgress {
        const char* code;
        const char* nom;
        const char* description;
        int progression;
        int objectif;
    };

    const QList<BadgeProgress> badgeList = {
        {
            "FIRST_WORKOUT",
            "🥇 Première Séance",
            "Créer ta première séance",
            nombreSeances,
            1
        },
        {
            "FIVE_WORKOUTS",
            "💪 Régulier",
            "Atteindre 5 séances",
            nombreSeances,
            5
        },
        {
            "TEN_WORKOUTS",
            "🏋️ 10 Séances",
            "Atteindre 10 séances",
            nombreSeances,
            10
        },
        {
            "TWENTY_FIVE_WORKOUTS",
            "🔥 25 Séances",
            "Atteindre 25 séances",
            nombreSeances,
            25
        },
        {
            "FIRST_PR",
            "🏆 Premier Record",
            "Obtenir ton premier record personnel",
            totalPR,
            1
        },
        {
            "FIVE_PR",
            "🏆 5 Records",
            "Obtenir 5 records personnels",
            totalPR,
            5
        },
        {
            "TEN_PR",
            "🏆 10 Records",
            "Obtenir 10 records personnels",
            totalPR,
            10
        },
        {
            "STREAK_3",
            "🔥 Streak 3 jours",
            "T'entraîner 3 jours consécutifs",
            streak,
            3
        },
        {
            "STREAK_7",
            "🔥 Streak 7 jours",
            "T'entraîner 7 jours consécutifs",
            streak,
            7
        },
        {
            "STREAK_30",
            "🔥 Streak 30 jours",
            "T'entraîner 30 jours consécutifs",
            streak,
            30
        }
    };

    for (const auto& badge : badgeList) {

        auto q = DatabaseManager::instance().execQuery(
            "SELECT date_obtention "
            "FROM badges "
            "WHERE code = ? "
            "LIMIT 1",
            { QString::fromUtf8(badge.code) }
            );

        const bool debloque = q.next();

        QVariantMap item;

        item["code"] = QString::fromUtf8(badge.code);
        item["nom"] = QString::fromUtf8(badge.nom);
        item["description"] = QString::fromUtf8(badge.description);

        item["progression"] = qMin(
            badge.progression,
            badge.objectif
            );

        item["objectif"] = badge.objectif;

        item["pourcentage"] = qMin(
            100,
            qRound(
                static_cast<double>(badge.progression)
                * 100.0
                / badge.objectif
                )
            );

        item["debloque"] = debloque;

        item["date"] = debloque
                           ? q.value(0).toString()
                           : QString();

        result.append(item);
    }

    return result;
}