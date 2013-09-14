console.verbose = console.log

$ = jQuery

class MainWatcher
  constructor: (@emailId) ->
    @views = []

  attachGrandmabook: (el, text) ->
    $el = $(el)
    unless $el.hasClass("grandmabook-nc-email")
      $el.addClass "grandmabook grandmabook-nc-email grandmabook-nc-email-" + @emailId
      _enabled = true
      _enabled_url = ""
      _tooltip = "Track Email with Grandmabook"

      callback = (success) =>
        @emailId += 1
        @views.push view
        console.log "GRANDMABOOK: Created View"

      binded_callback = _.bind(callback, this)
      view = new GmailNewComposeEmailTracker(
        emailId: @emailId
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
  constructor: (@emailId, @dialogEl, @enabled, @enabled_url, @tooltip, @callback) ->
    @watchEmailDialog()

  GmailNewComposeEmailTracker::clickedDisable = ->
    url = undefined
    url = @enabled_url
    window.open url, "_blank"

  GmailNewComposeEmailTracker::beforeRemove = ->
    @observer.disconnect()  if @observer
    $(@ui.messageBody).off "DOMSubtreeModified", @doBodyCheck
    @ui.sendButton.off()  if @ui.sendButton

  GmailNewComposeEmailTracker::render = ->
    tooltip = undefined
    tooltip = @tooltip
    @$el.html @template(tooltip: tooltip)
    @ui.checkbox = @$el.find(".grandmabook-js-checkbox")
    @ui.label = @$el.find(".grandmabook-css-newcompose")
    this

  watchEmailDialog: ->
    _this = this
    config =
      childList: true
      subtree: true

    console.verbose "GRANDMABOOK: Initializing Compose Mutation Observer for " + @dialogCls
    @observer = new MutationObserver((mutations) ->
      err = undefined
      send = undefined
      text_box = undefined
      trash = undefined
      trashCls = undefined
      wisestamp = undefined
      try
        text_box = $("" + _this.dialogCls + " .MqbIU")
        if text_box.length and not _this.ui.textBox
          _this.ui.textBox = text_box
          _this.initializeTextBox()
        else
          text_box = $("" + _this.dialogCls + " .aWQ")
          if text_box.length and not _this.ui.textBox
            _this.ui.textBox = text_box
            _this.initializeTextBox()
        send = $("" + _this.dialogCls + " .T-I.J-J5-Ji.aoO.T-I-atl.L3")
        if send.length and not _this.ui.sendButton
          _this.ui.sendButton = send
          _this.initializeSendButton()
        trashCls = ".og.T-I-J3"
        trash = $("" + _this.dialogCls + " " + trashCls)
        if trash.length and not _this.ui.trashcan
          console.verbose "GRANDMABOOK: Found Trashcan"
          _this.ui.trashcan = _this.ui.dialog.find(trashCls).parents(".J-J5-Ji[id]").last()
          _this.attachBar()  unless _this.wisestamp
        wisestamp = $("#WiseStamp_icon")
        if _this.wisestamp and _this.ui.trashcan and wisestamp.length and not _this.ui.wisestamp
          _this.ui.wisestamp = wisestamp
          setTimeout (->
            _this.attachBar()
            _this.initialTrackerCheck()
          ), 500
      catch _error
        err = _error
        console.verbose "GRANDMABOOK: " + err.messgae
    )
    try
      target = $("" + @dialogCls).get(0)
      return @observer.observe(target, config)
    catch _error
      err = _error
      return console.verbose("GRANDMABOOK: " + err.messgae)

  GmailNewComposeEmailTracker::initializeTextBox = ->
    if @enabled
      @ui.textBox.prepend "<span class='oG grandmabook-note grandmabook-tracked'>Tracked Email</span>"
      @ui.textBox.prepend "<span class='oG grandmabook-note grandmabook-untracked'>Untracked Email</span>"

  GmailNewComposeEmailTracker::initializeSendButton = ->
    @ui.sendButton.html "<i class='grandmabook-send-button-icon icon-grandmabook'></i>Send"

  GmailNewComposeEmailTracker::getCreateByDefault = ->
    GmailNewComposeEmailTracker.__super__.getCreateByDefault.call(this) and @enabled

  GmailNewComposeEmailTracker::attachBar = ->
    form_elem = undefined
    _this = this
    console.verbose "GRANDMABOOK: Attaching Grandmabook Bar"
    @ui.trashcan.before @render().el
    form_elem = @ui.dialog.find("form")
    @ui.hidden_elem = $("<input>").attr(
      type: "hidden"
      name: "grandmabook_tracked"
      value: @getCreateByDefault()
    )
    @ui.hidden_elem.appendTo form_elem
    @trackerBoxChecked = @getCreateByDefault()
    unless @enabled
      @ui.label.addClass "grandmabook-disabled"
    else
      chrome.storage.sync.get "grandmabook-tip-accepted", (result) ->
        checkmark = undefined
        tip = undefined
        unless result["grandmabook-tip-accepted"]
          console.verbose "GRANDMABOOK: Attaching Tip"
          #tip = new SIG.Views.GmailEmailTrackerTip(mode: "new")
          #checkmark = $(".grandmabook-js-checkbox .faux-checkmark")
          #checkmark.addClass "grandmabook-disabled"
          _this.ui.checkbox.append $("<div>mike test</div>")

    @attached_callback true


annotateCompose = ->
  mw = new MainWatcher()
  mw.watchForChanges()
  #$bottomRight = $ '.gUaz5'
  #console.log $bottomRight


annotateCompose()