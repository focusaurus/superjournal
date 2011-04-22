if exports?
  #Running in node.js, load dependencies
  SJ = require('../../../public/js/superjournal')
else
  #Running in the browser, dependencies already in global window object
  SJ = window.SJ
describe 'Entry AJAX REST API authorization filtering', ->
  entry = null

  beforeEach ->
      entry = new SJ.models.Entry {content: 'Test Content 2'}

  prepOptions = (spec, callback) ->
    doneFlag = {done: false}
    done = ->
      return doneFlag.done
    options = {}
    options.error = (model, response) ->
      spec.fail('REST calls failed unexpectedly')
    options.complete = ->
      doneFlag.done = true
    callback(options)
    waitsFor done

  it 'should create an entry', ->
    prepOptions this, (options) ->
      options.success = (model, response)->
        expect(model.content()).toEqual(response.content)
      entry.save {}, options

  it 'should list the entry created', ->
    prepOptions this, (options) ->
      options.success = (collection, response)->
        firstAuthor = collection.at(0).author()
        collection.each (entry) ->
          expect(entry.author()).toEqual(firstAuthor)
      SJ.data.EntryList.fetch options
