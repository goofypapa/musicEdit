import QtQuick 2.7
import QtQuick.Controls 2.0
import Qt.labs.platform 1.0

Item {
    id: root;
    visible: false;
    anchors.fill: parent;

    property bool m_show: false;
    property bool m_hide: false;

    property int m_errorTime: 50;
    property int m_minPower: 0;
    property int m_maxPower: 100;
    property real m_multiple: 1.0;

    property int m_selectIndex: 0;

    property ListModel m_fileList: ListModel{
        ListElement{ name: "文件一"; filePath: "" }
        ListElement{ name: "文件二"; filePath: "" }
        ListElement{ name: "文件三"; filePath: "" }
    }

    function changeSoundSource( p_index ){
        m_selectIndex = p_index;
        openFile.open();
    }

    function parsePower(  ){
        var t_dataPath = m_fileList.get(0).filePath;
        var t_errorTime = parseInt( errorTime.text );
        var t_minPower = parseInt( minPower.text );
        var t_maxPower = parseInt( maxPower.text );
        var t_multiple = parseFloat( multiple.text );

        var t_json = JSON.parse( musicedit.parsePower( JSON.stringify( m_json ), t_dataPath, t_errorTime, t_minPower, t_maxPower, t_multiple ) );
        if( !t_json || !t_json.data || !t_json.data.length){
            parseResult.text = qsTr( "解析失败" );
            return;
        }

        parseResult.text = qsTr( "解析成功" );

        _loadJson( t_json  );
    }

    FileDialog{
        id: openFile;
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation);
        nameFilters: ["files (*.CSV)"];
        onAccepted:{
            if( m_selectIndex < 0 || m_selectIndex >= m_fileList.count ){
                return;
            }
            m_fileList.get(m_selectIndex).filePath = file.toString().replace("file:///", "");
        }
    }

    //show
    ParallelAnimation{
        running: m_show;
        NumberAnimation {
            target: bg;
            property: "opacity"
            from: 0.0;
            to: 0.4;
            duration: 300;
            easing.type: Easing.InOutQuad;
        }

        NumberAnimation {
            target: window;
            property: "scale";
            from: 0.0;
            to: 1.0;
            duration: 300;
            easing.type: Easing.OutBack;
        }

        NumberAnimation {
            target: window;
            property: "opacity";
            from: 0.0;
            to: 1.0;
            duration: 300;
            easing.type: Easing.OutBack;
        }
        ScriptAction{
            script: {
                root.visible = true;
                m_hide = false;
            }
        }
    }

    SequentialAnimation{
        running: m_hide;
        ParallelAnimation{
            NumberAnimation {
                target: window;
                property: "scale";
                from: 1.0;
                to: 0.0;
                duration: 300;
                easing.type: Easing.OutBack;
            }
            NumberAnimation {
                target: window;
                property: "opacity";
                from: 1.0;
                to: 0.0;
                duration: 300;
                easing.type: Easing.OutBack;
            }

            NumberAnimation {
                target: bg;
                property: "opacity"
                from: 0.4;
                to: 0.0;
                duration: 300;
                easing.type: Easing.InOutQuad;
            }
        }
        ScriptAction{
            script: {
                m_show = false;
                root.visible = false;
                parseResult.text = "";
            }
        }
    }

    Rectangle{
        id: bg;
        anchors.fill: parent;
        color: "#000";
        opacity: 0.0;
    }

    Rectangle{
        id: window;
        width: parent.width - 200;
        height: parent.height - 150;
        color: "#FFF";
        anchors.centerIn: parent;
        scale: 0.0;

        Column{
            anchors.fill: parent;

            Item{
                width: parent.width;
                height: 20;
                Button{
                    anchors.top: parent.top;
                    anchors.right: parent.right;
                    height: 20;
                    width: 20;

                    Canvas{
                        anchors.fill: parent;
                        contextType: "2d";
                        onPaint: {
                            context.reset();
                            context.strokeStyle = "#999";
                            var t_margin = 5;
                            context.moveTo( t_margin, t_margin );
                            context.lineTo( width - t_margin, height - t_margin );
                            context.stroke();

                            context.moveTo( t_margin, width - t_margin );
                            context.lineTo( width - t_margin, t_margin );
                            context.stroke();
                        }
                    }


                    onClicked: {
                        root.m_hide = true;
                    }
                }


            }

            Item{
                id: content;
                height: parent.height - 20;
                width: parent.width;


                Item{
                    width: parent.width * 0.8;
                    height: parent.height ;
                    anchors.centerIn: parent;

                    Column{
                        spacing: 5;
                        anchors.fill: parent;

                        Item{
                            width: parent.width;
                            height: 50;
                            Text {
                                text: qsTr("解析力度");
                                anchors.centerIn: parent;
                                font.bold: true;
                                font.pixelSize: 20;
                            }
                        }

                        Row{
                            width: parent.width;
                            height: 50;
                            Item{
                                width: 80;
                                height: parent.height;
                                Text {
                                    text: qsTr("最大误差:");
                                    anchors.verticalCenter: parent.verticalCenter;
                                    font.pixelSize: 12;
                                }
                            }

                            Item{
                                width: 60;
                                height: parent.height;
                                Rectangle{
                                    width: parent.width;
                                    height: parent.height - 22;
                                    anchors.centerIn: parent;
                                    color: "#AAA";
                                    radius: 2;
                                    Rectangle{
                                        width: parent.width - 2;
                                        height: parent.height - 2;
                                        anchors.centerIn: parent;
                                        radius: 1;

                                        TextInput{
                                            id: errorTime;
                                            anchors.fill: parent;
                                            font.pixelSize: 14;
                                            leftPadding: 5;
                                            topPadding: 6;
                                            text: m_errorTime;
                                            clip: true;
                                        }
                                    }
                                }
                            }

                            Item{
                                width: 20;
                                height: parent.height;
                            }

                            Item{
                                width: 80;
                                height: parent.height;
                                Text{
                                    text: qsTr("力度范围：");
                                    anchors.verticalCenter: parent.verticalCenter;
                                    font.pixelSize: 12;
                                }
                            }
                            Item{
                                width: 60;
                                height: parent.height;
                                Rectangle{
                                    width: parent.width;
                                    height: parent.height - 22;
                                    anchors.centerIn: parent;
                                    color: "#AAA";
                                    radius: 2;
                                    Rectangle{
                                        width: parent.width - 2;
                                        height: parent.height - 2;
                                        anchors.centerIn: parent;
                                        radius: 1;

                                        TextInput{
                                            id: minPower;
                                            anchors.fill: parent;
                                            font.pixelSize: 14;
                                            leftPadding: 5;
                                            topPadding: 6;
                                            text: m_minPower;
                                            clip: true;
                                        }
                                    }
                                }
                            }
                            Item{
                                width: 20;
                                height: parent.height;
                                Text {
                                    text: qsTr("-");
                                    font.bold: true;
                                    font.pixelSize: 20;
                                    anchors.centerIn: parent;
                                }
                            }

                            Item{
                                width: 60;
                                height: parent.height;
                                Rectangle{
                                    width: parent.width;
                                    height: parent.height - 22;
                                    anchors.centerIn: parent;
                                    color: "#AAA";
                                    radius: 2;
                                    Rectangle{
                                        width: parent.width - 2;
                                        height: parent.height - 2;
                                        anchors.centerIn: parent;
                                        radius: 1;

                                        TextInput{
                                            id: maxPower;
                                            anchors.fill: parent;
                                            font.pixelSize: 14;
                                            leftPadding: 5;
                                            topPadding: 6;
                                            text: m_maxPower;
                                            clip: true;
                                        }
                                    }
                                }
                            }

                            Item{
                                width: 20;
                                height: parent.height;
                            }

                            Item{
                                width: 40;
                                height: parent.height;
                                Text{
                                    text: qsTr("放大:");
                                    anchors.verticalCenter: parent.verticalCenter;
                                    font.pixelSize: 12;
                                }
                            }

                            Item{
                                width: 60;
                                height: parent.height;
                                Rectangle{
                                    width: parent.width;
                                    height: parent.height - 22;
                                    anchors.centerIn: parent;
                                    color: "#AAA";
                                    radius: 2;
                                    Rectangle{
                                        width: parent.width - 2;
                                        height: parent.height - 2;
                                        anchors.centerIn: parent;
                                        radius: 1;

                                        TextInput{
                                            id: multiple;
                                            anchors.fill: parent;
                                            font.pixelSize: 14;
                                            leftPadding: 5;
                                            topPadding: 6;
                                            text: m_multiple;
                                            clip: true;
                                        }
                                    }
                                }
                            }
                        }

                        Repeater{
                            model: m_fileList;
                            Row{
                                height: 50;
                                width: parent.width;

                                Item{
                                    height: parent.height;
                                    width: 60;
                                    Text {
                                        text: qsTr(name + ":");
                                        anchors.verticalCenter: parent.verticalCenter;
                                        font.bold: true;
                                        font.pixelSize: 12;
                                    }
                                }

                                Item{
                                    height: parent.height;
                                    width: 400;
                                    clip: true;
                                    Text {
                                        text: qsTr(filePath ? filePath : "--");
                                        anchors.verticalCenter: parent.verticalCenter;
                                        x: ( width > parent.width ) ? parent.width - width : 0;
                                    }
                                }

                                Item{
                                    height: parent.height;
                                    width: 50;
                                }

                                Item{
                                    height: parent.height;
                                    width: 50;
                                    Button{
                                        height: 30;
                                        width: 50;
                                        anchors.centerIn: parent;
                                        text: qsTr("选择");
                                        font.bold: true;
                                        onClicked: {
                                            changeSoundSource( index );
                                        }
                                    }
                                }
                            }
                        }


                        Item{
                            width: parent.width;
                            height: 120;

                            Item{
                                height: parent.height;
                                width: 300;

                                Text {
                                    id: parseResult;
                                    text: qsTr("");
                                    font.bold:  true;
                                    font.pixelSize: 20;
                                    color: "#F00";
                                    anchors.centerIn: parent;
                                }
                            }

                            Button{
                                text: "解析";
                                font.bold: true;
                                font.pixelSize: 20;
                                x: parent.width - width - 50;
                                anchors.verticalCenter: parent.verticalCenter;
                                onClicked: parsePower();
                            }
                        }
                    }
                }
            }
        }
    }
}
