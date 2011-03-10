zombie = require "zombie"
assert = require "assert"
jasmine = require 'jasmine-node'
util = require 'util'

describe 'the home page', ->
  it "should have the basic layout HTML", ->
    browser = new zombie.Browser()
    browser.visit "http://localhost:9500/", (err, browser, status)-> 
      expect(browser.text("title")).toEqual "Home | SuperJournal"
      expect(browser.querySelector(".container")).toBeDefined()
      expect(browser.text(".header h1")).toEqual "Welcome to SuperJournal!"
      expect(browser.querySelector(".navigation a")).toBeDefined()
      expect(browser.querySelector(".content textarea")).toBeDefined()
      expect(browser.text(".footer")).toMatch(/Copyright.*Peter Lyons LLC/,
        "Copyright notice must be present")
      asyncSpecDone()
    asyncSpecWait()
