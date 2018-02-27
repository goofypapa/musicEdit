#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <musicedit.h>
#include <QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    musicEdit * edit = new musicEdit();
    QQmlContext * context = engine.rootContext();
    context->setContextProperty( "musicedit", edit );

    engine.load(QUrl(QLatin1String("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
