$(function() {

	$(".search-picker a").on("click", function(e){
		console.log($(this).parent().children("span").text())

		var id = $(this);
		console.log(id);

		addLicence($(this).parent().children("span").text(), id)
		
		e.preventDefault();
		return false;
	})

	function addLicence(plainTextTitle, id){
		console.log("plaintext: "+plainTextTitle+" id: "+id);
	}

	function removeLicence(id){

	}

});
