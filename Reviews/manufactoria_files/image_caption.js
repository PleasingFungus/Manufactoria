/*$Id: image_caption.js,v 1.1 2008/02/23 06:24:07 davidwhthomas Exp $*/
$(document).ready(function(){
  $("img.caption").each(function(i) {
    var imgwidth = $(this).width();
    var imgheight = $(this).height();
    var captiontext = $(this).attr('title');
    var alignment = $(this).css('float');
    $(this).css('float', 'none');
    $(this).attr({align:""});
    $(this).wrap("<span class=\"image-caption-container\" style=\"float:" + alignment + "\"></span>");
    $(this).parent().width(imgwidth);
    $(this).parent().append("<span class=\"image-caption\">" + captiontext + "</span>");
  });
});