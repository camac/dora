<?xml version="1.0" encoding="UTF-8"?>
<!--

Copyright 2013 Cameron Gregor
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License

-->
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
