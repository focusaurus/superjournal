if exports?
  #Running in node.js, load dependencies
  SJ = require('../../../public/js/superjournal')
else
  #Running in the browser, dependencies already in global window object
  SJ = window.SJ

describe 'Entry AJAX REST API', ->
  it 'should return 403 for non-authenticated GET', ->
    self = this
    doneFlag = {done: false}
    done = ->
      return doneFlag.done
    options = {}
    options.error = (entryList, response) ->
      expect(entryList.length).toEqual(0)
      expect(response.status).toEqual(403)
    options.success = ->
      self.fail('Fetching entries without logging in should not succeed')
    options.complete = ->
      doneFlag.done = true
    SJ.data.EntryList.fetch(options)
    waitsFor(done)

  it 'should return 403 for non-authenticated POST', ->
    self = this
    doneFlag = {done: false}
    done = ->
      return doneFlag.done

    options = {}
    options.error = (entry, response) ->
      expect(response.status).toEqual(403)
    options.success = ->
      self.fail('Fetching entries without logging in should not succeed')
    options.complete = ->
      doneFlag.done = true
    entry = new SJ.models.Entry
    entry.save(options)
    SJ.data.EntryList.fetch(options)
    waitsFor(done)
