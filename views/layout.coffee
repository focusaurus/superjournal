doctype 5
html lang: "en", ->
  head ->
    meta charset: "utf-8"
    comment "#{appName} Version: #{version}"
    meta name: "keywords", content: "journal"
    meta name:"author", content: "Peter Lyons"
    meta name: "description", content: "An elephant never forgets"
    meta name: "copyright", content: "2011, Peter Lyons LLC"
    link rel: "stylesheet", href: "css/blueprint/screen.css", type: "text/css", media: "screen, projection"
    link rel: "stylesheet", href: "css/blueprint/print.css", type: "text/css", media: "print"
    text "<!--[if lt IE 8]>"
    link rel: "stylesheet", href: "css/blueprint/ie.css", type: "text/css", media: "screen, projection"
    text "<![endif]-->"
    link rel: "stylesheet", href: "css/screen.css", type:"text/css"
    title "#{@title} | #{appName}" if @title?
    link rel: "stylesheet", href: "css/sj_theme/jquery-ui.css", type:"text/css"
    script type: "text/javascript", src: "js/jquery.js"
    script type: "text/javascript", src: "js/jquery-ui.js"
  body ->
    div class: "container", ->
      div class: "header span-24 last", ->
        h1 ->
          "Welcome to #{appName}!"
        div class: "navigation span-24 last", ->
          a href: "/", -> "Home"
      div class: "content span-24 last", ->
        text @body
      div class: "footer span-24 last", ->
        hr()
        
        text "Copyright &copy; 2011 Peter Lyons LLC"
  script type: "text/javascript", ->
    text '''$(".navigation > a").button()'''
  p "DID THE layout.coffee file get re-rendered?" #3

