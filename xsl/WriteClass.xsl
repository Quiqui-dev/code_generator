<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xml:space="preserve">
    <xsl:output method="text"/>

<!-- ~/Saxon/saxon-he-11.3.jar ./xml/test.xml ./xsl/testReadClass.xsl -o:./bin/testPy.py -->
<xsl:template match="table">

import <xsl:value-of select="@name"/>Read
from mysql.connector import Error
from common import whereClause, updateClause
from datetime import datetime
class <xsl:value-of select="@name"/>Write(<xsl:value-of select="@name"/>Read.<xsl:value-of select="@name"/>Read):

    def __init__(self, myWriteCursor=None, myReadCursor=None):

        if myReadCursor is None or myWriteCursor is None:
            raise Exception("No Cursor Exception")

        super(<xsl:value-of select="@name"/>Write, self).__init__(myReadCursor=myReadCursor)
        self.myWriteCursor = myWriteCursor


    def formatEscapeChars(self, dItem=None):

        if dItem is None:
            raise Exception("Cannot format None")


        dTmp = dItem
        for k, v in dItem.items():
            if not isinstance(v, str):
                continue
                
            v.replace("\\", "U+005C")<xsl:text disable-output-escaping="yes">
            v.replace("'", "U+0027")
            v.replace('"', "U+003C")</xsl:text>

            dTmp[k] = v

        dItem = dTmp
        return dItem

    def iUpdate(self, sQuery=None):

        try:

            self.myWriteCursor.execute(sQuery)
        except Error:
            raise

    def insertSingleton(self, dInsert=None):

        <xsl:call-template name="build-single-insert"/>

    def insertMultiple(self, lInserts=None):

        <xsl:call-template name="build-multi-insert"/>

    def updateNextPK(self, iNextPK=0):

        if not iNextPK or not isinstance(iNextPK, int):
            raise Exception("Must provide PK > 0 to be next PK")

        try:
            sQuery = f"""
            UPDATE s<xsl:value-of select="@name"/> 
            SET s<xsl:for-each select="column"><xsl:if test="key = 'PK'"><xsl:value-of select="@name"/></xsl:if></xsl:for-each> = {iNextPK}
            """

            self.iUpdate(sQuery=sQuery)
        except Error:
            raise 

    def update<xsl:value-of select="@name"/>(self, dCriteria=None, dNewValues=None):    

        if dNewValues is None or dCriteria is None:
            raise Exception("Must have criteria and values to update")

        
        sQuery = """
        UPDATE <xsl:value-of select="@name"/>
        """

        sQuery += updateClause.getUpdateClause(dNewValues)
        sQuery += whereClause.getWhereClause(dCriteria)

        self.iUpdate(sQuery=sQuery)


</xsl:template>


<xsl:template name="build-single-insert">

        sQuery = """
        INSERT INTO <xsl:value-of select="@name"/> (<xsl:for-each select="column"><xsl:value-of select="@name"/><xsl:if test="position() != last()">,</xsl:if></xsl:for-each>)
        VALUES (<xsl:for-each select="column">%s<xsl:if test="position() != last()">,</xsl:if></xsl:for-each>)
        """

        dInsert=self.formatEscapeChars(dInsert)
        defaultRow = self.setDefaultRow(sKey=None)

        defaultRow.update(dInsert)
        dInsert = defaultRow
        dInsert["dateCreated"] = datetime.now()

        try:

            nextPK = self.getNextPK() + 10
            dInsert["<xsl:for-each select="column"><xsl:if test="key='PK'"><xsl:value-of select="@name"/></xsl:if></xsl:for-each>"] = nextPK
            
            self.myWriteCursor.execute(
                sQuery,
                (<xsl:for-each select="column">dInsert["<xsl:value-of select="@name"/>"]<xsl:if test="position() != last()">,</xsl:if></xsl:for-each>)
            )

            self.updateNextPK(iNextPK=nextPK)
        except Error:
            raise
</xsl:template>

<xsl:template name="build-multi-insert">

        sQuery = """
        INSERT INTO <xsl:value-of select="@name"/> (<xsl:for-each select="column"><xsl:value-of select="@name"/><xsl:if test="position() != last()">,</xsl:if></xsl:for-each>)
        VALUES (<xsl:for-each select="column">%s<xsl:if test="position() != last()">,</xsl:if></xsl:for-each>)
        """

        lPrepInsert = []
        for dInsert in lInserts:

            if self.__dDefaultRow:
                defaultRow = self.__dDefaultRow.copy()
            else:
                defaultRow = self.setDefaultRow(sKey=None)

            defaultRow.update(dInsert)
            dTmp = defaultRow

            dTmp = self.formatEscapeChars(dItem=dTmp)

            dTmp["dateCreated"] = datetime.now()

            dTmp["<xsl:for-each select="column"><xsl:if test="key='PK'"><xsl:value-of select="@name"/></xsl:if></xsl:for-each>"] = self.nextPK + 10
            self.nextPK += 10
            
            lPrepInsert.append((<xsl:for-each select="column">dInsert["<xsl:value-of select="@name"/>"]<xsl:if test="position() != last()">,</xsl:if></xsl:for-each>))

        try:
            self.myWriteCursor.executemany(
                sQuery,
                lPrepInsert
            )

            self.updateNextPK(iNextPK=self.nextPK)
        except Error:
            raise

</xsl:template>

</xsl:transform>