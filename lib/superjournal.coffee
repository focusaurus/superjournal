SuperJournal = ->
if exports?
  #Running inside node/commonJS, not a browser
  Backbone = require 'backbone'
  
window.SJ = new SuperJournal()

SuperJournal::models = {}
SuperJournal::views = {}
SuperJournal::data = {}
#--------- Entry Model ----------
class SuperJournal::models.Entry extends window.Backbone.Model
  
  initialize: =>
    this.set("content": this.get("content") or "")
    this.set("createdOn": new Date().getTime())
    #this.set("order": SJ.data.EntryList.nextOrder())

  # Remove this Entry from *localStorage* and delete its view.
  clear: =>
    this.destroy()
    this.view.remove()

#--------- Entry Collection ----------
class SuperJournal::models.EntryList extends window.Backbone.Collection
  model: SJ.models.Entry
  url: "/entries"
  #Save all of the entry items under the `"entries"` namespace.
  localStorage: new Store("entries")

  #We keep the Entries in sequential order, despite being saved by unordered
  #GUID in the database. This generates the next order number for new items.
  nextOrder: =>
    if (!this.length)
      return 1
    return this.last().get('order') + 1

  #Entries are sorted by their original insertion order.
  comparator: (entry)=>
    return entry.get 'order'

SJ.data.EntryList = new SJ.models.EntryList()


#--------- Entry View ----------
class SuperJournal::views.EntryView extends window.Backbone.View
  #Cache the template function for a single item.
  #template: _.template($('#entry_template').html())

  #The DOM events specific to an item.
  events:
    "dblclick div.entry_content": "edit"
    "click span.entry_destroy": "clear"
    "keypress .entry_textarea": "createOnShiftEnter"
  
  #The EntryView listens for changes to its model, re-rendering. Since there's
  #a one-to-one correspondence between a **Entry** and a **EntryView** in this
  #app, we set a direct reference on the model for convenience.
  initialize: =>
    _.bindAll(this, 'render', 'close')
    this.model.bind('change', this.render)
    this.model.view = this

  #Re-render the contents of the entry item.
  render: =>
    #BUGBUG todo cache the template.
    template = _.template($('#entry_template').html())
    modelData = this.model.toJSON()
    date = new Date(this.model.get("createdOn"))
    displayDate = $.datepicker.formatDate("DD MM dd, yy", date)
    displayDate += " " + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds()
    modelData.createdOn = displayDate
    $(this.el).html(template(modelData))
    this.setContent()
    return this

  #To avoid XSS (not that it would be harmful in this particular app),
  #we use `jQuery.text` to set the contents of the entry item.
  setContent: =>
    content = this.model.get 'content'
    this.$('.entry_content').text(content)
    this.textarea = this.$('.entry_textarea')
    this.textarea.bind('blur', this.close)
    this.textarea.val content

  #Switch this view into `"editing"` mode, displaying the textarea field.
  edit: =>
    $(this.el).addClass("editing")
    this.textarea.focus()

  #Close the `"editing"` mode, saving changes to the entry.
  close: =>
    this.model.save({content: this.textarea.val()})
    $(this.el).removeClass("editing")

  #If you hit `enter`, we're through editing the item.
  createOnShiftEnter: (event)=>
    if (event.which is 13 and event.shiftKey)
      this.close()

  #Remove this view from the DOM.
  remove: =>
    $(this.el).remove()

  #Remove the item, destroy the model.
  clear: =>
    this.model.clear()

#--------- The Application ----------
class SuperJournal::views.AppView extends window.Backbone.View
  #Instead of generating a new element, bind to the existing skeleton of
  #the App already present in the HTML.
  #BUGBUG is this actually used?
  el: $("#superjournal")

  #Delegated events for creating new items, and clearing completed ones.
  events:
    "keypress #new_entry":  "createOnShiftEnter"
    "keyup #new_entry":     "showTooltip"
    "click .entry_clear a": "clearCompleted"

  #At initialization we bind to the relevant events on the `Entries`
  #collection, when items are added or changed. Kick things off by
  #loading any preexisting entrys that might be saved in *localStorage*.
  initialize: =>
    this.textarea    = $("#new_entry")
    this.textarea.keyup this.createOnShiftEnter

    EntryList = SJ.data.EntryList
    EntryList.bind('add',     this.addOne)
    EntryList.bind('refresh', this.addAll)

    EntryList.fetch()
  #Add a single entry item to the list by creating a view for it, and
  #appending its element to the list in the HTML.
  addOne: (entry)=>
    $("#entry_list").prepend(entry.view.render().el)

  #Add all items in the **EntryList** collection at once.
  addAll: =>
    SJ.data.EntryList.each(this.addOne)

  #If you hit return in the main textarea field, create new **Entry** model,
  #persisting it to *localStorage*.
  createOnShiftEnter: (event)=>
    if (event.which is 13 and event.shiftKey)
      value = $("#new_entry").val()
      if value
        entry = new SJ.models.Entry(content: value)
        view = new SJ.views.EntryView({model: entry})
        SJ.data.EntryList.add(entry)
        $("#new_entry").val('')
        $("#new_entry").focus()

  #Lazily show the tooltip that tells you to press `enter` to save
  #a new entry item, after one second.
  showTooltip: (e)=>
    tooltip = this.$(".ui-tooltip-top")
    val = this.textarea.val()
    tooltip.fadeOut()
    if (this.tooltipTimeout)
      clearTimeout(this.tooltipTimeout)
    if (val == '' or val == this.textarea.attr('placeholder'))
      return
    show = ->
      tooltip.show().fadeIn()
    this.tooltipTimeout = _.delay(show, 1000)
