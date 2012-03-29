# # Creamer
#
# A flatiron http plugin that adds `coffeecup` templates to your flatiron application
#
# install
#
#     npm install creamer
#
# usage
#
#     flatiron = require 'flatiron'
#     creamer = require 'creamer'
#     app = flatiron.app
#     layout = require __dirname + '/views/layout'
#     app.use creamer, layout: layout
#
#     app.router.get '/', ->
#       @res.html @bind -> h1 'Hello World'
#
#     app.start 3000
#
# ---
# require coffeecup
# [http://github.com/gradus/coffeecup](http://github.com/gradus/coffeecup)
cc = require 'coffeecup'
hardcode = require 'coffeecup-helpers'
fs = require 'fs'
wrench = require 'wrench'
# broadway plug attach method
#
# Plugin Options
#
#     Options      |    Description
#     -------------|----------------------------------------
#     layout       | CoffeeCup Template with content method
#     viewDir     | Add your views directory and we will pre-register your views
#
exports.attach = (options={}) ->
  self = this
  # ## load views by view directory
  # 
  # by passing the viewDir as an option
  # creamer will load your views
  registeredViews = {}
  if options.viewDir?
    views = wrench.readdirSyncRecursive(options.viewDir) 
    for view in views
      if view.match /(.js|.coffee)/
        fn = require options.viewDir + '/' + view
        name = view.split('.').shift()
        registeredViews[name] = fn
  # ## app.bind(page, data)
  #
  #     Parameter    |   Type    |  Required?  |  Description
  #     -------------|-----------|-------------|-------------------------
  #     page         | function  | yes         | coffeecup template
  #     data         | object    | no          | any data you want to pass to your template
  @bind = (page, data) ->
    page = registeredViews[page] if typeof page is 'string'
    if options.layout? and typeof page is 'function'
      hardcode.content = page
      cc.render(options.layout, data, { hardcode, locals: true })
    else if typeof page is 'function'
      cc.render(page, data, { hardcode, locals: true})
    else
      '<p>Not Found</p>'

  # ## app.regisgerHelper(name, fn)
  #
  #     Parameter    |   Type    |  Required?  |  Description
  #     -------------|-----------|-------------|-------------------------
  #     name         | string    | yes         | name of helper
  #     fn           | functio   | yes         | coffeecup function
  @registerHelper = (name, fn) ->
    valid = cc.compile(fn, {hardcode, locals: true})
    hardcode[name] = fn if typeof fn is 'function'

  # ## app.registerView(name, fn)
  #
  #     Parameter    |   Type    |  Required?  |  Description
  #     -------------|-----------|-------------|-------------------------
  #     name         | string    | yes         | name of helper
  #     fn           | functio   | yes         | coffeecup function
  @registerView = (name, fn) ->
    valid = cc.compile(fn, {hardcode, locals: true})
    registeredViews[name] = fn

  # if flatiron router exists, then attach creamers bind function
  @router.attach ( -> @bind = self.bind ) if @router?.attach?

  # init plugin method
exports.init = (done) -> done()