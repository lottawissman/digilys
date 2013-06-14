window.Digilys ?= {}

window.Digilys.loadMask = ($fields) ->
    $fields.css("position", "relative")
    $fields.append('<div class="load-mask"/>')


# Common method for initializing a select2-based autocomplete
window.Digilys.autocomplete = (selectorOrElem, options = {}) ->

    options.results ?= (data, page) ->
        { results: data.results, more: data.more }

    $(selectorOrElem).each ->
        $field = $(this)

        opts =
            width:              "off"
            multiple:           $field.data("multiple")
            minimumInputLength: 0
            placeholder:        $field.data("placeholder")
            ajax:
                url:            $field.data("url")
                results:        options.results
                data:           options.data

        opts.formatResult = options.formatResult if options.formatResult

        $field.select2(opts)

        data = $field.data("data")

        if data
            $field.select2("data", data)

        if $field.data("autofocus")
            $field.select2("open")

$ ->
    $("[autofocus]:not(:focus)").eq(0).focus()

    $("input.datepicker").datepicker(
        language:  "sv"
        format:    "yyyy-mm-dd"
        weekStart: 1
        autoclose: true
    )

    $("input.tag-field").each ->
        $field = $(this)

        tags = $field.data("existing-tags") ? []

        $field.select2(
            tags: tags
        )

        if $field.data("autofocus")
            $field.select2("open")

    $("form").on("change", ":input", (event) ->
        if !$(event.target).data("preventNavigationConfirmation")
            window.onbeforeunload = ->
                return window.Digilys.navigationConfirmation
    ).on("submit", ->
        window.onbeforeunload = null
    )
