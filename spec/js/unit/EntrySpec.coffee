describe 'Entry', ()->
  if exports?
    #Running in node.js, load dependencies
    require.paths.unshift "lib"
    SJ = require("superjournal")
  else
    #Running in the browser, dependencies already in global window object
    SJ = window.SJ
  
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

describe 'Entry View Browser Tests', ()->
  if ! exports?
    #Tests that should only run in the browser
    it 'should format the createdOn timestamp correctly', ()->
      #This specific time is used because it has 10:06 which needs a leading 0
      entry = new SJ.models.Entry(createdOn: 1300205199756)
      view = new SJ.views.EntryView(model: entry)
      expect(view.formatDate()).toContain("Tuesday")
      #This makes sure we add leading zeros to time elements less than 10
      expect(view.formatDate()).toContain("10:06")
