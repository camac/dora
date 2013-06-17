<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:n="http://www.lotus.com/dxl">
  <xsl:output indent="yes"/>
  <xsl:strip-space elements="*"/>

    <!-- Maybe want to do $DesignerVersion on Java MetaData?? -->

    <xsl:template match="n:noteinfo|n:updatedby|n:wassignedby"/>
    <xsl:template match="//n:note/@replicaid"/>
    <xsl:template match="//n:note/@version"/>

    <!-- For the Form Non-Binary DXL -->
    <xsl:template match="//n:form/@replicaid"/>
    <xsl:template match="//n:form/@version"/>
    <xsl:template match="//n:form/@designerversion"/>

    <xsl:template match="//n:database/@replicaid"/>
    <xsl:template match="//n:database/@version"/>
    <xsl:template match="//n:database/@designerversion"/>

    <xsl:template match="//n:sharedactions/@replicaid"/>
    <xsl:template match="//n:sharedactions/@version"/>
    <xsl:template match="//n:sharedactions/@designerversion"/>

    <xsl:template match="//n:agent/@replicaid"/>
    <xsl:template match="//n:agent/@version"/>
    <xsl:template match="//n:agent/@designerversion"/>

    <xsl:template match="//n:scriptlibrary/@replicaid"/>
    <xsl:template match="//n:scriptlibrary/@version"/>
    <xsl:template match="//n:scriptlibrary/@designerversion"/>

    <xsl:template match="//n:databasescript/@replicaid"/>
    <xsl:template match="//n:databasescript/@version"/>
    <xsl:template match="//n:databasescript/@designerversion"/>

    <xsl:template match="//n:dataconnection/@replicaid"/>
    <xsl:template match="//n:dataconnection/@version"/>    
    <xsl:template match="//n:dataconnection/@designerversion"/>

    <xsl:template match="//n:folder/@replicaid"/>
    <xsl:template match="//n:folder/@version"/>
    <xsl:template match="//n:folder/@designerversion"/>

    <xsl:template match="//n:frameset/@replicaid"/>
    <xsl:template match="//n:frameset/@version"/>
    <xsl:template match="//n:frameset/@designerversion"/>

    <xsl:template match="//n:page/@replicaid"/>
    <xsl:template match="//n:page/@version"/>
    <xsl:template match="//n:page/@designerversion"/>

    <xsl:template match="//n:imageresource/@replicaid"/>
    <xsl:template match="//n:imageresource/@version"/>
    <xsl:template match="//n:imageresource/@designerversion"/>

    <xsl:template match="//n:helpaboutdocument/@replicaid"/>
    <xsl:template match="//n:helpaboutdocument/@version"/>
    <xsl:template match="//n:helpaboutdocument/@designerversion"/>

    <xsl:template match="//n:stylesheetresource/@replicaid"/>
    <xsl:template match="//n:stylesheetresource/@version"/>
    <xsl:template match="//n:stylesheetresource/@designerversion"/>

    <xsl:template match="//n:view/@replicaid"/>
    <xsl:template match="//n:view/@version"/>
    <xsl:template match="//n:view/@designerversion"/>

    <xsl:template match="//n:helpusingdocument/@replicaid"/>
    <xsl:template match="//n:helpusingdocument/@version"/>
    <xsl:template match="//n:helpusingdocument/@designerversion"/>

    <xsl:template match="//n:sharedcolumn/@replicaid"/>
    <xsl:template match="//n:sharedcolumn/@version"/>
    <xsl:template match="//n:sharedcolumn/@designerversion"/>

    <xsl:template match="//n:sharedfield/@replicaid"/>
    <xsl:template match="//n:sharedfield/@version"/>
    <xsl:template match="//n:sharedfield/@designerversion"/>

    <xsl:template match="//n:navigator/@replicaid"/>
    <xsl:template match="//n:navigator/@version"/>
    <xsl:template match="//n:navigator/@designerversion"/>

    <xsl:template match="//n:outline/@replicaid"/>
    <xsl:template match="//n:outline/@version"/>
    <xsl:template match="//n:outline/@designerversion"/>

    <xsl:template match="//n:subform/@replicaid"/>
    <xsl:template match="//n:subform/@version"/>
    <xsl:template match="//n:subform/@designerversion"/>

    <xsl:template match="//n:fileresource/@replicaid"/>
    <xsl:template match="//n:fileresource/@version"/>
    <xsl:template match="//n:fileresource/@designerversion"/>

    <!-- 
         For Agent Non-Binary DXL 
         For both LotusScript and Java agents

      
         For Java Agents You may also wish to look at some extra ones like javaproject->codepath or
         item->$JavaCompilerSource item->$JavaComplierTarget

    -->
    <xsl:template match="//n:agent/n:rundata"/>
    <xsl:template match="//n:agent/n:designchange"/>

    <xsl:template match="//n:javaproject/@codepath"/>

    <xsl:template match="//n:folder/@formatnoteid"/> <!-- not 100% but I don't like the sound of it! Not in the DTD in help anyway -->

    <xsl:template match="//n:imageresource/n:item[@name='$FileModDT']"/> <!-- not 100% sure but I don't like the sound of datetimes in there! double check -->

    <!-- 
        For the Database Properties Non-Binary DXL.
        It is probably a better idea just to ignore database.proprties and add it using 
        git add -f <filename>
        when needed 
    -->
    <xsl:template match="//n:database/@path"/>
    <xsl:template match="//n:database/n:databaseinfo/@dbid"/>
    <xsl:template match="//n:database/n:databaseinfo/@percentused"/>
    <xsl:template match="//n:database/n:databaseinfo/@numberofdocuments"/>
    <xsl:template match="//n:database/n:databaseinfo/@diskspace"/>
    <xsl:template match="//n:database/n:databaseinfo/@odsversion"/>

    <xsl:template match="//n:database/n:databaseinfo/n:datamodified"/>
    <xsl:template match="//n:database/n:databaseinfo/n:designmodified"/>

    <!-- Ignore the database ACL -->
    <xsl:template match="//n:database/n:acl"/>

    <!-- Ignore the DesignerVersion Item -->
    <xsl:template match="//n:item[@name='$DesignerVersion']"/>

    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template> 
    
</xsl:stylesheet>

