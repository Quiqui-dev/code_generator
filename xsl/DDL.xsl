<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xml:space="preserve">
    <xsl:output method="text"/>
<!-- ~/Saxon/saxon-he-11.3.jar ./xml/test.xml ./xsl/testSQL.xsl -o:./bin/testSQL.sql -->
<xsl:template match="table">
USE <xsl:value-of select="@db"/>;
DROP TABLE IF EXISTS <xsl:value-of select="@name"/>;

CREATE TABLE <xsl:value-of select="@name"/> (<xsl:for-each select="column">
    <xsl:value-of select="@name"/> <xsl:value-of select="dtype"/> <xsl:if test="key='PK'">PRIMARY KEY</xsl:if> <xsl:if test="null='n'"> NOT NULL</xsl:if><xsl:if test="position() != last()">,</xsl:if></xsl:for-each>
);

INSERT INTO <xsl:value-of select="@name"/> (<xsl:for-each select="column"><xsl:value-of select="@name"/><xsl:if test="position() != last()">,</xsl:if></xsl:for-each>) 
VALUES (<xsl:for-each select="column"><xsl:value-of select="default"/><xsl:if test="position() != last()">,</xsl:if></xsl:for-each>);

DROP TABLE IF EXISTS s<xsl:value-of select="@name"/>;

CREATE TABLE s<xsl:value-of select="@name"/> (
    s<xsl:for-each select="column"><xsl:if test="key = 'PK'"><xsl:value-of select="@name"/> <xsl:value-of select="dtype"/> PRIMARY KEY NOT NULL</xsl:if></xsl:for-each>
)

INSERT INTO s<xsl:value-of select="@name"/> (s<xsl:for-each select="column"><xsl:if test="key = 'PK'"><xsl:value-of select="@name"/></xsl:if></xsl:for-each>) VALUES (1000);

</xsl:template>
</xsl:transform>