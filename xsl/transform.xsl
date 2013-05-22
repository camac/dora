<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:n="http://www.lotus.com/dxl">

    <xsl:template match="n:noteinfo|n:updatedby|n:wassignedby"/>
    <xsl:template match="//n:note/@replicaid"/>
    <xsl:template match="//n:note/@version"/>
  

    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template> 
    
</xsl:stylesheet>

