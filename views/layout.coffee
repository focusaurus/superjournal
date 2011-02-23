doctype 5
html lang: "en", ->
  head ->
    meta charset: "utf-8"
    comment "    #{appName} Version: #{version}"
    meta name: "keywords", content: "journal"
    meta name:"author", content: "Peter Lyons"
    meta name: "description", content: "An elephant never forgets"
    meta name: "copyright", content: "2011, Peter Lyons LLC"
    link rel: "stylesheet", href: "/screen.css", type:"text/css"
    title "#{@title} | #{appName}" if @title?
  body ->
    div class: "body", ->
      @body
