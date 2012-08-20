$.fn.overette = (options) ->
	return this.each ->
		$this = $(this)
		Overette.initializeTrigger $this, options

Overette = 
	dataSrcAttr:	'data-o-src'
	dataTypeAttr:	'data-o-type'
	dataActionAttr:	'data-o-action'

	defaults:
		popover:
			position: 	["center","bottom"]
		dialog:
			position:	["center","center"]
		dropdown:
			position: 	["center","bottom"]

	initializeTrigger: (element, options) ->
		Overette.observeOpenTriggers element, options

	observeOpenTriggers: (element, options) ->
		element.bind 'click', ->
			Overette.openFromElement element

	openFromElement: (element, options) ->
		Overette.open element, element.attr(Overette.dataSrcAttr), element.attr(Overette.dataTypeAttr)

	open: (trigger, src, type, options = {}) ->
		$o = Overette[type].init(trigger, src, options)
		if not Overette.isLoaded($o)
			Overette.retrieveData $o, src, (err, contents) ->
				# create element based on type
				Overette[type].replace.call($o, contents.html())

	close: ($o) ->
		Overette.triggerClose $o

	retrieveData: ($o, src, callback) ->
		if src.charAt(0) == "#"
			$data = $(src)
			callback null, $data
		else
			callback new Error "Unsupported Source"

	action: (action, $o) ->
		switch action
			when "selection"
				console.log "selection!"
			when "close"
				Overette.close $o

# conditionals
	isLoaded: ($o) ->
		return $o && $o.hasClass ("overette-loaded")

# small methods
	generateUniqueId: (from) ->
		"overette-ready-" + Math.random().toString(36).substring(7)

	show: ($o) ->
		$o.fadeIn(100)

	hide: ($o) ->
		$o.fadeOut(100)

	assignId: ($o, trigger) ->
		$o.attr("id", Overette.generateUniqueId(trigger.attr(Overette.dataSrcAttr)))
		trigger.attr(Overette.dataSrcAttr, "#"+$o.attr("id"))

# actions
	onUpdate: ($o, callback) ->
		$o.bind "overette:update", callback

	triggerUpdate: ($o) ->
		$o.trigger "overette:update"

	onClose: ($o, callback) ->
		$o.bind "overette:close", callback

	triggerClose: ($o) ->
		$o.trigger "overette:close"

	observeActions: ($o, options) ->
		observe = ->
			$o.find('*['+Overette.dataActionAttr+']').on 'click', ->
				Overette.action $(this).attr(Overette.dataActionAttr), $o

		Overette.onUpdate $o, observe
		observe()

# types
	popover: 
		init: (trigger, src, options = {}) ->
			# returns overette object ($o)
			$o = $(src)
			if Overette.isLoaded $o
				Overette.show($o)
			else
				$o = Overette.popover.container
				Overette.popover.setup($o, trigger, $.extend(Overette.defaults.popover, options))
				$('body').append($o)
				Overette.show($o)
			return $o

		replace: (contents) ->
			this.removeClass "loading"
			this.find(".overette-content").html(contents)
			Overette.triggerUpdate this

		setup: ($o, trigger, options) ->
			Overette.repositionAroundTriggerWhenWindowResized.call $o, trigger, options
			Overette.closeWhenOverlayClicked.call $o, options
			Overette.observeActions $o, options
			
			Overette.onUpdate $o, =>
				Overette.repositionAroundTrigger.call $o, trigger, options
				$o.addClass("overette-loaded").removeClass("loading")

			Overette.onClose $o, =>
				Overette.hide($o)

			Overette.assignId $o, trigger

		container: $("<div class=\"overette-container overette-popover loading\"><div class=\"overette-overlay\"> </div><div class=\"overette-arrow\"> </div><div class=\"overette-content\"> </div></div>")


	dialog:
		init: (trigger, src, options = {}) =>
			$o = $(src)
			if Overette.isLoaded $o
				Overette.show($o)
			else
				$o = Overette.dialog.container
				Overette.dialog.setup($o, trigger, $.extend(Overette.defaults.dialog, options))
				$('body').append($o)
				Overette.show($o)
			return $o

		replace: (contents) ->
			this.removeClass "loading"
			this.find(".overette-content").html(contents)
			Overette.triggerUpdate this

		setup: ($o, trigger, options) ->
			Overette.centerWhenWindowResized.call $o, trigger, options
			Overette.observeActions $o, options

			Overette.onUpdate $o, =>
				Overette.centerInWindow.call $o, trigger, options
				$o.addClass("overette-loaded").removeClass("loading")

			Overette.onClose $o, =>
				Overette.hide($o)

			Overette.assignId $o, trigger

		container: $("<div class=\"overette-container overette-dialog loading\"><div class=\"overette-overlay\"> </div><div class=\"overette-content\"> </div></div>")

	dropdown:
		init: (trigger, src, options = {}) ->
			# returns overette object ($o)
			$o = $(src)
			if Overette.isLoaded $o
				Overette.show($o)
			else
				$o = Overette.dropdown.container
				Overette.dropdown.setup($o, trigger, $.extend(Overette.defaults.popover, options))
				$('body').append($o)
				Overette.show($o)
			return $o

		replace: (contents) ->
			this.removeClass "loading"
			this.find(".overette-content").html(contents)
			Overette.triggerUpdate this

		setup: ($o, trigger, options) ->
			Overette.repositionAroundTriggerWhenWindowResized.call $o, trigger, options
			Overette.closeWhenOverlayClicked.call $o, options
			Overette.observeActions $o, options
			
			Overette.onUpdate $o, =>
				Overette.repositionAroundTrigger.call $o, trigger, options
				$o.addClass("overette-loaded").removeClass("loading")

			Overette.onClose $o, =>
				Overette.hide($o)

			Overette.assignId $o, trigger

		container: $("<div class=\"overette-container overette-dropdown loading\"><div class=\"overette-overlay\"> </div><div class=\"overette-arrow\"> </div><div class=\"overette-content\"> </div></div>")

# Methods with "this" context set to $o
	closeWhenOverlayClicked: (options) ->
		this.find(".overette-overlay").bind "click", =>
			Overette.close this

	repositionAroundTriggerWhenWindowResized: (trigger, options) ->
		$(window).resize =>
			Overette.repositionAroundTrigger.call this, trigger, options
		Overette.repositionAroundTrigger.call this, trigger, options

	centerWhenWindowResized: (trigger, options) ->
		$(window).resize =>
			Overette.centerInWindow.call this, trigger, options
		Overette.centerInWindow.call this, trigger, options

	centerInWindow: (trigger, options) ->
		# TODO: Allow for other options
		$content = this.find('.overette-content')
		$window = $(window)

		content_width = $content.outerWidth()
		window_width = $window.outerWidth()
		left = window_width/2 - content_width/2
		left = 0 if left < 0

		content_height = $content.outerHeight()
		window_height = window.innerHeight
		top = window_height/2 - content_height/2
		top = 0 if top < 0

		$content.css('left',left).css('top',top)

	repositionAroundTrigger: (trigger, options) ->
		# TODO: Allow for other options besides center
		# TODO: Allign trigger and add trigger class
		coordinates = trigger.offset()

		content_width = this.find('.overette-content').outerWidth() 
		arrow_width = this.find(".overette-arrow").outerWidth()
		window_width = $(window).width()

		# CASE: x=center, y=bottom, relative to trigger and top boundry of box
		base_left = coordinates.left + trigger.outerWidth()/2

		coordinates.left = base_left - content_width/2

		if coordinates.left < 0
			coordinates.left = 0
		else if coordinates.left + content_width > window_width
			coordinates.left = window_width - content_width

		this.find('.overette-content')
		.css('left', coordinates.left)
		.css 'top', coordinates.top+trigger.height()+this.find('.overette-arrow').height()

		this.find('.overette-arrow').css('left', base_left - arrow_width/2).css('top',coordinates.top+trigger.height()+2)