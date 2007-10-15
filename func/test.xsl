<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet
	exclude-result-prefixes="#default"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.w3.org/1999/xhtml"
	version="1.0"
>
	<xsl:output
		method="xml"
		encoding="UTF-8"
		doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
		indent="yes"
	/>

	<xsl:strip-space elements="*" />
	<!-- <xsl:preserve-space elements="" /> -->
	<xsl:namespace-alias stylesheet-prefix="#default" result-prefix="#default"/>

	<!-- 解答欄用属性のセット -->
	<xsl:attribute-set name="responseLists">
		<xsl:attribute name="type"><xsl:text>radio</xsl:text></xsl:attribute>
	 	<xsl:attribute name="name">
	 		<xsl:value-of select="../@id" />
	 	</xsl:attribute>
	 	<xsl:attribute name="value">
	 		<xsl:value-of select="@id" />
	 	</xsl:attribute>
	 	<xsl:attribute name="id">
			<xsl:value-of select="../@id" />
		 	<xsl:text>_</xsl:text>
		 	<xsl:value-of select="@id" />
	 	</xsl:attribute>
	 </xsl:attribute-set>

	<xsl:attribute-set name="submitAnswer">
		<xsl:attribute name="type"><xsl:text>button</xsl:text></xsl:attribute>
		<xsl:attribute name="name"><xsl:value-of select="@id" /></xsl:attribute>
		<xsl:attribute name="value"><xsl:text>解答</xsl:text></xsl:attribute>
		<xsl:attribute name="onClick"><xsl:text>evaluate()</xsl:text></xsl:attribute>
	</xsl:attribute-set>

	<xsl:template match="exam">
		<html xml:lang="ja" lang="ja">
			<head>
				<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=UTF-8" />
				<link href="test_m.css" type="text/css" rel="stylesheet" />
				<title>■テスト機構プロトタイプ■</title>
				<script type="text/javascript" src="evaluate.js"><xsl:comment>hoge</xsl:comment></script>
			</head>
		<body>
			<xsl:apply-templates select="item" />
		</body>
		</html>
	</xsl:template>

	<xsl:template match="item">
		<div>
			<xsl:attribute name="id">
				<xsl:text>item_</xsl:text><xsl:value-of select="@id" />
			</xsl:attribute>
			<div>
				<xsl:attribute name="id">
					<xsl:text>title_</xsl:text><xsl:value-of select="@id" />
				</xsl:attribute>
				<h2><xsl:text>問</xsl:text><xsl:value-of select="position()" /></h2>
			</div>
			<div>
				<xsl:attribute name="id">
					<xsl:text>question_</xsl:text><xsl:value-of select="@id" />
				</xsl:attribute>
				<xsl:apply-templates select="question" />
			</div>
			<div>
				<xsl:attribute name="id">
					<xsl:text>response_</xsl:text><xsl:value-of select="@id" />
				</xsl:attribute>
				<xsl:apply-templates select="response" />
			</div>
			<div>
				<xsl:attribute name="id">
					<xsl:text>submit_</xsl:text><xsl:value-of select="@id" />
				</xsl:attribute>
				<p>
					<input xsl:use-attribute-sets="submitAnswer" />
				</p>
			</div>
			<div>
				<xsl:attribute name="id">
					<xsl:text>hints_</xsl:text><xsl:value-of select="@id" />
				</xsl:attribute>
				<xsl:apply-templates select="hints" />
			</div>
			<div>
				<xsl:attribute name="id">
					<xsl:text>explanation_</xsl:text><xsl:value-of select="@id" />
				</xsl:attribute>
				<xsl:apply-templates select="explanation" />
			</div>
		</div>
	</xsl:template>

	<xsl:template match="prob">
		<p><xsl:copy-of select="./node()" /></p>
	</xsl:template>

	<xsl:template match="response">
		<li>
			<input xsl:use-attribute-sets="responseLists" />
			 <label>
			 	<xsl:attribute name="for">
			 		<xsl:value-of select="../@id" />
		 			<xsl:text>_</xsl:text>
		 			<xsl:value-of select="@id" />
			 	</xsl:attribute>
			 	<xsl:copy-of select="./node()" />
			 </label>
		</li>
	</xsl:template>

	<xsl:template match="hints">
		<xsl:text>ヒント：</xsl:text><xsl:copy-of select="./node()" />
	</xsl:template>

	<xsl:template match="explanation">
		<xsl:text>解説：</xsl:text><xsl:copy-of select="./node()" />
	</xsl:template>

</xsl:stylesheet>