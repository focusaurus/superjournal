doctype 5
html lang: "en", ->
  head ->
    meta charset: "utf-8"
    comment "#{appName} Version: #{version}"
    meta name: "keywords", content: "journal"
    meta name:"author", content: "Peter Lyons"
    meta name: "description", content: "An elephant never forgets"
    meta name: "copyright", content: "2011, Peter Lyons LLC"
    link rel: "stylesheet" href: "css/blueprint/screen.css" type: "text/css" media: "screen, projection"
    link rel: "stylesheet" href: "css/blueprint/print.css" type: "text/css" media: "print"
    text "<!--[if lt IE 8]>"
    link rel: "stylesheet" href: "css/blueprint/ie.css" type: "text/css" media: "screen, projection"
    text "<![endif]-->"
    link rel: "stylesheet", href: "/css/screen.css", type:"text/css"
    title "#{@title} | #{appName}" if @title?
  body ->
    div class: "wrapper", ->
      div class: "header", ->
        h1 ->
          "Welcome to #{appName}!"
        div class: "navigation", ->
          a href: "/", -> "Home"
      div class: "content", ->
        text @body
      div class: "footer", ->
        hr
        text "Copyright &copy; 2011 Peter Lyons LLC"

