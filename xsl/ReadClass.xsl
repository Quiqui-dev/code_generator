<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xml:space="preserve">
    <xsl:output method="text"/>

<!-- ~/Saxon/saxon-he-11.3.jar ./xml/test.xml ./xsl/testReadClass.xsl -o:./bin/testPy.py -->
<xsl:template match="table">

from common import whereClause
class <xsl:value-of select="@name"/>Read:

    def __init__(self, myReadCursor=None):

        if myReadCursor is None:
            raise Exception("No Cursor Exception")

        self.myReadCursor = myReadCursor

        self.__d<xsl:value-of select="@name"/>Rows = {}
        self.__dDefaultRow = {}
        self.__iRowCount = 0
        self.nextPK = 0


    def get<xsl:value-of select="@name"/>Rows(self):
        return self.__d<xsl:value-of select="@name"/>Rows

    def setRowCount(self, numRows):
        self.__iRowCount = numRows

    def getRowCount(self):
        return self.__iRowCount

    
    def removeEscapeChars(self, dItem=None):

        if dItem is None:
            raise Exception("cannot format None")

        dTmp = dItem
        for k,v in dItem.items():
            if not isinstance(v, str):
                continue

            v.replace("U+005C", " \\")
            v.replace("U+0027", "'")
            v.replace("U+003C", '"')

            dTmp[k] = v 

        dItem = dTmp
        return dItem

    def iSelect(self, sQuery, sKey=None):

        self.myReadCursor.execute(sQuery)
        rows = self.myReadCursor.fetchall()
        rowcount = self.myReadCursor.rowcount


        if not self.myReadCursor.rowcount:
            raise Exception("No Rows Found")


        if sKey is None:

            iCount = 0

            for row in rows:

                # index the rows from 0 -> n-1

                dTmp = self.removeEscapeChars(row)
                self.__d<xsl:value-of select="@name"/>Rows[iCount] = dTmp
                iCount += 1

        else:

            try:

                for row in rows:
                    # index the rows by a column in the result set
                    dTmp = self.removeEscapeChars(row)
                    self.__d<xsl:value-of select="@name"/>Rows[row[sKey]] = dTmp

                    iCount += 1

            except:
                raise Exception(f"No column matching {sKey}")

        
        if iCount != rowcount:
            raise Exception("Row count mismatch")


        self.setRowCount(iCount)

        return iCount

    def set_<xsl:value-of select="@name"/>Rows(self, dCriteria=None, sKey=None):

        
        try:
            self.removeEscapeChars(dItem=dCriteria)

            <xsl:call-template name="build-select"/>

            self.iSelect(sQuery=sQuery, sKey=sKey)
        except:
            raise Exception("failed to fetch")

        
        return self.__d<xsl:value-of select="@name"/>Rows

    def setDefaultRow(self, sKey=None):

        try:
            <xsl:call-template name="fetch-default"/>

            self.iSelect(sQuery=sQuery, sKey=sKey)
            self.__dDefaultRow = self.__d<xsl:value-of select="@name"/>Rows

            self.__d<xsl:value-of select="@name"/>Rows = {}

            return self.__dDefaultRow
        except:
            raise Exception("could not fetch default row")

    def setFreeQueryRows(self, sQuery=None, sKey=None):

        # should likely validate the query to ensure it is safe but let's let the dev worry about it

        if sQuery is None:
            raise Exception("Query must be supplied to execute")

        self.iSelect(sQuery=sQuery, sKey=sKey)
        
        return self.__d<xsl:value-of select="@name"/>Rows

    def getNextPK(self):

        sQuery = """
        SELECT * FROM s<xsl:value-of select="@name"/>
        """

        self.iSelect(sQuery=sQuery, sKey=None)
        self.__dDefaultRow = self.__d<xsl:value-of select="@name"/>Rows
        self.nextPK = self.__d<xsl:value-of select="@name"/>Rows[0]["s<xsl:for-each select="column"><xsl:if test="key = 'PK'"><xsl:value-of select="@name"/></xsl:if></xsl:for-each>"]

        return self.__d<xsl:value-of select="@name"/>Rows[0]["s<xsl:for-each select="column"><xsl:if test="key = 'PK'"><xsl:value-of select="@name"/></xsl:if></xsl:for-each>"]
        

</xsl:template>

<xsl:template name="build-select">
            sQuery = """
            SELECT <xsl:for-each select="column"><xsl:value-of select="@name"/><xsl:if test="position() != last()">,</xsl:if></xsl:for-each>
            FROM <xsl:value-of select="@name"/>
            """
            sQuery += whereClause.getWhereClause(dCriteria=dCriteria)
</xsl:template>

<xsl:template name="fetch-default">
            sQuery = """
            SELECT <xsl:for-each select="column"><xsl:value-of select="@name"/><xsl:if test="position() != last()">,</xsl:if></xsl:for-each>
            FROM <xsl:value-of select="@name"/>
            WHERE <xsl:for-each select="column"><xsl:if test="key = 'PK'"><xsl:value-of select="@name"/> = <xsl:value-of select="default"/></xsl:if></xsl:for-each>
            """
</xsl:template>

</xsl:transform>