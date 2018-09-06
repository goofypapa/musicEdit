#ifndef MUSICEDIT_H
#define MUSICEDIT_H

#include <QObject>
#include <QString>
#include <QMediaPlayer>


class musicEdit : public QObject
{

    Q_OBJECT
public:
    musicEdit( QObject * parent = nullptr );
    ~musicEdit();
public slots:
    QString readFile( const QString p_str );
    bool saveFile( const QString p_data );
    bool saveFileAs( const QString p_str, const QString p_data );
    QString parsePower( const QString p_music, const QString p_data, int p_errorTime, int p_minPower, int p_maxPower, float p_mulitple );
    QString parsePower( const QString p_music, const QString p_data_1, const QString p_data_2, const QString p_data_3 );

    QString getPwd( void );


    void play( const QString p_path, const int p_volume );


    void stateChanged( QMediaPlayer::State p_state );


private:
    QString m_filePath;
};

#endif // MUSICEDIT_H
