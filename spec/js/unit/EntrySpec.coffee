assert = require "assert"
util = require "util"
require.paths.unshift "lib"
SJ = require("superjournal")

describe 'Entry', ()->
  testContent = 'foo\nbar'
  entry = new SJ.models.Entry(content: testContent)
  
  beforeEach ()->
    entry = new SJ.models.Entry(content: testContent)

  it 'should store the content', ()->
    expect(entry.get 'content').toEqual(testContent)

  it 'should store a new epoch timestamp', ()->
    expect(0 < entry.get('createdOn') < new Date().getTime() + 1).toBe(true)
    entry2 = new SJ.models.Entry
    expect(entry.get('createdOn') < entry2.get('createdOn') + 1).toBe(true)
