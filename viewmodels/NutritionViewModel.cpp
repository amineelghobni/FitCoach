#include "NutritionViewModel.h"
#include "../database/DatabaseManager.h"
#include <QDate>

// ── MealModel ─────────────────────────────────────────────

MealModel::MealModel(QObject* parent)
    : QAbstractListModel(parent) {}

int MealModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid()) return 0;
    return m_meals.size();
}

QVariant MealModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() >= m_meals.size()) return {};
    const Meal& m = m_meals[index.row()];
    switch (role) {
    case IdRole:        return m.id;
    case NomRole:       return m.nom;
    case CaloriesRole:  return m.calories;
    case ProteinesRole: return m.proteines;
    case GlucidesRole:  return m.glucides;
    case LipidesRole:   return m.lipides;
    case MomentRole:    return m.moment;
    case HeureRole:     return m.heure;
    }
    return {};
}

QHash<int, QByteArray> MealModel::roleNames() const {
    return {
        { IdRole,        "mealId"    },
        { NomRole,       "nom"       },
        { CaloriesRole,  "calories"  },
        { ProteinesRole, "proteines" },
        { GlucidesRole,  "glucides"  },
        { LipidesRole,   "lipides"   },
        { MomentRole,    "moment"    },
        { HeureRole,     "heure"     }
    };
}

void MealModel::loadFromDb(const QString& date) {
    beginResetModel();
    m_meals.clear();

    auto q = DatabaseManager::instance().execQuery(
        "SELECT id, nom, calories, proteines, glucides, lipides, "
        "moment, heure FROM meals WHERE date = ? "
        "ORDER BY heure ASC",
        { date }
        );

    while (q.next()) {
        m_meals.append({
            q.value(0).toInt(),
            q.value(1).toString(),
            q.value(2).toInt(),
            q.value(3).toDouble(),
            q.value(4).toDouble(),
            q.value(5).toDouble(),
            q.value(6).toString(),
            q.value(7).toString()
        });
    }

    endResetModel();
}

void MealModel::clear() {
    beginResetModel();
    m_meals.clear();
    endResetModel();
}

// ── NutritionViewModel ────────────────────────────────────

NutritionViewModel::NutritionViewModel(QObject* parent)
    : QObject(parent)
    , m_mealModel(new MealModel(this))
    , m_currentDate(QDate::currentDate())
{
    m_mealModel->loadFromDb(m_currentDate.toString("yyyy-MM-dd"));
}

MealModel* NutritionViewModel::meals() const {
    return m_mealModel;
}

QString NutritionViewModel::currentDate() const {
    return m_currentDate.toString("yyyy-MM-dd");
}

QString NutritionViewModel::currentDateDisplay() const {
    if (isToday())
        return "Aujourd'hui";
    if (m_currentDate == QDate::currentDate().addDays(-1))
        return "Hier";
    return m_currentDate.toString("dddd dd MMMM");
}

bool NutritionViewModel::isToday() const {
    return m_currentDate == QDate::currentDate();
}

void NutritionViewModel::previousDay() {
    m_currentDate = m_currentDate.addDays(-1);
    m_mealModel->loadFromDb(m_currentDate.toString("yyyy-MM-dd"));
    emit dateChanged();
    emit totalsChanged();
}

void NutritionViewModel::nextDay() {
    if (!isToday()) {
        m_currentDate = m_currentDate.addDays(1);
        m_mealModel->loadFromDb(m_currentDate.toString("yyyy-MM-dd"));
        emit dateChanged();
        emit totalsChanged();
    }
}

void NutritionViewModel::goToToday() {
    m_currentDate = QDate::currentDate();
    m_mealModel->loadFromDb(m_currentDate.toString("yyyy-MM-dd"));
    emit dateChanged();
    emit totalsChanged();
}

int NutritionViewModel::totalCalories() const {
    auto q = DatabaseManager::instance().execQuery(
        "SELECT COALESCE(SUM(calories), 0) FROM meals WHERE date = ?",
        { m_currentDate.toString("yyyy-MM-dd") }
        );
    if (q.next()) return q.value(0).toInt();
    return 0;
}

double NutritionViewModel::totalProteines() const {
    auto q = DatabaseManager::instance().execQuery(
        "SELECT COALESCE(SUM(proteines), 0) FROM meals WHERE date = ?",
        { m_currentDate.toString("yyyy-MM-dd") }
        );
    if (q.next()) return q.value(0).toDouble();
    return 0;
}

double NutritionViewModel::totalGlucides() const {
    auto q = DatabaseManager::instance().execQuery(
        "SELECT COALESCE(SUM(glucides), 0) FROM meals WHERE date = ?",
        { m_currentDate.toString("yyyy-MM-dd") }
        );
    if (q.next()) return q.value(0).toDouble();
    return 0;
}

double NutritionViewModel::totalLipides() const {
    auto q = DatabaseManager::instance().execQuery(
        "SELECT COALESCE(SUM(lipides), 0) FROM meals WHERE date = ?",
        { m_currentDate.toString("yyyy-MM-dd") }
        );
    if (q.next()) return q.value(0).toDouble();
    return 0;
}

void NutritionViewModel::ajouterRepas(const QString& nom, int calories,
                                      double proteines, double glucides,
                                      double lipides, const QString& moment)
{
    DatabaseManager::instance().execQuery(
        "INSERT INTO meals (nom, calories, proteines, glucides, lipides, moment, date) "
        "VALUES (?, ?, ?, ?, ?, ?, ?)",
        { nom, calories, proteines, glucides, lipides, moment,
         m_currentDate.toString("yyyy-MM-dd") }
        );

    m_mealModel->loadFromDb(m_currentDate.toString("yyyy-MM-dd"));
    emit totalsChanged();
}

void NutritionViewModel::supprimerRepas(int id)
{
    DatabaseManager::instance().execQuery(
        "DELETE FROM meals WHERE id = ?", { id }
        );

    m_mealModel->loadFromDb(m_currentDate.toString("yyyy-MM-dd"));
    emit totalsChanged();
}

void NutritionViewModel::modifierRepas(int id, const QString& nom, int calories,
                                       double proteines, double glucides,
                                       double lipides, const QString& moment)
{
    DatabaseManager::instance().execQuery(
        "UPDATE meals SET nom=?, calories=?, proteines=?, glucides=?, "
        "lipides=?, moment=? WHERE id=?",
        { nom, calories, proteines, glucides, lipides, moment, id }
        );

    m_mealModel->loadFromDb(m_currentDate.toString("yyyy-MM-dd"));
    emit totalsChanged();
}

void NutritionViewModel::refresh()
{
    m_mealModel->loadFromDb(m_currentDate.toString("yyyy-MM-dd"));
    emit totalsChanged();
}