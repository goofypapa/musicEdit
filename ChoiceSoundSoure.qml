import QtQuick 2.7
import QtQuick.Controls 2.0
import Qt.labs.platform 1.0

Item {
    id: root;
    visible: false;
    anchors.fill: parent;

    property bool m_show: false;
    property bool m_hide: false;
    property string m_instrument: "";

    property var pm_soundSource: {

    }

    property string m_selectName: "";

    property ListModel t_soundSource: ListModel{
        ListElement{ name: "B"; path: "" }
        ListElement{ name: "T"; path: "" }
        ListElement{ name: "S"; path: "" }
    }

    function loadSoundSource(){
        t_soundSource.clear();
        for( var item in pm_soundSource ){
            t_soundSource.append({ name: item, path: pm_soundSource[item] });
        }
    }

    onPm_soundSourceChanged: {
        loadSoundSource();
    }

    Component.onCompleted: {
        loadSoundSource();
    }

    function changeSoundSource( p_key ){
        m_selectName = p_key;
        openFile.open();
    }

    FileDialog{
        id: openFile;
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation);
        nameFilters: ["Audio files (*.wav)"];
        onAccepted:{
            if( m_selectName === "" ){
                return;
            }

            pm_soundSource[m_selectName] = file.toString().replace("file://", "");

            loadSoundSource();
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
                    height: parent.height;
                    anchors.centerIn: parent;

                    Column{
                        spacing: 5;
                        anchors.fill: parent;

                        Item{
                            width: parent.width;
                            height: 50;
                            Text {
                                text: qsTr("更换音源");
                                anchors.centerIn: parent;
                                font.bold: true;
                                font.pixelSize: 20;
                            }
                        }

                        Repeater{
                            model: t_soundSource;
                            Row{
                                height: 50;
                                width: parent.width;
                                Item{
                                    height: parent.height;
                                    width: 40;
                                    Text {
                                        text: qsTr(name + ":");
                                        anchors.verticalCenter: parent.verticalCenter;
                                    }
                                }
                                Item{
                                    height: parent.height;
                                    width: 400;
                                    clip: true;
                                    Text {
                                        text: qsTr(path ? path : "--");
                                        anchors.verticalCenter: parent.verticalCenter;
                                        x: parent.width - width;
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
                                        text: qsTr("更改");
                                        onClicked: {
                                            changeSoundSource( name );
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

            }
        }



    }


}
