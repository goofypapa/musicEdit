import QtQuick 2.0


Item{
    id: root;
    property real m_scale: 1.0;
    property int m_unit: 5;
    property int m_playCursorX: 0;
    property real m_width: 0.0;

    property real m_currWidth: 0.0;
    property real m_playing: m_width <= 0 ? 1.0 : m_playCursorX / m_width;

    height: 5;
    width: parent.width;

    property var m_items: [];

    property var compont: Qt.createComponent("Mark.qml");
    onM_widthChanged: {
        load();
    }

    Component.onCompleted: {
        load();
    }

    function load(){
        var t_itemWidth =  m_scale * m_unit;
        if( (m_width < width ? width :m_width) > m_currWidth  )
        {
            for( var i = m_currWidth; i < (m_width < width ? width :m_width) ; i += t_itemWidth )
            {
                var t_mark = createMark();
                if( !t_mark ) break;
                m_items.push( t_mark );
                setMarkInfo( m_items.length - 1 );
            }
        }else{
            var t_itemLength = Math.ceil( (m_width < width ? width :m_width)  / t_itemWidth );

            if( t_itemLength < 0 || t_itemLength >= m_items.length )
            {
                return;
            }

            for( i = t_itemLength; i < m_items.length; ++i )
            {
                m_items[i].destroy();
            }
            m_items.length = t_itemLength;

        }
        m_currWidth = m_width;
    }

    onM_scaleChanged: {
        for( var i = 0; i < m_items.length; ++i )
        {
            m_items[i].m_scale = m_scale;
        }
    }

    function setMarkInfo( p_index )
    {
        m_items[p_index].m_index = p_index;
        m_items[p_index].m_scale = m_scale;
        m_items[p_index].m_unit = m_unit;
    }

    function createMark()
    {
        if( compont.status !== Component.Ready  )
        {
            console.log(" mark compont status is not ready ");
            return false;
        }
        return compont.createObject(root);
    }

    MouseArea{
        height: parent.height;
        width: m_width;
        onMouseXChanged: {
            if( mouseX > width )
            {
                m_playCursorX = width;
            }else if( mouseX < 0.0 )
            {
                m_playCursorX = 0.0;
            }else
            {
                m_playCursorX = mouseX;
            }
        }
    }
}


