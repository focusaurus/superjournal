describe 'The home page', ->
  it "should show the user's email", ->
    expect($("#sign_out_form").html()).toContain('test@sj.peterlyons.com')
