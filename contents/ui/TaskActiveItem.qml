import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents


Item{
    width: ( icList.orientation === Qt.Horizontal ) ? wrapper.regulatorWidth : 6
    height: ( icList.orientation === Qt.Vertical ) ? wrapper.regulatorHeight : 6

    Rectangle{
        opacity: m.IsActive ? 1 : 0

        color: theme.buttonFocusColor

        width: ( icList.orientation === Qt.Horizontal ) ? parent.width : 3
        height: ( icList.orientation === Qt.Vertical ) ? parent.height : 3

        anchors.bottom: (panel.position === PlasmaCore.Types.BottomPositioned) ? parent.bottom : undefined
        anchors.top: (panel.position === PlasmaCore.Types.TopPositioned) ? parent.top : undefined
        anchors.left: (panel.position === PlasmaCore.Types.LeftPositioned) ? parent.left : undefined
        anchors.right: (panel.position === PlasmaCore.Types.RightPositioned) ? parent.right : undefined
    }
}// active indicator
