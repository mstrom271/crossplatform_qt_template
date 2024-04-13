#pragma once

#include <QEvent>

class ThemeChangeEvent : public QEvent {
  public:
    static const QEvent::Type type =
        static_cast<QEvent::Type>(QEvent::User + 200);
    ThemeChangeEvent() : QEvent(static_cast<QEvent::Type>(type)) {}
};

class Theme {
    Theme();
    Theme(const Theme &other) = delete;
    Theme &operator=(const Theme &other) = delete;

  public:
    static Theme &instance();

    static void applyTheme();
    static QString getSystemTheme();
    static QString getEffectiveTheme();
    static void notifyAll();
    static QStringList getThemeList();
    static QString correct(QString theme);
};
