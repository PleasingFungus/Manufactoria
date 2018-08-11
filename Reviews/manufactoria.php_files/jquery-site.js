$(document).ready(function(){
	var style = "h7";
	$("#tagsearch-form input[name='sort']").click(function() {
		if($(this).attr("value") === "date") {
			var loc = 'http://jayisgames.com/tag/'+$("input[name='tag']").attr("value");
			window.location = loc;
		} else {
			var loc = 'http://jayisgames.com/tag/'+$("input[name='tag']").attr("value")+'/rating';
			window.location = loc;
		}
	});
	$("#walkthroughs-form input[name='sort']").click(function() {
		if($(this).attr("value") === "date") {
			var loc = 'http://jayisgames.com/walkthroughs/';
			window.location = loc;
		} else {
			var loc = 'http://jayisgames.com/walkthroughs/a';
			window.location = loc;
		}
	});
	if($("#sort_form").css("display") == "none") $("#sort_form").slideDown("slow");
	$("a.addGame").each(function(i){
		$(this).get(0).onclick = null;
   		$(this).click(function() {
	 		if($("div.Gamecode"+i).css("display") == "none") $("div.Gamecode"+i).slideDown("slow");
			else $("div.Gamecode"+i).slideUp("slow");
			return false;
		});
 	});
	$("#banner-link img").hover(
      function () {
        $(this).attr('src','/images/pokedstudio-hover.jpg');
      }, 
      function () {
        $(this).attr('src','/images/pokedstudio-hotspot.jpg');
      }
    );

	$(".comment-content a").not($(".comment-update-link a")).attr('target', '_blank');

	$("a.unavailable").replaceWith('<span id="fg_mac" class="button-disabled">Mac OS X Download</span>');

	$("a.addJIGame").click(function() {
		if($("div.JIGamecode").css("display") == "none") $("div.JIGamecode").slideDown("slow");
		else $("div.JIGamecode").slideUp("slow");
		return false;
	});
	$("a.toggle-recommended").click(function() {
 		if($("span.icons-recommended").css("display") == "none") {
			$("span.icons-toprated").hide();
			$.get("/icons_sql.php", function(data){
			  $("span.icons-recommended").html(data);
			});
			$("span.icons-recommended").show();
			$(this).css({"text-decoration":"underline"});
			$("a.toggle-toprated").css({"text-decoration":"none"});
			$.cookie('panelpref','recommend',{expires: 30, path: '/'});
		} else {
			// refresh recommended list
			$.get("/icons_sql.php", function(data){
			  $("span.icons-recommended").html(data);
			});
		}
		return false;
	});
	$("a.toggle-toprated").click(function() {
 		if($("span.icons-toprated").css("display") == "none") {
			$("span.icons-recommended").hide();
			$("span.icons-toprated").show();
			$(this).css({"text-decoration":"underline"});
			$("a.toggle-recommended").css({"text-decoration":"none"});
			$.cookie('panelpref','toprated',{expires: 30, path: '/'});
		}
		return false;
	});
	if($.cookie('panelpref') && $.cookie('panelpref') == "recommend")
		$("a.toggle-recommended").css({"text-decoration":"underline"});
	else
		$("a.toggle-toprated").css({"text-decoration":"underline"});
	$('a[href*="casualgameplay.com"]').removeAttr('target');
	$('a[href*="#walkthrough"]').removeAttr('target');
	var timeout = 0;
	var ready = "true";
	var featureCycle = Math.floor(Math.random()*8)+3;
	$("span#feature-panel1").click(function() {	
		if(!$("span#feature-panel1 a").hasClass("panel-on")) switchFeature("stop");
		return false;
	});
	$("span#feature-panel2").click(function() {	
		if(!$("span#feature-panel2 a").hasClass("panel-on")) switchFeature("stop");
		return false;
	});
	function complete() {
		ready="true";
	}
	function switchFeature(persist) {
		if(ready=="true") {
			ready="false";
			if($("span#feature-panel1 a").hasClass("panel-on")) {
				if($("div.new-games-panel:nth-child(2)").css("left") == "-1000px") $("div.new-games-panel:nth-child(2)").css({left:"0px"});
				$("span#feature-panel1 a").removeClass("panel-on");
				$("span#feature-panel2 a").addClass("panel-on");
			} else {
				if($("div.new-games-panel:first-child").css("left") == "-500px") $("div.new-games-panel:first-child").css({left:"500px"});
				$("span#feature-panel1 a").addClass("panel-on");
				$("span#feature-panel2 a").removeClass("panel-on");
			}
			if(featureCycle-- >=0) {
				clearTimeout(timeout);
				if(persist=="go") timeout = setTimeout(function(){switchFeature("go");},12000);
			}
			$("div.new-games-panel").animate({left:"-=500"}, 1500, complete);
		}
	}
	$(window).bind("load", function() { 
	    timeout = setTimeout(function(){switchFeature("go");},1000);
	}); 
});

