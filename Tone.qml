import QtQuick 2.0

Rectangle {

    height: parent.height;

    property int m_index: -1;
    property int note: 1;
    property real special: 1;
    property string tone: "";
    property real m_scale: 1.0;
    property int m_unit: 5;
    property int m_beat: 4;
    property real m_currBeat: 0;

    property string t_color : ["#EEE", "#DDD"][ Math.floor( m_currBeat / m_beat) % 2 ];
    color: m_selectIndex == m_index ? "#21be2b" : t_color;

    width: m_unit * m_scale * 8 / note / special;
    x: m_currBeat * m_unit * m_scale * 8;

    Text {
        text: parent.width < 10 ? "." : tone + ( Math.abs( special - 2.0 / 3.0 ) < 0.001 ? "." : "" );
        anchors.verticalCenter: parent.verticalCenter;
        anchors.horizontalCenter: parent.horizontalCenter;
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
            m_selectIndex = m_index;
        }
    }
}
