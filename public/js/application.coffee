SuperJournal = ->

SuperJournal.prototype.newEntry = () ->
  entry = $("#newentry")
  entry.before("<pre>" + entry.attr("value") + "</pre>")
  entry.val('')
  entry.focus()
window.SJ = new SuperJournal()
