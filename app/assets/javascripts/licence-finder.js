$(function() {

	/* Add one thing to another thing, alphabetically */
	function swapList(elem, targetList, state){
	
		var id = $(elem).attr("href").split("sectors=");
		if(id[1].indexOf("_")){
			var id = id[1].split("_");
			var id = id[0]
		}
		else{
			id = id[1];
		}

		
		var plainTextTitle = $(elem).parent().children("span").text();

		if(state == "add"){
			var toAdd = "<li><input type='hidden' value='"+id+"' name='sector_ids[]' id='sector_ids_'><span class='sector-name'>"+plainTextTitle+"</span> <a href='/licence-finder/sectors?sectors="+id+"'>Remove</a></li>";
		}
		else{
			var toAdd = "<li><span class='sector-name'>"+plainTextTitle+"</span><a href='/licence-finder/sectors?sectors="+id+"'>Add</a></li>";
		};

    var added = false;
    var targetListItems = $(targetList+" li");

   	$(targetListItems).each(function(){
  		if($(this).text() > plainTextTitle){
  			$(toAdd).insertBefore($(this));
  				added = true;
  				return false;
  		};
  	});
  	
  	if(!added) $(toAdd).appendTo(targetList);
  	$(elem).parent().remove();
  	setupEvents();
	};


	function setupEvents(){
		$(".business-sector-picked a").off("click");
		$(".business-sector-picked a").on("click", function(){
			swapList(this, ".search-picker", "remove")
			return false;
		});
		$(".search-picker a").off("click");
		$(".search-picker a").on("click", function(){
			swapList(this, ".business-sector-picked ul", "add")
			return false;
		});
	};

	function init(){
		if($(".business-sector-picked ul").length == 0){
			$("<ul></ul><input type='submit' value='Next step' name='commit' class='button medium'>").insertAfter(".business-sector-picked h3");
		};
		setupEvents();
	};

	// setup for given step section
	function setupElements(){

	};

	// manage url
	function manageURL(){

	};

	init();

});
