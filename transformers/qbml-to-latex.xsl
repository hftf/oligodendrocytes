<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" encoding="UTF-8" />
	<xsl:preserve-space elements="*" />
	
<xsl:template match="qpdb">% !TEX TS-program = XeLaTeX
\documentclass[10pt]{packet}

\input{\jobname.edges}

\begin{document}
<xsl:apply-templates select="tournaments" />
\end{document}
</xsl:template>

<xsl:template match="tournaments"><xsl:apply-templates select="tournament" /></xsl:template>

<xsl:template match="tournament">
	\renewcommand{\tournamentname}{<xsl:value-of select="@name" />}
	\renewcommand{\tournamentyear}{<xsl:value-of select="@year" />}
%	\renewcommand{\subtitle}{<xsl:value-of select="@subtitle" />}
<!-- TODO remove hardcoded subtitle -->
	\renewcommand{\subtitle}{“sometimes referred to as Groper\textsuperscript{\textit{(citation needed)}}”}

	<xsl:apply-templates select="packets" />
</xsl:template>

<xsl:template match="packets"><xsl:apply-templates select="packet" /></xsl:template>

<xsl:template match="packet">
	<!-- \renewcommand{\packet}{<xsl:value-of select="round/@type" />} -->
	\newcommand{\packetname}{<xsl:value-of select="@name" />}
	\newcommand{\authors}{<xsl:value-of select="@authors" />}

	\maketitle

	<xsl:apply-templates select="tossups" />

	\clearpage

	<xsl:apply-templates select="boni" />
</xsl:template>

<xsl:template match="tossups">
	\subsection*{Tossups}
	<xsl:apply-templates select="tossup" />
</xsl:template>

<xsl:template match="tossup">
	\begin{question}%
		<xsl:apply-templates select="question" />\\
		<xsl:apply-templates select="answer" /><!--  <xsl:call-template name="author" /> -->
	\end{question}
	
</xsl:template>

<xsl:template match="boni">
	\subsection*{Bonuses}
	\begin{enumerate}[leftmargin=0pt]
	<xsl:apply-templates select="bonus" />
	\end{enumerate}
</xsl:template>

<xsl:template match="bonus">
	\item\hyperdef{bonus}{\arabic{enumi}}{}
	\begin{minipage}[t]{\linewidth}
		<xsl:apply-templates select="stem" />
		<xsl:apply-templates select="part" />
	\end{minipage}

</xsl:template>

<xsl:template match="part">\\[1mm]
		\partvalue{<xsl:value-of select="@value" />} <xsl:apply-templates select="question" />\\
		<xsl:apply-templates select="answer" /><!-- <xsl:if test="position()=last()"> <xsl:call-template name="author2" /></xsl:if> -->
</xsl:template>

<xsl:template match="question">
	<xsl:apply-templates />
	<!-- <xsl:if test="@time-limit"><em class="time-limit"> You have <xsl:value-of select="@time-limit" /> seconds.</em></xsl:if> -->
</xsl:template>

	<xsl:template match="power"><span class="power"><xsl:apply-templates /><xsl:text> (*) </xsl:text></span></xsl:template>
	<xsl:template match="intro"><xsl:apply-templates /><xsl:text> </xsl:text></xsl:template>
	<xsl:template match="answer">\answer{<xsl:apply-templates />}</xsl:template>
	<xsl:template match="req">\req{<xsl:apply-templates />}{}</xsl:template>
	<xsl:template match="question/req">\power{<xsl:apply-templates />}{}</xsl:template>
	<xsl:template match="title">\textit{<xsl:apply-templates />}{}</xsl:template>
	<xsl:template match="i"><i><xsl:apply-templates /></i></xsl:template>
	<xsl:template match="pronunciation"><xsl:value-of select="grapheme" /> [<span class="phoneme" title="Representation in {phoneme/@notation}"><xsl:value-of select="phoneme" /></span>]</xsl:template>
	<xsl:template match="note-to-mod">(<!--<em>Note to moderator:</em><xsl:text> </xsl:text>--><xsl:apply-templates />)</xsl:template>
	<xsl:template match="prompt-on"><em>Prompt on:</em><xsl:text> </xsl:text><xsl:apply-templates />.</xsl:template>
	<xsl:template match="also-accept"><em>Also accept:</em><xsl:text> </xsl:text><xsl:apply-templates />.</xsl:template>
	<xsl:template match="do-not-accept"><em>Do not accept:</em><xsl:text> </xsl:text><xsl:apply-templates />.</xsl:template>
	<xsl:template name ="author">[<abbr title="{/qpdb/authors/author[@id=current()/@author-id]/name}"   ><xsl:value-of select="/qpdb/authors/author[@id=current()/@author-id]/initials"   /></abbr>]</xsl:template>
	<xsl:template name="author2">[<abbr title="{/qpdb/authors/author[@id=current()/../@author-id]/name}"><xsl:value-of select="/qpdb/authors/author[@id=current()/../@author-id]/initials" /></abbr>]</xsl:template>

	<xsl:template match="lining">{\lf <xsl:apply-templates />}</xsl:template>
	<xsl:template match="sup">\textsuperscript{<xsl:apply-templates />}</xsl:template>
	<xsl:template match="sub">\textsubscript{<xsl:apply-templates />}</xsl:template>
	<xsl:template match="sc">\textsc{<xsl:apply-templates />}</xsl:template>

<!--Tournament:    <p><xsl:choose><xsl:when test="@url"><a href="{@url}" target="_blank"><xsl:value-of select="@summary" /></a></xsl:when><xsl:otherwise><xsl:value-of select="@summary" /></xsl:otherwise></xsl:choose>: <xsl:value-of select="@location" />, <xsl:value-of select="@date" /></p>-->
<!--Packet round:  <xsl:value-of select="/qpdb/tournaments/tournament[@id=//@tournament-id]/@summary" /><xsl:text> </xsl:text>-->
<!--Tossup-info:   , <xsl:value-of select="/qpdb/tournaments/tournament[@id=//@tournament-id]/@summary" />-->
<!--Bonus:         <xsl:choose><xsl:when test="count(part)>1"><ol class="part">...</ol></xsl:when></xsl:choose>-->
</xsl:stylesheet>