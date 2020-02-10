<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html"/>
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="head">
        <xsl:copy select=".">
            <base>
                <xsl:attribute name="href">
                    <xsl:value-of select="document('config.xml')//domain/text()"/>
                </xsl:attribute>
            </base>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
