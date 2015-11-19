/// <reference path='../../../../typings/slatwallTypescript.d.ts' />
/// <reference path='../../../../typings/tsd.d.ts' />
class ConfirmationController{
  //@ngInject
  constructor($scope,$log,$modalInstance){
      $scope.deleteEntity = function (entity) { 
      $log.debug("Deleting an entity.");
      $log.debug($scope.entity);
      this.close();
    };
    /**
    * Closes the modal window
    */
    $scope.close = function () { 
      $modalInstance.close();
    }; 
    /**
    * Cancels the modal window
    */
    $scope.cancel = function () {
      $modalInstance.dismiss("cancel");  
    };
  }
}
export{
  ConfirmationController
}
