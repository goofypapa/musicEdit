import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.0

ApplicationWindow {
    id: widnow;
    visible: true
    width: 900
    height: 600
    minimumHeight: height;
    maximumHeight: height;
    minimumWidth: width;
    maximumWidth: width;

    title: {
        return m_currEditFile === "" ? qsTr("笨爸爸-乐谱编辑器") : ( m_currEditFile + ( isSave ? "" : "*" ) );
    }

    property bool m_shiftDown: false;
    property bool m_ctrlDown: false;

    property var m_copyArea: [];


    property var m_instrumentList: [ "非洲鼓", "钢琴" ];


    property alias m_scale: soundEdit.m_scale;
    property alias m_unit: soundEdit.m_unit;
    property alias m_beat: soundEdit.m_beat;
    property alias m_playCursorX: soundEdit.m_playCursorX;
    property alias m_selectIndex: soundEdit.m_selectIndex;
    property alias m_playing: playPause.m_playing;
    property alias m_volume: sysVolume.value;


    property int m_playIndex: 0;
    property real m_nextTime: 0.0;
    property int m_playingTime: 0;
    property bool isSave: true;
    property string m_currEditFile: "";
    property string m_backgroundMusic: "";


    property int m_pitch: 0;
    property var m_pianoToneList: ["C", "D", "E", "F", "G", "A", "B"];

    onM_backgroundMusicChanged: {
        console.log( m_backgroundMusic, m_playingTime, m_volume )
        if( m_playing && m_backgroundMusic.length > 0 )
        {
            musicedit.playBackgroundMusic( m_backgroundMusic, m_playingTime, Math.floor( m_volume * 100 ) );
        }
    }

    property var m_json: {

    }

    property var m_soundSource: {

    }

    property var playAudioModelCompont: Qt.createComponent("PlayAudioModel.qml");

    Component.onCompleted: {
        m_json = { name: "", speed: 60, data: [], instrument: m_instrumentList[0] }

        m_soundSource = {};

        m_soundSource["B"] = musicedit.getPwd() + "/soundSource/Djembe/Bass.wav";
        m_soundSource["T"] = musicedit.getPwd() + "/soundSource/Djembe/Tone.wav";
        m_soundSource["S"] = musicedit.getPwd() + "/soundSource/Djembe/Slap.wav";


        m_soundSource["C"] = musicedit.getPwd() + "/soundSource/Piano/C.wav";
        m_soundSource["C+1"] = musicedit.getPwd() + "/soundSource/Piano/C+1.wav";
        m_soundSource["C+2"] = musicedit.getPwd() + "/soundSource/Piano/C+2.wav";
        m_soundSource["#C"] = musicedit.getPwd() + "/soundSource/Piano/#C.wav";

    }

    function getToneIndex()
    {
        var t_tone = pianoTone.text;
        if( t_tone === "-" )
        {
            return m_pitch * m_pianoToneList.length;
        }

        var t_toneSplit = t_tone.split( "+" );
        var t_pitch = 0;
        if( t_toneSplit.length <= 1 )
        {
            t_toneSplit = t_tone.split( "-" );
            if( t_toneSplit.length === 2 ){
                t_pitch = -( Number( t_toneSplit[1] ) );
            }
        }else{
            t_pitch = ( Number( t_toneSplit[1] ) );
        }

        t_tone = t_toneSplit[0];

        return t_pitch * m_pianoToneList.length + m_pianoToneList.indexOf( t_tone[t_tone.length - 1] );
    }

    function insert( p_type )
    {
        var t_selectIndex = m_selectIndex;

        var t_note = null;

        if( m_json.instrument === "钢琴" )
        {
            t_note = {note: p_type, tone: "C" + ( m_pitch !== 0 ? "+" + m_pitch : "" ) , power: 1.0, special: 1.0, hand: "left" };
        }else{
            t_note = {note: p_type, tone: "-", power: 1.0, special: 1.0, hand: "left" };
        }

        soundEdit.f_insert( t_note );
        if( m_selectIndex === m_json.data.length - 1 && soundEdit.m_width > frame.width ){
            hbar.position = ( soundEdit.m_width - frame.width ) / soundEdit.m_width;
        }
        isSave = false;
        keyboard.focus = true;
        soundEdit.m_selectArea = [];
    }

    function insert_area( p_list )
    {
        for( var i = 0; i < p_list.length; ++i ){
            soundEdit.f_insert( p_list[i] );
        }

        isSave = false;
        keyboard.focus = true;
    }

    function f_delete()
    {
        soundEdit.f_delete();
        isSave = false;
        keyboard.focus = true;
        soundEdit.m_selectArea = [];
    }

    function clear()
    {
        m_json.data = [];
        soundEdit.m_selectArea = [];
        soundEdit.m_data = m_json.data;
        hbar.position = 0.0;
        isSave = false;
        keyboard.focus = true;
    }

    onM_selectIndexChanged: {
        showSelectinfo();
        keyboard.focus = true;
    }

    function showSelectinfo(){
        if( m_selectIndex < 0 ) return;

        var t_prveXiaoJie = 0.0;
        var t_xiaojie = 0.0, t_noteIndex = 0;
        for( var i = 0; i <= m_selectIndex; ++i ){

            if( t_xiaojie - t_prveXiaoJie >= 1.0 ){
                t_prveXiaoJie = Math.floor(t_xiaojie);
                t_noteIndex = 0;
            }

            t_xiaojie += 1 / m_json.data[ i ].note / m_beat;
            t_noteIndex++;
        }

        xiaojie.t_xiaojie = Math.ceil( t_xiaojie );
        note_index.t_index = t_noteIndex;

        var t_item = m_json.data[m_selectIndex]

        switch( t_item.note )
        {
        case 0.5:
            note.text = "二分音符";
            break;
        case 1:
            note.text = "四分音符";
            break;
        case 2:
            note.text = "八分音符";
            break;
        case 4:
            note.text = "十六分音符";
            break;
        case 8:
            note.text = "三十二分音符";
            break;
        }

        if( m_json.instrument === "非洲鼓" )
        {
            if( t_item.tone === "B" )
            {
                djembe_b.checked = true;
            }else if( t_item.tone === "T" ){
                djembe_t.checked = true;
            }else if( t_item.tone === "S" ){
                djembe_s.checked = true;
            }else{
                djembe_e.checked = true;
            }
        }

        if( m_json.instrument === "钢琴" )
        {
            pianoTone.text = typeof( t_item.tone ) === "string" ? t_item.tone : JSON.stringify(t_item.tone);
        }


        if( t_item.power >= 0 && t_item.power <= 1.0 ){
            power.value = t_item.power;
        }

        if( Math.abs( t_item.special - 1.0 ) < 0.001 ){
            zhengchang.checked = true;
        }else if( Math.abs( t_item.special - 3.0 ) < 0.001 ){
            sanlian.checked = true;
        }else if( Math.abs( t_item.special - 6.0 ) < 0.001 ){
            liulian.checked = true;
        }else if( Math.abs( t_item.special - 2.0 / 3.0 ) < 0.001 ){
            fudian.checked = true;
        }

        if( t_item.hand === "left" ){
            zuoshou.checked = true;
        }else if( t_item.hand === "right" ){
            youshou.checked = true;
        }
    }

    function changeTone( t_tone ){

        keyboard.focus = true;

        if( m_selectIndex < 0 || m_selectIndex >= m_json.data.length ){
            return;
        }

        if(  m_json.data[m_selectIndex].tone !== t_tone ){
            m_json.data[m_selectIndex].tone = t_tone;

            soundEdit.f_reload( m_selectIndex );
            isSave = false;
        }

        if( m_json.instrument === "钢琴" )
        {
            pianoTone.text = t_tone;
        }
    }

    function changePower( p_power ){
        keyboard.focus = true;
        if( m_selectIndex < 0 || m_selectIndex >= m_json.data.length ){
            return;
        }

        m_json.data[m_selectIndex].power = p_power;
        isSave = false;
    }

    function changeSpecial( p_special ){
        keyboard.focus = true;
        if( m_selectIndex < 0 || m_selectIndex >= m_json.data.length ){
            return;
        }
        m_json.data[m_selectIndex].special = p_special;

        soundEdit.f_changeSpecial( m_selectIndex, p_special );
        isSave = false;
    }

    function changeHand( p_hand ){
        keyboard.focus = true;
        if( m_selectIndex < 0 || m_selectIndex >= m_json.data.length ){
            return;
        }
        m_json.data[m_selectIndex].hand = p_hand;

        soundEdit.f_changeHand( m_selectIndex, p_hand );
        isSave = false;
    }

    function openFile( p_filePath ){

        var t_fileStr = musicedit.readFile( p_filePath );


        var t_obj = JSON.parse( t_fileStr )

        _loadJson( t_obj );

        m_currEditFile = p_filePath;
        isSave = true;
    }

    function saveFile( ){
        m_json.name = qumu.text;
        m_json.speed = parseInt( speed.text );

        if( m_currEditFile === "" ){
            saveFileDialog.open();
            return;
        }

        if( musicedit.saveFile( JSON.stringify(m_json) ) )
        {
            isSave = true;
        }
    }

    function saveFileAs( p_filePath ){
        m_json.name = qumu.text;
        m_json.speed = parseInt( speed.text );

        if( musicedit.saveFileAs( p_filePath, JSON.stringify(m_json)  ) )
        {
            m_currEditFile = p_filePath;
            isSave = true;
        }
    }

    function newFile(){
        m_json.name = "新建文件";
        m_json.speed = 60;
        m_json.data = [];
        soundEdit.m_data = m_json.data;

        qumu.text = m_json.name;
        m_currEditFile = "";
        isSave = false;
    }

    function play( p_playFile, p_power ){

        if( typeof(p_playFile) === "undefined" || !p_playFile || p_power <= 0.0 ){
            return;
        }

//        if( playAudioModelCompont.status !== Component.Ready ){
//            console.log( "playAudioModelCompont is not ready" );
//            return;
//        }
//        var t_model = playAudioModelCompont.createObject(widnow);

//        t_model.m_source = p_playFile;
//        t_model.m_powerLavel = Math.ceil( p_power / ( 1.0 / t_model.m_audioCount ) );
//        t_model.m_volume = m_volume;
//        t_model.m_power = p_power;
//        t_model.m_playing = true;

        musicedit.play( p_playFile,  Math.floor( m_volume * 100 ) );
    }

    function _loadJson( p_json ){
        var t_obj = p_json;

        if( !t_obj ){ return; }

        if( typeof( t_obj.name ) !== "undefined" && typeof( t_obj.speed ) !== "undefined" && typeof(  t_obj.data ) !== "undefined" )
        {
            for( var i = 0; i < t_obj.data.length; ++i ){
                if( typeof( t_obj.data[i].note ) === "undefined" ){
                    t_obj.data[i].note = 1;
                }
                if( typeof( t_obj.data[i].tone ) === "undefined" ){
                    t_obj.data[i].tone = "-";
                }
                if( typeof( t_obj.data[i].power ) === "undefined" ){
                    t_obj.data[i].power = 1;
                }
                if( typeof( t_obj.data[i].special ) === "undefined" ){
                    t_obj.data[i].special = 1;
                }
                if( typeof( t_obj.data[i].lamp ) === "undefined" ){
                    t_obj.data[i].lamp = "";
                }
            }

            if( typeof( t_obj.beat ) === "undefined" ){
                t_obj.beat = "4/4";
            }

            if( typeof(t_obj.instrument) === "undefined" ){
                t_obj.instrument = "非洲鼓";
            }

            switch(t_obj.instrument){
            case "PIANO":
                t_obj.instrument = "钢琴";
                break;
            default:
                t_obj.instrument = "非洲鼓";
                break;
            }

            switch( t_obj.beat )
            {
            case "4/4":
                m_beat = 4;
                break;
            case "4/3":
                m_beat = 3;
                break;
            case "4/2":
                m_beat = 2;
                break;
            default:
                t_obj.beat = "4/4";
                m_beat = 4;
                break;
            }

            instrumentSelect.currentIndex = m_instrumentList.indexOf( t_obj.instrument );

            control.currentIndex = control.model.indexOf( t_obj.beat );

            m_json = t_obj;

            soundEdit.m_data = m_json.data;
            qumu.text = m_json.name;
        }
    }

    function clone( p_obj ){
        var result = {};

        for( var item in p_obj ){
            if( typeof( p_obj[item] ) === "object" ){

            }else{
                result[item] = p_obj[item];
            }
        }

        return result;
    }

    Timer{
        running: m_playing;
        interval: 10;
        repeat: true;
        property real m_runningTime: 0.0;
        property real m_noteTime: 0.0;
        property real m_startTime: 0;
        onRunningChanged: {
            if( !running )
            {
                musicedit.pauseBackgroundMusic();
                return;
            }

            m_startTime = (new Date()).getTime();

            if( m_playCursorX >= soundEdit.m_width ){
                m_playCursorX = 0.0;
                hbar.position = 0.0;
            }

            m_runningTime = 0.0;

            var t_width = 0.0;
            m_nextTime = 0.0;
            m_noteTime = 60000 / m_json.speed;
            m_startTime -= m_playCursorX / m_unit / m_scale / 8 * m_noteTime;

            if( m_backgroundMusic != "" )
            {
                musicedit.playBackgroundMusic( m_backgroundMusic, (new Date()).getTime() - m_startTime, Math.floor( m_volume * 100 ) );
            }

            for( m_playIndex = -1; m_playIndex < m_json.data.length && t_width < m_playCursorX; ++m_playIndex ){

                var ttt_width = t_width + m_unit * m_scale / m_json.data[m_playIndex + 1].note * 8 / m_json.data[m_playIndex + 1].special;
                if( ttt_width >= m_playCursorX){
                    break;
                }
                m_nextTime += m_noteTime / m_json.data[m_playIndex + 1].note / m_json.data[m_playIndex + 1].special;
                t_width = ttt_width;
            }

        }

        onTriggered: {
            m_playingTime = (new Date()).getTime() - m_startTime;

            if( m_playingTime >= m_nextTime ){
                if( ++m_playIndex >= m_json.data.length ){
                    m_playing = false;
                    m_playCursorX = soundEdit.m_width;
                    return;
                }

                var dir = ""
                if( m_json.instrument === "钢琴" ){
                    dir = "Piano";
                }else{
                    dir = "Djembe";
                }

                if( typeof( m_json.data[m_playIndex].tone) !== "string" && m_json.data[m_playIndex].tone.length ){
                    for( var i = 0; i < m_json.data[m_playIndex].tone.length; ++i ){
                        play( musicedit.getPwd() + "/soundSource/" + dir + "/" + m_json.data[m_playIndex].tone[i] +  ".wav", m_json.data[m_playIndex].power);
                    }
                }else{
                    play( musicedit.getPwd() + "/soundSource/" + dir + "/" + m_json.data[m_playIndex].tone +  ".wav", m_json.data[m_playIndex].power);
                }

                m_nextTime += m_noteTime / m_json.data[m_playIndex].note / m_json.data[m_playIndex].special;
            }

            m_playCursorX = m_playingTime / m_noteTime * m_unit * m_scale * 8;

            var t_half = frame.width * 0.5;
            if( soundEdit.m_width - m_playCursorX > t_half && m_playCursorX > t_half ){
                hbar.position = ( m_playCursorX - t_half ) / soundEdit.m_width;
            }

        }
    }

    FileDialog{
        id: openFileDialog;
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation);
        nameFilters: ["JSON files (*.json)"];
        onAccepted: {
            openFile( file );
        }
    }

    FileDialog{
        id: saveFileDialog;
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation);
        nameFilters: ["JSON files (*.json)"];
        fileMode: FileDialog.SaveFile;
        onAccepted: {
            saveFileAs(file);
        }
    }

    FileDialog{
        id: selectAccompaniment;
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation);
        nameFilters: ["Audio files (*.wav)"];
        onAccepted:{
            m_backgroundMusic = file.toString().replace("file://", "");
        }
    }

    header: ToolBar{
        height: 40;
        RowLayout{
            height: parent.height;
            Button{
                height: parent.height;
                text: qsTr("打开");
                font.bold: true;
                font.pixelSize: 12;
                onClicked: {
                    openFileDialog.open();
                }
            }
            Button{
                height: parent.height;
                text: qsTr("保存");
                font.bold: true;
                font.pixelSize: 12;
                onClicked: saveFile();
            }
            Button{
                height: parent.height;
                text: qsTr("新建");
                font.bold: true;
                font.pixelSize: 12;
                onClicked: newFile();
            }
            Button{
                height: parent.height;
                text: qsTr("力度匹配");
                font.bold: true;
                font.pixelSize: 12;
                onClicked: {
                    powerParse.m_show = !powerParse.m_show;
                }
            }
        }
    }

    Column{
        anchors.fill: parent;

        Item{
            height: 100;
            width: parent.width;

            Column{
                anchors.fill: parent;
                Item{
                    height: 10;
                    width: parent.width;
                }

                Row{
                    height: 40;
                    width: parent.width;

                    Item{
                        height: parent.height;
                        width: 20;
                    }

                    Item{
                        height: parent.height;
                        width: 60;
                        Text {
                            text: qsTr("曲目：");
                            anchors.horizontalCenter: parent.horizontalCenter;
                            anchors.bottom: parent.bottom;
                            anchors.bottomMargin: 5;
                            font.pixelSize: 20;
                        }
                    }

                    Item{
                        height: parent.height;
                        width: 20;
                    }

                    Item{
                        height: parent.height;
                        width: 260;

                        Rectangle{
                            width: parent.width;
                            height: parent.height - 10;
                            anchors.centerIn: parent;
                            color: "#AAA";
                            radius: 2;
                            Rectangle{
                                width: parent.width - 2;
                                height: parent.height - 2;
                                anchors.centerIn: parent;
                                radius: 1;

                                TextInput{
                                    id: qumu;
                                    anchors.fill: parent;
                                    font.pixelSize: 14;
                                    leftPadding: 5;
                                    topPadding: 6;
                                    text: m_json.name;
                                    clip: true;
                                }
                            }
                        }
                    }

                    Item{
                        height: parent.height;
                        width: 20;
                    }

                    Item{
                        height: parent.height;
                        width: 60;
                        Text {
                            text: qsTr("节拍：");
                            anchors.horizontalCenter: parent.horizontalCenter;
                            anchors.bottom: parent.bottom;
                            anchors.bottomMargin: 5;
                            font.pixelSize: 20;
                        }
                    }

                    Item{
                        height: parent.height;
                        width: 20;
                    }

                    Item{
                        height: parent.height;
                        width: 60;

                        MyComboBox{
                            id: control;
                            model: ["4/4", "4/3", "4/2"]

                            height: parent.height - 10;
                            width: parent.width;
                            anchors.centerIn: parent;
                            currentIndex: 0;
                            onCurrentIndexChanged: {
                                f_valueChange();
                            }
                            function f_valueChange()
                            {
                                switch( currentIndex )
                                {
                                case 0:
                                    m_beat = 4;
                                    break;
                                case 1:
                                    m_beat = 3;
                                    break;
                                case 2:
                                    m_beat = 2;
                                    break;
                                }

                                m_json.beat = model[currentIndex];
                            }

                            Component.onCompleted: {
                                f_valueChange();
                            }
                        }
                    }

                    Item{
                        height: parent.height;
                        width: 20;
                    }

                    Item{
                        height: parent.height;
                        width: 60;
                        Text {
                            text: qsTr("伴奏：");
                            anchors.horizontalCenter: parent.horizontalCenter;
                            anchors.bottom: parent.bottom;
                            anchors.bottomMargin: 5;
                            font.pixelSize: 20;
                        }
                    }

                    Item{
                        height: parent.height;
                        width: 20;
                    }

                    Item{
                        height: parent.height;
                        width: 160;
                        clip: true;
                        Text {
                            text: qsTr( m_backgroundMusic != "" ? m_backgroundMusic : "--" );
                            anchors.verticalCenter: parent.verticalCenter;
                            x: width > parent.width ?  parent.width - width : 0;
                        }
                    }

                    Item{
                        height: parent.height;
                        width: 20;
                    }

                    Item{
                        height: parent.height;
                        width: 50;
                        Button{
                            height: 30;
                            width: 50;
                            anchors.centerIn: parent;
                            text: qsTr("更改");
                            onClicked: {
                                selectAccompaniment.open();
                            }
                        }
                    }

                }

                Row{
                    height: 40;
                    width: parent.width;

                    Item{
                        height: parent.height;
                        width: 20;
                    }

                    Item{
                        height: parent.height;
                        width: 60;
                        Text {
                            text: qsTr("速度：");
                            anchors.horizontalCenter: parent.horizontalCenter;
                            anchors.bottom: parent.bottom;
                            anchors.bottomMargin: 5;
                            font.pixelSize: 20;
                        }
                    }

                    Item{
                        height: parent.height;
                        width: 20;
                    }

                    Item{
                        height: parent.height;
                        width: 60;

                        Rectangle{
                            width: parent.width;
                            height: parent.height - 10;
                            anchors.centerIn: parent;
                            color: "#AAA";
                            radius: 2;
                            Rectangle{
                                width: parent.width - 2;
                                height: parent.height - 2;
                                anchors.centerIn: parent;
                                radius: 1;

                                TextInput{
                                    id: speed;
                                    anchors.fill: parent;
                                    font.pixelSize: 14;
                                    leftPadding: 5;
                                    topPadding: 6;
                                    autoScroll: true;
                                    text: m_json.speed;
                                    clip: true;
                                    onTextChanged: {
                                        m_json.speed = parseInt( text );
                                    }
                                }
                            }
                        }
                    }

                    Item{
                        height: parent.height;
                        width: 200;
                        Text {
                            text: qsTr("(拍/分钟)");
                            x: 10;
                            anchors.verticalCenter: parent.verticalCenter;
                            font.pixelSize: 16;
                        }
                    }

                    Item{
                        height: parent.height;
                        width: 20;
                    }

                    Item{
                        height: parent.height;
                        width: 60;
                        Text {
                            text: qsTr("缩放：");
                            anchors.horizontalCenter: parent.horizontalCenter;
                            anchors.bottom: parent.bottom;
                            anchors.bottomMargin: 5;
                            font.pixelSize: 20;
                        }
                    }

                    Item{
                        height: parent.height;
                        width: 20;
                    }

                    Item{
                        height: parent.height;
                        width: 200;

                        Slider {
                            id: slider_control
                            value: 0.0;

                            onValueChanged:{
                                m_scale = value * 4.0 + 1.0;
                            }

                            background: Rectangle {
                                x: slider_control.leftPadding
                                y: slider_control.topPadding + slider_control.availableHeight / 2 - height / 2
                                implicitWidth: 200
                                implicitHeight: 4
                                width: slider_control.availableWidth
                                height: implicitHeight
                                radius: 2
                                color: "#bdbebf"

                                Rectangle {
                                    width: slider_control.visualPosition * parent.width
                                    height: parent.height
                                    color: "#21be2b"
                                    radius: 2
                                }
                            }

                            handle: Rectangle {
                                x: slider_control.leftPadding + slider_control.visualPosition * (slider_control.availableWidth - width)
                                y: slider_control.topPadding + slider_control.availableHeight / 2 - height / 2
                                implicitWidth: 26
                                implicitHeight: 26
                                radius: 13
                                color: slider_control.pressed ? "#f0f0f0" : "#f6f6f6"
                                border.color: "#bdbebf"
                            }
                        }
                    }
                }
            }
        }

        Rectangle{
            height:5;
            width: parent.width;
            color: "#CCC";
        }

        Item{
            id: frame;
            width: parent.width;
            height: soundEdit.height + 5 + hbar.height;

            SoundEdit{
                id: soundEdit;
                x: -hbar.position * m_width
                m_data: m_json.data;
            }
            Rectangle{
                height:5;
                width: parent.width;
                color: "#CCC";
                y: 80;
            }

            ScrollBar{
                id: hbar;
                hoverEnabled: true;
                active: hovered || pressed
                orientation: Qt.Horizontal
                size: frame.width / soundEdit.m_width
                anchors.bottom: soundEdit.bottom
                width: parent.width;
            }
        }


        Row{
            width: parent.width;
            height: 300;
            Column{
                width: parent.width / 2;
                Item{
                    height: 50;
                    width: parent.width;
                    Text {
                        text: qsTr("插入");
                        font.pixelSize: 20;
                        anchors.centerIn: parent;
                    }
                }

                Row{
                    height: 50;
                    width: parent.width;

                    visible: instrumentSelect.currentText === "钢琴";

                    Item{
                        height: parent.height;
                        width: 80;
                        Text {
                            text: qsTr("八度:");
                            font.pixelSize: 12;
                            anchors.centerIn: parent;
                        }
                    }

                    MyComboBox{
                        model: [ "C0", "C1", "C2" ];
                        width: 100;
                        height: 30;
                        font.pixelSize: 12;
                        anchors.verticalCenter: parent.verticalCenter;

                        currentIndex: 0;
                        onCurrentIndexChanged: {
                            m_pitch = currentIndex;
                            keyboard.focus = true;
                        }
                    }

                }

                Item{
                    height: 50;
                    width: parent.width;

                    Row{
                        anchors.fill: parent;
                        Item{
                            height: parent.height;
                            width: 20;
                        }

                        Item{
                            height: parent.height;
                            width: 100;

                            Button{
                                text: qsTr("二分音");
                                font.pixelSize: 12;
                                width: 80;
                                height: 30;
                                anchors.centerIn: parent;
                                onClicked: insert(0.5);
                            }
                        }

                        Item{
                            height: parent.height;
                            width: 20;
                        }

                        Item{
                            height: parent.height;
                            width: 100;

                            Button{
                                text: qsTr("四分音");
                                font.pixelSize: 12;
                                width: 80;
                                height: 30;
                                anchors.centerIn: parent;
                                onClicked: insert(1);
                            }
                        }

                        Item{
                            height: parent.height;
                            width: 20;
                        }

                        Item{
                            height: parent.height;
                            width: 100;

                            Button{
                                text: qsTr("八分音");
                                font.pixelSize: 12;
                                width: 80;
                                height: 30;
                                anchors.centerIn: parent;
                                onClicked: insert(2);
                            }
                        }
                    }
                }

                Item{
                    height: 50;
                    width: parent.width;

                    Row{
                        anchors.fill: parent;

                        Item{
                            height: parent.height;
                            width: 20;
                        }

                        Item{
                            height: parent.height;
                            width: 100;

                            Button{
                                text: qsTr("十六分音");
                                font.pixelSize: 12;
                                width: 80;
                                height: 30;
                                anchors.centerIn: parent;
                                onClicked: insert(4);
                            }
                        }

                        Item{
                            height: parent.height;
                            width: 20;
                        }

                        Item{
                            height: parent.height;
                            width: 100;

                            Button{
                                text: qsTr("三十二分音");
                                font.pixelSize: 12;
                                width: 80;
                                height: 30;
                                anchors.centerIn: parent;
                                onClicked: insert(8);
                            }
                        }
                    }
                }

                Item{
                    height: 50;
                    width: parent.width;

                    Row{
                        anchors.fill: parent;
                        Item{
                            height: parent.height;
                            width: 20;
                        }

                        Item{
                            height: parent.height;
                            width: 100;

                            Button{
                                text: qsTr("删除");
                                font.pixelSize: 12;
                                width: 80;
                                height: 30;
                                anchors.centerIn: parent;
                                onClicked: f_delete();
                            }
                        }

                        Item{
                            height: parent.height;
                            width: 20;
                        }

                        Item{
                            height: parent.height;
                            width: 100;

                            Button{
                                text: qsTr("清空");
                                font.pixelSize: 12;
                                width: 80;
                                height: 30;
                                anchors.centerIn: parent;
                                onClicked: clear();
                            }
                        }
                    }
                }

            }

            Column{
                width: parent.width / 2;
                Item{
                    height: 50;
                    width: parent.width;
                    Text {
                        text: qsTr("编辑");
                        font.pixelSize: 20;
                        anchors.centerIn: parent;
                        font.bold: true;
                    }
                }

                Item{
                    height: 50;
                    width: parent.width;

                    Row{
                        anchors.fill: parent;
                        Item{
                            height: parent.height;
                            width: 20;
                        }

                        Item{
                            height: parent.height;
                            width: 50;

                            Text {
                                text: qsTr("乐器:");
                                font.pixelSize: 14;
                                anchors.verticalCenter: parent.verticalCenter;
                            }
                        }

                        MyComboBox{
                            id: instrumentSelect;
                            model: m_instrumentList;
                            width: 100;
                            height: 30;
                            font.pixelSize: 12;
                            anchors.verticalCenter: parent.verticalCenter;

                            currentIndex: 0;
                            onCurrentIndexChanged: {
                                m_json.instrument = m_instrumentList[currentIndex];
                                isSave = false;
                                keyboard.focus = true;
                            }
                        }

                        Item{
                            height: parent.height;
                            width: 20;
                        }

                        Button{
                            width: 80;
                            height: 30;
                            anchors.verticalCenter: parent.verticalCenter;
                            text: qsTr("音源");
                            font.pixelSize: 12;
                            onClicked: {
                                choiceSoundSoure.m_show = true;
                            }
                        }
                    }
                }

                Item{
                    height: 200;
                    width: parent.width;
                    Column{
                        anchors.fill: parent;

                        Row{
                            height: 50;
                            width: parent.width;

                            Item{
                                height: parent.height;
                                width: 80;
                                Text {
                                    text: qsTr("信息:");
                                    font.pixelSize: 12;
                                    anchors.centerIn: parent;
                                }
                            }

                            Item{
                                height: parent.height;
                                width: 100;
                                Text{
                                    id: xiaojie;
                                    anchors.verticalCenter: parent.verticalCenter;
                                    property int t_xiaojie: 0;
                                    text: qsTr("第") + t_xiaojie + qsTr("小节");
                                    font.pixelSize: 12;
                                }
                            }

                            Item{
                                height: parent.height;
                                width: 100;
                                Text{
                                    id: note_index;
                                    anchors.verticalCenter: parent.verticalCenter;
                                    property int t_index: 0;
                                    text: qsTr("第") + t_index + qsTr("个音符");
                                    font.pixelSize: 12;
                                }
                            }

                            Item{
                                height: parent.height;
                                width: 100;
                                Text{
                                    id: note;
                                    anchors.verticalCenter: parent.verticalCenter;
                                    text: qsTr("四分音符");
                                    font.pixelSize: 12;
                                }
                            }

                        }


                        Row{
                            height: 50;
                            width: parent.width;

                            visible: instrumentSelect.currentText === "非洲鼓";

                            ButtonGroup{
                                id: bts;
                            }

                            Item{
                                height: parent.height;
                                width: 80;
                                Text {
                                    text: qsTr("音符:");
                                    font.pixelSize: 12;
                                    anchors.centerIn: parent;
                                }
                            }

                            RadioButton{
                                id: djembe_b;
                                text: qsTr("B");
                                font.pixelSize: 16;
                                ButtonGroup.group: bts;
                                onClicked: changeTone(text);
                            }

                            Item{
                                height: parent.height;
                                width: 20;
                            }

                            RadioButton{
                                id: djembe_t;
                                text: qsTr("T");
                                font.pixelSize: 16;
                                ButtonGroup.group: bts;
                                onClicked: changeTone(text);
                            }
                            Item{
                                height: parent.height;
                                width: 20;
                            }

                            RadioButton{
                                id: djembe_s;
                                text: qsTr("S");
                                font.pixelSize: 16;
                                ButtonGroup.group: bts;
                                onClicked: changeTone(text);
                            }
                            Item{
                                height: parent.height;
                                width: 20;
                            }

                            RadioButton{
                                id: djembe_e;
                                text: qsTr("-");
                                font.pixelSize: 16;
                                ButtonGroup.group: bts;
                                checked: true;
                                onClicked: changeTone(text);
                            }
                        }

                        Row{
                            height: 50;
                            width: parent.width;

                            visible: instrumentSelect.currentText === "钢琴";


                            Item{
                                height: parent.height;
                                width: 80;
                                Text {
                                    text: qsTr("音符:");
                                    font.pixelSize: 12;
                                    anchors.centerIn: parent;
                                }
                            }


                            Item{
                                height: parent.height;
                                width: 20;
                            }

                            Item{
                                height: parent.height;
                                width: 100;
                                Text{
                                    id: pianoTone;
                                    anchors.verticalCenter: parent.verticalCenter;
                                    text: qsTr("-");
                                    font.pixelSize: 12;
                                }
                            }

                        }





                        Row{
                            height: 50;
                            width: parent.width;

                            ButtonGroup{
                                id: special;
                            }

                            Item{
                                height: parent.height;
                                width: 80;
                                Text {
                                    text: qsTr("特殊类型:");
                                    font.pixelSize: 12;
                                    anchors.centerIn: parent;
                                }
                            }

                            RadioButton{
                                id: sanlian;
                                text: qsTr("三连");
                                font.pixelSize: 16;
                                ButtonGroup.group: special;
                                onClicked: changeSpecial( 3 );
                            }

                            Item{
                                height: parent.height;
                                width: 10;
                            }

                            RadioButton{
                                id: liulian;
                                text: qsTr("六连");
                                font.pixelSize: 16;
                                ButtonGroup.group: special;
                                onClicked: changeSpecial( 6 );
                            }

                            Item{
                                height: parent.height;
                                width: 10;
                            }

                            RadioButton{
                                id: fudian;
                                text: qsTr("附点");
                                font.pixelSize: 16;
                                ButtonGroup.group: special;
                                onClicked: changeSpecial( 2.0 / 3.0 );
                            }

                            Item{
                                height: parent.height;
                                width: 10;
                            }

                            RadioButton{
                                id: zhengchang;
                                text: qsTr("正常");
                                font.pixelSize: 16;
                                ButtonGroup.group: special;
                                checked: true;
                                onClicked: changeSpecial( 1.0 );
                            }
                        }


                        Row{
                            height: 50;
                            width: parent.width;

                            Item{
                                height: parent.height;
                                width: 80;
                                Text {
                                    text: qsTr("力度:");
                                    font.pixelSize: 12;
                                    anchors.centerIn: parent;
                                }
                            }

                            Slider {
                                id: power;
                                from: 0.0;
                                to: 1.0;
                                value: 1.0;
                                anchors.verticalCenter: parent.verticalCenter;
                                onValueChanged: changePower( value );

                                x: 20;
                            }

                            Text {
                                text: "(" + ( Math.ceil( power.value * 10000 ) / 100 ) + ")";
                                anchors.bottom: parent.bottom;
                                anchors.bottomMargin: 18;
                            }
                        }

                        Row{
                            height: 50;
                            width: parent.width;

                            ButtonGroup{
                                id: suoyoushou;
                            }

                            Item{
                                height: parent.height;
                                width: 80;
                                Text {
                                    text: qsTr("左右手:");
                                    font.pixelSize: 12;
                                    anchors.centerIn: parent;
                                }
                            }

                            Item{
                                height: parent.height;
                                width: 10;
                            }

                            RadioButton{
                                id: zuoshou;
                                text: qsTr("左手");
                                font.pixelSize: 16;
                                ButtonGroup.group: suoyoushou;
                                checked: true;
                                onClicked: changeHand( "left" );
                            }

                            Item{
                                height: parent.height;
                                width: 10;
                            }

                            RadioButton{
                                id: youshou;
                                text: qsTr("右手");
                                font.pixelSize: 16;
                                ButtonGroup.group: suoyoushou;
                                onClicked: changeHand( "right" );
                            }
                        }
                    }
                }

            }
        }

        Row{
            height: 60;
            width: parent.width;
            clip: true;

            Item {
                height: parent.height;
                width: 20;
            }
            Item{
                height: 40;
                width: height;
                anchors.verticalCenter: parent.verticalCenter;
                Rectangle{
                    id: magic;
                    height: parent.height;
                    width: parent.width;
                    anchors.centerIn: parent;
                    radius: width / 2;
                    color: "#EEE";
                    opacity: 0.0;
                    scale: 0.0;
                    visible: scale > 0.0;
                }

                SequentialAnimation{
                    property bool t_playing: m_playing;
                    onT_playingChanged: {
                        restart();
                    }

                    ParallelAnimation{
                        running: false;
                        NumberAnimation{
                            target:magic;
                            property: "scale";
                            from: 1.0;
                            to: 2.0;
                            duration: 200;
                            easing.type: Easing.InOutQuad;
                        }
                        NumberAnimation{
                            target:magic;
                            property: "opacity";
                            from: 0.0;
                            to: 0.4;
                            duration: 50;
                            easing.type: Easing.InOutQuad;
                        }

                        SequentialAnimation{

                            PauseAnimation {
                                duration: 150;
                            }
                            NumberAnimation {
                                target: magic;
                                property: "opacity";
                                from: 0.4;
                                to: 0.0;
                                duration: 150;
                                easing.type: Easing.InOutQuad;
                            }
                        }
                    }
                }

                Rectangle{
                    anchors.fill: parent;
                    radius: width / 2;
                    color: "#F00"
                    Rectangle{
                        height: parent.height - 4;
                        width: height;
                        radius: width / 2;
                        color: "#FFF"
                        anchors.centerIn: parent;

                        Canvas{
                            id: playPause;
                            contextType: "2d";
                            anchors.fill: parent;

                            property bool m_playing: false;
                            onM_playingChanged: {
                                requestPaint();
                            }

                            onPaint: {
                                context.reset();
                                if( m_playing ){
                                    context.strokeStyle = "#F00";
                                    context.lineWidth = 2;
                                    context.moveTo( width / 3 * 1.2, height / 3 );
                                    context.lineTo( width / 3 * 1.2, height / 3 * 2 );
                                    context.stroke();
                                    context.moveTo( width / 3 * 2 / 1.1, height / 3 );
                                    context.lineTo( width / 3 * 2 / 1.1, height / 3 * 2 );
                                    context.stroke();
                                }else{
                                    context.fillStyle = "#F00";
                                    context.moveTo( width / 2.6, height / 3 / 1.2);
                                    context.lineTo(width / 2.6, height / 3 * 2 * 1.1);
                                    context.lineTo(width / 3 * 2 * 1.1, width / 2);
                                    context.closePath();
                                    context.fill();
                                }
                            }

                            MouseArea{
                                anchors.fill: parent;
                                onClicked: {
                                    m_json.speed = parseInt( speed.text );
                                    playPause.m_playing = !playPause.m_playing;
                                }
                            }
                        }
                    }
                }
            }

            Item{
                height: parent.height;
                width: 20;
            }

            Text {
                text: qsTr("音量:");
                font.pixelSize: 12;
                anchors.bottom: parent.bottom;
                anchors.bottomMargin: 15;
            }

            Item{
                height: parent.height;
                width: 20;
            }

            Slider{
                id: sysVolume;
                from: 0.0;
                to: 1.0;
                value: 0.8;
                anchors.verticalCenter: parent.verticalCenter;
                onValueChanged: {
                    keyboard.focus = true;
                }
            }
        }
    }


    ChoiceSoundSoure{
        id: choiceSoundSoure;
        pm_soundSource: m_soundSource;
    }

    PowerParse{
        id: powerParse;
    }


    Item{
        id: keyboard;
        anchors.fill: parent
        focus: true;

        Keys.onPressed: {
            event.accepted = true;
            console.log( event.key );
            switch( event.key )
            {
            case Qt.Key_Shift:
                m_shiftDown = true;
                break;
            case Qt.Key_Control:
                 m_ctrlDown = true;
                 break;
            case Qt.Key_C:
                if(m_ctrlDown){
                    m_copyArea = [];
                    for( var i = 0; i < soundEdit.m_selectArea.length; ++i ){
                        m_copyArea.push( clone( soundEdit.f_read( soundEdit.m_selectArea[i] ) ) );
                    }
                }
                break;
            case Qt.Key_V:
                if(m_ctrlDown){
                    insert_area(m_copyArea);
                }
                break;

            case Qt.Key_1:
                   insert( 0.5 );
                   break;
            case Qt.Key_2:
                   insert( 1 );
                   break;
            case Qt.Key_3:
                   insert( 2 );
                   break;
            case Qt.Key_4:
                   insert( 4 );
                   break;
            case Qt.Key_5:
                   insert( 8 );
                   break;
            case Qt.Key_6:
                   insert( 16 );
                   break;
            case Qt.Key_7:
                   insert( 32 );
                   break;
            case Qt.Key_Left:
                    if( m_selectIndex - 1 >= 0 )
                    {
                        --m_selectIndex;
                    }
                break;
            case Qt.Key_Right:
                    if( m_selectIndex + 1 < m_json.data.length )
                    {
                        ++m_selectIndex;
                    }
                break;
            case Qt.Key_Backspace:
                    f_delete();
                break;
            case Qt.Key_Minus:
                    changeTone("-");
                break;
            }

            if( m_json.instrument === "非洲鼓" )
            {
                switch( event.key )
                {
                case Qt.Key_B:
                        changeTone("B");
                    break;
                case Qt.Key_T:
                        changeTone("T");
                    break;
                case Qt.Key_S:
                        changeTone("S");
                    break;
                }
            }

            if( m_json.instrument === "钢琴" )
            {
                var t_first = m_json.data[m_selectIndex].tone[0];
                t_first = t_first === "#" || t_first === "b" ? t_first : "";

                switch( event.key )
                {
                case Qt.Key_A:
                        changeTone( "A" + ( m_pitch !== 0 ? "+" + m_pitch : "" ) );
                    break;
                case Qt.Key_B:
                        changeTone( "B" + ( m_pitch !== 0 ? "+" + m_pitch : "" ) );
                    break;
                case Qt.Key_C:
                        changeTone( "C" + ( m_pitch !== 0 ? "+" + m_pitch : "" ) );
                    break;
                case Qt.Key_D:
                        changeTone( "D" + ( m_pitch !== 0 ? "+" + m_pitch : "" ) );
                    break;
                case Qt.Key_E:
                        changeTone( "E" + ( m_pitch !== 0 ? "+" + m_pitch : "" ) );
                    break;
                case Qt.Key_F:
                        changeTone( "F" + ( m_pitch !== 0 ? "+" + m_pitch : "" ) );
                    break;
                case Qt.Key_G:
                        changeTone( "G" + ( m_pitch !== 0 ? "+" + m_pitch : "" ) );
                    break;

                case Qt.Key_Up:

                        var t_toneSize = m_pianoToneList.length;
                        var t_toneIndex = getToneIndex();
                        var t_num =  Math.floor( t_toneIndex / t_toneSize );
                        var t_tone = Math.abs( t_toneIndex % t_toneSize );

                        if( ++t_tone >= t_toneSize )
                        {
                            t_num += Math.floor( t_tone / t_toneSize );
                            t_tone = t_tone % t_toneSize;
                        }


                        if( t_num <= 3 )
                        {
                            changeTone( t_first + m_pianoToneList[ t_tone ] + ( t_num !== 0 ? ( t_num >= 0 ? "+" : "-" ) + Math.abs( t_num ) : "" ) );
                        }

                    break;
                case Qt.Key_Down:
                     t_toneSize = m_pianoToneList.length;
                     t_toneIndex = getToneIndex();
                     t_num =  Math.floor( t_toneIndex / t_toneSize );
                     t_tone = Math.abs( t_toneIndex % t_toneSize );

                    if( --t_tone < 0 )
                    {
                        t_num--;
                        t_tone =  t_tone % t_toneSize + t_toneSize;
                    }

                    if( t_num >= 0 )
                    {
                        changeTone( t_first + m_pianoToneList[ t_tone ] + ( t_num !== 0 ? ( t_num >= 0 ? "+" : "-" ) + Math.abs( t_num ) : "" ) );
                    }
                    break;

                case Qt.Key_BracketLeft:
                    t_tone = pianoTone.text;

                    var t_toneSplit = t_tone.split( "+" );

                    if( t_toneSplit[0].length === 1 )
                    {
                        t_tone = "b" + t_tone;
                    }else{
                        if( t_toneSplit[0][0] === "#" )
                        {
                            t_tone = t_tone.substr( 1 );
                        }
                    }
                    changeTone( t_tone );

                    break;
                case Qt.Key_BracketRight:
                    t_tone = pianoTone.text;

                    t_toneSplit = t_tone.split( "+" );

                    if( t_toneSplit[0].length === 1 )
                    {
                        t_tone = "#" + t_tone;
                    }else{
                        if( t_toneSplit[0][0] === "b" )
                        {
                            t_tone = t_tone.substr( 1 );
                        }
                    }
                    changeTone( t_tone );

                    break;
                }
            }
        }

        Keys.onReleased: {
            if(event.key === Qt.Key_Shift){
                m_shiftDown = false;
            }else if(event.key === Qt.Key_Control){
                m_ctrlDown = false;
            }
        }

        DropArea{
            anchors.fill: parent;
            onDropped: {
                var t_jsonFile = "";
                var t_backgroundMusicFile = "";
                if(drop.hasUrls){
                    for(var i = 0; i < drop.urls.length; i++){

                        var t_sourcePath = drop.urls[i].replace( "file://", "" );
                        var t_filePathSprit = t_sourcePath.split( "/" );
                        var t_fileName = t_filePathSprit[t_filePathSprit.length - 1];

                        var t_fileNameSplit = t_fileName.split( "." );
                        if( t_fileNameSplit.length === 2 )
                        {
                            switch( t_fileNameSplit[1] )
                            {
                            case "json":
                                t_jsonFile = t_sourcePath;
                                break;
                            case "wav":
                                t_backgroundMusicFile = t_sourcePath;
                                break;
                            }
                        }
                    }
                }

                if( t_jsonFile.length > 0 )
                {
                    openFile( t_jsonFile );
                }

                if( t_backgroundMusicFile.length > 0 )
                {
                    m_backgroundMusic = t_backgroundMusicFile;
                }
            }
        }
    }
}
