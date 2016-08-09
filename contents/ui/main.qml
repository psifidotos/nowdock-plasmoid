import QtQuick 2.7
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
    property int iconMargin: 5
    property int realSize: iconSize + iconMargin

    property bool glow: plasmoid.configuration.showGlow
    property int clearWidth
    property int clearHeight
    property int delegateTransformOrigin

    property int position : PlasmaCore.Types.BottomPositioned

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    property bool vertical: (plasmoid.formFactor === PlasmaCore.Types.Vertical)

    property Item dragSource: null
    property bool inAnimation: false
    property bool enableShadows: plasmoid.configuration.showShadows

    property QtObject contextMenuComponent: Qt.createComponent("ContextMenu.qml");

    Connections {
        target: plasmoid
        onLocationChanged: {
            panel.updatePosition();
            iconGeometryTimer.start();
        }
    }

    Connections {
        target: plasmoid.configuration

        onLaunchersChanged: tasksModel.launcherList = plasmoid.configuration.launchers
        onGroupingAppIdBlacklistChanged: tasksModel.groupingAppIdBlacklist = plasmoid.configuration.groupingAppIdBlacklist;
        onGroupingLauncherUrlBlacklistChanged: tasksModel.groupingLauncherUrlBlacklist = plasmoid.configuration.groupingLauncherUrlBlacklist;
    }


    signal requestLayout
    signal windowsHovered(variant winIds, bool hovered)
    signal presentWindows(variant winIds)

    /////

    //very important !!!!
    //this function updates the size of the plasmoid according to the number
    //of tasks in the model !!!
    onInAnimationChanged: {
        if (inAnimation === false){
            panel.updateImplicits();
            iconGeometryTimer.restart();
        }
    }

    TaskManager.TasksModel {
        id: tasksModel

        virtualDesktop: virtualDesktopInfo.currentDesktop
        screen: plasmoid.screen
        activity: activityInfo.currentActivity

        filterByVirtualDesktop: plasmoid.configuration.showOnlyCurrentDesktop
        filterByScreen: plasmoid.configuration.showOnlyCurrentScreen
        filterByActivity: plasmoid.configuration.showOnlyCurrentActivity

        launchInPlace: true
        separateLaunchers: false

        groupMode: TaskManager.TasksModel.GroupApplications
        groupInline: false


        onCountChanged: {
            //    panel.updateImplicits()  // is going to triger it the inAnimation ending
            //  iconGeometryTimer.restart();
        }

        onActivityChanged: {
            panel.updateImplicits();
            //panelGeometryTimer.start();
        }

        onLauncherListChanged: {
            //    layoutTimer.restart();
            plasmoid.configuration.launchers = launcherList;
            //  panel.updateImplicits();
        }

        onGroupingAppIdBlacklistChanged: {
            plasmoid.configuration.groupingAppIdBlacklist = groupingAppIdBlacklist;
        }

        onGroupingLauncherUrlBlacklistChanged: {
            plasmoid.configuration.groupingLauncherUrlBlacklist = groupingLauncherUrlBlacklist;
        }

        Component.onCompleted: {
            launcherList = plasmoid.configuration.launchers;
            groupingAppIdBlacklist = plasmoid.configuration.groupingAppIdBlacklist;
            groupingLauncherUrlBlacklist = plasmoid.configuration.groupingLauncherUrlBlacklist;

            tasksListRepeater.model = tasksModel;
        }
    }

    TaskManagerApplet.Backend {
        id: backend

        taskManagerItem: panel
        //toolTipItem: toolTipDelegate
        //highlightWindows: plasmoid.configuration.highlightWindows

        onAddLauncher: {
            tasksModel.requestAddLauncher(url);
        }
    }

    TaskManager.VirtualDesktopInfo {
        id: virtualDesktopInfo
    }

    TaskManager.ActivityInfo {
        id: activityInfo
    }


    /*  IconsModel{
        id: iconsmdl
    }*/

    //Timer to check if the mouse is still inside the ListView
    Timer{
        id:checkListHovered
        repeat:false;
        interval:60;

        onTriggered: {
            var tasks = icList.children;
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
                icList.hoveredIndex = -1;
            }

        }
    }

    Item{
        id:barLine
        //   property bool blockLoop: false
        opacity: tasksModel.count > 0 ? 1 : 0

        property int spacing: panel.iconSize / 2
        //   property int currentSizeW: (icList.hoveredIndex >= 0) ? panel.implicitWidth : panel.clearWidth + spacing
        //   property int currentSizeH: (icList.hoveredIndex >= 0) ? panel.implicitHeight : panel.clearHeight + spacing


        width: ( icList.orientation === Qt.Horizontal ) ? icList.width + spacing : 18
        height: ( icList.orientation === Qt.Vertical ) ? icList.height + spacing : 18

        //debugging code
        //      width: ( icList.orientation === Qt.Horizontal ) ? icList.width+8 : 18
        //    height: ( icList.orientation === Qt.Vertical ) ? icList.height+8 : 18
        //   onWidthChanged: console.log("!!!!! New Width:"+width);


        BorderImage{
            anchors.fill:parent
            source: "../images/panel-west.png"
            border { left:8; right:8; top:8; bottom:8 }

            opacity: plasmoid.configuration.showBarLine ? 1 : 0

            visible: (opacity == 0) ? false : true

            horizontalTileMode: BorderImage.Stretch
            verticalTileMode: BorderImage.Stretch

            Behavior on opacity{
                NumberAnimation { duration: 200 }
            }
        }

        /*  Rectangle{
            anchors.horizontalCenter:  parent.horizontalCenter
            anchors.verticalCenter: parent.bottom

            width: ( icList.orientation === Qt.Horizontal ) ? panel.implicitWidth+4 : 60
            height: ( icList.orientation === Qt.Vertical ) ? panel.implicitHeight+4 : 60
            opacity: tasksModel.count > 0 ? 1 : 0

            radius: 6

           // color: "transparent"
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#00000000" }
                GradientStop { position: 0.5; color: "#ff000000" }
                GradientStop { position: 1.0; color: "#ff000000" }
            }
        }*/


        Behavior on opacity{
            NumberAnimation { duration: 150 }
        }

        /*     Behavior on width{
            NumberAnimation { duration: 40 }
        }

        Behavior on height{
            NumberAnimation { duration: 40 }
        }*/

        /*        PlasmaCore.FrameSvgItem{
            anchors.fill:parent
            imagePath: "widgets/panel-background"
            prefix:"east"
        }*/
        /*  Rectangle{
            anchors.centerIn: parent
            width: icList.width
            height: icList.height+50
            border.width: 1
            border.color: "red"
            color: "lightblue"
        }*/

        Grid {
            id:icList

            //trigger updating scaling of neighbour delegates of zoomed delegate
            signal updateScale(int delegateIndex, real newScale, real step)

            property int currentSpot : -1000
            property int hoveredIndex : -1
            property int previousCount : 0

            property int count: children ? children.length : 0

            verticalItemAlignment: (panel.position === PlasmaCore.Types.BottomPositioned) ? Grid.AlignBottom : Grid.AlignTop
            horizontalItemAlignment: (panel.position === PlasmaCore.Types.LeftPositioned) ? Grid.AlignLeft : Grid.AlignRight

            //   LayoutMirroring.enabled: ((panel.position === PlasmaCore.Types.RightPositioned) ||
            //            (panel.position === PlasmaCore.Types.TopPositioned)) ? true : false

            rows: ((panel.position === PlasmaCore.Types.BottomPositioned) ||
                   (panel.position === PlasmaCore.Types.TopPositioned)) ? 1 : 0

            columns: ((panel.position === PlasmaCore.Types.LeftPositioned) ||
                      (panel.position === PlasmaCore.Types.RightPositioned)) ? 1 : 0

            property int orientation: Qt.Horizontal



            flow: (panel.position === PlasmaCore.Types.BottomPositioned) ? Flow.LeftToRight : Flow.TopToBottom
            //  layoutDirection: (panel.position === PlasmaCore.Types.LeftPositioned) ? Qt.RightToLeft : Qt.LeftToRight


            Repeater {
                id: tasksListRepeater
                delegate: TaskDelegate{}

                onItemAdded: {
                    panel.inAnimation = true;
                    panel.inAnimation = false;
                }

                onItemRemoved: {
                    panel.inAnimation = true;
                    panel.inAnimation = false;
                }
            }

            /*Rectangle{
                anchors.fill: parent
                border.width: 1
                border.color: "red"
                color: "transparent"
            }*/

            //    interactive: false

            //  model: tasksModel



            //    add: Transition {
            //          PropertyAction { target: panel; property: "inAnimation"; value: true }
            //       ParallelAnimation{
            //         NumberAnimation { property: "opacity"; to:1; duration: 300 }
            //      }
            //      PropertyAction { target: panel; property: "inAnimation"; value: false }
            //  }


            /*     displaced: Transition {
                NumberAnimation { properties: "x,y"; duration: 350 }
                //when the element because of displacement goest outside the listView and
                //return the opacity must be fixed
                NumberAnimation { property: "opacity"; to:1; duration: 200 }
            }
*/
            //helps to calculate property the size of the panel on the first run...
            //      populate: Transition {
            //     NumberAnimation { property: "opacity"; to:1; duration: 300 }
            //  }


            /*    property int durationA: 0;

            move: Transition {
                NumberAnimation { properties: "x,y"; duration: durationA; easing.type: Easing.OutBounce }
                PropertyAction { target:icList; property: "durationA"; value: 0 }
            }*/
            /*
            add: Transition {
                ParallelAnimation{
                    NumberAnimation { property: "opacity"; from:0.2; to:1; duration: 150 }
                }
            }
            */

        }
    }

    //// helpers

    Timer {
        id: iconGeometryTimer
        // INVESTIGATE: such big interval but unfortunately it doesnot work otherwise
        interval: 500
        repeat: false

        onTriggered: {
            //    console.debug("Found children: "+icList.contentItem.children.length);
            TaskTools.publishIconGeometries(icList.children);
        }
    }

    //It is used when changing activities..
    //Because of many suddent moves, deletes and adds
    //sometimes the ListView appearance breaks
    //this timer makes a full repaint for the ListView
    /*   Timer {
        id: panelGeometryTimer

        interval: 2000
        repeat: false

        onTriggered: {
            //icList.model = 0;
            //    tasksListRepeater.model = 0;
            //    tasksListRepeater.model = tasksModel;
            //  icList.model = tasksModel;

            /// Debugging loop
            /*    var taskItems = icList.contentItem.children;
            for (var i = 0; i < taskItems.length - 1; ++i) {
                var task = taskItems[i];
                console.debug(i+": "+task.objectName+" "+task.width+" "+task.height);
            }*/
    //     }
    //   }


    Component.onCompleted:  {
        updatePosition();

        //   updateImplicits(); // the models items have not been added yet

        panel.presentWindows.connect(backend.presentWindows);
        //    iconGeometryTimer.start();
    }

    function movePanel(obj, newPosition){
        var bLine = obj;
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

    //   property int ncounter:0

    function updateImplicits(){
        if(icList.previousCount !== icList.count){
            icList.previousCount = icList.count;

            var zoomedLength = Math.floor( 1.7 * (iconSize+iconMargin) * (panel.zoomFactor));
            var bigAxis = (tasksModel.count-1) * (iconSize+iconMargin) + zoomedLength
            var smallAxis = zoomedLength + 1

            var clearBigAxis = tasksModel.count * (iconSize+iconMargin);
            var clearSmallAxis = (iconSize+iconMargin);

            //  debugging code
            //     ncounter++;
            //    console.log("Implicits______ "+ncounter+". - "+tasksModel.count);

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

            iconGeometryTimer.restart();
        }
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

        movePanel(barLine,newPosition);
        movePanel(icList,newPosition);

        if(tempVertical)
            icList.orientation = Qt.Vertical;
        else
            icList.orientation = Qt.Horizontal;

        panel.position = newPosition;
    }

    function hasLauncher(url) {
        return tasksModel.launcherPosition(url) != -1;
    }

    function addLauncher(url) {
        tasksModel.requestAddLauncher(url);
    }

}
