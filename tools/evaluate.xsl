<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml"/>
    <xsl:strip-space elements="*"/>
	<!-- &lt;xsl:preserve-space elements="" /&gt; -->
    <xsl:namespace-alias stylesheet-prefix="#default" result-prefix="#default"/>
    <xsl:template match="item">
        <div>
            <xsl:attribute name="id">
                <xsl:text>item_</xsl:text>
                <xsl:value-of select="@id"/>
            </xsl:attribute>
            <div>
                <xsl:attribute name="id">
                    <xsl:text>title_</xsl:text>
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
                <h2/>
            </div>
            <div>
                <xsl:attribute name="id">
                    <xsl:text>question_</xsl:text>
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
                <xsl:apply-templates select="question"/>
            </div>
            <div>
                <xsl:attribute name="id">
                    <xsl:text>response_</xsl:text>
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
                <xsl:apply-templates select="response"/>
            </div>
            <div>
                <xsl:attribute name="id">
                    <xsl:text>explanation_</xsl:text>
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
                <xsl:apply-templates select="explanation"/>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="question">
        <p>
            <xsl:copy-of select="./node()"/>
        </p>
    </xsl:template>
   <xsl:template match="response">
        <li>
            <xsl:copy-of select="./node()"/>
        </li>
    </xsl:template>
    <xsl:template match="explanation">
        <xsl:text>解説：</xsl:text>
        <xsl:copy-of select="./node()"/>
    </xsl:template>
</xsl:stylesheet>