import QtQuick 2.0

Column {
    id: root;
    property real m_scale: 1.0;
    property int m_unit: 5;

    property var m_data: {

    }

    property int m_selectIndex: -1;
    property real m_index: 0.0;
    property int m_beat: 4;

    property var m_selectArea: [];

    property real m_width: 0.0;

    height: 60;
    width: parent.width;

    onM_dataChanged: {
        f_load();
    }

    property var tones: [];

    property real m_currBeat: 0.0;
    property var compont: Qt.createComponent("Tone.qml");
    property var f_load: function(){

        if( !m_data )
        {
            return;
        }

        if( tones.length )
        {
            f_clear();
        }

        for( var i = 0; i < m_data.length; ++i )
        {
            tones[i] = createItem();
            tones[i].m_index = i;
            setInfo(i);
            tones[i].m_currBeat = m_currBeat;
            m_currBeat += 1 / m_data[i].note / m_data[i].special;
        }

        m_width = m_currBeat * m_unit * m_scale * 8;
    }

    property var f_insert: function( p_data ){

        var t_index = m_selectIndex + 1;
        if( t_index > m_data.length )
        {
            return;
        }
        if( t_index === m_data.length )
        {
            m_data.push( p_data );

            tones[t_index] = createItem();
            tones[t_index].m_index = t_index;
            tones[t_index].note = p_data.note;
            setInfo(t_index);
            tones[t_index].m_currBeat = m_currBeat;
            m_currBeat += 1 / m_data[t_index].note / m_data[t_index].special;

            m_selectIndex = t_index;
        }else{

            var t_item = createItem();
            t_item.m_index = t_index;
            t_item.m_currBeat = tones[t_index].m_currBeat
            t_item.note = p_data.note;
            var t_beat = 1 / p_data.note / p_data.special;

            for( var i = m_data.length - 1; i >= t_index; --i )
            {
                m_data[i + 1] = m_data[i];
            }
            m_data[t_index] = p_data;

            for( i = tones.length - 1; i >= t_index; --i )
            {
                tones[i].m_index = i + 1;
                tones[i].m_currBeat = tones[i].m_currBeat + t_beat;
                tones[i + 1] = tones[i];
            }
            tones[t_index] = t_item;

            setInfo(t_index);
            m_currBeat += t_beat;
            m_selectIndex++;
        }

        m_width = m_currBeat * m_unit * m_scale * 8;
    }

    property var f_changeSpecial: function( p_index, p_special ){
        if( p_index < 0 || p_index >= tones.length ){
            return;
        }

        var t_tone = tones[p_index];
        var t_BeatDiff = ( 1 / t_tone.note / p_special ) - ( 1 / t_tone.note / t_tone.special );
        t_tone.special = p_special;
        for( var i = p_index + 1; i < tones.length; ++i ){
            tones[i].m_currBeat += t_BeatDiff;
        }
        m_currBeat += t_BeatDiff;
        m_width = m_currBeat * m_unit * m_scale * 8;
    }

    property var f_changeHand: function( p_index, p_hand ){
        if( p_index < 0 || p_index >= tones.length ){
            return;
        }

        tones[p_index].hand = p_hand;
    }

    property var f_delete: function( ){

        if(m_selectArea.length == 0 ){
            m_selectArea.push(m_selectIndex);
        }

        var t_beat = 0;
        var min = m_selectArea[0];
        var max = m_selectArea[0];

        for( var i = 0; i < m_selectArea.length; ++i )
        {
            var t_index = m_selectArea[i];

            if( t_index >= tones.length || t_index < 0 )
            {
                continue;
            }

            if(min > t_index) min = t_index;
            if(max < t_index) max = t_index;

            t_beat += 1 / tones[t_index].note / tones[t_index].special;
            tones[t_index].destroy();
        }

        for(i = min; i < tones.length - max + min - 1; ++i )
        {
            tones[i] = tones[i + max - min + 1];
            tones[i].m_currBeat -= t_beat;
            tones[i].m_index = i;
            m_data[i] = m_data[i + max - min + 1 ];
        }
        tones.length = tones.length - max + min - 1;
        m_data.length = m_data.length - max + min - 1;
        m_currBeat -= t_beat;
        m_width = m_currBeat * m_unit * m_scale * 8;

        m_selectIndex = min;
        m_selectArea = [];

        if( m_selectIndex >= tones.length )
        {
            m_selectIndex = tones.length - 1;
        }
    }

    property var f_clear: function(){
        for( var i = 0; i < tones.length; ++i )
        {
            tones[i].destroy();
            tones[i] = null;
        }
        tones.length = 0;
        m_currBeat = 0.0;
        m_width = 0;
        m_selectIndex = -1;
    }

    property var f_reload: function( p_index )
    {
        tones[p_index].tone = m_data[p_index].tone;
    }

    property var f_read: function( p_index )
    {
        var columns = ["hand", "lamp", "note", "power", "special", "tone" ];
        var result = {};
        for(var i = 0; i < columns.length; ++i){
            result[columns[i]] = m_data[p_index][columns[i]];
        }
        return result;
    }

    function createItem()
    {
        if( compont.status !== Component.Ready )
        {
            console.log( "compont is not ready" );
            return false;
        }
        return compont.createObject(box);
    }

    onM_scaleChanged: {
        for( var i = 0; m_data && i < m_data.length; ++i )
        {
            tones[i].m_scale = m_scale;
        }
        if( tones.length > 0 ){
            m_width = tones[tones.length - 1].m_currBeat * m_unit * m_scale * 8;
        }
    }

    onM_beatChanged: {
        for( var i = 0; m_data && i < m_data.length; ++i )
        {
            tones[i].m_beat = m_beat;
        }
    }

    function setInfo( p_index )
    {
        if( tones.length <= p_index ) return;
        tones[p_index].note = m_data[p_index].note;
        tones[p_index].tone = m_data[p_index].tone;
        tones[p_index].special = m_data[p_index].special;
        tones[p_index].hand = m_data[p_index].hand;
        tones[p_index].m_scale = m_scale;
        tones[p_index].m_unit = m_unit;
        tones[p_index].m_beat = m_beat;
    }

    Item{
        height: parent.height - box.height + 5;
        width: parent.width;
    }

    Item{
        height: parent.height - 10;
        width: parent.width;
        Item{
            id: box;
            width: 0;
            height: parent.height;
        }
    }
}
