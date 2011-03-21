config = require '../../../server_config'
util = require 'util'
zombie = require 'zombie'

describe 'Pages using the main layout', ->

  it "should have the basic layout HTML", ->
    browser = new zombie.Browser()
    self = this
    browser.visit 'http://localhost:' + config.port, (err, browser, status)->
      if err
        if err.message.toLowerCase().indexOf('connection refused') >= 0
          self.fail(config.appName + " is not running. Please start the server.")
        else
          self.fail(err.message)
        asyncSpecDone()
        return
      expect(browser.text("title")).toEqual "Home | SuperJournal"
      expect(browser.querySelector(".container")).toBeDefined()
      expect(browser.text(".header h1")).toEqual "Welcome to SuperJournal!"
      expect(browser.querySelector(".navigation a")).toBeDefined()
      expect(browser.querySelector(".content")).toBeDefined()
      expect(browser.text(".footer")).toMatch(/Copyright.*Peter Lyons LLC/,
        "Copyright notice must be present")
      asyncSpecDone()
    asyncSpecWait()
