#include "musicedit.h"

#include <QDebug>
#include <QFile>
#include <QCoreApplication>
#include <vector>
#include <math.h>
#include <QDateTime>

#include "json.h"

musicEdit::musicEdit( QObject * parent ) : QObject( parent )
{
    m_filePath = "";
    m_mediaPlayer = nullptr;
}

musicEdit::~musicEdit()
{

}

QString musicEdit::readFile( const QString p_str )
{

    QString result;
    QString t_str = p_str;

    t_str.replace("file:///", "");
    QFile file( t_str );
    if( !file.open(QIODevice::ReadOnly | QIODevice::Text) )
    {
        return "";
    }

    m_filePath = t_str;

//    ws_core::node * t_json = ws_core::parse( file.readAll().toStdString().c_str() );

//    if( !t_json )
//    {
//        return "";
//    }

//    result = t_json->to_string().c_str();

//    ws_core::free_json_node( &t_json );

    result = file.readAll();

    file.close();

    return result;
}

bool musicEdit::saveFile( const QString p_data )
{
    if( m_filePath.count() <= 0 )
    {
        return false;
    }

    ws_core::node * t_json = ws_core::parse( p_data.toStdString().c_str() );

    if( !t_json )
    {
        return false;
    }

    QFile file( m_filePath );
    if( !file.open(QIODevice::WriteOnly | QIODevice::Text) )
    {
        return false;
    }

    std::string t_str = t_json->to_string();

    file.write( t_str.c_str(), static_cast<qint64>( t_str.size() ) );

    file.close();

    ws_core::free_json_node( &t_json );

    return true;
}

bool musicEdit::saveFileAs( const QString p_str, const QString p_data )
{
    QString t_str = p_str;
    t_str.replace("file:///", "");

    QFile file( t_str );
    if( !file.open(QIODevice::WriteOnly | QIODevice::Text) )
    {
        return false;
    }

    m_filePath = t_str;

    file.close();
    return saveFile( p_data );
}

QString musicEdit::parsePower( const QString p_music, const QString p_data, int p_errorTime, int p_minPower, int p_maxPower, float p_mulitple )
{
    std::vector< std::pair< float, float > > t_sourceData;
    QFile t_file( p_data );
    char buf[1024] = {0};
    bool t_fileStart = false;
    float t_emptyData = 0.0f;
    float t_errorTime = static_cast<float>(p_errorTime) / 1000.0f;
    float t_minPower = static_cast<float>(p_minPower) / 100.0f;
    float t_maxPower = static_cast<float>(p_maxPower) / 100.0f;

    float t_startTimeOffset = 0.0f;

    if( !t_file.open(QIODevice::ReadOnly | QIODevice::Text) )
    {
        return "";
    }

    while(t_file.readLine( buf, sizeof(buf) ) > 0)
    {
        QStringList t_list = QString(buf).split(',');

        if( t_list.size() != 2 ) continue;

        if( t_fileStart )
        {
            float t_time = t_list[0].toFloat();
            float t_power = fabs( t_list[1].toFloat() );
            if( t_emptyData == 0.0f )
            {
                t_emptyData = t_power;
            }
            t_sourceData.push_back( std::pair<float, float>(t_time, (t_power == t_emptyData) ? 0.0f : t_power ) );
        }
        if( !t_fileStart && t_list[0] == "TIME" ) t_fileStart = true;
    }
    t_file.close();


    ws_core::node * t_json = ws_core::parse( p_music.toStdString().c_str() );
    if( !t_json )
    {
        return "";
    }

    ws_core::node * t_data = t_json->get_sub_node("data");
    if( !t_data ){
        ws_core::free_json_node( &t_json );
        return "";
    }

    float t_beatTime = 60.0f / t_json->get_int_val( "speed" );

    qDebug() << "beat time: " << t_beatTime;


    int t_currDataIndex = 0;
    float t_fristSoundTime = 0.0f;
    while( true )
    {
        ws_core::node * t_sound = t_data->get_sub_node(t_currDataIndex++);
        if( !t_sound ){
            break;
        }
        if( t_sound->get_string_val( "tone" ) != "-" ){
            break;
        }
        t_fristSoundTime += t_beatTime / t_sound->get_int_val("note") / t_sound->get_float_val("special");
    }

    t_currDataIndex = 0;

    for( size_t i = 0; i < t_sourceData.size(); ++i )
    {
        float t_power = t_sourceData[i].second;
        if( t_power < 0.6f ) continue;
        bool t_flag = true;
        for( size_t t = 0; t <= 5; ++t )
        {
            if( i - t >= 0 && t_sourceData[i - t].second > t_power ){
                t_flag = false;
                break;
            }

            if( i + t < t_sourceData.size() && t_sourceData[i + t].second > t_power ){
                t_flag = false;
                break;
            }
        }

        if( t_flag )
        {
            t_startTimeOffset = t_sourceData[i].first - t_fristSoundTime;

            qDebug() << t_sourceData[i].first << ", " << t_sourceData[i].second;
            qDebug() << t_sourceData[i - 5].second << ","
                                                      << t_sourceData[i - 4].second << ","
                                                      << t_sourceData[i - 3].second << ","
                                                      << t_sourceData[i - 2].second << ","
                                                      << t_sourceData[i - 1].second << ","
                                                      << t_sourceData[i - 0].second << ","
                                                      << t_sourceData[i + 1].second << ","
                                                      << t_sourceData[i + 2].second << ","
                                                      << t_sourceData[i + 3].second << ","
                                                      << t_sourceData[i + 4].second << ","
                                                      << t_sourceData[i + 5].second;
            break;
        }
    }


    size_t t_index = 0;
    float t_nextNoteTime = 0.0f;
    while(true)
    {
        ws_core::node * t_sound = t_data->get_sub_node(t_currDataIndex++);
        if( !t_sound ){
            break;
        }

        float t_power = 0.0f;

        for( ; t_index < t_sourceData.size(); ++t_index )
        {
             float t_time = t_sourceData[t_index].first;

             if( fabs( t_time - t_startTimeOffset - t_nextNoteTime ) < t_errorTime )
             {
                 if( t_sourceData[t_index].second > t_power ){
                     t_power = t_sourceData[t_index].second;
                 }
             }else if( t_time - t_startTimeOffset - t_nextNoteTime > t_errorTime ){
                 break;
             }

        }

        if( t_index > 0 && t_index < t_sourceData.size() ){
            t_index--;
        }

        float f_f_power = (float)( t_power / fabs( t_emptyData ) * p_mulitple * (t_maxPower - t_minPower) + t_minPower ) ;

        if( f_f_power < 0.0f ){
            f_f_power = 0.0f;
        }else if ( f_f_power > 1.0f ){
            f_f_power = 1.0f;
        }

        t_sound->set_val( "power", f_f_power);
        t_nextNoteTime += t_beatTime / t_sound->get_int_val("note") / t_sound->get_float_val("special");
    }

    std::string t_result = t_json->to_string();
    ws_core::free_json_node( &t_json );
    return t_result.c_str();
}

QString musicEdit::parsePower( const QString p_music, const QString p_data_1, const QString p_data_2, const QString p_data_3 )
{
    std::vector< std::pair< float, float > > t_sourceData[3];
    QFile t_file_1(p_data_1), t_file_2(p_data_2), t_file_3(p_data_3);
    QFile * t_files[] = { &t_file_1, &t_file_2, &t_file_3 };
    char buf[1024] = {0};

    float t_emptyData[3] = { 0.0f };
    size_t t_vectorSize[3] = { 0 };
    bool t_fileStart = false;
    for( size_t i = 0; i < sizeof( t_files ) / sizeof(QFile *); ++i ){
        t_fileStart = false;
        QFile & t_file = *t_files[i];
        if( !t_file.open(QIODevice::ReadOnly | QIODevice::Text) )
        {
            return "";
        }

        while(t_file.readLine( buf, sizeof(buf) ) > 0)
        {
            QStringList t_list = QString(buf).split(',');

            if( t_list.size() != 2 ) continue;

            if( t_fileStart )
            {
                float t_time = t_list[0].toFloat();
                float t_power = fabs( t_list[1].toFloat() );
                if( t_emptyData[i] == 0.0f )
                {
                    t_emptyData[i] = t_power;
                }
                t_sourceData[i].push_back( std::pair<float, float>(t_time, t_power == t_emptyData[i] ? 0.0f : t_power ) );
            }
            if( !t_fileStart && t_list[0] == "TIME" ) t_fileStart = true;
        }
        t_file.close();
    }

    t_vectorSize[0] = t_sourceData[0].size();
    t_vectorSize[1] = t_sourceData[1].size();
    t_vectorSize[2] = t_sourceData[2].size();

    if( t_sourceData[0][0].first != t_sourceData[1][0].first || t_sourceData[1][0].first != t_sourceData[2][0].first ||
           t_vectorSize[0] != t_vectorSize[1] || t_vectorSize[1] != t_vectorSize[2]  )
    {
        qDebug() << "文件不匹配";
        return "";
    }

    float t_startTimeOffset = 0.0f;

    for( size_t i = 0; i < 3; ++i )
    {
        for( size_t t = 1; t < t_sourceData[i].size(); ++t )
        {
            float t_power = t_sourceData[i][t].second;
            if( t_power < 0.6 ) continue;

            bool t_flag = true;
            for( size_t s = 0; s <= 5; ++s )
            {
                if( t - s > 0 ){
                    if( t_sourceData[i][t - s].second > t_power ){
                        t_flag = false;
                    }
                }

                if( t + s < t_sourceData[i].size() ) {
                    if( t_sourceData[i][t + s].second > t_power ){
                        t_flag = false;
                    }
                }
            }

            if( t_flag )
            {
                if( t_startTimeOffset == 0.0f || t_startTimeOffset > t_sourceData[i][t].first ){
                    t_startTimeOffset = t_sourceData[i][t].first;
                }
                qDebug() << t_sourceData[i][t].first << ", " << t_sourceData[i][t].second;
                qDebug() << t_sourceData[i][t - 5].second << ","
                                                          << t_sourceData[i][t - 4].second << ","
                                                          << t_sourceData[i][t - 3].second << ","
                                                          << t_sourceData[i][t - 2].second << ","
                                                          << t_sourceData[i][t - 1].second << ","
                                                          << t_sourceData[i][t - 0].second << ","
                                                          << t_sourceData[i][t + 1].second << ","
                                                          << t_sourceData[i][t + 2].second << ","
                                                          << t_sourceData[i][t + 3].second << ","
                                                          << t_sourceData[i][t + 4].second << ","
                                                          << t_sourceData[i][t + 5].second;
                break;
            }
        }
    }

    qDebug() << "t_startTimeOffset: " << t_startTimeOffset;


    ws_core::node * t_json = ws_core::parse( p_music.toStdString().c_str() );

    if( !t_json )
    {
        return "";
    }

    ws_core::node * t_data = t_json->get_sub_node("data");
    if( !t_data ){
        ws_core::free_json_node( &t_json );
        return "";
    }

    float t_beatTime = 60.0f / t_json->get_int_val( "speed" );

    qDebug() << "beat time: " << t_beatTime;


    int t_currDataIndex = 0;
    size_t t_index = 0;
    float t_nextNoteTime = 0.0f;
    while( true )
    {
        ws_core::node * t_sound = t_data->get_sub_node(t_currDataIndex++);
        if( !t_sound ){
            break;
        }

        float t_power = 0.0f;
        int t_roadIndex = 0;
        for( ; t_index < t_vectorSize[0]; ++t_index )
        {
            float t_time = t_sourceData[0][t_index].first;
//            qDebug() << "time: " << t_time;
            if( fabs( t_time - t_startTimeOffset - t_nextNoteTime ) < 0.125f )
            {

                for( int t_sss = 0; t_sss < 3; ++t_sss ){
                    if( t_sourceData[t_sss][t_index].second > t_power ) {
                        t_roadIndex = t_sss;
                        t_power = t_sourceData[t_sss][t_index].second;
                    }
                }
            }else if( t_time - t_startTimeOffset - t_nextNoteTime > 0.125f  ){
                break;
            }
        }

        if( t_index > 0 && t_index < t_vectorSize[0] ){
            t_index--;
        }

        qDebug() << t_sound->get_int_val("tone") << ": " << t_nextNoteTime << ", " << ( t_power / fabs( t_emptyData[t_roadIndex] ) );
        t_sound->set_val( "power", (float)( t_power / fabs( t_emptyData[t_roadIndex] ) ) );
        t_nextNoteTime += t_beatTime / t_sound->get_int_val("note") / t_sound->get_float_val("special");
    }

    std::string t_result = t_json->to_string();
    ws_core::free_json_node( &t_json );
    return t_result.c_str();
}

QString musicEdit::getPwd(void)
{
    static QString t_pwd = "";

    if( t_pwd == "" ){
        t_pwd = QCoreApplication::applicationDirPath();
    }

    return t_pwd;
}


void musicEdit::play( const QString p_path, const int p_volume )
{
    QMediaPlayer * t_mediaPlayer = new QMediaPlayer();
    t_mediaPlayer->setMedia( QUrl::fromLocalFile( p_path ));
    t_mediaPlayer->setVolume( p_volume );
    connect( t_mediaPlayer, SIGNAL( stateChanged( QMediaPlayer::State ) ), this, SLOT( stateChanged( QMediaPlayer::State ) ) );
    t_mediaPlayer->play();
}

void musicEdit::playBackgroundMusic( const QString p_path, const int p_time, const int p_volume )
{
    if( m_mediaPlayer )
    {
        delete m_mediaPlayer;
        m_mediaPlayer = nullptr;
    }

    m_mediaPlayer = new QMediaPlayer();
    m_mediaPlayer->setMedia( QUrl::fromLocalFile( p_path ));
    m_mediaPlayer->setVolume( p_volume );
    m_mediaPlayer->setPosition( p_time );
    m_mediaPlayer->play();
}

void musicEdit::pauseBackgroundMusic( void )
{
    if( m_mediaPlayer )
    {
        m_mediaPlayer->stop();
    }
}

void musicEdit::stateChanged( QMediaPlayer::State p_state )
{
    QMediaPlayer * t_mediaPlayer = qobject_cast< QMediaPlayer * >( sender() );

    switch( p_state )
    {
    case QMediaPlayer::PlayingState:
//        qDebug() << "Playering: " << QDateTime::currentDateTime().toTime_t();
        break;
    case QMediaPlayer::StoppedState:
        delete t_mediaPlayer;
        break;
    default:
        break;
    }
}
