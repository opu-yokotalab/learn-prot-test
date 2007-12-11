<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="#default" version="1.0">
    <xsl:output method="xml" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" indent="yes"/>
    <xsl:strip-space elements="*"/>
	<!-- &lt;xsl:preserve-space elements="" /&gt; -->
    <xsl:namespace-alias stylesheet-prefix="#default" result-prefix="#default"/>

	<!-- 解答欄用属性のセット -->
    <xsl:attribute-set name="responseLists">
        <xsl:attribute name="type">
            <xsl:value-of select="../@type"/>
			<!-- &lt;xsl:text&gt;radio&lt;/xsl:text&gt; -->
        </xsl:attribute>
        <xsl:attribute name="name">
            <xsl:value-of select="../@id"/>
        </xsl:attribute>
        <xsl:attribute name="value">
            <xsl:value-of select="@id"/>
        </xsl:attribute>
        <xsl:attribute name="id">
            <xsl:value-of select="../@id"/>
            <xsl:text>_</xsl:text>
            <xsl:value-of select="@id"/>
        </xsl:attribute>
        <xsl:attribute name="onClick">
            <xsl:text>javascript:pre_evaluate(this);</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="ques_pkey">
            <xsl:value-of select="../@ques_pkey"/>
        </xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="submitAnswer">
        <xsl:attribute name="type">
            <xsl:text>button</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="name">
            <xsl:value-of select="@id"/>
        </xsl:attribute>
        <xsl:attribute name="value">
            <xsl:text>解答</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="onClick">
            <xsl:text>javascript:set_evaluate(this); return false</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="onKeypress">
            <xsl:text>javascript:set_evaluate(this); return false</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="ques_pkey">
            <xsl:value-of select="@ques_pkey"/>
        </xsl:attribute>
    </xsl:attribute-set>
    <xsl:template match="exam">
        <html xml:lang="ja" lang="ja">
            <head>
                <meta http-equiv="Content-Type" content="application/xhtml+xml; charset=UTF-8"/>
                <link href="test_m.css" type="text/css" rel="stylesheet"/>
                <title>■テスト機構プロトタイプ■</title>
                <script type="text/javascript" src="./func/evaluate.js">
                    <xsl:comment>hoge</xsl:comment>
                </script>
            </head>
            <body>
                <xsl:apply-templates select="item"/>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="item">
        <div>
            <xsl:attribute name="id">
                <xsl:text>item_</xsl:text>
                <xsl:value-of select="@id"/>
            </xsl:attribute>
            <form>
                <xsl:attribute name="name">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>

				<!-- &lt;xsl:attribute name="id"&gt;
					&lt;xsl:text&gt;title_&lt;/xsl:text&gt;&lt;xsl:value-of select="@id" /&gt;
				&lt;/xsl:attribute&gt; -->
                <h2>
                    <xsl:text>問</xsl:text>
                    <xsl:value-of select="position()"/>
                </h2>
				<!-- &lt;xsl:attribute name="id"&gt;
					&lt;xsl:text&gt;question_&lt;/xsl:text&gt;&lt;xsl:value-of select="@id" /&gt;
				&lt;/xsl:attribute&gt; -->
                <xsl:apply-templates select="question"/>
				<!-- &lt;xsl:attribute name="id"&gt;
					&lt;xsl:text&gt;response_&lt;/xsl:text&gt;&lt;xsl:value-of select="@id" /&gt;
				&lt;/xsl:attribute&gt; -->
                <ul>
                    <xsl:apply-templates select="response"/>
                </ul>
				<!-- &lt;xsl:attribute name="id"&gt;
					&lt;xsl:text&gt;submit_&lt;/xsl:text&gt;&lt;xsl:value-of select="@id" /&gt;
				&lt;/xsl:attribute&gt; -->
                <p>
                    <input xsl:use-attribute-sets="submitAnswer"/>
                </p>
				<!-- &lt;xsl:attribute name="id"&gt;
					&lt;xsl:text&gt;hints_&lt;/xsl:text&gt;&lt;xsl:value-of select="@id" /&gt;
				&lt;/xsl:attribute&gt; -->
                <xsl:apply-templates select="hints"/>
				<!-- &lt;xsl:attribute name="id"&gt;
					&lt;xsl:text&gt;explanation_&lt;/xsl:text&gt;&lt;xsl:value-of select="@id" /&gt;
				&lt;/xsl:attribute&gt; -->
                <xsl:apply-templates select="explanation"/>
            </form>
        </div>
    </xsl:template>
    <xsl:template match="question">
        <p>
            <xsl:copy-of select="./node()"/>
        </p>
    </xsl:template>
    <xsl:template match="response">
        <li>
            <input xsl:use-attribute-sets="responseLists"/>
            <label>
                <xsl:attribute name="for">
                    <xsl:value-of select="../@id"/>
                    <xsl:text>_</xsl:text>
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
                <xsl:copy-of select="./node()"/>
            </label>
        </li>
    </xsl:template>
    <xsl:template match="hints">
		<!-- &lt;xsl:text&gt;ヒント：&lt;/xsl:text&gt;&lt;xsl:copy-of select="./node()" /&gt; -->
    </xsl:template>
    <xsl:template match="explanation">
		<!-- &lt;xsl:text&gt;解説：&lt;/xsl:text&gt;&lt;xsl:copy-of select="./node()" /&gt; -->
    </xsl:template>
</xsl:stylesheet>