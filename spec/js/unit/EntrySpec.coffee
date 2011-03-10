assert = require "assert"
util = require "util"
require.paths.unshift "lib"
SJ = require("superjournal").SJ

describe 'Entry', ()->
  entry = {}
  
  beforeEach ()->
    entry = new SJ.models.Entry("foo\nbar")
  it 'should store the content', ()->
    expect(entry.content).toBeDefined()
    entry = new SJ.models.Entry "bingo"
    expect(entry.content).toEqual("bingo")

  it 'should store a new epoch timestamp', ()->
    entry = new SJ.models.Entry "bingo"
    expect(entry.createdOn).toBeDefined()
    expect(0 < entry.createdOn < new Date().getTime() + 1).toBe(true)
    entry2 = new SJ.models.Entry "bango"
    expect(entry.createdOn < entry2.createdOn + 1).toBe(true)
