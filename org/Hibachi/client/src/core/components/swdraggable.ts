/// <reference path='../../../typings/hibachiTypescript.d.ts' />
/// <reference path='../../../typings/tsd.d.ts' />

class SWDraggableController{
    
    public draggable:boolean; 

    //@ngInject
    constructor(){
        if(angular.isUndefined(this.draggable)){
            this.draggable = false; 
        }
    }

}

class SWDraggable implements ng.IDirective{
    public restrict:string = 'EA';
    public scope={};
    public bindToController={
        draggable:"=?",
        draggableRecord:"=?",
        draggableKey:"=?"
    };

    public static Factory(){
        var directive:ng.IDirectiveFactory=(
            corePartialsPath,
            utilityService,
            draggableService,
			hibachiPathBuilder
        ) => new SWDraggable(
            corePartialsPath,
            utilityService,
            draggableService,
			hibachiPathBuilder
        );
        directive.$inject = [
            'corePartialsPath',
            'utilityService',
            'draggableService',
			'hibachiPathBuilder'
        ];
        return directive;
    }

    public controller=SWDraggableController;
    public controllerAs="swDraggable";
    //@ngInject
    constructor(
        public corePartialsPath,
        public utilityService,
        public draggableService,
		public hibachiPathBuilder
     ){
    }

    public link:ng.IDirectiveLinkFn = (scope:any, element:any, attrs:any) =>{
        angular.element(element).attr("draggable", "true");
        console.log("draggable link");
        var id = angular.element(element).attr("id");
        if (!id) {
            id = this.utilityService.createID(32);  
        } 
        element.bind("dragstart", function(e) {
            e = e.originalEvent || e;
            e.stopPropagation(); 
            if(!scope.swDraggable.draggable) return false; 
            element.addClass("s-dragging");
            //set the drag data
            e.dataTransfer.setData("application/json", scope.swDraggable.draggableRecord);
            e.dataTransfer.effectAllowed = "move";
            e.dataTransfer.setDragImage(element[0], 0, 0);
        });
        
        element.bind("dragend", function(e) {
            e = e.originalEvent || e;
            e.stopPropagation(); 
            element.removeClass("s-dragging");
            
        });

        /*element.on('dragenter', function (e) {
            e = e.originalEvent || e;
            e.stopPropagation(); 
        });

        element.on('dragover', function(e) {
            e = e.originalEvent || e;
            e.stopPropagation(); 
        });

        element.on('drop', function(e) {
            e = e.originalEvent || e;
            e.stopPropagation(); 
        }); 

        element.on('dragleave', function(e) {
            e = e.originalEvent || e;
            e.stopPropagation(); 
        });*/
    }
}
export{
    SWDraggable
}

