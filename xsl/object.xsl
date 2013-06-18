<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:n="http://www.lotus.com/dxl">

    <!-- 
         Remove any items that begin with $ and end with _O
         for example
         <item name="$yourfield_O" ....></item>

         These Items are Script Object items, they are not source code!
         you freshly check out a repo version of the design element, but at
         least you won't get merge conflicts all the time
         -->
     <xsl:template match="*">
       <xsl:if test="not(starts-with(@name,'$') and substring(@name,string-length(@name)-1,2) = '_O')">
        <xsl:call-template name="identity"/>
      </xsl:if>
    </xsl:template> 

   
</xsl:stylesheet>

