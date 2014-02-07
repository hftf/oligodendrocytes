<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- See first note at http://www.w3.org/TR/xslt#attribute-value-templates for why this can't be done -->
	<!-- <xsl:param name="indent">no</xsl:param> -->
	<xsl:output method="xml" indent="no" encoding="UTF-8" />
	<xsl:preserve-space elements="*" />
	<xsl:template match="html">
<!--
	The expected format of the HTML document is basically this, where every line is contained in a <p>,
	and empty lines are just <p><br /></p>.

		Tournament name and year: Subtitle (TODO)
		Packet by <Packet name>
		Questions/Edited by <Authors>

		Tossups

		1. Blah blah.
		ANSWER: Blah blah.

		Bonuses

		1. Blah blah.
		[10] Blah blah.
		ANSWER: Blah blah.
		[10] Blah blah.
		ANSWER: Blah blah.
		[10] Blah blah.
		ANSWER: Blah blah.

	Notice that the components of tossups and bonuses are determined by their position relative to the
	preceding <p><br /></p>.

	TODO: Wrap all substring-after() with if starts-with() 
-->
<qpdb version="0.2">
	<tournaments>
		<!-- TODO: Take this hardcoding out of the stylesheet -->
		<tournament
			id="1"
			name="SUBMIT"
			year="2014"
			date="February 1, 2014"
			location="University of Maryland"
			summary="SUBMIT 2014: “sometimes referred to as Groper[citation needed]”"
		>
			<subtitle>“sometimes referred to as Groper<sup><title>(citation needed)</title></sup>”</subtitle>
			<packets>
				<xsl:variable name="packet-name">
					<xsl:choose>
						<xsl:when test="contains(p[2], 'Editors')">
							<xsl:text>Editors </xsl:text><xsl:value-of select="substring-after(p[2], 'Packet ')" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="substring-after(p[2], 'by ')" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<packet
					name="{$packet-name}"
					authors="{substring-after(p[3], 'by ')}"
				>
					<tossups>
						<xsl:apply-templates select="p[text()='Tossups']" />
					</tossups>
					<boni>
						<xsl:apply-templates select="p[text()='Bonuses']" />
					</boni>
				</packet>
			</packets>
		</tournament>
	</tournaments>
</qpdb>
	</xsl:template>

	<xsl:template match="p[text()='Tossups']">
		<xsl:for-each select="following-sibling::p[(preceding-sibling::p[1])[br] and following-sibling::p[text()='Bonuses']]">
			<tossup id="{substring-before(text(), '.')}">
				<question>
					<xsl:call-template name="strip-number">
						<xsl:with-param name="p" select="." />
					</xsl:call-template>
				</question>
				<answer>
					<xsl:call-template name="strip-answer">
						<xsl:with-param name="p" select="following-sibling::p[1]" />
					</xsl:call-template>
				</answer>
			</tossup>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="p[text()='Bonuses']">
		<xsl:for-each select="following-sibling::p[(preceding-sibling::p[1])[br]]">
			<bonus id="{substring-before(text(), '.')}">
				<xsl:variable name="cur" select="generate-id(preceding::br[1])" />
				<stem>
					<xsl:call-template name="strip-number">
						<xsl:with-param name="p" select="." />
					</xsl:call-template>
				</stem>
				<xsl:for-each select="following-sibling::p[generate-id(preceding::br[1]) = $cur and starts-with(text(), '[10]')]">
					<part value="10">
						<question>
							<xsl:variable name="temp">
								<xsl:apply-templates select="text()[1]" />
							</xsl:variable>
							<xsl:value-of select="substring-after($temp, '[10] ')" />

							<xsl:apply-templates select="*|text()[not(position()=1)]" />
						</question>
						<answer>
							<xsl:call-template name="strip-answer">
								<xsl:with-param name="p" select="following-sibling::p[1]" />
							</xsl:call-template>
						</answer>
					</part>
				</xsl:for-each>
			</bonus>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="strip-number">
		<xsl:param name="p" />

		<xsl:variable name="temp">
			<xsl:apply-templates select="$p/text()[1]" />
		</xsl:variable>
		<xsl:value-of select="substring-after($temp, '. ')" />

		<xsl:apply-templates select="$p/*|$p/text()[not(position()=1)]" />
	</xsl:template>
	<xsl:template name="strip-answer">
		<xsl:param name="p" />

		<xsl:variable name="temp">
			<xsl:apply-templates select="$p/text()[1]" />
		</xsl:variable>
		<!--
			Sometimes a typo like "ANWER: " or "ANSWER " will cause substring-after to fail, but you may be
			lucky enough that the actual answer starts with a tag (instead of more text) that it cancels out.
		-->
		<xsl:value-of select="substring-after($temp, 'ANSWER: ')" />

		<xsl:apply-templates select="$p/*|$p/text()[not(position()=1)]" />

		<!--
			When using <xsl:output indent="yes" />, elements containing mixed content (both children
			and non-whitespace child text nodes) are not indented, which is the behavior we want. Otherwise,
			they are indented, introducing whitespace that interferes with LaTeX (and possibly other things
			that may use the resulting QBML).

			(This could probably be limited to non-mixed content answers easily, but this works fine because
			answers usually end paragraphs. We don't need this for questions because they always have text nodes.)
		-->
		<!-- <xsl:text> </xsl:text> -->
	</xsl:template>

	<xsl:template match="p">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="strong"><req><xsl:apply-templates /></req></xsl:template>
	<xsl:template match="em"><title><xsl:apply-templates /></title></xsl:template>
	<xsl:template match="sup"><sup><xsl:apply-templates /></sup></xsl:template>
	<xsl:template match="sub"><sub><xsl:apply-templates /></sub></xsl:template>
</xsl:stylesheet>
