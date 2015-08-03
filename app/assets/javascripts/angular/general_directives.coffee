angular.module('general_directives', [])

.directive 'errorMessage', ['$timeout',
  ($timeout) ->
    {
      link: (scope, elem) ->
        scope.$on 'displayError', (e, message) ->
          elem.html(message)
          elem.fadeIn()
          $timeout ( -> elem.fadeOut()), 2000
    }
]

.directive 'formSubmit', ->
  {
    require: 'form',
    link: (scope, elem, attrs, ctrl) ->
      elem.on 'submit', ->
        return false if scope.$formDisabled

        if ctrl.$valid
          scope.$formDisabled = true
          scope.$apply(attrs.formSubmit)
          .finally ->
            scope.$formDisabled = false

        return false
  }

.directive 'playerAutocomplete', ['BASE_URL',
  (BASE_URL) ->
    {
      require: '?ngModel',
      link: (scope, elem, attrs, ngModel) ->
        elem.attr('data-autocomplete', "#{BASE_URL}/players/autocomplete_player_name")
        elem.attr('data-autocomplete-label', "Sorry, no players found")
        elem.attr('data-update-elements', '{}')
        $('input[player-autocomplete]').railsAutocomplete()
        elem.bind 'railsAutocomplete.select', (e, data) ->
          ngModel.$viewValue  = data.item.label
          ngModel.$modelValue = data.item.id
    }
]

.directive 'restrictToMaxTags', ->
  KEY_BACKSPACE =  8
  KEY_TAB = 9

  {
    require: '?ngModel',
    priority: -10,
    link: ($scope, $element, $attrs, ngModel) ->
        tagsInputScope = $element.isolateScope()
        input          = $element.find('input')
        maxTags        = if $attrs.maxTags then parseInt($attrs.maxTags, '10') else null
        placeholder    = undefined

        getTags = ->
          ngModel.$modelValue

        checkTags = ->
          if reachedMaxTagLimit()
            # trigger the autocomplete to hide
            tagsInputScope.events.trigger('input-blur')
            placeholder = input.attr('placeholder')
            input.attr('placeholder', '')
          else
            input.attr('placeholder', placeholder)

        reachedMaxTagLimit = ->
          tags = getTags()
          return false unless tags
          return false unless tags.length
          tags.length >= maxTags

        $scope.$watchCollection(getTags, checkTags)

        # prevent any keys from being entered into
        # the input when max tags is reached
        input.on 'keydown', (event) ->
          if reachedMaxTagLimit() && event.keyCode != KEY_BACKSPACE && event.keyCode != KEY_TAB
            event.stopImmediatePropagation()
            event.preventDefault()

        # prevent the autocomplete from being triggered
        input.on 'focus', (event) ->
          if reachedMaxTagLimit()
            tagsInputScope.hasFocus = true
            event.stopImmediatePropagation()
  }
