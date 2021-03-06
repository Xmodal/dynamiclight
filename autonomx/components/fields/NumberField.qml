import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import "qrc:/stylesheet"

Field {
    id: numberField

    property string placeholder: ""
    property real defaultNum: propName && generatorModel.at(window.activeGeneratorIndex) ? generatorModel.at(window.activeGeneratorIndex)[propName] : 0

    property bool unsigned: false   // when true: negative values allowed
    property int type: 0            // 0 = int; 1 = real
    property real min               // minimum accepted range value
    property real max               // maximum accepted range value
    property real incStep: 1        // inc/dec widget step value

    // inc/dec functions
    function increment() {
        var newNum = defaultNum + incStep;
        if (max && newNum > max) newNum = max;
        valueChanged(newNum);
    }
    function decrement() {
        var newNum = defaultNum - incStep;
        if (min && newNum < min) newNum = min;
        valueChanged(newNum);
    }

    // validators
    IntValidator {
        id: intValidator
        top: max ? max : 2147483647
        bottom: min ? min : (unsigned ? 0 : -2147483647)
    }
    DoubleValidator {
        id: doubleValidator;
        top: max ? max : Number.POSITIVE_INFINITY
        bottom: min ? min : Number.NEGATIVE_INFINITY
    }

    // this is essentially just a TextField with Int/Double validation
    // and fancy increment/decrement controls :)
    fieldContent: TextField {
        id: fieldInput

        // alignment
        leftPadding: 0

        // text
        text: defaultNum
        placeholderText: placeholder

        // background
        background: Item {}

        validator: type === 0 ? intValidator : doubleValidator

        // interactivity
        selectByMouse: true

        // signal hooks
        onEditingFinished: {
            numberField.valueChanged(type === 0 ? parseInt(text, 10) : parseFloat(text, 10));
            focus = false;
        }

        // field frame
        onHoveredChanged: fieldHovered = hovered
        onActiveFocusChanged: fieldFocused = activeFocus

        // inc/dec widget
        Item {
            anchors.right: parent.right
            width: 10
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            // block default field pointer events on widget zone
            MouseArea {
                anchors.fill: parent
            }

            // image buttons
            Repeater {
                model: 2

                Image {
                    id: caret
                    source: "qrc:/assets/images/down-caret.svg"
                    opacity: caretMouse.containsMouse && !caretMouse.pressed ? 1 : 0.25

                    anchors {
                        right: parent.right
                        top: index % 2 === 0 ? parent.top : undefined
                        topMargin: index % 2 === 0 ? 8 : 0
                        bottom: index % 2 === 0 ? undefined : parent.bottom
                        bottomMargin: index % 2 === 0 ? 0 : 8
                    }

                    transform: Rotation {
                        angle: index % 2 === 0 ? 180 : 0
                        origin { x: caret.width/2; y: caret.height/2 }
                    }

                    MouseArea {
                        id: caretMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: index % 2 === 0 ? increment() : decrement()
                    }
                }
            }
        }

        // keypress events: inc/dec with up/down arrows
        Keys.onPressed: {
            if (event.key === Qt.Key_Down) decrement();
            if (event.key === Qt.Key_Up) increment();
        }
    }
}
