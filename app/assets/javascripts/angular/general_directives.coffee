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

.directive 'matchParticipantScore', ['$compile', ($compile) ->
  {
    scope: {
      participant: '=matchParticipantScore',
      min:         '@',
      max:         '@',
      name:        '@formName'
    },
    templateUrl: "match_participant_score.html"
  }
]

.directive 'scoringButton', ->
  {
    link: (scope, elem, attrs, ctrl) ->
      min = parseInt(scope.min)
      max = parseInt(scope.max)
      elem.text(attrs.direction)

      scope.updateScore = (symbol) ->
        newScore = eval("scope.participant.goals #{symbol} 1")
        scope.participant.goals = newScore if canUpdateScore(newScore)

      canUpdateScore = (newScore) ->
        newScore >= min
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

.directive 'focusElement', ->
  {
    link: (scope, elem, attr, ctrl) ->
      findInput = ->
        if elem.is('input') then elem else elem.find('input')

      input = findInput()
      if input
        input.blur  -> elem.removeClass('focus')

      scope.$on 'inputFocused', (e, elementToFocus) ->
        elementToFocus.addClass('focus')

      scope.$watch ->
        try
          eval("scope.#{attr.focusElement}")
        catch
          false
      , (newVal, oldVal) ->
        if newVal
          input = findInput()[0]
          input.focus() if input

  }

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
        placeholder    = $element.attr('placeholder')

        getTags = ->
          ngModel.$modelValue

        checkTags = ->
          if reachedMaxTagLimit()
            # trigger the autocomplete to hide
            tagsInputScope.events.trigger('input-blur')
            input.attr('placeholder', '')
            input.css('max-width', '8px')
          else
            input.attr('placeholder', placeholder)
            input.css('max-width', '')

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
          $scope.$emit('inputFocused', $element)
          if reachedMaxTagLimit()
            tagsInputScope.hasFocus = true
            event.stopImmediatePropagation()
  }
