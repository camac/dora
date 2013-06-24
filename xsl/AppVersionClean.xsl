<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xp="http://www.ibm.com/xsp/core">

  <xsl:output indent="yes"/>
  <xsl:strip-space elements="*"/>

	<!-- Remove the Version and Branch from the version custom control --> 
	<xsl:template match="//xp:text[@id='sourceVersion']/@value"/>
	<xsl:template match="//xp:text[@id='sourceBranch']/@value"/>
	
  <xsl:template match="node() | @*" name="identity">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template> 

</xsl:stylesheet>
