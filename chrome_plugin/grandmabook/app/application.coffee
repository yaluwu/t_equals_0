console.verbose = console.log

$ = jQuery

unless window.io
  script = document.createElement 'script'
  script.setAttribute 'src', "//ws.familicircle.com/socket.io/socket.io.js"
  document.head.appendChild script


class MainWatcher
  constructor: (@emailId) ->
    @emailId = 0
    @views = []

  attachGrandmabook: (el, text) ->
    $el = $(el)
    unless $el.hasClass("grandmabook-nc-email")
      emailId = @emailId
      @emailId += 1

      $el.addClass "grandmabook grandmabook-nc-email grandmabook-nc-email-" + emailId
      _enabled = false
      _enabled_url = ""
      _tooltip = "Track Email with Grandmabook"

      callback = (success) =>
        @views.push view
        console.log "GRANDMABOOK: Created View"

      binded_callback = _.bind callback, @

      view = new GmailNewComposeEmailTracker(
        emailId: emailId
        dialogEl: $el
        enabled: _enabled
        enabled_url: _enabled_url
        tooltip: _tooltip
        callback: binded_callback
      )

  parseDOM: ->
    try
      unless window.detected_email?
        email_elem = $("span[class='gbps2']:first")
        if email_elem[0]?
          email = email_elem.first().text()
          console.verbose "GRANDMABOOK: Found email " + email
          email_pattern = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/
          if email_pattern.test(email)
            window.detected_email = email
          else
            window.detected_email = null
      popouts = $("body.xE.xp")
      dialogs = $(".nH.Hd[role='dialog']")
      replies = $("table .M9")

      for dialog in dialogs
        @attachGrandmabook dialog, "dialog"

      for reply in replies
        @attachGrandmabook reply, "reply"

      for popout in popouts
        @attachGrandmabook popout, "popout"

    catch _error
      err = _error
      console.verbose "Mutation Error - " + err.message

  watchForChanges: ->
    config =
      childList: true
      subtree: true

    console.verbose "GRANDMABOOK: Starting Compose Mutation Observer"
    parseFunc = @parseDOM
    @parseDOM()
    observer = new MutationObserver(_.bind(parseFunc, @))
    observer.observe document, config


class GmailNewComposeEmailTracker
  LOGO: 'http://www.familicircle.com/images/logo_24_trans.png'
  HOST: 'http://www.familicircle.com'

  constructor: (params) ->
    {@emailId, @dialogEl, @enabled, @enabled_url, @tooltip, @callback} = params
    @dialogCls = ".grandmabook-nc-email-#{@emailId}"
    @ui =
      dialog: @dialogEl
    @$el = $("<p class='grandmabook-container'/>")
    @el = @$el[0]

    @setEnabled @enabled

    @watchEmailDialog()

  template: (params) ->
    status = if @enabled then "enabled" else "disabled"
    """
    <img src='#{@LOGO}' alt='FamiliCircle'>
    <a href='http://www.familicircle.com/' class='home-link'>FamiliCircle</a>
    <span class='status'>#{status}</span>
    <a href='#' class='enable-link'>Share pictures/video with <b>FamiliCircle</b></a>
    <div class='controls'>
    </div>
    """

  setEnabled: (enabled) ->
    current = if enabled then "enabled" else "disabled"
    old = if enabled then "disabled" else "enabled"
    @$el.find(".status").html(current)
    $(@dialogCls).removeClass("grandmabook-#{old}").addClass("grandmabook-#{current}")
    @enabled = enabled

  beforeRemove: ->
    @observer.disconnect()  if @observer
    $(@ui.messageBody).off "DOMSubtreeModified", @doBodyCheck
    @ui.sendButton.off()  if @ui.sendButton

  render: ->
    tooltip = undefined
    tooltip = @tooltip
    @$el.html @template(tooltip: tooltip)
    @ui.checkbox = @$el.find(".grandmabook-js-checkbox")
    @ui.label = @$el.find(".grandmabook-css-newcompose")
    @$el.find(".enable-link").on 'click', (e) =>
      e.preventDefault()
      @setEnabled true
      true
    @

  watchEmailDialog: ->
    config =
      childList: true
      subtree: true

    console.verbose "GRANDMABOOK: Initializing Compose Mutation Observer for " + @dialogCls
    @observer = new MutationObserver (mutations) =>
      try
        send = $("" + @dialogCls + " .T-I.J-J5-Ji.aoO.T-I-atl.L3")

        if send.length and not @ui.sendButton
          @ui.sendButton = send
          @initializeSendButton()
        trashCls = ".og.T-I-J3"
        trash = $("" + @dialogCls + " " + trashCls)
        if trash.length and not @ui.trashcan
          console.verbose "GRANDMABOOK: Found Trashcan"
          @ui.trashcan = @ui.dialog.find(trashCls).parents(".J-J5-Ji[id]").last()
          @attachBar()  unless @wisestamp

        #handlers = $form.data('events')['submit']
        #lastHandler = handlers.pop()
        #handlers.splice(0, 0, lastHandler)

        #wisestamp = $("#WiseStamp_icon")
        #if @wisestamp and @ui.trashcan and wisestamp.length and not @ui.wisestamp
        #  @ui.wisestamp = wisestamp
        #  setTimeout (->
        #    @attachBar()
        #    @initialTrackerCheck()
        #  ), 500
      catch _error
        err = _error
        console.verbose "GRANDMABOOK: " + err.message

    try
      target = $("" + @dialogCls).get(0)
      return @observer.observe(target, config)
    catch _error
      err = _error
      return console.verbose("GRANDMABOOK: " + err.messgae)

  initializeTextBox: ->
    if @enabled
      @ui.textBox.prepend "<span class='oG grandmabook-note grandmabook-tracked'>Tracked Email</span>"
      @ui.textBox.prepend "<span class='oG grandmabook-note grandmabook-untracked'>Untracked Email</span>"

  initializeSendButton: ->
    $btn = @ui.sendButton.clone()
    @ui.sendButton.before($btn)
    @ui.sendButton.css 'display', 'none'
    $btn.on 'click', _.bind(@clickSend, @)

  rewriteBody: (callback) ->
      $editable = $("#{@dialogCls} .editable")
      $.post "#{@HOST}/api/id", {}, (data) =>
        $editable.prepend("<h3>Click here to see content!</h3> <a href='#{data.url}'>#{data.url}</a><br><br>")
        recipient = $("#{@dialogCls} .vT").text()
        callback()
        @triggerWait(data.id, recipient)

  triggerWait: (id, recipient) ->
    win = window.open "#{@HOST}/sharing/#{id}/#{recipient}", '_blank'
    win.focus();


  clickSend: (e) ->
    unless @enabled
      return @ui.sendButton.click()

    @rewriteBody (id) =>
      @ui.sendButton.click()

  attachBar: ->
    console.verbose "GRANDMABOOK: Attaching Grandmabook Bar"
    @dialogEl.find(".aDh").before @render().el


annotateCompose = ->
  mw = new MainWatcher()
  mw.watchForChanges()
  #$bottomRight = $ '.gUaz5'
  #console.log $bottomRight

annotateCompose()