import QtQuick 2.0
import QtMultimedia 5.8

Item {
    id: root;
    property string m_source: "";
    property real m_volume: 1.0;
    property real m_power: 1.0;
    property bool m_playing: false;
    property int m_powerLavel: 1;

    property int m_audioCount: 8;

    onM_playingChanged: {
        if( m_playing ){

//            var t_offset = m_powerLavel / m_audioCount - m_power;

//            var volume = m_power - 10 / m_audioCount * 20 * t_offset;

//            audio.volume = volume < 0 ? 0 : volume * m_power;

            audio.play();
        }else{
            audio.pause();
        }
    }

    Audio{
        id: audio;
        source: m_source + m_powerLavel + ".wav";
        volume: m_volume;
        onStatusChanged: {
            if( status === 7 )
            {
                root.destroy( );
            }
        }
    }
}
