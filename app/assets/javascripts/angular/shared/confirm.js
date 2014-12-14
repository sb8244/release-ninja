/**
 * A generic confirmation for risky actions.
 * Usage: Add attributes:
 * * ng-confirm-message="Are you sure?"
 * * ng-confirm-click="takeAction()" function
 */
angular.module("shared").directive('ngConfirmClick', [function() {
  return {
    restrict: 'A',
    link: function(scope, element, attrs) {
      element.bind('click', function() {
        var message = attrs.ngConfirmMessage;
        if (message && confirm(message)) {
          scope.$apply(attrs.ngConfirmClick);
        }
      });
    }
  }
}]);
