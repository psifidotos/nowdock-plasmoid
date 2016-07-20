import QtQuick 2.0

ListModel {
    ListElement {
        icon:"icons/firefox.png"
        instances:2
        active: true
    }
    ListElement {
        icon:"icons/libreoffice-writer.png"
        instances:1
        active:false
    }
    ListElement {
        icon:"icons/google-chrome.png"
        instances:0
        active:true
    }
    ListElement {
        icon:"icons/kwrite.png"
        instances:2
        active:false
    }
}
