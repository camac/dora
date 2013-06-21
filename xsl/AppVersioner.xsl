<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xp="http://www.ibm.com/xsp/core">

	<!-- Parameters to supply the actual Version and branch -->
	<xsl:param name="sourceVersion" select="'unknown'"/>
	<xsl:param name="sourceBranch"  select="'unknown'"/>

  <xsl:output indent="yes"/>
  <xsl:strip-space elements="*"/>


	<!-- Until my xpath/xslt skills get better, i need two sets of templates! -->

	<!-- This Set covers the case where the attribute is not there yet -->

	<xsl:template match="//xp:text[@id='sourceVersion']">
		<xsl:copy>
			<xsl:attribute name="value">
				<xsl:value-of select="$sourceVersion"/>
			</xsl:attribute>
			<xsl:apply-templates select="node() | @*"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="//xp:text[@id='sourceBranch']">
		<xsl:copy>
			<xsl:attribute name="value">
				<xsl:value-of select="$sourceBranch"/>
			</xsl:attribute>
			<xsl:apply-templates select="node() | @*"/>
		</xsl:copy>
	</xsl:template>


	<!-- this set covers the case where the attributes are there and need replacing -->

	<xsl:template match="//xp:text[@id='sourceVersion']/@value">
			<xsl:attribute name="value">
				<xsl:value-of select="$sourceVersion"/>
			</xsl:attribute>
	</xsl:template>

	<xsl:template match="//xp:text[@id='sourceBranch']/@value">
			<xsl:attribute name="value">
				<xsl:value-of select="$sourceBranch"/>
			</xsl:attribute>
	</xsl:template>

	
	<!-- identity template -->

  <xsl:template match="node() | @*" name="identity">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template> 

</xsl:stylesheet>
