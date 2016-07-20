import QtQuick 2.0

import QtQuick.Controls 1.4

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.private.taskmanager 0.1 as TaskManagerApplet

Item {
    id:panel
    width: 750; height: 600

    property real zoomFactor: 1.7
    property int iconSize: 64
    property bool glow: true


    property int position : PlasmaCore.Types.LeftPositioned

    TaskManager.TasksModel {
        id: tasksModel

        virtualDesktop: virtualDesktopInfo.currentDesktop
        //screen: plasmoid.screen
        //    activity: activityInfo.currentActivity

        Component.onCompleted: {
            console.debug();
        }
    }

    TaskManager.VirtualDesktopInfo {
        id: virtualDesktopInfo
    }

    TaskManager.ActivityInfo {
        id: activityInfo
    }

    Image {
        source: "images/1280x800.jpg"
        anchors.fill: parent
        fillMode: Image.Pad
    }

    IconsModel{
        id: iconsmdl
    }

    Component {
        id: iconDelegate
        MouseArea{
            id: wrapper
            anchors.bottom: (panel.position === PlasmaCore.Types.BottomPositioned) ? parent.bottom : undefined
            anchors.top: (panel.position === PlasmaCore.Types.TopPositioned) ? parent.top : undefined

            anchors.left: (panel.position === PlasmaCore.Types.LeftPositioned) ? parent.left : undefined
            anchors.right: (panel.position === PlasmaCore.Types.RightPositioned) ? parent.right : undefined

            property int iconMargin: 15

            width: (panel.iconSize+iconMargin)*scale;
            height: (panel.iconSize+iconMargin)*scale;

            property real scale: 1;
            property real appearScale: 1;

            property int curSpot: icList.currentSpot
            property int center: Math.floor(width / 2)


            Behavior on scale {
                NumberAnimation { duration: 80 }
            }

            ListView.onRemove: SequentialAnimation {
                PropertyAction { target: wrapper; property: "ListView.delayRemove"; value: true }
                ParallelAnimation{
                    NumberAnimation { target: wrapper; property: "scale"; to: 0; duration: 350; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: wrapper; property: "opacity"; to: 0; duration: 350; easing.type: Easing.InOutQuad }
                }
                PropertyAction { target: wrapper; property: "ListView.delayRemove"; value: false }
            }

            onCurSpotChanged: {
                var absCoords = mapToItem(icList, 0, 0);
                var zone = panel.zoomFactor * 100;
                var absCenter;

                if(icList.orientation === Qt.Horizontal)
                    absCenter = absCoords.x + center;
                else
                    absCenter = absCoords.y + center;

                var rDistance = Math.abs(curSpot - absCenter);
                scale = Math.max(1, panel.zoomFactor - ( (rDistance) / zone));
            }


            PlasmaCore.IconItem {
                id: iconImage
                width: panel.iconSize * parent.scale * parent.appearScale;
                height: panel.iconSize * parent.scale * parent.appearScale;

                anchors.bottom: (panel.position === PlasmaCore.Types.BottomPositioned) ? parent.bottom : undefined
                anchors.top: (panel.position === PlasmaCore.Types.TopPositioned) ? parent.top : undefined
                anchors.left: (panel.position === PlasmaCore.Types.LeftPositioned) ? parent.left : undefined
                anchors.right: (panel.position === PlasmaCore.Types.RightPositioned) ? parent.right : undefined

                anchors.bottomMargin: (panel.position === PlasmaCore.Types.BottomPositioned) ? parent.iconMargin : 0
                anchors.topMargin: (panel.position === PlasmaCore.Types.TopPositioned) ? parent.iconMargin : 0
                anchors.leftMargin: (panel.position === PlasmaCore.Types.LeftPositioned) ? parent.iconMargin : 0
                anchors.rightMargin: (panel.position === PlasmaCore.Types.RightPositioned) ? parent.iconMargin : 0


                anchors.horizontalCenter: ((panel.position === PlasmaCore.Types.BottomPositioned) ||
                                           (panel.position === PlasmaCore.Types.TopPositioned)) ? parent.horizontalCenter : undefined
                anchors.verticalCenter: ((panel.position === PlasmaCore.Types.LeftPositioned) ||
                                         (panel.position === PlasmaCore.Types.RightPositioned)) ? parent.verticalCenter : undefined

                active: wrapper.containsMouse
                enabled: true
                usesPlasmaTheme: false

                source: decoration
            }

            Item{
                width: ( icList.orientation === Qt.Horizontal ) ? iconImage.width : parent.iconMargin - 3
                height: ( icList.orientation === Qt.Vertical ) ? iconImage.height : parent.iconMargin - 3

                anchors.bottom: (panel.position === PlasmaCore.Types.BottomPositioned) ? parent.bottom : undefined
                anchors.top: (panel.position === PlasmaCore.Types.TopPositioned) ? parent.top : undefined
                anchors.left: (panel.position === PlasmaCore.Types.LeftPositioned) ? parent.left : undefined
                anchors.right: (panel.position === PlasmaCore.Types.RightPositioned) ? parent.right : undefined

                anchors.horizontalCenter: ((panel.position === PlasmaCore.Types.BottomPositioned) ||
                                           (panel.position === PlasmaCore.Types.TopPositioned)) ? parent.horizontalCenter : undefined
                anchors.verticalCenter: ((panel.position === PlasmaCore.Types.LeftPositioned) ||
                                         (panel.position === PlasmaCore.Types.RightPositioned)) ? parent.verticalCenter : undefined


                Rectangle{
                    visible: IsActive ? true : false

                    color: theme.highlightColor
                    width: ( icList.orientation === Qt.Horizontal ) ? parent.width : 3
                    height: ( icList.orientation === Qt.Vertical ) ? parent.height : 3

                    anchors.top: (panel.position === PlasmaCore.Types.BottomPositioned) ? parent.top : undefined
                    anchors.bottom: (panel.position === PlasmaCore.Types.TopPositioned) ? parent.bottom : undefined
                    anchors.left: (panel.position === PlasmaCore.Types.RightPositioned) ? parent.left : undefined
                    anchors.right: (panel.position === PlasmaCore.Types.LeftPositioned) ? parent.right : undefined
                }

                Item{
                    id:glowFrame
                    width: (( IsGroupParent ) && (icList.orientation === Qt.Horizontal)) ? 2*size : size
                    height: (( IsGroupParent ) && (icList.orientation === Qt.Vertical)) ? 2*size : size
                    anchors.bottom: (panel.position === PlasmaCore.Types.BottomPositioned) ? parent.bottom : undefined
                    anchors.top: (panel.position === PlasmaCore.Types.TopPositioned) ? parent.top : undefined
                    anchors.left: (panel.position === PlasmaCore.Types.LeftPositioned) ? parent.left : undefined
                    anchors.right: (panel.position === PlasmaCore.Types.RightPositioned) ? parent.right : undefined

                    anchors.horizontalCenter: ( icList.orientation === Qt.Horizontal ) ? parent.horizontalCenter : undefined
                    anchors.verticalCenter: ( icList.orientation === Qt.Vertical ) ? parent.verticalCenter : undefined

                    property int size: 8

                    Flow{
                        anchors.fill: parent

                        GlowPoint{
                            width: glowFrame.size
                            height: width

                            visible: ( !IsLauncher ) ? true: false
                        }
                        GlowPoint{
                            width: glowFrame.size
                            height: width

                            visible: (IsGroupParent) ? true: false
                        }
                    }
                }
            }


            //MouseArea {
            //       id: taskMouseArea
            //    anchors.fill: parent
            hoverEnabled: true

            onEntered: {
                var pos = mapToItem(icList, mouseX, mouseY);

                if (icList.orientation == Qt.Horizontal)
                    icList.currentSpot = pos.x;
                else
                    icList.currentSpot = pos.y;
            }

            onExited: {
                icList.currentSpot = -1000;
            }

            onPositionChanged: {
                var pos = mapToItem(icList, mouse.x, mouse.y);

                if (icList.orientation == Qt.Horizontal)
                    icList.currentSpot = pos.x;
                else
                    icList.currentSpot = pos.y;
            }

            onReleased: {
                if (mouse.button == Qt.LeftButton) {
                    if (IsMinimized === true) {
                        var i = modelIndex();
                        tasksModel.requestToggleMinimized(i);
                        tasksModel.requestActivate(i);
                    } else if (IsActive === true) {
                        tasksModel.requestToggleMinimized(modelIndex());
                    } else {
                        tasksModel.requestActivate(modelIndex());
                    }

                }
            }

            function modelIndex(){
                return tasksModel.makeModelIndex(index);
            }

        }
    }

    PlasmaCore.FrameSvgItem {
        id:barLine
        imagePath: "widgets/panel-background";
        property bool blockLoop: false

        width: ( (icList.orientation === Qt.Horizontal) && (!blockLoop) )? icList.width+10 : 12
        height: ((icList.orientation === Qt.Vertical) && (!blockLoop) ) ? icList.height+10 : 12

        function movePanel(){
            if (panel.position === PlasmaCore.Types.BottomPositioned){
                anchors.horizontalCenter = parent.horizontalCenter;
                anchors.verticalCenter = undefined;
                anchors.bottom = parent.bottom;
                anchors.top = undefined;
                anchors.left = undefined;
                anchors.right = undefined;
            }
            else if (panel.position === PlasmaCore.Types.TopPositioned){
                anchors.horizontalCenter = parent.horizontalCenter;
                anchors.verticalCenter = undefined;
                anchors.bottom = undefined;
                anchors.top = buttonsGrp.bottom;
                anchors.left = undefined;
                anchors.right = undefined;
            }
            else if (panel.position === PlasmaCore.Types.LeftPositioned){
                anchors.horizontalCenter = undefined;
                anchors.verticalCenter = parent.verticalCenter;
                anchors.bottom = undefined;
                anchors.top = undefined;
                anchors.left = parent.left;
                anchors.right = undefined;
            }
            else if (panel.position === PlasmaCore.Types.RightPositioned){
                anchors.horizontalCenter = undefined;
                anchors.verticalCenter = parent.verticalCenter;
                anchors.bottom = undefined;
                anchors.top = undefined;
                anchors.left =undefined;
                anchors.right = parent.right;
            }
        }

        /*  PlasmaCore.FrameSvgItem {
            imagePath: "widgets/panel-background";
            prefix: "shadow"
            anchors.centerIn: parent
            width: parent.width+12
            height: parent.height+12
        }*/

        ListView {
            id:icList
            anchors.bottom: (panel.position === PlasmaCore.Types.BottomPositioned) ? parent.bottom : undefined
            anchors.top: (panel.position === PlasmaCore.Types.TopPositioned) ? parent.top : undefined

            anchors.horizontalCenter: ((panel.position === PlasmaCore.Types.BottomPositioned) ||
                                       (panel.position === PlasmaCore.Types.TopPositioned)) ? parent.horizontalCenter : undefined

            anchors.left: (panel.position === PlasmaCore.Types.LeftPositioned) ? parent.left : undefined
            anchors.right: (panel.position === PlasmaCore.Types.RightPositioned) ? parent.right : undefined
            anchors.verticalCenter: ((panel.position === PlasmaCore.Types.LeftPositioned) ||
                                     (panel.position === PlasmaCore.Types.RightPositioned)) ? parent.verticalCenter : undefined


            property int currentSpot : -1000
            width: (orientation === Qt.Horizontal) ? contentWidth + 1 : 120
            height: (orientation === Qt.Vertical) ? contentHeight + 1 : 120

            //  model: iconsmdl
            model: tasksModel
            delegate: iconDelegate
            orientation: ((panel.position === PlasmaCore.Types.BottomPositioned) ||
                          (panel.position === PlasmaCore.Types.TopPositioned)) ? Qt.Horizontal : Qt.Vertical

            add: Transition {
                ParallelAnimation{
                    NumberAnimation { property: "appearScale"; from: 0; to: 1; duration: 500 }
                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 500 }
                }
            }

            removeDisplaced: Transition {
                NumberAnimation { properties: "x,y"; duration: 500 }
            }
        }
    }

    //// Buttons on the top
    Row{
        id: buttonsGrp
        anchors.right: parent.right
        anchors.top: parent.top

        /*        PlasmaComponents.Button {
            text: "Add Item"
            onClicked: iconsmdl.append({"icon": "icons/firefox.png","instances": 1, "active":true})
        }
        PlasmaComponents.Button {
            text: "Remove Item"
            onClicked: iconsmdl.remove(2)
        }*/

        PlasmaComponents.Button {
            text: "Disable Glow"
            onClicked: {
                if (panel.glow){
                    panel.glow = false;
                    text = "Enable Glow"
                }
                else{
                    panel.glow = true;
                    text = "Disable Glow"
                }


            }
        }

        PlasmaComponents.Button {
            text: "Change Layout"
            onClicked: {
                barLine.blockLoop = true;
                if(panel.position === PlasmaCore.Types.BottomPositioned){
                    panel.position = PlasmaCore.Types.RightPositioned
                    console.debug(" On Right");
                }
                else if (panel.position === PlasmaCore.Types.RightPositioned){
                    panel.position = PlasmaCore.Types.TopPositioned
                    console.debug(" On Top");
                }
                else if (panel.position === PlasmaCore.Types.TopPositioned){
                    panel.position = PlasmaCore.Types.LeftPositioned
                    console.debug(" On Left");
                }
                else{
                    panel.position = PlasmaCore.Types.BottomPositioned
                    console.debug("On Bottom");
                }

                barLine.movePanel();
                barLine.blockLoop = false;
            }
        }
    }


    Component.onCompleted: barLine.movePanel();

}
