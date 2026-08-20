#pragma once
#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QStandardPaths>
#include <QDir>

class DatabaseManager : public QObject
{
    Q_OBJECT

public:
    static DatabaseManager& instance();

    bool isOpen() const;
    bool openTestDatabase();
    void closeTestDatabase();

    bool isFirstLaunch() const;

    void completeOnboarding(const QString& nom, int age, double poids,
                            int taille, const QString& objectif,
                            const QString& niveau, int joursSemaine,
                            const QString& equipement);

    QSqlQuery execQuery(const QString& sql) const;
    QSqlQuery execQuery(const QString& sql, const QVariantList& params) const;

    QString getSetting(const QString& key, const QString& defaultValue = "") const;
    void    setSetting(const QString& key, const QString& value);
    QString trouverCategorieFuzzy(const QString& nomExercice, int seuilMax = 3) const;


private:
    explicit DatabaseManager(QObject* parent = nullptr);
    ~DatabaseManager() = default;

    DatabaseManager(const DatabaseManager&)            = delete;
    DatabaseManager& operator=(const DatabaseManager&) = delete;

    bool openDatabase();
    void createTables();

    QSqlDatabase m_db;
    QSqlDatabase m_testDb;

    void seedExercisesLibrary();
};