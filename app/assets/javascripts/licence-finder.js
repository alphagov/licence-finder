$(function() {

	var section,
		pluralSection;

	/* Add one thing to another thing, alphabetically */
	function swapList(elem, targetList, state){
	
		var id = $(elem).attr("href").split(pluralSection+"=");
		if(id[1].indexOf("_")){
			var id = id[1].split("_");
			var id = id[0];
		}
		
		else{
			id = id[1];
		};

		if(id.indexOf("&")){
			var id = id.split("&");
			var id = id[0];
		}
		
		var plainTextTitle = $(elem).parent().children("span").text();

		if(state == "add"){
			var toAdd = "<li><input type='hidden' value='"+id+"' name='"+section+"_ids[]' id='"+section+"_ids_'><span class='"+section+"-name'>"+plainTextTitle+"</span> <a href='/licence-finder/"+pluralSection+"?"+pluralSection+"="+id+"'>Remove</a></li>";
		}
		else{
			var toAdd = "<li><span class='"+section+"-name'>"+plainTextTitle+"</span> <a href='/licence-finder/"+pluralSection+"?"+pluralSection+"="+id+"'>Add</a></li>";
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
		$(".business-"+section+"-picked a").off("click");
		$(".business-"+section+"-picked a").on("click", function(){
			swapList(this, ".search-picker", "remove")
			return false;
		});
		$(".search-picker a").off("click");
		$(".search-picker a").on("click", function(){
			swapList(this, ".business-"+section+"-picked ul", "add")
			return false;
		});
	};

	function init(){
		if($(".business-sector-picked").length > 0){
			section = "sector";
			pluralSection = "sectors"
		}
		else{
			section = "activity";
			pluralSection = "activities";
		}
		
		if($(".business-"+section+"-picked ul").length == 0){
			$("<ul></ul><input type='submit' value='Next step' name='commit' class='button medium'>").insertAfter(".business-"+section+"-picked h3");
		};
		setupEvents();

	};


	// manage url
	function manageURL(){
		// add each to a url, with an underscore before
		if(section == "sector"){

		}
		else{
			
		}
	};

	init();

});
