if exports?
  #Running in node.js, load dependencies
  SJ = require('../../../public/js/superjournal')
else
  #Running in the browser, dependencies already in global window object
  SJ = window.SJ

describe 'Entry AJAX REST API', ->
  run403Test = (spec, callback) ->
    doneFlag = {done: false}
    done = ->
      return doneFlag.done
    options = {}
    options.error = (entry, response) ->
      spec.expect(response.status).toEqual(403)
    options.success = ->
      spec.fail('REST calls without logging in should not succeed')
    options.complete = ->
      doneFlag.done = true
    callback(options)
    waitsFor done

  it 'should return 403 for non-authenticated GET on /entries', ->
    run403Test this, (options) ->
      SJ.data.EntryList.fetch options

  xit 'should return 403 for non-authenticated POST to /entries', ->
    self=this
    doneFlag = {done: false}
    options = {}
    done = ->
      return doneFlag.done
    options.error = (entry, response) ->
      self.expect(response.status).toEqual(403)
    options.success = ->
      self.fail('REST calls without logging in should not succeed')
    options.complete = ->
      doneFlag.done = true
    entry = new SJ.models.Entry()
    entry.save options
    waitsFor done

  xit 'should return 403 for non-authenticated PUT to /entries/ID', ->
    entry = new SJ.models.Entry
    entry._id = 42
    run403Test this, (options) ->
      entry.save options
