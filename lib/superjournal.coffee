SuperJournal = ->

SuperJournal.prototype.newEntry = () ->
  entry = $("#newentry")
  $("#entry_list").prepend("<pre>" + entry.attr("value") + "</pre>")
  entry.val('')
  entry.focus()
  
SuperJournal.prototype.init = () ->
  $("#newentry").keypress (event) ->
    SJ.newEntry() if (event.which is 13 and event.shiftKey)
    $("#newentry").focus()

SuperJournal.prototype.models = {}
SuperJournal.prototype.models.Entry = (content) ->
  this.content = content
  this.createdOn = new Date().getTime()

SuperJournal.prototype.init = () ->
  $("#newentry").keypress (event) ->
    SJ.newEntry() if (event.which is 13 and event.shiftKey)
    $("#newentry").focus()


if exports?
  exports.SJ = new SuperJournal()
else
  window.SJ = new SuperJournal()

