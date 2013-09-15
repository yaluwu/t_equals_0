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
      _enabled = true
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
  LOGO: 'http://www.familicircle.com/images/logo_40_trans.png'

  constructor: (params) ->
    {@emailId, @dialogEl, @enabled, @enabled_url, @tooltip, @callback} = params
    @dialogCls = ".grandmabook-nc-email-#{@emailId}"
    @ui =
      dialog: @dialogEl
    @$el = $("<p class='grandmabook-container'/>")
    @el = @$el[0]

    @watchEmailDialog()

  template: (params) ->
    """<div class='#{params.dialogCls}'>
    <img src='#{@LOGO}' alt='FamiliCircle'>
    Yo, what up
    </div>
    """

  clickedDisable: ->
    url = undefined
    url = @enabled_url
    window.open url, "_blank"

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
    @

  watchEmailDialog: ->
    config =
      childList: true
      subtree: true

    console.verbose "GRANDMABOOK: Initializing Compose Mutation Observer for " + @dialogCls
    @observer = new MutationObserver (mutations) =>
      try
        text_box = $("#{@dialogCls} .MqbIU")
        if text_box.length and not @ui.textBox
          @ui.textBox = text_box
          @initializeTextBox()
        else
          text_box = $("#{@dialogCls} .aWQ")
          if text_box.length and not @ui.textBox
            @ui.textBox = text_box
            @initializeTextBox()
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
        wisestamp = $("#WiseStamp_icon")
        if @wisestamp and @ui.trashcan and wisestamp.length and not @ui.wisestamp
          @ui.wisestamp = wisestamp
          setTimeout (->
            @attachBar()
            @initialTrackerCheck()
          ), 500
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
    @ui.sendButton.html "<i class='grandmabook-send-button-icon icon-grandmabook'></i>Send"

  attachBar: ->
    form_elem = undefined
    console.verbose "GRANDMABOOK: Attaching Grandmabook Bar"
    @dialogEl.find(".aDh").before @render().el

    return
    form_elem = @ui.dialog.find("form")
    @ui.hidden_elem = $("<input>").attr(
      type: "hidden"
      name: "grandmabook_tracked"
      value: true
    )
    @ui.hidden_elem.appendTo form_elem
    @trackerBoxChecked = true
    @attached_callback true


annotateCompose = ->
  mw = new MainWatcher()
  mw.watchForChanges()
  #$bottomRight = $ '.gUaz5'
  #console.log $bottomRight


annotateCompose()