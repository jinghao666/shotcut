/*
 * Copyright (c) 2014 Meltytech, LLC
 * Author: Brian Matherly <pez4brian@yahoo.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.1
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.0
import QtQuick.Window 2.1
import Shotcut.Controls 1.0 as Shotcut
import org.shotcut.qml 1.0 as Shotcut

Rectangle {
    width: 400
    height: 200
    color: 'transparent'
    
    SystemPalette { id: activePalette; colorGroup: SystemPalette.Active }
    Shotcut.File { id: htmlFile }
    
    Component.onCompleted: {
        var resource = filter.get('resource')
        if (resource.substring(0,6) == "plain:") {
            resource = resource.substring(6)
            webvfxCheckBox.checked = false
        } else if (resource) {
            webvfxCheckBox.checked = true
        }
        else {
            webvfxCheckBox.checked = false
        }

        htmlFile.url = resource
        
        if (htmlFile.exists()) {
            fileLabel.text = htmlFile.fileName
            fileLabelTip.text = htmlFile.url.toString()
            openButton.enabled = false
            newButton.enabled = false
            webvfxCheckBox.enabled = false
        } else {
            fileLabel.text = qsTr("No File Loaded")
            fileLabel.color = 'red'
            fileLabelTip.text = qsTr('No HTML file loaded. Click "Open" or "New" to load a file.')
            filter.set("disable", 1)
            editButton.enabled = false
            reloadButton.enabled = false
        }
    }
    
    FileDialog {
        id: fileDialog
        modality: Qt.WindowModal
        selectMultiple: false
        selectFolder: false
        folder: settings.savePath
        nameFilters: [ "HTML-Files (*.htm *.html)", "All Files (*)" ]
        selectedNameFilter: "HTML-Files (*.htm *.html)"
        onAccepted: {
            htmlFile.url = fileDialog.fileUrl
            settings.savePath = htmlFile.path
            
            if (fileDialog.selectExisting == false) {
                if (!htmlFile.suffix()) {
                    htmlFile.url = htmlFile.url + ".html"
                }
                htmlFile.copyFromFile(":/scripts/new.html")
            }

            fileLabel.text = htmlFile.fileName
            fileLabel.color = activePalette.text
            fileLabelTip.text = htmlFile.url.toString()
            openButton.enabled = false
            newButton.enabled = false
            webvfxCheckBox.enabled = false
            editButton.enabled = true
            reloadButton.enabled = true
            
            var resource = htmlFile.url.toString()
            if (!webvfxCheckBox.checked) {
                resource = "plain:" + resource
            }
            filter.set('resource', resource)
            filter.set("disable", 0)
        }
    }

    GridLayout {
        columns: 4
        anchors.fill: parent
        anchors.margins: 8
        
        // Row 1
        Label {
            text: qsTr('<b>File:</b>') 
        }
        Label {
            id: fileLabel
            Layout.columnSpan: 3
            Shotcut.ToolTip { id: fileLabelTip }
        }
        
        // Row 2
        CheckBox {
            id: webvfxCheckBox
            Layout.columnSpan: 4
            text: qsTr('Use WebVfx JavaScript extension')
            Shotcut.ToolTip {
                id: webvfxCheckTip
                text: '<b>' + qsTr('For Advanced Users: ') + '</b>' + '<p>' +
                      qsTr('If you enable this, and you do not use the WebVfx JavaScript extension, your content will not render!')
            }
            onClicked: {
                if (checked) {
                    webvfxDialog.visible = true
                }
            }
            MessageDialog {
                id: webvfxDialog
                visible: false
                modality: Qt.ApplicationModal
                icon: StandardIcon.Question
                title: qsTr("Confirm Selection")
                text: webvfxCheckTip.text + "<p>" + qsTr("Do you still want to use this?")
                standardButtons: StandardButton.Yes | StandardButton.No
                onNo: {
                    webvfxCheckBox.checked = false
                }
            }
        }
        
        // Row 3
        Button {
            id: openButton
            text: qsTr('Open...')
            onClicked: {
                openButton.enabled = false
                fileDialog.selectExisting = true
                fileDialog.title = qsTr( "Open HTML File" )
                fileDialog.open()
            }
            Shotcut.ToolTip {
                 text: qsTr("Load an existing HTML file.")
            }
        }
        Button {
            id: newButton
            text: qsTr('New...')
            onClicked: {
                newButton.enabled = false
                fileDialog.selectExisting = false
                fileDialog.title = qsTr( "Save HTML File" )
                fileDialog.open()
            }
            Shotcut.ToolTip {
                 text: qsTr("Load new HTML file.")
            }
        }
        Item {
            Layout.columnSpan: 2
            Layout.fillWidth: true
        }

        // Row 4
        Button {
            id: editButton
            text: qsTr('Edit...')
            onClicked: {
                editor.edit(htmlFile.url.toString())
                editButton.enabled = false
            }
            Shotcut.HtmlEditor {
                id: editor
                onSaved: {
                    filter.set("_reload", 1);
                }
                onClosed: {
                    editButton.enabled = true
                }
            }
        }
        Button {
            id: reloadButton
            text: qsTr('Reload')
            onClicked: {
                filter.set("_reload", 1);
            }
        }
        Item {
            Layout.columnSpan: 2
            Layout.fillWidth: true
        }
        
        Item {
            Layout.fillHeight: true;
            Layout.columnSpan: 4
        }
    }

}
