
#include "myclass.h"
#include "settings.h"
#include <QApplication>

int main(int argc, char **argv) {
    QApplication app(argc, argv);
    QApplication::setOrganizationName(ORGANIZATION_NAME);
    QApplication::setApplicationName(PROJECT_NAME);

    qDebug() << Settings::getLanguage();
    qDebug() << Settings::getTheme();
    qDebug() << Settings::getFirstRun();

    MyClass myClass;
    myClass.resize(400, 300);
    myClass.show();

    return app.exec();
}
