<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

  <xsl:param name="html.stylesheet">styles.css</xsl:param>
  <xsl:param name="toc.section.depth">3</xsl:param>
  <xsl:param name="annotate.toc">0</xsl:param>

  <xsl:param name="generate.id.attributes" select="1"></xsl:param>
  <xsl:param name="header.rule" select="0"></xsl:param>
  <xsl:param name="footer.rule" select="0"></xsl:param>
  <xsl:param name="html.cleanup" select="1"></xsl:param>
  <xsl:param name="admon.style"><xsl:text></xsl:text></xsl:param>
  <xsl:param name="admon.graphics" select="1"></xsl:param>
  <xsl:param name="admon.graphics.path">figs/</xsl:param>

  <xsl:template match="sect1" mode="toc">
    <xsl:param name="toc-context" select="."/>
    <xsl:call-template name="subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes" 
        select="sect2|refentry|bridgehead[$bridgehead.in.toc != 0]"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="sect2" mode="toc">
    <xsl:param name="toc-context" select="."/>

    <xsl:call-template name="subtoc">
      <xsl:with-param name="toc-context" select="$toc-context"/>
      <xsl:with-param name="nodes" 
        select="sect3|refentry|bridgehead[$bridgehead.in.toc != 0]"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Add id attributes to <p> tags. This is mostly a copy of the
       base XSL. -->
  <xsl:template name="paragraph">
    <xsl:param name="class" select="''"/>
    <xsl:param name="content"/>

    <xsl:variable name="p">
      <p>
        <xsl:call-template name="dir"/>
        <xsl:if test="$class != ''">
          <xsl:apply-templates select="." mode="class.attribute">
            <xsl:with-param name="class" select="$class"/>
          </xsl:apply-templates>
        </xsl:if>
        <!-- Here we go. -->
        <xsl:if test="$generate.id.attributes != 0">
          <xsl:attribute name="id">
            <xsl:call-template name="object.id"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:copy-of select="$content"/>
      </p>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$html.cleanup != 0">
        <xsl:call-template name="unwrap.p">
          <xsl:with-param name="p" select="$p"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$p"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
