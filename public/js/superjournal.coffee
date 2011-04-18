if exports?
  #Running inside node/commonJS, not a browser
  #Get our libraries into the local coffeescript function scope with 'require'
  SJ = exports
  #IMPORTANT. We must load the NODE version of jquery
  #NOT the browser jquery, which will cause all kinds of breakage
  $ = require 'jquery'
  _ = require('./underscore')._
  Backbone = require './backbone'
  #Store = require('./backbone-localstorage').Store
else
  #Running in a browser
  #Get the libraries into the local coffeescript function scope with explicit
  #shadowing from 'this', which is the browser's 'window' global object
  $ = this.$ #jQuery
  _ = this._ #underscore.js
  #Store = this.Store #backbone-localstorage
  Backbone = this.Backbone #backbone.js
  SJ = this.SJ = {} #Create a new empty global SJ object

SJ.models = {}
SJ.views = {}
SJ.data = {}

addConvenienceMethods = (obj, properties) ->
  for prop in properties
    ((prop) ->
      obj[prop] = (newValue...) ->
        if newValue.length
          toSet = {}
          toSet[prop] = newValue[0]
          return obj.set(toSet) or this
        else
          return obj.get(prop)
        ).call(obj, prop)

#Save all of the entry items under the `'entries'` namespace.
#SJ.localStorage = new Store('entries')
#--------- Entry Model ----------
class SJ.models.Entry extends Backbone.Model

  initialize: =>
    self = this
    this.idAttribute = '_id' #This provides MongoDB compatibility
    addConvenienceMethods(this, ['content', 'createdOn'])
    this.id = ->
      return self.get self.idAttribute
    this.content(this.content() or '')
    this.createdOn(this.createdOn() or new Date().getTime())

  # Remove this Entry and delete its view.
  clear: =>
    this.destroy()
    this.view.remove()

#--------- Entry Collection ----------
class SJ.models.EntryList extends Backbone.Collection
  model: SJ.models.Entry
  url: '/entries'
  localStorage: SJ.localStorage

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
class SJ.views.EntryView extends Backbone.View
  #Cache the template function for a single item.
  #BUGBUG TODO
  #template: null

  #The DOM events specific to an item.
  events:
    'dblclick div.entry_content': 'edit'
    'click a.entry_delete': 'clear'
    'keypress .entry_textarea': 'closeOnShiftEnter'

  #The EntryView listens for changes to its model, re-rendering. Since there's
  #a one-to-one correspondence between a **Entry** and a **EntryView** in this
  #app, we set a direct reference on the model for convenience.
  initialize: (model)=>
    this.model = model
    this.model.bind('change', this.render)
    this.model.view = this

  formatDate: =>
    date = new Date(this.model.createdOn())
    displayDate = $.datepicker.formatDate('DD MM dd, yy', date)
    displayDate += (' ' + date.toTimeString().split(' ')[0])

  #Re-render the contents of the entry item.
  render: =>
    template = _.template($('#entry_template').html())
    modelData = this.model.toJSON()

    modelData.createdOn = this.formatDate()
    #Escape HTML entities
    modelData.content = this.model.escape('content')
    modelData.id = modelData._id
    $(this.el).html(template(modelData))
    return this

  #Switch this view into `'editing'` mode, displaying the textarea field.
  edit: =>
    $(this.el).addClass('editing')
    this.$('textarea').focus()
    this.$('textarea').val(this.model.content())

  #Close the `'editing'` mode, saving changes to the entry.
  close: =>
    rawValue = this.$('textarea').val()
    this.model.save({content: rawValue})
    $(this.el).removeClass('editing')

  #If you hit `enter`, we're through editing the item.
  closeOnShiftEnter: (event)=>
    if (event.which is 13 and event.shiftKey)
      this.close()

  #Remove the item, destroy the model.
  clear: =>
    this.model.clear()

  remove: =>
    $(this.el).remove()

#--------- The Application ----------
class SJ.views.AppView extends Backbone.View
  #Instead of generating a new element, bind to the existing skeleton of
  #the App already present in the HTML.
  #BUGBUG is this actually used?
  el: $('#superjournal')

  #Delegated events for creating new items, and clearing completed ones.
  events:
    'keypress #new_entry':  'createOnShiftEnter'
    'click .entry_clear a': 'clearCompleted'

  #At initialization we bind to the relevant events on the `Entries`
  #collection, when items are added or changed. Kick things off by
  #loading any preexisting entrys that might be saved in *localStorage*.
  initialize: =>
    this.textarea    = $('#new_entry')
    this.textarea.keyup this.createOnShiftEnter

    EntryList = SJ.data.EntryList
    EntryList.bind('add',     this.addOne)
    EntryList.bind('refresh', this.addAll)
    EntryList.fetch()
    this.addAll()
  #Add a single entry item to the list by creating a view for it, and
  #appending its element to the list in the HTML.
  addOne: (entry)=>
    if not entry.view
      entry.view = new SJ.views.EntryView entry
    #TODO addOne is getting called multiple times and is not idempotent
    $('#entry_list').prepend(entry.view.render().el)

  #Add all items in the **EntryList** collection at once.
  addAll: =>
    SJ.data.EntryList.each(this.addOne)

  #If you hit return in the main textarea field, create new **Entry** model,
  #persisting it to *localStorage*.
  createOnShiftEnter: (event)=>
    if (event.which is 13 and event.shiftKey)
      value = $('#new_entry').val().trim()
      if value
        entry = new SJ.models.Entry(content: value)
        view = new SJ.views.EntryView({model: entry})
        SJ.data.EntryList.add(entry)
        entry.save()
        $('#new_entry').val('')
        $('#new_entry').focus()
