if exports?
  #Running in node.js, load dependencies
  SJ = require('../../../public/js/superjournal')
else
  #Running in the browser, dependencies already in global window object
  SJ = window.SJ

describe 'Entry AJAX REST API', ->
  entry = null

  beforeEach ->
      entry = new SJ.models.Entry

  run403Test = (spec, callback) ->
    doneFlag = {done: false}
    done = ->
      return doneFlag.done
    options = {}
    options.error = (entry, response) ->
      spec.expect(response.status).toEqual(403)
      doneFlag.done = true
    options.success = ->
      spec.fail('REST calls without logging in should not succeed')
    options.complete = ->
      doneFlag.done = true
    callback(options)
    waitsFor done

  it 'should return 403 for non-authenticated GET on /entries', ->
    run403Test this, (options) ->
      SJ.data.EntryList.fetch options

  it 'should return 403 for non-authenticated POST to /entries', ->
    run403Test this, (options) ->
      entry.save {}, options

  it 'should return 403 for non-authenticated PUT to /entries/ID', ->
    entry._id = 42
    run403Test this, (options) ->
      entry.save {}, options

  it 'should return 403 for non-authenticated GET on /entries/ID', ->
    entry._id = 42
    entry.url = =>
      return '/entries/' + entry._id
    run403Test this, (options) ->
      entry.fetch options

  it 'should return 403 for non-authenticated DELETE on /entries/ID', ->
    entry._id = 42
    entry.url = =>
      return '/entries/' + entry._id
    run403Test this, (options) ->
      entry.destroy options
