//=============================================================================
//  MuseScore
//  Music Composition & Notation
//
//  Copyright (C) 2017 Karen Zita Haigh, Nicolas Froment
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//=============================================================================
// History
// Version 1 by iancboswell September 2012. Contains Harpfont.tff
// Version 2 by kzh October 2015. Code is a complete rewrite of the plugin.
// Version 3 by Nicolas Froment 2017, use Bravura text, no external font
// Version 4 by Joachim Schmitz 2019, port to MuseScore 3
// Version 5 by Trudy Firestone 2021, support updating an existing pedal diagram

import QtQuick 2.9
import MuseScore 3.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.5
import QtQuick.Dialogs 1.2

MuseScore {
  menuPath: "Plugins.Harp Pedal Diagram"
  version: "3.0"
  pluginType: "dialog"
  id: pedalDialog
  width: 370
  height: 260

  onRun: {
    console.log("Drawing Harp Pedal Diagram popup dialog");
    if (typeof curScore === 'undefined') {
      console.log("Quitting: no score");
      Qt.quit();
    }
    var cursor = curScore.newCursor();
    cursor.rewind(1); // start of selection
    // If existing pedal diagram is selected, allow editing
    if (curScore.selection.elements.length == 1 && isPedalDiagram(curScore.selection.elements[0])) {
      initializeStateBasedOnCurrentElement(curScore.selection.elements[0]);
    } else if (!cursor.segment) {
      console.log("Quitting: no selection");
      Qt.quit();
    }
  }


  function isPedalDiagram(element)  {
    if (element.type == Element.STAFF_TEXT) {
      const elementText = element.text.split('');
      if (element.text.length == 8) {
        return elementText.every(function (pedalUnicode, index) {
           if(index == 3) {
             return pedalUnicode == "\uE683";
           } else {
             return pedalUnicode == "\uE680" || pedalUnicode == "\uE682" || pedalUnicode == "\uE681";
           }
        });
      }
    }
  }

  function initializeStateBasedOnCurrentElement(element) {
    const originalPedalDiagram = element.text;
    const checkedStates = originalPedalDiagram.split('').reverse().forEach(function (pedalChar, pedalCharIndex) {
      const buttonIndex = pedalCharIndex > 3 ? pedalCharIndex - 1 : pedalCharIndex;
      if (pedalCharIndex != 4) {
        if (pedalChar == "\uE680") {
          flatRow.buttonList[buttonIndex].checked = true;
        } else if(pedalChar == "\uE681") {
          natRow.buttonList[buttonIndex].checked = true;
        } else if(pedalChar == "\uE682") {
          sharpRow.buttonList[buttonIndex].checked = true;
        }
      }
    })
  }

  function showVals () {
    // store a version for the UI and a version for the staff text
    var positions="";
    var upositions=""
    for (var i=0; i < flatRow.buttonList.length; i++ ) {
      var s = flatRow.buttonList[i];
      var n = natRow.buttonList[i];
      var f = sharpRow.buttonList[i];
      if (s.checked) {
        positions = "<sym>harpPedalRaised</sym>"+positions;
        upositions = "\uE680"+upositions;
      } else if (f.checked) {
        positions = "<sym>harpPedalLowered</sym>"+positions;
        upositions = "\uE682"+upositions;
      } else {
        positions = "<sym>harpPedalCentered</sym>"+positions;
        upositions = "\uE681"+upositions;
      }

      if (i==3) {
        positions="<sym>harpPedalDivider</sym>"+positions;
        upositions = "\uE683"+upositions;
      }
    }
    console.log(positions);
    diagram.text = upositions;
    diagram.symText = positions;
  }

  ColumnLayout {
    id: pedalPositions
    anchors.left: pedalDialog.left
    anchors.leftMargin: 10
    anchors.top: parent.top
    anchors.topMargin: -5
    spacing: 10
    width: 20


    Text  {   } // Blank
    Label { verticalAlignment: Text.AlignVCenter; font.family: "Bravura Text"; text: "\u266D";   font.bold: true; } // flat
    Label { verticalAlignment: Text.AlignVCenter; font.family: "Bravura Text"; text: "\u266E";   font.bold: true; }   // natural
    Label { verticalAlignment: Text.AlignVCenter; font.family: "Bravura Text"; text: "\u266F";   font.bold: true; } // sharp
  }

  ColumnLayout {
      // Left: column of note names
      // Right: radio buttons in flat/nat/sharp positions
      id: radioVals
      anchors.left: pedalPositions.right
      RowLayout {
        spacing: 41
        Text  { text:  "D"; font.bold: true }
        Text  { text:  "C"; font.bold: true }
        Text  { text:  "B"; font.bold: true }
        Text  { text:  "E"; font.bold: true }
        Text  { text:  "F"; font.bold: true }
        Text  { text:  "G"; font.bold: true }
        Text  { text:  "A"; font.bold: true }
      }
      RowLayout {
        id: flatRow
        spacing: 20
        property list<RadioButton> buttonList: [
          RadioButton { parent: flatRow; exclusiveGroup: colA },
          RadioButton { parent: flatRow; exclusiveGroup: colG },
          RadioButton { parent: flatRow; exclusiveGroup: colF },
          RadioButton { parent: flatRow; exclusiveGroup: colE },
          RadioButton { parent: flatRow; exclusiveGroup: colD },
          RadioButton { parent: flatRow; exclusiveGroup: colC },
          RadioButton { parent: flatRow; exclusiveGroup: colB }
        ]
      }
      RowLayout {
        id: natRow
        spacing: 20
        property list<RadioButton> buttonList: [
          RadioButton { parent: natRow; exclusiveGroup: colA; checked: true },
          RadioButton { parent: natRow; exclusiveGroup: colG; checked: true },
          RadioButton { parent: natRow; exclusiveGroup: colF; checked: true },
          RadioButton { parent: natRow; exclusiveGroup: colE; checked: true },
          RadioButton { parent: natRow; exclusiveGroup: colD; checked: true },
          RadioButton { parent: natRow; exclusiveGroup: colC; checked: true },
          RadioButton { parent: natRow; exclusiveGroup: colB; checked: true }
        ]
      }
      RowLayout {
        id: sharpRow
        spacing: 20
        property list<RadioButton> buttonList: [
          RadioButton { parent: sharpRow; exclusiveGroup: colA },
          RadioButton { parent: sharpRow; exclusiveGroup: colG },
          RadioButton { parent: sharpRow; exclusiveGroup: colF },
          RadioButton { parent: sharpRow; exclusiveGroup: colE },
          RadioButton { parent: sharpRow; exclusiveGroup: colD },
          RadioButton { parent: sharpRow; exclusiveGroup: colC },
          RadioButton { parent: sharpRow; exclusiveGroup: colB }
        ]
      }

      // Every time a button is clicked, change the values
      ExclusiveGroup { id: colD; onCurrentChanged: { showVals(); }}
      ExclusiveGroup { id: colC; onCurrentChanged: { showVals(); }}
      ExclusiveGroup { id: colB; onCurrentChanged: { showVals(); }}
      ExclusiveGroup { id: colE; onCurrentChanged: { showVals(); }}
      ExclusiveGroup { id: colF; onCurrentChanged: { showVals(); }}
      ExclusiveGroup { id: colG; onCurrentChanged: { showVals(); }}
      ExclusiveGroup { id: colA; onCurrentChanged: { showVals(); }}
  }

  Rectangle {
    // Show the results
    id: diag
    anchors.topMargin: 10
    anchors.bottomMargin: 10
    anchors.leftMargin: 20
    anchors.left: pedalDialog.left
    anchors.top: pedalPositions.bottom
    border.width: 2
    border.color: "black"
    width: 330
    height: 90

    Text {
      property var symText;
      id: diagram;
      anchors.centerIn: parent
      font.family: "Bravura Text";
      // initial text is all naturals
      // corresponds to initial checked buttons
      text: "\uE681\uE681\uE681\uE683\uE681\uE681\uE681\uE681";
      font.pointSize: 80
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
    }
  }

  Button {
    id: buttonCancel
    text: qsTr("Cancel")
    anchors.bottom: pedalDialog.bottom
    anchors.right: pedalDialog.right
    anchors.bottomMargin: 10
    anchors.rightMargin: 10
    width: 100
    height: 40
    onClicked: {
      Qt.quit();
    }
  }

  function addText () {
      if (curScore.selection.elements.length == 1 && isPedalDiagram(curScore.selection.elements[0])) {
        const element = curScore.selection.elements[0]
        element.text = diagram.text;
        element.fontFace = "Bravura Text";
      } else {
        var cursor = curScore.newCursor();
        cursor.rewind(1); // start of selection

        var myDiag = newElement( Element.STAFF_TEXT );

        myDiag.text =  diagram.text;
        myDiag.fontFace = "Bravura Text";
        myDiag.fontSize = 14;
        cursor.add(myDiag);
      }
      console.log(curScore)
  }

  Button {
    id: buttonOK
    text: qsTr("OK")
    width: 100
    height: 40
    anchors.bottom: pedalDialog.bottom
    anchors.right:  buttonCancel.left
    anchors.topMargin: 10
    anchors.bottomMargin: 10
    onClicked: {
      curScore.startCmd();
      addText();
      curScore.endCmd();
      Qt.quit();
    }
  }

}
