#pragma once

#include <QEvent>
#include <QTranslator>

class LanguageChangeEvent : public QEvent {
  public:
    static const QEvent::Type type =
        static_cast<QEvent::Type>(QEvent::User + 201);
    LanguageChangeEvent() : QEvent(static_cast<QEvent::Type>(type)) {}
};

class Language {
    QTranslator translator;

    Language();
    Language(const Language &other) = delete;
    Language &operator=(const Language &other) = delete;

  public:
    static Language &instance();

    static void applyLanguage();
    static QString getSystemLanguage();
    static QString getEffectiveLanguage();
    static void notifyAll();
    static QStringList getLanguageList();
    static QString correct(QString language);
};
