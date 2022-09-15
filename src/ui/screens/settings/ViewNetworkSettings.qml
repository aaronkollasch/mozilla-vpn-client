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
    id: vpnFlickable
    objectName: "settingsNetworkingBackButton"

    property string _appPermissionsTitle
    property bool vpnIsOff: (VPNController.state === VPNController.StateOff)

    //% "Network settings"
    _menuTitle: qsTrId("vpn.settings.networking")
    _viewContentData: Column {
        id: col
        spacing: VPNTheme.theme.windowMargin
        Layout.fillWidth: true

        VPNContextualAlerts {
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: VPNTheme.theme.windowMargin
                rightMargin: VPNTheme.theme.windowMargin
            }

            messages: [
                {
                    type: "warning",
                    //% "VPN must be off to edit these settings"
                    //: Associated to a group of settings that require the VPN to be disconnected to change
                    message: qsTrId("vpn.settings.vpnMustBeOff"),
                    visible: VPNController.state !== VPNController.StateOff
                }
            ]
        }

        VPNCheckBoxRow {
            id: localNetwork
            objectName: "settingLocalNetworkAccess"
            visible: VPNFeatureList.get("lanAccess").isSupported
            width: parent.width - VPNTheme.theme.windowMargin
            showDivider: true

            //% "Local network access"
            labelText: qsTrId("vpn.settings.lanAccess")
            //% "Access printers, streaming sticks and all other devices on your local network"
            subLabelText: qsTrId("vpn.settings.lanAccess.description")
            isChecked: (VPNSettings.localNetworkAccess)
            isEnabled: vpnFlickable.vpnIsOff
            onClicked: {
                if (vpnFlickable.vpnIsOff) {
                    VPNSettings.localNetworkAccess = !VPNSettings.localNetworkAccess
                }
            }
        }

        VPNCheckBoxRow {
            id: tunnelPort53
            objectName: "settingTunnelPort53"
            width: parent.width - VPNTheme.theme.windowMargin
            showDivider: true

            labelText: VPNl18n.SettingsTunnelPort53
            subLabelText: VPNl18n.SettingsTunnelPort53Description
            isChecked: (VPNSettings.tunnelPort53)
            isEnabled: vpnFlickable.vpnIsOff
            onClicked: {
                if (vpnFlickable.vpnIsOff) {
                    VPNSettings.tunnelPort53 = !VPNSettings.tunnelPort53
                }
            }
        }

        Column {
            width: parent.width
            spacing: VPNTheme.theme.windowMargin  /2
            VPNSettingsItem {
                objectName: "advancedDNSSettings"
                anchors.left: parent.left
                anchors.right: parent.right
                width: parent.width - VPNTheme.theme.windowMargin

                //% "Advanced DNS Settings"
                settingTitle: qsTrId("vpn.settings.networking.advancedDNSSettings")
                imageLeftSrc: "qrc:/ui/resources/settings-dark.svg"
                imageRightSrc: "qrc:/nebula/resources/chevron.svg"
                onClicked: stackview.push("qrc:/ui/screens/settings/dnsSettings/ViewAdvancedDNSSettings.qml")
                visible: VPNFeatureList.get("customDNS").isSupported
            }

            VPNSettingsItem {
                objectName: "appPermissions"
                anchors.left: parent.left
                anchors.right: parent.right
                width: parent.width - VPNTheme.theme.windowMargin
                settingTitle: _appPermissionsTitle
                imageLeftSrc: "qrc:/ui/resources/settings/apps.svg"
                imageRightSrc: "qrc:/nebula/resources/chevron.svg"
                onClicked: stackview.push("qrc:/ui/screens/settings/appPermissions/ViewAppPermissions.qml")
                visible: VPNFeatureList.get("splitTunnel").isSupported
            }

            Rectangle {
                id: divider
                width: parent.width
                height: 1
                color: "#E7E7E7"
                visible: true
            }

            Text {
                id: ipDesc
                text: qsTr("    Don't tunnel these IP addresses/ranges:")
                color: Theme.fontColorDark
            }

            VPNTextField {
                property bool valueInvalid: false
                property string error: "This is an error string"
                hasError: valueInvalid
                visible: true
                readOnly: !vpnFlickable.vpnIsOff
                id: ipMaskInput

                enabled: true
                placeholderText: "1.1.1.1,10.0.0.0/8,fe80::/64"
                text: ""
                width: parent.width
                height: 40

                PropertyAnimation on opacity {
                    duration: 200
                }

                Component.onCompleted: {
                    ipMaskInput.text = VPNSettings.userIPMask;
                }

                onTextChanged: text => {
                    if (ipMaskInput.text === "") {
                        // If nothing is entered, thats valid too. We will ignore the value later.
                        ipMaskInput.valueInvalid = false;
                        VPNSettings.userIPMask = ipMaskInput.text
                        return;
                    }
                    if (VPN.validateIPList(ipMaskInput.text)) {
                        ipMaskInput.valueInvalid = false;
                        VPNSettings.userIPMask = ipMaskInput.text
                    } else {
                        ipMaskInput.error = "Invalid IP list"
                        ipMaskInput.valueInvalid = true;
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        VPN.recordGleanEvent("networkSettingsViewOpened");
        if (!vpnIsOff) {
            VPN.recordGleanEvent("networkSettingsViewWarning");
        }
    }
}
