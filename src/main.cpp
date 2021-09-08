#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <QGuiApplication>
#include <QQmlEngine>
#include <QQmlContext>
#include <QQuickView>
#include <QDebug>

#include <sailfishapp.h>

int main(int argc, char *argv[])
{
  QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));

  QScopedPointer<QQuickView> v;
  v.reset(SailfishApp::createView());
  QQmlContext *rootContext = v->rootContext();

  v->setSource(SailfishApp::pathTo("qml/main.qml"));
  v->show();

  return app->exec();
}
