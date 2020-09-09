<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- The indent for child nodes -->
<xsl:variable name="indent">15</xsl:variable>

<!-- The indent for attributes -->
<xsl:variable name="AttributeIndent">12</xsl:variable>

<!-- The font and font size to be used. -->
<xsl:variable name="FontFamily">Malgun Gothic</xsl:variable>
<xsl:variable name="FontFamily_FixWidth">Malgun Gothic</xsl:variable>
<xsl:variable name="FontSize">11</xsl:variable>
<xsl:variable name="FontStyle">font-family: 'Malgun Gothic';</xsl:variable>

<!-- Vertical align style of table items. -->
<xsl:variable name="VerticalAlignStyle">vertical-align: top;</xsl:variable>

<!-- The width for + and - sign column -->
<xsl:variable name="SignColumnWidth">15</xsl:variable>

<!-- The element name column width -->
<xsl:variable name="ElementNameColumnWidth">130</xsl:variable>

<!-- The attribute name column width -->
<xsl:variable name="AttributeNameColumnWidth">105</xsl:variable>

<!-- _locID_text="WordsFormat" -->
<xsl:variable name="WordsFormat">단어 단위</xsl:variable>

<!-- _locID_text="BytesFormat" -->
<xsl:variable name="BytesFormat">바이트 단위</xsl:variable>

<xsl:template match="/*">   <!-- Match /Event, regardless of namespace -->

<html>
<head>
  <meta http-equiv="Content-Script-Type" content="text/javascript"/>
  <script>
  <![CDATA[
    function Toggle(node)
    {
      if (!window.fullyLoaded) return;

      // Expand the branch?
      if (node.nextSibling.style.display == 'none')
      {
        // Change the sign from "+" to "-".
        var tBodyNode = node.childNodes[0];
        var trNode = tBodyNode.childNodes[0];
        var tdNode = trNode.childNodes[0];
        var bNode = tdNode.childNodes[0];
        var textNode = bNode.childNodes[0];
        if (textNode.nodeType == 3 /* Node.TEXT_NODE */) {
          var s = textNode.data;
          if (s.length > 0 && s.charAt(0) == '+') {
            textNode.data = '-' + s.substring(1, s.length);
          }
        }

        // show the branch
        node.nextSibling.style.display = '';
      }
      else // Collapse the branch
      {
        // Change the sign from "-" to "+".
        var tBodyNode = node.childNodes[0];
        var trNode = tBodyNode.childNodes[0];
        var tdNode = trNode.childNodes[0];
        var bNode = tdNode.childNodes[0];
        var textNode = bNode.childNodes[0];
        if (textNode.nodeType == 3 /* Node.TEXT_NODE */) {
          var s = textNode.data;
          if (s.length > 0 && s.charAt(0) == '-') {
            textNode.data = '+' + s.substring(1, s.length);
          }
        }

        // hide the branch
        node.nextSibling.style.display = 'none';
      }
    }

    // Toggle "System" element by default so that it's default status is to hide its children
    function ToggleSystemElement()
    {
      var body = document.getElementById("body");
      var anchor = body.getElementsByTagName("table")[0];
      Toggle(anchor);
    }

    // If binary data is present in event XML, show it in friendly form.
    function ProcessBinaryData(binaryString, binaryDataCaption, wordsFormatString, bytesFormatString, normalFont, fixedWidthFont)
    {
      var bodyNode = document.getElementById("body");

      // Add a <hr> at the end of the HTML body.
      bodyNode.appendChild(document.createElement("hr"));      

      // This paragraph (p element) is the "Binary data:" literal string.
      var p = document.createElement("p");
      p.style.fontFamily = normalFont;
      var b = document.createElement("b");
      b.appendChild(document.createTextNode(binaryDataCaption));
      p.appendChild(b);
      p.appendChild(document.createElement("br"));
      bodyNode.appendChild(p);

      //
      // Show binary data in Words format.
      //
      p = document.createElement("p");
      p.style.fontFamily = normalFont;
      p.appendChild(document.createTextNode(wordsFormatString));
      bodyNode.appendChild(p);

      // Must use fixed-width font for binary data.
      p = document.createElement("p");
      p.style.fontFamily = fixedWidthFont;
    
      var i = 0;
      var j = 0;
      var s, tempS;
      var translatedString;
      var charCode;
      var byte1, byte2;

      // Each character in binaryString is a hex (16-based) representation of
      // 4 binary bits. So it takes 2 characters in binaryString to form a
      // complete byte; 4 characters for a word.
      while (i < binaryString.length) {

        s = (i / 2).toString(16);    // To hex representation.
        while (s.length < 4) {
          s = "0" + s;
        }
        s += ": ";

        // DWords representation is simply a rearrangement of the original binaryString
        // For example, from:
        // 
        // 0000000002005600000000000f000540
        //
        // (which is 00 00 00 00 02 00 56 00 00 00 00 00 0f 00 05 40).
        //
        // to:
        //
        // 0000: 00000000 00560002 00000000 4005000f
        // 8 words per line, 4 DWords per line.
        for (j = 0; j < 4; j++) {
          s += binaryString.substring(i + 6, i + 8);
          s += binaryString.substring(i + 4, i + 6);
          s += binaryString.substring(i + 2, i + 4);
          s += binaryString.substring(i, i + 2) + " ";
          i += 8;
        }

        p.appendChild(document.createTextNode(s));
        p.appendChild(document.createElement("br"));
      }

      bodyNode.appendChild(p);

      //
      // Show binary data in bytes format.
      //
      p = document.createElement("p");
      p.style.fontFamily = normalFont;
      p.appendChild(document.createTextNode(bytesFormatString));
      bodyNode.appendChild(p);

      // Must use fixed-width font for binary data.
      p = document.createElement("p");
      p.style.fontFamily = fixedWidthFont;
    
      i = 0;
      j = 0;

      // Each character in binaryString is a hex (16-based) representation of
      // 4 binary bits. So it takes 2 characters in binaryString to form a
      // complete byte.
      while (i < binaryString.length) {
        translatedString = "";
        // 2 characters in binaryString to form a byte
        s = (i / 2).toString(16);   // to hex representation.

        // Prefix with '0' until its length is 4.
        while (s.length < 4) {
          s = "0" + s;
        }
        s += ": ";

        // Show 8 bytes per line
        for (j = 0; j < 8; j++) {
          tempS = binaryString.substring(i, i + 2); // 2 for 1 byte
          i += 2;
          s += tempS + " ";

          // Treat tempS as hex integer
          charCode = parseInt(tempS, 16);
          if (charCode < 32) {
            translatedString += ".";
          } else {
            translatedString += String.fromCharCode(charCode);
          }
        }

        while (s.length < 32) {
          s += " ";
        }
        s += translatedString;
        
        p.appendChild(document.createTextNode(s));
        p.appendChild(document.createElement("br"));
      }

      bodyNode.appendChild(p);
    }
  ]]>
  </script>
</head>

<!-- Test whether there is binary data -->
<xsl:choose>
<xsl:when test="descendant::*[contains(local-name(), 'Binary')]">
  <!-- _locID_text="BinaryDataCaption" _locComment="Caption for Binary Data" -->
  <xsl:variable name="BinaryDataCaption">이진 데이터:</xsl:variable>
  <xsl:variable name="BinaryData"><xsl:value-of select="descendant::*[contains(local-name(), 'Binary')]"/></xsl:variable>
  <body id="body" onload="window.fullyLoaded='true'; ToggleSystemElement(); ProcessBinaryData('{$BinaryData}', '{$BinaryDataCaption}', '{$WordsFormat}', '{$BytesFormat}', '{$FontFamily}', '{$FontFamily_FixWidth}')">
    <xsl:for-each select="node()">
      <!-- Treat EventData specially -->
      <xsl:choose>
        <xsl:when test="name()='EventData'">
          <xsl:call-template name="EventDataNode"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="node"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </body>
</xsl:when>
<xsl:otherwise>  <!-- No binary data -->
  <body id="body" onload="window.fullyLoaded=true;ToggleSystemElement();">
    <xsl:for-each select="node()">
      <!-- Treat EventData specially -->
      <xsl:choose>
        <xsl:when test="name()='EventData'">
          <xsl:call-template name="EventDataNode"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="node"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </body>
</xsl:otherwise>
</xsl:choose>

</html>
</xsl:template>

<xsl:template name="node">

<!-- Is this a "pure" text node like the "inner text" inside "<node>inner text</node>"? -->
<xsl:choose>
<xsl:when test="count(node())=0 and string-length(.) and not(name())">
<table border="0" cellspacing="0">
  <tr>
    <td width="{$SignColumnWidth}" nowrap="true"></td>
    <td style="{$FontStyle} {$VerticalAlignStyle}">
      <xsl:value-of select="."/>
    </td>
  </tr>
</table>
</xsl:when>
<xsl:otherwise>
<!-- Not a pure text node-->

<xsl:choose>
  <!-- Does this node contains attributes? -->
  <xsl:when test="count(./@*)">
    <!-- Yes, contains attributes, we need to make it collapsable -->

    <xsl:choose>

      <!-- Does this node contains only text like "<node>inner text</node>"? -->
      <xsl:when test="count(node())=1 and text()">
        <!-- Yes, only inner text -->
        <table onClick="Toggle(this)" style="cursor: hand;">
          <tr>
            <td style="{$FontStyle} {$VerticalAlignStyle}" width="{$SignColumnWidth}" nowrap="true">
              <b>-</b>
            </td>
            <xsl:text>	</xsl:text>
            <td style="{$FontStyle} {$VerticalAlignStyle}" width="{$ElementNameColumnWidth}" nowrap="true">
              <b>
                <xsl:value-of xmlns:xsl="http://www.w3.org/1999/XSL/Transform" select="name()"/>
              </b>
            </td>
            <td style="{$FontStyle} {$VerticalAlignStyle}">
              <xsl:value-of select="text()"/>
            </td>
          </tr>
        </table>
        <div>
          <!-- This div will be hided upon handling the above "onclick" event -->
          <xsl:for-each select="./@*">
            <table border="0" cellspacing="0">
              <tr>
                <td width="{$SignColumnWidth}" nowrap="true"></td>
                <td width="{$SignColumnWidth}" nowrap="true"></td>
                <!-- We do need 2 sign widths for nice formatting -->
                <td width="{$AttributeIndent}" nowrap="true"></td>
                <td style="{$FontStyle} {$VerticalAlignStyle}" width="{$AttributeNameColumnWidth}" nowrap="true">
                  [ <b>
                    <xsl:value-of xmlns:xsl="http://www.w3.org/1999/XSL/Transform" select="name()"/>
                  </b>]
                </td>
                <td style="{$FontStyle} {$VerticalAlignStyle}">
                  <xsl:value-of select="."/>
                </td>
              </tr>
            </table>
          </xsl:for-each>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <!-- Not "only inner text -->
        <table onClick="Toggle(this)" style="cursor: hand;">
          <tr>
            <td style="{$FontStyle} {$VerticalAlignStyle}" width="{$SignColumnWidth}" nowrap="true">
              <b>-</b>
            </td>
            <xsl:text>	</xsl:text>
            <td style="{$FontStyle} {$VerticalAlignStyle}" width="{$ElementNameColumnWidth}" nowrap="true">
              <b>
                <xsl:value-of xmlns:xsl="http://www.w3.org/1999/XSL/Transform" select="name()"/>
              </b>
            </td>
          </tr>
        </table>
        <div>
          <!-- Deal with attributes -->
          <xsl:for-each select="./@*">
            <table border="0" cellspacing="0">
              <tr>
                <td width="{$SignColumnWidth}" nowrap="true"></td>
                <td width="{$SignColumnWidth}" nowrap="true"></td>
                <!-- We do need 2 sign widths for nice formatting -->
                <td width="{$AttributeIndent}" nowrap="true"></td>
                <td style="{$FontStyle} {$VerticalAlignStyle}" width="{$AttributeNameColumnWidth}" nowrap="true">
                  [ <b>
                    <xsl:value-of xmlns:xsl="http://www.w3.org/1999/XSL/Transform" select="name()"/>
                  </b>]
                </td>
                <td style="{$FontStyle} {$VerticalAlignStyle}">
                  <xsl:value-of select="."/>
                </td>
              </tr>
            </table>
          </xsl:for-each>

          <!-- Deal with sub-nodes -->
          <xsl:for-each select="node()">
            <table border="0" cellspacing="0">
              <tr>
                <td width="{$SignColumnWidth}" nowrap="true"></td>
                <td width="{$indent}" nowrap="true"></td>
                <td style="{$FontStyle} {$VerticalAlignStyle}">
                  <xsl:call-template name="node"/>
                </td>
              </tr>
            </table>
          </xsl:for-each>
        </div>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:when>
  <xsl:otherwise>
    <!-- Contains no attributes. Whether to be collapsable depends on whether it has children. -->
    <!-- Does this node contains only text like "<node>inner text</node>"? -->
    <xsl:choose>
      <xsl:when test="count(node())=1 and text()">
        <!-- Only has inner text -->
        <table>
          <tr>
            <td style="{$FontStyle} {$VerticalAlignStyle}" width="{$SignColumnWidth}" nowrap="true"></td>
            <td style="{$FontStyle} {$VerticalAlignStyle}" width="{$ElementNameColumnWidth}" nowrap="true">
              <b>
                <xsl:value-of xmlns:xsl="http://www.w3.org/1999/XSL/Transform" select="name()"/>
              </b>
            </td>
            <td style="{$FontStyle} {$VerticalAlignStyle}">
              <xsl:value-of select="text()"/>
            </td>
          </tr>
        </table>
      </xsl:when>
      <xsl:otherwise>
        <!-- Not "only inner text" -->

        <!-- Does this node have children? -->
        <xsl:choose>
          <xsl:when test="count(node())">
            <table onClick="Toggle(this)" style="cursor: hand;">
              <tr>
                <td style="{$FontStyle} {$VerticalAlignStyle}" width="{$SignColumnWidth}" nowrap="true">
                  <b>-</b>
                </td>
                <xsl:text>	</xsl:text>
                <td style="{$FontStyle} {$VerticalAlignStyle}" width="{$ElementNameColumnWidth}" nowrap="true">
                  <b>
                    <xsl:value-of xmlns:xsl="http://www.w3.org/1999/XSL/Transform" select="name()"/>
                  </b>
                </td>
              </tr>
            </table>
            <div>
              <xsl:for-each select="node()">
                <table border="0" cellspacing="0">
                  <tr>
                    <td width="{$SignColumnWidth}" nowrap="true"></td>
                    <td width="{$indent}" nowrap="true"></td>
                    <td style="{$FontStyle} {$VerticalAlignStyle}">
                      <xsl:call-template name="node"/>
                    </td>
                  </tr>
                </table>
              </xsl:for-each>
            </div>
          </xsl:when>
          <xsl:otherwise>
            <!-- No children -->
            <table>
              <tr>
                <td style="{$FontStyle} {$VerticalAlignStyle}" width="{$SignColumnWidth}" nowrap="true"></td>
                <td style="{$FontStyle}">
                  <b>
                    <xsl:value-of xmlns:xsl="http://www.w3.org/1999/XSL/Transform" select="name()"/>
                  </b>
                </td>
              </tr>
            </table>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:otherwise>
</xsl:choose>

</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- Template for "EventData". This is used for "System\EventData" only. -->
<xsl:template name="EventDataNode">
  <!-- Does this node have children? -->
  <xsl:choose>
    <xsl:when test="count(node())">
      <table onClick="Toggle(this)" style="cursor: hand;">
        <tr>
          <td style="{$FontStyle} {$VerticalAlignStyle}" width="{$SignColumnWidth}" nowrap="true">
            <b>-</b>
          </td>
          <!-- &#&#x09; is tab -->
          <xsl:text>	</xsl:text>
          <td style="{$FontStyle} {$VerticalAlignStyle}" width="{$ElementNameColumnWidth}" nowrap="true">
            <b>
              <xsl:value-of xmlns:xsl="http://www.w3.org/1999/XSL/Transform" select="name()"/>
            </b>
          </td>
        </tr>
      </table>
      <div>
        <xsl:for-each select="node()">
          <table border="0" cellspacing="0">
            <tr>
              <td width="{$SignColumnWidth}" nowrap="true"></td>
              <td width="{$indent}" nowrap="true"></td>
              <td style="{$FontStyle} {$VerticalAlignStyle}" width="{$ElementNameColumnWidth}" nowrap="true">
                <b>
                  <xsl:value-of xmlns:xsl="http://www.w3.org/1999/XSL/Transform" select="./@Name"/>
                </b>
              </td>
              <td style="{$FontStyle} {$VerticalAlignStyle}">
                <xsl:value-of select="text()"/>
              </td>
            </tr>
          </table>
        </xsl:for-each>
      </div>
    </xsl:when>
    <xsl:otherwise>
      <!-- No children -->
      <table>
        <tr>
          <td style="{$FontStyle} {$VerticalAlignStyle}" width="{$SignColumnWidth}" nowrap="true"></td>
          <td style="{$FontStyle}">
            <b>
              <xsl:value-of xmlns:xsl="http://www.w3.org/1999/XSL/Transform" select="name()"/>
            </b>
          </td>
        </tr>
      </table>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>  

</xsl:stylesheet>
