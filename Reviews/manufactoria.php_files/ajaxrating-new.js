function updateRating(request) {
			/* alert(request.responseText);  // DEBUGGING */
			var resp_arr = request.responseText.split("||");
			if (resp_arr[0] == 'ERR') {
				alert(resp_arr[1]);
			}

			if (resp_arr[0] == 'OK') {
				var type = resp_arr[1];
				var id = resp_arr[2];
				var r = parseInt(resp_arr[3]);
				var b = 1;
				var total = parseInt(resp_arr[4]) - r;
                                var count = parseInt(resp_arr[5]) -1;
                                var a = 0;
                //                var theUL = document.getElementById('rater_ul'+type+id); // the UL
                //	        if (theUL) { theUL.innerHTML = '<li id="rater_li'+type+id+'" class="current-rating" style="width:0px"></div>'; }
                                updatePage(type,id,r,b,total,count,a);
			}
}

		function pushRating(type,id,r,b,total,count,a) {
                        updatePage(type,id,r,b,total,count,a);
                //        var theUL = document.getElementById('rater_ul'+type+id); // the UL
                //	if (theUL) { theUL.innerHTML = '<div class="loading"></div>'; }
      		        new ajax('/mt4/plugins/AjaxRating/mt-vote.cgi', {postBody: 'obj_type='+type+'&r='+r+'&obj_id='+id+'&blog_id='+b+'&a='+a, onComplete: updateRating});
		}

function updatePage (type,id,r,b,total,count,a) {
	if(count >= 20) {
		var avg = Math.round(((total + r)/(count + 1))*10)/10;
		if (type == "comment") {
		    var new_width =  Math.round(avg / 5 * 150);
		} else {
		    var new_width =  Math.round(avg / 5 * 150);
		}
		var span_avg = document.getElementById("ajaxrating_" + type + "_" + id + "_avg");
		if (span_avg) {span_avg.innerHTML = avg; }
		var span_ttl = document.getElementById("ajaxrating_" + type + "_" + id + "_ttl");
		if (span_ttl) {span_ttl.innerHTML =  total + r; }
		var rater_li = document.getElementById("rater_li" + type +  id);
		if (rater_li) {rater_li.style.width =  new_width.toString() + "px"; }
		var thumb = document.getElementById("thumb" + type +  id);
		if (thumb) {thumb.innerHTML =  ""; }
	}
	var span_cnt = document.getElementById("ajaxrating_" + type + "_" + id + "_cnt");
	if (span_cnt) {span_cnt.innerHTML =  count + 1; }
	var thanks = document.getElementById("thanks" + type +  id);
	if (thanks) {thanks.innerHTML =  "Thanks for voting!"; }
}

function showComment(id) {
   var threshold = document.getElementById("threshold-" + id);
   if (threshold) {threshold.innerHTML =  ""; }
   var comment = document.getElementById("comment-" + id);
   if (comment) {comment.style.display = "block"; }
}

function hideComments(comments) {
      var threshold = getCookie("threshold");
      if (!threshold) { threshold = -9999; }
      for (var i=0; i < comments.length - 1; i++) {
          var comment = document.getElementById("comment-" +  comments[i]);
          var total = document.getElementById("ajaxrating_comment_" +  comments[i] + "_ttl").innerHTML;
          if (parseInt(total) < parseInt(threshold)) { 
              comment.style.display = "none"; 
              var threshold_span = document.getElementById("threshold-" + comments[i]);
              if (threshold_span) {threshold_span.style.display =  "block"; }
          }
      }
      if (document.threshold_form) { document.threshold_form.threshold.value = threshold; }
}

function setThreshold (f) {
    var now = new Date();
    fixDate(now);
    now.setTime(now.getTime() + 365 * 24 * 60 * 60 * 1000);
    now = now.toGMTString();
    setCookie('threshold', f.threshold.value, now, '/', '', '');
}
 
function reportComment (id) {
    new ajax('/mt4/plugins/AjaxRating/mt-report.cgi', {postBody: 'id='+id, onComplete: updateRating});
}