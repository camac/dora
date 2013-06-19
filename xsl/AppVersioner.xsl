<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xp="http://www.ibm.com/xsp/core">
	<xsl:param name="appVersion" select="'unknown'"/>
	<xsl:param name="currBranch" select="'unknown'"/>
  <xsl:output indent="yes"/>
  <xsl:strip-space elements="*"/>

	<xsl:template match="//xp:text[@id='doraVersion']">
		<xsl:copy>
			<xsl:attribute name="value">
				<xsl:value-of select="$appVersion"/>
			</xsl:attribute>
			<xsl:apply-templates select="node() | @*"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="//xp:text[@id='doraBranch']">
		<xsl:copy>
			<xsl:attribute name="value">
				<xsl:value-of select="$currBranch"/>
			</xsl:attribute>
			<xsl:apply-templates select="node() | @*"/>
		</xsl:copy>
	</xsl:template>

  <xsl:template match="node() | @*" name="identity">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template> 

</xsl:stylesheet>
