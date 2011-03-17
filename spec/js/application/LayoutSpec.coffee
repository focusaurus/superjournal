zombie = require 'zombie'
require.paths.unshift '.'
config = require 'server_config'
describe 'Pages using the main layout', ->
  #require.paths.shift()

  it "should have the basic layout HTML", ->
    browser = new zombie.Browser()
    browser.visit 'http://localhost:' + config.port, (err, browser, status)-> 
      expect(browser.text("title")).toEqual "Home | SuperJournal"
      expect(browser.querySelector(".container")).toBeDefined()
      expect(browser.text(".header h1")).toEqual "Welcome to SuperJournal!"
      expect(browser.querySelector(".navigation a")).toBeDefined()
      expect(browser.querySelector(".content")).toBeDefined()
      expect(browser.text(".footer")).toMatch(/Copyright.*Peter Lyons LLC/,
        "Copyright notice must be present")
      asyncSpecDone()
    asyncSpecWait()
