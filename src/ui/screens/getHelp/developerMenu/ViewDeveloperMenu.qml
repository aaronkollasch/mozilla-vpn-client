/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import QtQuick 2.5
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Mozilla.VPN 1.0
import components 0.1
import components.forms 0.1

VPNViewBase {
    _menuTitle: VPNl18n.SettingsDevTitle
    _viewContentData: ColumnLayout {
        id: root
        property bool vpnIsOff: (VPNController.state === VPNController.StateOff) ||
                                    (VPNController.state === VPNController.StateInitializing)


        spacing: VPNTheme.theme.windowMargin

        VPNCheckBoxRow {
            id: developerUnlock

            Layout.fillWidth: true
            Layout.rightMargin: VPNTheme.theme.windowMargin
            labelText:  VPNl18n.SettingsDevShowOptionTitle
            subLabelText: VPNl18n.SettingsDevShowOptionSubtitle
            isChecked: VPNSettings.developerUnlock
            onClicked: VPNSettings.developerUnlock = !VPNSettings.developerUnlock
        }

        VPNCheckBoxRow {
            id: checkBoxRowStagingServer

            Layout.fillWidth: true
            Layout.rightMargin: VPNTheme.theme.windowMargin
            labelText: VPNl18n.SettingsDevUseStagingTitle
            subLabelText: VPNl18n.SettingsDevUseStagingSubtitle
            isChecked: VPNSettings.stagingServer
            isEnabled: root.vpnIsOff
            showDivider: false
            onClicked: {
                if (root.vpnIsOff) {
                    VPNSettings.stagingServer = !VPNSettings.stagingServer
                }
            }
        }

        VPNTextField {
            id: serverAddressInput

            Layout.fillWidth: true
            Layout.rightMargin: VPNTheme.theme.windowMargin * 2
            Layout.leftMargin: VPNTheme.theme.windowMargin * 3

            Layout.alignment: Qt.AlignHCenter
            enabled: root.vpnIsOff && VPNSettings.stagingServer
            _placeholderText: "Staging server address"
            Layout.preferredHeight: VPNTheme.theme.rowHeight

            PropertyAnimation on opacity {
                duration: 200
            }

            onTextChanged: text => {
                               if (root.vpnIsOff && VPNSettings.stagingServerAddress !== serverAddressInput.text) {
                                   VPNSettings.stagingServerAddress = serverAddressInput.text;
                               }
                           }

            Component.onCompleted: {
                serverAddressInput.text = VPNSettings.stagingServerAddress;
            }
        }

        VPNCheckBoxRow {
            Layout.fillWidth: true
            Layout.topMargin: VPNTheme.theme.windowMargin
            Layout.rightMargin: VPNTheme.theme.windowMargin

            labelText: "Custom Add-on URL"
            subLabelText: "Load add-ons from an alternative URL address"

            isChecked: VPNSettings.addonCustomServer
            showDivider: false
            onClicked: {
                if (root.vpnIsOff) {
                    VPNSettings.addonCustomServer = !VPNSettings.addonCustomServer
                }
            }
        }

        VPNTextField {
            id: addonCustomServerInput

            Layout.topMargin: VPNTheme.theme.windowMargin
            Layout.rightMargin: VPNTheme.theme.windowMargin * 2
            implicitWidth: checkBoxRowStagingServer.labelWidth - VPNTheme.theme.windowMargin
            Layout.alignment: Qt.AlignRight

            enabled: VPNSettings.addonCustomServer
            _placeholderText: "Addon Custom Server Address"
            height: 40

            PropertyAnimation on opacity {
                duration: 200
            }

            onTextChanged: text => {
                               if (VPNSettings.addonCustomServerAddress !== addonCustomServerInput.text) {
                                   VPNSettings.addonCustomServerAddress = addonCustomServerInput.text;
                               }
                           }

            Component.onCompleted: {
                addonCustomServerInput.text = VPNSettings.addonCustomServerAddress;
            }
        }

        Rectangle {
            id: divider
            Layout.preferredHeight: 1
            Layout.fillWidth: true
            Layout.topMargin: VPNTheme.theme.windowMargin / 2
            Layout.leftMargin: VPNTheme.theme.windowMargin * 3
            Layout.rightMargin: VPNTheme.theme.windowMargin
            color: "#E7E7E7"
        }

        Repeater {
            model: ListModel {
                id: devMenu

                ListElement {
                    title: "Feature list"
                    viewQrc: "qrc:/ui/screens/getHelp/developerMenu/ViewFeatureList.qml"
                }
                ListElement {
                    title: "Theme list"
                    viewQrc: "qrc:/ui/screens/getHelp/developerMenu/ViewThemeList.qml"
                }
                ListElement {
                    title: "Messages - REMOVE ME"
                    viewQrc: "qrc:/ui/screens/getHelp/developerMenu/ViewMessages.qml"
                }
                ListElement {
                    title: "Animations playground"
                    viewQrc: "qrc:/ui/screens/getHelp/developerMenu/ViewAnimationsPlayground.qml"
                }
            }

            delegate: VPNSettingsItem {
               settingTitle:  title
               imageLeftSrc: "qrc:/ui/resources/settings/whatsnew.svg"
               imageRightSrc: "qrc:/nebula/resources/chevron.svg"
               onClicked: getHelpStackView.push(viewQrc)
               Layout.preferredWidth: parent.width - VPNTheme.theme.windowMargin
            }
        }

        //Need to wrap VPNExternalLinkListItem in an item since it is not written to work in a layout
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: VPNTheme.theme.rowHeight

            visible: checkBoxRowStagingServer.isChecked && !restartRequired.isVisible

            VPNExternalLinkListItem {
                id: inspectorLink

                anchors.left: parent.left
                anchors.right: parent.right

                objectName: "openInspector"
                title: "Open Inspector"
                accessibleName: "Open Inspector"
                iconSource:  "qrc:/nebula/resources/externalLink.svg"
                backgroundColor: VPNTheme.theme.clickableRowBlue
                onClicked: {
                    VPN.openLink(VPN.LinkInspector)
                }
            }
        }

        VPNContextualAlerts {
            id: restartRequired

            property bool isVisible: false

            Layout.topMargin: VPNTheme.theme.listSpacing
            Layout.leftMargin: VPNTheme.theme.windowMargin/2

            messages: [
                {
                    type: "warning",
                    message: VPNl18n.SettingsDevRestartRequired,
                    visible: isVisible
                }
            ]

            Connections {
                target: VPNSettings
                function onStagingServerAddressChanged() {
                    restartRequired.isVisible = true;
                }
                function onStagingServerChanged() {
                    restartRequired.isVisible = true;
                }
            }
        }

        VPNButton {
            id: crashApp
            property int clickNeeded: 5


            text: "Test Crash Reporter"
            onClicked: {
                if (!VPNSettings.stagingServer){
                    text = "Test Crash Reporter (Staging only!)";
                    return;
                }
                if (clickNeeded) {
                    text = "Test Crash Reporter (" + clickNeeded + ")";
                    --clickNeeded;
                    return;
                }
                VPN.crashTest()
            }
        }

        VPNButton {
            id: resetAndQuit
            property int clickNeeded: 5

           text: "Reset and Quit"
            onClicked: {
                if (clickNeeded) {
                    text = "Reset and Quit (" + clickNeeded + ")";
                    --clickNeeded;
                    return;
                }

                VPN.hardResetAndQuit()
            }
        }

        VPNTextBlock {
            id: qtVersionText

            Layout.leftMargin: 31
            Layout.rightMargin: 3
            Layout.fillWidth: true

            text: VPN.devVersion
        }

        VPNVerticalSpacer {
            Layout.preferredHeight: VPNTheme.theme.windowMargin
        }
    }
}
