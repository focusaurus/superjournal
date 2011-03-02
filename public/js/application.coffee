SuperJournal = ->

SuperJournal.prototype.newEntry = () ->
  entry = $("#newentry")
  entry.before("<pre>" + entry.attr("value") + "</pre>")
  entry.attr("value", "")
window.SJ = new SuperJournal()
