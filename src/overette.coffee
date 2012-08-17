$.fn.overette = (options) ->
	return this.each =>
		$this = $(this)
		Overette.initializeTrigger $this, options

Overette = 
	dataSrcAttr:  'data-o-src'
	dataTypeAttr: 'data-o-type'

	defaults:
		popover:
			position: 	["center","bottom"]
		dialog:
			position:   ["center","center"]
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

# conditionals
	isLoaded: ($o) ->
		return $o.hasClass ("overette-loaded")

# small methods
	generateUniqueId: (from) ->
		"overette-ready-" + Math.random().toString(36).substring(7)

# actions
	onUpdate: ($o, callback) ->
		$o.bind "overette:update", callback

	triggerUpdate: ($o) ->
		$o.trigger "overette:update"

	onClose: ($o, callback) ->
		$o.bind "overette:close", callback

	triggerClose: ($o) ->
		$o.trigger "overette:close"

# types
	popover: 
		init: (trigger, src, options = {}) ->
			# returns overette object ($o)
			$o = $(src)
			if Overette.isLoaded $o
				$o.fadeIn(100)
				return $o
			else
				$o = Overette.popover.container
				Overette.popover.setup($o, trigger, $.extend(Overette.defaults.popover, options))

				$('body').append($o)
				$o.fadeIn(100)
				return $o

		replace: (contents) ->
			this.removeClass "loading"
			this.find(".overette-content").html(contents)
			Overette.triggerUpdate this

		setup: ($o, trigger, options) ->
			Overette.repositionWhenWindowResized.call $o, trigger, options['position']
			Overette.closeWhenOverlayClicked.call $o, options
			
			Overette.onUpdate $o, =>
				Overette.repositionAroundTrigger.call $o, trigger, options
				$o.addClass("overette-loaded").removeClass("loading")

			Overette.onClose $o, =>
				$o.fadeOut(100)

			$o.attr("id", Overette.generateUniqueId(trigger.attr(Overette.dataSrcAttr)))
			trigger.attr(Overette.dataSrcAttr, "#"+$o.attr("id"))

		container: $("<div class=\"overette-container overette-popover loading not-ready\"><div class=\"overette-overlay\"> </div><div class=\"overette-arrow\"> </div><div class=\"overette-content\"> </div></div>")


	dialog:
		replace: ($o, contents, options = {}) ->
			console.log "opening dialog"

	dropdown:
		replace: ($o, contents, options = {}) ->
			console.log "opening dropdown"

# Methods with "this" context set to $o
	closeWhenOverlayClicked: (options) ->
		this.find(".overette-overlay").bind "click", =>
			Overette.close this

	repositionWhenWindowResized: (trigger, options) ->
		$(window).resize =>
			Overette.repositionAroundTrigger.call this, trigger, options
		Overette.repositionAroundTrigger.call this, trigger, options

	repositionAroundTrigger: (trigger, options) ->
		# TODO: Allow for other options besides center
		# TODO: Allign trigger and add trigger class
		coordinates = trigger.offset()

		content_width = this.find('.overette-content').outerWidth() 
		arrow_width = this.find(".overette-arrow").outerWidth()

		# CASE: x=center, y=bottom, relative to trigger and top boundry of box
		base_left = coordinates.left + trigger.outerWidth()/2

		coordinates.left = base_left - content_width/2
		if coordinates.left < 0
			coordinates.left = 0

		this.find('.overette-content')
		.css('left', coordinates.left)
		.css 'top', coordinates.top+trigger.height()+this.find('.overette-arrow').height()-1

		this.find('.overette-arrow').css 'left', base_left - arrow_width/2
