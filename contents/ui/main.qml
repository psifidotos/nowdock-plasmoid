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

            readonly property var m: model
            property int itemIndex: index

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
                PropertyAction { target: panel; property: "inAnimation"; value: true }
                PropertyAction { target: wrapper; property: "ListView.delayRemove"; value: true }
                ParallelAnimation{
                    NumberAnimation { target: wrapper; property: "scale"; to: 0; duration: 350; easing.type: Easing.InOutQuad }
                    NumberAnimation { target: wrapper; property: "opacity"; to: 0; duration: 350; easing.type: Easing.InOutQuad }
                }
                PropertyAction { target: wrapper; property: "ListView.delayRemove"; value: false }
                PropertyAction { target: panel; property: "inAnimation"; value: false }
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

            hoverEnabled: true

            ////IMPORTANT: This shouldnt been calculated so many times for every task even those
            ////that arent going to alter their scale, plus could be calculated with differences
            ////instead of every step even 1px to calculate every 3 or 4
            onCurSpotChanged: {
                var distanceFromHovered = Math.abs(index - icList.hoveredIndex);

                if (distanceFromHovered <= 1){
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
            }

            onEntered: {
                var pos = mapToItem(icList, mouseX, mouseY);

                if (icList.orientation == Qt.Horizontal)
                    icList.currentSpot = pos.x;
                else
                    icList.currentSpot = pos.y;
            }

            // IMPORTANT: This must be improved ! even for small miliseconds  it reduces performance
            onExited: {
                icList.currentSpot = -1000;
            }

            onPositionChanged: {
                var pos = mapToItem(icList, mouse.x, mouse.y);
                var animationStep = 5;

                if (icList.orientation == Qt.Horizontal){
                    var step = Math.abs(icList.currentSpot-pos.x);
                    if (step >= animationStep){
                        icList.hoveredIndex = index;
                        icList.currentSpot = pos.x;
                    }
                }
                else{
                    var step = Math.abs(icList.currentSpot-pos.y);
                    if (step >= animationStep){
                        icList.hoveredIndex = index;
                        icList.currentSpot = pos.y;
                    }
                }
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

    Item{
        id:barLine
     //   property bool blockLoop: false

        width: ( icList.orientation === Qt.Horizontal ) ? panel.implicitWidth+10 : 12
        height: ( icList.orientation === Qt.Vertical ) ? panel.implicitHeight+10 : 12

        PlasmaCore.FrameSvgItem{
            anchors.fill:parent
            imagePath: "widgets/panel-background";
        }


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

            width: (orientation === Qt.Horizontal) ? runningWidth  : 120
            height: (orientation === Qt.Vertical) ? runningHeight  : 120

            /*Rectangle{
                anchors.fill: parent
                border.width: 1
                border.color: "red"
                color: "transparent"
            }*/

            interactive: false

            model: tasksModel
            delegate: iconDelegate
            orientation: Qt.Horizontal

            Behavior on width{
                 NumberAnimation { duration: 100 }
            }

            Behavior on height{
                NumberAnimation { duration: 100 }
            }

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

    Timer {
        id: panelGeometryTimer

        interval: 500
        repeat: false

        onTriggered: updateImplicits();
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
