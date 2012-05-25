$(function() {

	var section,
		pluralSection;

	/* Add one thing to another thing, alphabetically */
	function swapList(elem, targetList, state){
		if($(".business-"+section+"-picked ul").length == 0){
            var picked_sectors = "<ul id='picked-business-sectors'></ul><input type='submit' value='Next step' name='commit' class='button medium'>";
			$(picked_sectors).insertAfter(".business-"+section+"-picked h3");
			$(".hint").css("display", "none");
		};

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
        // this handles adding/removing logic:
        // adding the initial elements is handled in the swapList function
        var picked = $(".business-"+section+"-picked");
        if (picked.find('.hint').length == 0) {
            var el = $('<p class="hint">Your chosen sectors will appear here</p>');
            $(".business-"+section+"-picked").append(el);
        }
        picked = picked.find("ul");
        if (picked.length > 0 && picked.find('li').length == 0) {
            $('.hint').removeAttr('style');
            $(".business-"+section+"-picked input[type=submit]").css('display', 'none');
        }
        else if (picked.length > 0 && picked.find('li').length > 0) {
            $('.hint').css('display', 'none');
            $(".business-"+section+"-picked input[type=submit]").removeAttr('style');
        }
	};

    function setupSearchForMore() {
        $("#search-again-button").off("click");
        $("#search-again-button").on("click", function() {
            var sectors = $.makeArray(
                $("#picked-business-sectors input").map(function(i, item) {
                    return item.value;
                })
            ).join("_");
            window.location.search = "sectors=" + sectors;

            return false;
        });
    }

	function init(){
		if($(".business-sector-picked").length > 0){
			section = "sector";
			pluralSection = "sectors"
		}
		else{
			section = "activity";
			pluralSection = "activities";
		}


		setupEvents();
        setupSearchForMore();

	};


	init();

});
