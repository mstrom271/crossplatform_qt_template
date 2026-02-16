#pragma once

#include <QFont>
#include <QSettings>

class Settings {
    QSettings settings;

    bool FirstRun;
    QString Language;
    QString Theme;
    QFont Font;
    uint Param1;
    bool Param2;

    Settings();
    Settings(const Settings &) = delete;
    Settings &operator=(const Settings &) = delete;
    void upgradeOldSettings();

  public:
    static Settings &instance();

    static bool getFirstRun();

    static QString getLanguage();
    static void setLanguage(QString newLanguage);

    static QString getTheme();
    static void setTheme(QString newTheme);

    static QFont getFont();
    static void setFont(QFont newFont);

    static uint getParam1();
    static void setParam1(uint newParam1);

    static bool getParam2();
    static void setParam2(bool newParam2);
};