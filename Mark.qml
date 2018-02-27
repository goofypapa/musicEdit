import QtQuick 2.0

Item {

    property int m_index: 0;
    property real m_scale: 1.0;
    property int m_unit: 5;
    width: m_unit * m_scale;
    height: parent.height;
    x : m_index * m_scale * m_unit;


    Rectangle{
        height: m_index % 8 === 0 ? parent.height : parent.height * 0.5 ;
        width: 1;
        color: "#000";
    }

    Text{
        text: m_index / 8 + 1;
        x: 1;
        y: 5;
        visible: m_index % 8 === 0;
    }
}
