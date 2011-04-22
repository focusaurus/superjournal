describe 'Pages using the main layout', ->
  it "should have the basic layout HTML", ->
    expect($("title").text()).toContain " | SuperJournal"
    expect($(".container")).toBeDefined()
    expect($(".header h1").text()).toEqual "Welcome to SuperJournal!"
    expect($(".navigation a")).toBeDefined()
    expect($(".content")).toBeDefined()
    expect($(".footer").text()).toMatch(/Copyright.*Peter Lyons LLC/,
      "Copyright notice must be present")
