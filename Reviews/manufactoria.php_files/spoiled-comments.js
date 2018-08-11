// *** begin SpoiledComments
jQuery.fn.spoil = function() {
 return this.each(function(){
    $(this).addClass('spoiled').wrapInner('<div style="display:none;"></div>').children().hide().end()
     .prepend('<a class="hide" href="javascript:void(0);">Spoiler</a>')
     .children(':first').click(function(event){
       event.preventDefault();
       $(this).toggleClass('hide').siblings().slideToggle('fast');
     });
 });
};

if('function' === typeof onLoadComments) {
  onLoadComments(function(data) {
    $(data).find('div.spoiler').spoil();
  });
} else {
  $(function(){ $('div.spoiler').spoil();});
}

$(function() {
  $('#comments-form').bind('form-pre-serialize', function(event, form, opt, veto) {
    var depth = 0;
    var a = [];
    var text = form[0].text.value;
    var tags = text.match(/<\/?(?:spoiler)>/g);
    if(!tags)
      return;
    $.each(tags, function(i, val) {
      if(this.match(/\//)) {
        depth -= 1;
        if(depth < 0) {
          a.push(i);
          return false;
        }
        a.pop(i);
      } else {
        depth += 1;
        a.push(i);
      }
    });
    if(depth == 0)
      return;
    var prob = a.pop();
    var tag = tags[prob];
    var msg = 'unmatched ' + ((depth > 0) ? 'start' : 'end') + ' tag, "'
      + tag.replace(/</, '&lt;').replace(/>/, '&gt;') + '"';
    var texts = text.split(/(<\/?(?:spoiler)>)/);
    texts = $.map(texts, function(n, i) {
      n = n.replace(/&/, '&amp;').replace(/</, '&lt;').replace(/>/, '&gt;');
      return (i == 2*prob+1) ? '<span class="error-tag">' + n + '</span>' : n;
    });
    texts = texts.join('');
    $('#comment-preview-box').html('<div class="comment-invalid"><p>Invalid Comment Format: '+ msg +'</p><pre>'+texts+'</pre></div>');
    xommentFormOkay();
     veto.veto = true;
  });
});
// *** end SpoiledComments
