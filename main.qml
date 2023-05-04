import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCore
import QtQml

import pdfbookmark

ApplicationWindow {
    width: 640
    height: 480
    visible: true
    title: qsTr("pdfbookmark-qt")

    menuBar: MenuBar {
        Menu {
            title: qsTr("&File")
            Action {
                text: qsTr("&Read From")
                onTriggered: fileDialog_r.open()
            }
        }
        FileDialog {
            id: fileDialog_r
            title: 'Read From'
            currentFolder: StandardPaths.standardLocations(
                               StandardPaths.HomeLocation)[0]
            nameFilters: ["PDF files (*.pdf)"]
            onAccepted: {
                pdfBookmark.file = cvtFileURL2Path(selectedFile)
                textArea.text = pdfBookmark.bookmark
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 5
        RowLayout {
            Label {
                text: qsTr("Based on")
                Layout.minimumWidth: 60
            }
            TextField {
                id: textEdit_b
                Layout.fillWidth: true
                leftPadding: 2
                onTextChanged: enableWriting()
            }
            Button {
                text: qsTr("Select")
                onClicked: fileDialog_b.open()
            }
            FileDialog {
                id: fileDialog_b
                currentFolder: StandardPaths.standardLocations(
                                   StandardPaths.HomeLocation)[0]
                nameFilters: ["PDF files (*.pdf)"]
                onAccepted: {
                    textEdit_b.text = cvtFileURL2Path(selectedFile)
                }
            }
        }
        RowLayout {
            Label {
                text: qsTr("Write to")
                Layout.minimumWidth: 60
            }
            TextField {
                id: textEdit_w
                Layout.fillWidth: true
                leftPadding: 2
                onTextChanged: enableWriting()
            }
            Button {
                text: qsTr("Select")
                onClicked: fileDialog_w.open()
            }
            FileDialog {
                id: fileDialog_w
                currentFolder: StandardPaths.standardLocations(
                                   StandardPaths.HomeLocation)[0]
                nameFilters: ["PDF files (*.pdf)"]
                onAccepted: {
                    textEdit_w.text = cvtFileURL2Path(selectedFile)
                }
            }
        }
        RowLayout {
            Label {
                text: 'Offset'
            }
            TextField {
                id: offset
                text: '0'
                implicitWidth: 30
                leftPadding: 2
                onTextChanged: enableWriting()
            }
            Item {
                Layout.fillWidth: true
            }
            Button {
                id: writeButton
                Layout.alignment: Qt.AlignRight
                text: qsTr("Write")
                onClicked: {
                    pdfBookmark.file = textEdit_b.text
                    footerMsg.text = 'Writing...'
                    if (pdfBookmark.write(textEdit_w.text, textArea.text,
                                          offset.text))
                        footerMsg.text = 'Wrote to ' + textEdit_w.text
                }
                Component.onCompleted: enableWriting()
            }
        }

        ScrollView {
            Layout.fillHeight: true
            Layout.fillWidth: true

            ScrollBar.vertical.policy: ScrollBar.AsNeeded
            ScrollBar.horizontal.policy: ScrollBar.AsNeeded

            TextArea {
                id: textArea
                placeholderText: qsTr("Example:\n" + "Chapter 1 Animal 1\n"
                                      + "\t1.1 Rabbit 1\n" + "\t1.2 Monkey 2\n"
                                      + "Chapter 2 Plant 3\n" + "\t2.1 Sunflower 3")
                anchors.fill: parent
                onTextChanged: enableWriting()
            }
        }
    }

    footer: ToolBar {
        RowLayout {
            anchors.fill: parent
            Label {
                id: footerMsg
                onTextChanged: {
                    footerTs.text = timestamp()
                }
            }
            Item {
                Layout.fillWidth: true
            }
            Label {
                Layout.alignment: Qt.AlignRight
                id: footerTs
            }
        }
    }

    FileDialog {
        id: ofileDialog
        currentFolder: StandardPaths.standardLocations(
                           StandardPaths.HomeLocation)[0]
        nameFilters: ["PDF files (*.pdf)"]
        onAccepted: {
            pdfBookmark.file = ifileDialog.selectedFile
            textArea.text = pdfBookmark.bookmark
        }
    }
    PDFBookmark {
        id: pdfBookmark
    }

    Connections {
        target: pdfBookmark

        function onFooterMsgChanged(msg) {
            footerMsg.text = msg
        }
    }

    function cvtFileURL2Path(_url) {
        const url = new URL(_url)
        return url.pathname.substring(1)
    }

    function timestamp() {
        return new Date().toLocaleTimeString(Qt.locale(), Locale.LongFormat)
    }

    function enableWriting() {
        if (textEdit_b.text != '' && textEdit_w.text != ''
                && textArea.text != '' && offset.text != '')
            writeButton.enabled = true
        else
            writeButton.enabled = false
    }
}
