#pragma once

#include <QColor>
#include <QEvent>
#include <QMap>

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
    static Theme &getInstance();

    static void applyTheme(QString theme);
    static QString getSystemTheme();
    static void notifyAll();
    static QString correct(QString theme);

    enum ColorRole {
        TransparentText,
        Text,
        Background,
        Control,
        ControlStart,
        ControlStop
    };
    static void setColor(ColorRole colorRole, QColor color);
    static QColor getColor(ColorRole colorRole);

  private:
    QMap<ColorRole, QColor> colorMap;
};
