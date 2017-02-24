<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
<xsl:strip-space elements="*"/>

<!-- identity transform -->
<xsl:template match="@*|node()">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
</xsl:template>

<xsl:template match="text()[ancestor::mixed]">
    <xsl:analyze-string select="." regex="\s+">
        <xsl:matching-substring>
            <xsl:value-of select="." />
        </xsl:matching-substring>
        <xsl:non-matching-substring>
            <w>
                <xsl:value-of select="." />
            </w>
        </xsl:non-matching-substring>
    </xsl:analyze-string>
</xsl:template>

</xsl:stylesheet>
