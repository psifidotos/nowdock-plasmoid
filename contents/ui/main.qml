import QtQuick 2.0
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.private.taskmanager 0.1 as TaskManagerApplet

import QtGraphicalEffects 1.0

Item {
    id:panel

    implicitWidth: (icList.orientation === Qt.Horizontal) ? icList.width+10 : zoomedLength
    implicitHeight: (icList.orientation === Qt.Vertical) ? icList.height+10 : zoomedLength

    Layout.minimumWidth: width
    Layout.minimumHeight: height

    property int zoomedLength: Math.floor((iconSize+iconMargin)*zoomFactor)

    property real zoomFactor: 1.7
    property int iconSize: 64
    property int iconMargin: 15
    property bool glow: false

    //property int position : PlasmaCore.Types.BottomPositioned
    property int position : {
        switch (plasmoid.location) {
        case PlasmaCore.Types.LeftEdge:
            return PlasmaCore.Types.LeftPositioned
        case PlasmaCore.Types.RightEdge:
            return PlasmaCore.Types.RightPositioned;
        case PlasmaCore.Types.TopEdge:
            return PlasmaCore.Types.TopPositioned;
        default:
            return PlasmaCore.Types.BottomPositioned
        }
    }

    property bool vertical: (plasmoid.formFactor === PlasmaCore.Types.Vertical)

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground


    property Item dragSource: null

    signal requestLayout
    signal windowsHovered(variant winIds, bool hovered)
    signal presentWindows(variant winIds)


    /////


    TaskManager.TasksModel {
        id: tasksModel

        virtualDesktop: virtualDesktopInfo.currentDesktop
        screen: plasmoid.screen
        activity: activityInfo.currentActivity

        filterByActivity: true

        Component.onCompleted: {
            console.debug();
        }
    }

    TaskManagerApplet.Backend {
        id: backend

        taskManagerItem: panel
        //toolTipItem: toolTipDelegate
        //highlightWindows: plasmoid.configuration.highlightWindows

        //onAddLauncher: {
        //   tasksModel.requestAddLauncher(url);
        //}
    }

    TaskManager.VirtualDesktopInfo {
        id: virtualDesktopInfo
    }

    TaskManager.ActivityInfo {
        id: activityInfo
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

            width: (panel.iconSize+iconMargin)*scale;
            height: (panel.iconSize+iconMargin)*scale;

            acceptedButtons: Qt.LeftButton | Qt.MidButton

            property bool pressed: false
            property int iconMargin: panel.iconMargin

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

            DropShadow {
                anchors.fill: iconImage
                horizontalOffset: 3
                verticalOffset: 3
                radius: 8.0
                samples: 17
                color: "#80000000"
                source: iconImage
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

            onPressed: {
                if (mouse.button == Qt.LeftButton || mouse.button == Qt.MidButton) {
                    pressed = true;
                }
            }

            onReleased: {
                if(pressed){
                    if (mouse.button == Qt.MidButton){
                        tasksModel.requestNewInstance(modelIndex());
                    } else if (mouse.button == Qt.LeftButton) {
                        if (model.IsGroupParent)
                            panel.presentWindows(model.LegacyWinIdList);
                        else {
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
                }

                pressed = false;
            }

            function modelIndex(){
                return tasksModel.makeModelIndex(index);
            }

        }
    }

    Item {
        id:barLine
        //   imagePath: "widgets/panel-background";
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
            interactive: false

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
    /*  Row{
        id: buttonsGrp
        anchors.right: parent.right
        anchors.top: parent.top

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
        }*/

    /*     PlasmaComponents.Button {
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
        }*/
    //}


    Component.onCompleted:  {
        barLine.movePanel();
        panel.presentWindows.connect(backend.presentWindows);
    }


}
