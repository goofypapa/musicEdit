import QtQuick 2.0


Item{

    property alias m_scale: editCore.m_scale;
    property alias m_unit: ruler.m_unit;
    property alias m_beat: editCore.m_beat;
    property alias m_selectIndex: editCore.m_selectIndex;
    property alias m_playCursorX: ruler.m_playCursorX;
    property alias m_data: editCore.m_data;
    property alias m_selectArea: editCore.m_selectArea;

    property alias f_load: editCore.f_load;
    property alias f_clear: editCore.f_clear;
    property alias f_insert: editCore.f_insert;
    property alias f_changeSpecial: editCore.f_changeSpecial;
    property alias f_changeHand: editCore.f_changeHand;
    property alias f_delete: editCore.f_delete;
    property alias f_reload: editCore.f_reload;
    property alias f_read: editCore.f_read;

    property real m_width: editCore.m_width > parent.width ? editCore.m_width : parent.width;
    property real m_maxWidth: editCore.m_width;

    height: 80;
    width: parent.width;

    Column {
        anchors.fill: parent;

        Ruler{
            id: ruler;
            m_scale: editCore.m_scale;
            m_width: editCore.m_width;
            width: parent.width;
        }

        EditCore{
            id: editCore;
            m_unit: ruler.m_unit;
        }
    }

    Rectangle{
        height: parent.height;
        width: 1;
        x: m_playCursorX;
        color: "#F00"
    }
}
