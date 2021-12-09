/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import QtQuick 2.5
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Mozilla.VPN 1.0
import components 0.1
import components.forms 0.1
import themes 0.1

import org.mozilla.Glean 0.24
import telemetry 0.24


Item {
    property string _appPermissionsTitle
    //% "Network settings"
    property string _menuTitle: qsTrId("vpn.settings.networking")

    id: root
    objectName: "settingsNetworkingBackButton"

    VPNFlickable {
        id: vpnFlickable
        property bool vpnIsOff: (VPNController.state === VPNController.StateOff)

        anchors.top: parent.top
        anchors.topMargin: 56
        anchors.right: parent.right
        anchors.left: parent.left
        height: root.height - menu.height
        flickContentHeight: col.childrenRect.height
        interactive: flickContentHeight > height

        Component.onCompleted: {
            Sample.networkSettingsViewOpened.record();
            if (!vpnIsOff) {
                Sample.networkSettingsViewWarning.record();
            }
        }

        Column {
            id: col
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: Theme.windowMargin
            spacing: Theme.windowMargin

            VPNCheckBoxAlert {
                id: alert
                //% "VPN must be off to edit these settings"
                //: Associated to a group of settings that require the VPN to be disconnected to change
                errorMessage: qsTrId("vpn.settings.vpnMustBeOff")
            }

            VPNCheckBoxRow {
                id: localNetwork
                objectName: "settingLocalNetworkAccess"
                visible: VPNFeatureList.get("lanAccess").isSupported
                width: parent.width - Theme.windowMargin
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

            Column {
                width: parent.width
                spacing: Theme.windowMargin  /2
                VPNSettingsItem {
                    objectName: "advancedDNSSettings"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    width: parent.width - Theme.windowMargin

                    //% "Advanced DNS Settings"
                    settingTitle: qsTrId("vpn.settings.networking.advancedDNSSettings")
                    imageLeftSrc: "qrc:/ui/resources/settings-dark.svg"
                    imageRightSrc: "qrc:/nebula/resources/chevron.svg"
                    onClicked: settingsStackView.push("qrc:/ui/settings/ViewAdvancedDNSSettings.qml")
                    visible: VPNFeatureList.get("customDNS").isSupported
                }

                VPNSettingsItem {
                    objectName: "appPermissions"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    width: parent.width - Theme.windowMargin
                    settingTitle: _appPermissionsTitle
                    imageLeftSrc: "qrc:/ui/resources/settings/apps.svg"
                    imageRightSrc: "qrc:/nebula/resources/chevron.svg"
                    onClicked: settingsStackView.push("qrc:/ui/settings/ViewAppPermissions.qml")
                    visible: VPNFeatureList.get("splitTunnel").isSupported
                }
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
}
