zombie = require 'zombie'
require.paths.unshift '.'
config = require 'server_config'
describe 'Pages using the main layout', ->
  #require.paths.shift()

  it "should have the basic layout HTML", ->
    browser = new zombie.Browser()
    browser.visit 'http://localhost:' + config.port, (err, browser, status)-> 
      expect(browser.querySelector("#superjournal")).toBeDefined()
      expect(browser.querySelector("#new_entry")).toBeDefined()
      expect(browser.querySelector("#entry_list")).toBeDefined()
      expect(browser.querySelector("#entry_template")).toBeDefined()
      asyncSpecDone()
    asyncSpecWait()
