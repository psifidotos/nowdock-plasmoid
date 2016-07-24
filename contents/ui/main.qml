import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.private.taskmanager 0.1 as TaskManagerApplet

import "../code/tools.js" as TaskTools

Item {
    id:panel

    Layout.minimumWidth: implicitWidth
    Layout.minimumHeight: implicitHeight

    property real zoomFactor: 1.7
    property int iconSize: 64
    property int iconMargin: 15
    property bool glow: false

    property int clearWidth
    property int clearHeight
    property int delegateTransformOrigin

    property int position

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    property bool vertical: (plasmoid.formFactor === PlasmaCore.Types.Vertical)

    property Item dragSource: null
    property bool inAnimation: false


    Connections {
        target: plasmoid
        onLocationChanged: {
            panel.updatePosition();
            iconGeometryTimer.start();
        }
    }

    signal requestLayout
    signal windowsHovered(variant winIds, bool hovered)
    signal presentWindows(variant winIds)

    /////

    onInAnimationChanged: {
        if (!inAnimation){
            panel.updateImplicits();
            iconGeometryTimer.restart();
        }
    }

    TaskManager.TasksModel {
        id: tasksModel

        virtualDesktop: virtualDesktopInfo.currentDesktop
        screen: plasmoid.screen
        activity: activityInfo.currentActivity

        filterByActivity: true


        separateLaunchers: false
        groupMode: TaskManager.TasksModel.GroupApplication
        groupInline: false

        onCountChanged: {
            panel.updateImplicits()
            iconGeometryTimer.restart();
        }

        onActivityChanged: {
            panelGeometryTimer.start();
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

    //Timer to check if the mouse is still inside the ListView
    Timer{
        id:checkListHovered
        repeat:false;
        interval:20;

        onTriggered: {
            var tasks = icList.contentItem.children;
            var lostMouse = true;

            //      console.debug("---------");
            for(var i=0; i<tasks.length; ++i){
                var task = tasks[i];
                //        console.debug(task.containsMouse);
                if (task.containsMouse){
                    lostMouse = false;
                    break;
                }
            }

            if(lostMouse){
                icList.currentSpot = -1000;
                icList.currentIndex = -1;
            }

        }
    }


    Item{
        id:barLine
        //   property bool blockLoop: false

        width: ( icList.orientation === Qt.Horizontal ) ? panel.implicitWidth+4 : 18
        height: ( icList.orientation === Qt.Vertical ) ? panel.implicitHeight+4 : 18


        BorderImage{
            anchors.fill:parent
            source: "../images/panel-west.png"
            border { left:8; right:8; top:8; bottom:8 }

            horizontalTileMode: BorderImage.Stretch
            verticalTileMode: BorderImage.Stretch
        }

        Behavior on width{
            NumberAnimation { duration: 100 }
        }

        Behavior on height{
            NumberAnimation { duration: 100 }
        }

        /*        PlasmaCore.FrameSvgItem{
            anchors.fill:parent
            imagePath: "widgets/panel-background"
            prefix:"east"
        }*/


        ListView {
            id:icList

            anchors.bottom: (panel.position === PlasmaCore.Types.BottomPositioned) ? parent.bottom : undefined
            anchors.top: (panel.position === PlasmaCore.Types.TopPositioned) ? parent.top : undefined
            anchors.left: (panel.position === PlasmaCore.Types.LeftPositioned) ? parent.left : undefined
            anchors.right: (panel.position === PlasmaCore.Types.RightPositioned) ? parent.right : undefined

            anchors.horizontalCenter: ((panel.position === PlasmaCore.Types.BottomPositioned) ||
                                       (panel.position === PlasmaCore.Types.TopPositioned)) ? parent.horizontalCenter : undefined
            anchors.verticalCenter: ((panel.position === PlasmaCore.Types.LeftPositioned) ||
                                     (panel.position === PlasmaCore.Types.RightPositioned)) ? parent.verticalCenter : undefined


            property int currentSpot : -1000
            property int hoveredIndex : -1

            property int runningWidth : (currentSpot  === -1000) ? panel.clearWidth : panel.implicitWidth
            property int runningHeight : (currentSpot === -1000) ? panel.clearHeight : panel.implicitHeight

            //       width: (orientation === Qt.Horizontal) ? runningWidth  : 120
            //      height: (orientation === Qt.Vertical) ? runningHeight  : 120

            width: (orientation === Qt.Horizontal) ? contentWidth + 1  : 120
            height: (orientation === Qt.Vertical) ? contentHeight + 1  : 120
            /*Rectangle{
                anchors.fill: parent
                border.width: 1
                border.color: "red"
                color: "transparent"
            }*/

            interactive: false

            model: tasksModel
            delegate: TaskDelegate{}
            orientation: Qt.Horizontal

            /*     Behavior on width{
                NumberAnimation { duration: 100 }
            }

            Behavior on height{
                NumberAnimation { duration: 100 }
            }*/

            add: Transition {
                PropertyAction { target: panel; property: "inAnimation"; value: true }
                ParallelAnimation{
                    NumberAnimation { property: "appearScale"; from: 0.25; to: 1; duration: 500 }
                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 500 }
                }
                PropertyAction { target: panel; property: "inAnimation"; value: false }
            }

            moveDisplaced: Transition {
                NumberAnimation { properties: "x,y"; duration: 500 }
            }

            removeDisplaced: Transition {
                NumberAnimation { properties: "x,y"; duration: 500 }
            }
        }
    }

    //// helpers

    Timer {
        id: iconGeometryTimer
        // INVESTIGATE: such big interval but unfortunately it doesnot work otherwise
        interval: 1000
        repeat: false

        onTriggered: {
            //    console.debug("Found children: "+icList.contentItem.children.length);
            TaskTools.publishIconGeometries(icList.contentItem.children);
        }
    }

    //It is used when changing activities..
    //Because of many suddent moves, deletes and adds
    //sometimes the ListView appearance breaks
    //this timer makes a full repaint for the ListView
    Timer {
        id: panelGeometryTimer

        interval: 2000
        repeat: false

        onTriggered: {
            icList.model = 0;
            icList.model = tasksModel;

            /// Debugging loop
            /*    var taskItems = icList.contentItem.children;
            for (var i = 0; i < taskItems.length - 1; ++i) {
                var task = taskItems[i];
                console.debug(i+": "+task.objectName+" "+task.width+" "+task.height);
            }*/
        }
    }


    Component.onCompleted:  {
        updatePosition();
        updateImplicits();
        //        updateDelegateTransformOrigin();

        panel.presentWindows.connect(backend.presentWindows);
        iconGeometryTimer.start();
    }

    function movePanel(newPosition){
        var bLine = barLine;
        if (newPosition === PlasmaCore.Types.BottomPositioned){
            bLine.anchors.horizontalCenter = bLine.parent.horizontalCenter;
            bLine.anchors.verticalCenter = undefined;
            bLine.anchors.bottom = bLine.parent.bottom;
            bLine.anchors.top = undefined;
            bLine.anchors.left = undefined;
            bLine.anchors.right = undefined;
        }
        else if (newPosition === PlasmaCore.Types.TopPositioned){
            bLine.anchors.horizontalCenter = bLine.parent.horizontalCenter;
            bLine.anchors.verticalCenter = undefined;
            bLine.anchors.bottom = undefined;
            bLine.anchors.top = bLine.parent.top;
            bLine.anchors.left = undefined;
            bLine.anchors.right = undefined;
        }
        else if (newPosition === PlasmaCore.Types.LeftPositioned){
            bLine.anchors.horizontalCenter = undefined;
            bLine.anchors.verticalCenter = bLine.parent.verticalCenter;
            bLine.anchors.bottom = undefined;
            bLine.anchors.top = undefined;
            bLine.anchors.left = bLine.parent.left;
            bLine.anchors.right = undefined;
        }
        else if (newPosition === PlasmaCore.Types.RightPositioned){
            bLine.anchors.horizontalCenter = undefined;
            bLine.anchors.verticalCenter = bLine.parent.verticalCenter;
            bLine.anchors.bottom = undefined;
            bLine.anchors.top = undefined;
            bLine.anchors.left =undefined;
            bLine.anchors.right = bLine.parent.right;
        }
    }


    function updateImplicits(){
        var zoomedLength = Math.floor( (iconSize+iconMargin) * panel.zoomFactor);
        var bigAxis = (tasksModel.count-1) * (iconSize+iconMargin) + zoomedLength
        var smallAxis = zoomedLength + 1

        var clearBigAxis = tasksModel.count * (iconSize+iconMargin);
        var clearSmallAxis = (iconSize+iconMargin);

        if (panel.vertical){
            panel.implicitWidth = smallAxis;
            panel.implicitHeight = bigAxis;
            panel.clearWidth = clearSmallAxis;
            panel.clearHeight = clearBigAxis;
        }
        else{
            panel.implicitWidth = bigAxis;
            panel.implicitHeight = smallAxis;
            panel.clearWidth = clearBigAxis;
            panel.clearHeight = clearSmallAxis;
        }
    }

    function updateDelegateTransformOrigin (){
        /*    switch(panel.position){
        case PlasmaCore.Types.LeftPositioned:
            panel.delegateTransformOrigin = Item.Left;
            break;
        case PlasmaCore.Types.RightPositioned:
            panel.delegateTransformOrigin = Item.Right;
            break;
        case PlasmaCore.Types.TopPositioned:
            panel.delegateTransformOrigin = Item.Top;
            break;
        case PlasmaCore.Types.BottomPositioned:
            panel.delegateTransformOrigin = Item.Bottom;
            break;
        default:
            panel.delegateTransformOrigin = Item.Bottom;
            break;
        }*/
    }


    function updatePosition(){
        var newPosition;
        var tempVertical=false;

        switch (plasmoid.location) {
        case PlasmaCore.Types.LeftEdge:
            newPosition = PlasmaCore.Types.LeftPositioned;
            tempVertical = true;
            break;
        case PlasmaCore.Types.RightEdge:
            newPosition = PlasmaCore.Types.RightPositioned;
            tempVertical = true;
            break;
        case PlasmaCore.Types.TopEdge:
            newPosition = PlasmaCore.Types.TopPositioned;
            break;
        default:
            newPosition = PlasmaCore.Types.BottomPositioned;
        }

        movePanel(newPosition);

        if(tempVertical)
            icList.orientation = Qt.Vertical;
        else
            icList.orientation = Qt.Horizontal;

        panel.position = newPosition;
        //  updateDelegateTransformOrigin();
    }

}
