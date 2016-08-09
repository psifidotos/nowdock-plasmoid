import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents


Rectangle{
    opacity: m.IsActive ? 1 : 0

    color: theme.highlightColor
    width: ( icList.orientation === Qt.Horizontal ) ? wrapper.regulatorWidth : 3
    height: ( icList.orientation === Qt.Vertical ) ? wrapper.regulatorHeight : 3

}// active indicator
