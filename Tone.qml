import QtQuick 2.0

Rectangle {

    height: parent.height;

    property int m_index: -1;
    property real note: 1;
    property real special: 1;
    property string tone: "";
    property string hand: "";
    property real m_scale: 1.0;
    property int m_unit: 5;
    property int m_beat: 4;
    property real m_currBeat: 0;

    property string t_color : ["#EEE", "#DDD"][ Math.floor( m_currBeat / m_beat) % 2 ];
    color: m_selectIndex == m_index ? "#21be2b" : ( m_selectArea.indexOf(m_index) >= 0 ? "#41de4b" : t_color);

    width: m_unit * m_scale * 8 / note / special;
    x: m_currBeat * m_unit * m_scale * 8;

    Text {
        text: parent.width < 10 ? "." : ( tone[0] === "b" || tone[0] === "#" ? tone[1] : tone[0] ) + ( Math.abs( special - 2.0 / 3.0 ) < 0.001 ? "." : "" );
        anchors.verticalCenter: parent.verticalCenter;
    }


    Rectangle{
        width: parent.width;
        height: 1;
        color: "#000";
        y: 10;
        visible: Math.abs( special - 6.0 ) < 0.001;
    }

    Rectangle{
        width: parent.width;
        height: 1;
        color: "#000";
        y: 15;
        visible: Math.abs( special - 3.0 ) < 0.001 || Math.abs( special - 6.0 ) < 0.001;
    }

    Rectangle{
        width: parent.width;
        height: 1;
        color: "#000";
        y: 32;
        visible: note >= 2;
    }

    Rectangle{
        width: parent.width;
        height: 1;
        color: "#000";
        y: 37;
        visible: note >= 4;
    }

    Rectangle{
        width: parent.width;
        height: 1;
        color: "#000";
        y: 42;
        visible: note >= 8;
    }

    MouseArea{
        anchors.fill: parent;
        onClicked: {

            m_selectArea = [];

            if( m_shiftDown && m_selectIndex != m_index )
            {
                var min = m_selectIndex, max = m_index;
                if( m_index < m_selectIndex){
                    min = m_index;
                    max = m_selectIndex;
                }

                for( var i = 0; i <= max - min; ++i ){
                    m_selectArea.push( min + i );
                }
            }

            m_selectIndex = m_index;
        }
    }
}
