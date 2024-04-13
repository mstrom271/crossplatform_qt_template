#include "theme.h"
#include "settings.h"
#include <QApplication>
#include <QStringList>
#include <QWidget>

Theme::Theme() {}

Theme &Theme::instance() {
    static Theme instance;
    return instance;
}

// notify all widgets to change a theme
void Theme::notifyAll() {
    const QWidgetList allWidgets = QApplication::allWidgets();
    for (auto widget : allWidgets) {
        QApplication::instance()->postEvent(widget, new ThemeChangeEvent);
    }
}

void Theme::applyTheme() {
    // QString style;
    // static_cast<QApplication
    // *>(QApplication::instance())->setStyleSheet(style);
    notifyAll();
}

QString Theme::getSystemTheme() {
    QPalette palette = QApplication::palette();
    QColor windowColor = palette.color(QPalette::Window);
    if (windowColor.value() < 128)
        return "DarkTheme";
    else
        return "LightTheme";
}

// sustitutes System theme for a real one
QString Theme::getEffectiveTheme() {
    QString theme = Settings::getTheme();
    theme = correct(theme);
    if (theme == "System") {
        qDebug() << getSystemTheme();
        return getSystemTheme();
    }
    qDebug() << theme;
    return theme;
}

QStringList Theme::getThemeList() {
    return {"System", "DarkTheme", "GreyTheme", "LightTheme"};
}

// check if theme is allowed. Return default, if theme is incorrect
QString Theme::correct(QString theme) {
    QStringList themeAllowed = getThemeList();
    if (!themeAllowed.contains(theme))
        return themeAllowed.front();
    return theme;
}
