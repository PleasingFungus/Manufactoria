function mtHide(id) { return hideDocumentElement(id); }
function mtShow(id) { return showDocumentElement(id); }
function mtEntryOnLoad() { return individualArchivesOnLoad(); }
function mtReplyCommentOnClick(x,y) { return; }
function mtGetCookie(name) { return getCookie(name);}
function mtSetCookie(name, value, expires, path, domain, secure)  { return setCookie(name, value, expires, path, domain, secure);}
function mtFixDate(name) { return fixDate(name);}

first_comments = [];
comment_count = 0;
panel_size = 100;
xcurl = '/mt4/newcomments.cgi';  
last_comment = 0;
last_comment_memory = 50;
tabsshow_hash = null;

function panelUpdate(id) {
  $('#comment-panels').addClass("submitted");
  $.get(xcurl, {__mode:'xomment',id:id,a:comment_count,r:0},
  function(data) {
    addComments(data);
    $('#comment-panels').removeClass("submitted");
  });
  return false;
}
function findPanel(id) {
  var panel = 0;
  for(panel=0;panel+1 < first_comments.length && id>=first_comments[panel+1];++panel)
    ;
  return panel;
}
function lastCommentCookie(id) {
  var path = window.location.pathname;
  var now = new Date();
  mtFixDate(now);
  now.setTime(now.getTime() + 365 * 24 * 60 * 60 * 1000);
  var ret = 0;
  var a = mtGetCookie('xomment.last_comment.a').split('|', 2*last_comment_memory);
  if(a.length == 1)
    a = [];
  for(var i=0;i<a.length;i+=2) {
    if(a[i] != path)
      continue;
    ret = a[i+1];
    a.splice(i,2);
    break;
  }
  id = id ? id : ret;
  if(id)
    a.unshift(path, id);
  mtSetCookie('xomment.last_comment.a', a.join('|'), now, '/', '', '');
  return ret;
}
function initPanel() {
  var h = window.location.hash;
  if( h == '#comment-print') {
    return null;
  }
  var id = 0;
  var res = h.match(/^#comment-(\d+)$/);
  var cook = lastCommentCookie(last_comment);
  if(res) {
    id = res[1];
    tabsshow_hash = h;
  } else {
    if(cook) {
      id = cook;
      if(h == '#comment-last')
        tabsshow_hash = '#comment-'+cook;
    } else if(h == '#comment-last') {
      tabsshow_hash = '#comments';
    }
  }
  return findPanel(id);
}
function checkHashOnClick(event) {
  var res;
  var rhere = new RegExp('(^|'+window.location.pathname+')(#comment-.*)$', '');
  if(!(res = this.href.match(rhere)))
    return;
  event.preventDefault();
  var id = 0;
  var h = res[2];
  if(h == '#comment-print') {
    return;
  } else if(h == '#comment-last') {
    id = last_comment;
  } else if(res = h.match(/^#comment-(\d+)$/)) {
    id = res[1];
  }
  if(id) {
    var panel = findPanel(id);
    var $ul = $('#comment-panels > ul');
    if(panel != $ul.data('selected.tabs')) {
      tabsshow_hash = '#comment-'+id;
      $ul.tabs('select', panel);
    } else {
      window.location.hash = '#comment-'+id;
    }
  }
}
function addComments(data){
    $('#comment-panels div.comment.new').removeClass('new');
    if(data == '') {
      $('#comment-update-message').html('no new comments');
      return;
    }
    var $data = $(data).filter('div.comment');
    lastCommentCookie($data.filter(':last').attr('id').replace('comment-', ''));
    var pcount = ((comment_count-1)%panel_size)+1;
    if(pcount%2 == 1) {
      $data.filter(':even').removeClass('odd').addClass('even');
      $data.filter(':odd').removeClass('even').addClass('odd');
    }
    $data.addClass('new');
    var lastp = Math.ceil(comment_count/panel_size);
    if(lastp == 0) {
      lastp = 1;
      $('#comment-panels').add('#comment-panels-dummy').show();
    }
    var space = panel_size-pcount;
    var did = $data.attr('id');
    last_comment = did.replace('comment-', '');
    var $ul = $('#comment-panels > ul');
    var callback = function(event, ui) {
      if($data.length <= space) {
        $('#comment-update').before($data);
      } else {
        var p = lastp;
        var $pan = $('#Comment_Panel_'+p);
        for(var i=0;i<$data.length;++i) {
          if((comment_count+i)%panel_size == 0)
          {
            var myid = '#Comment_Panel_'+(++p);
            var pp = p-1;
            $ul.tabs('add', myid, p)
              .find('li:last > a')
              .attr('title', 'Comment Panel '+p)
              .parent().clone()
              .click(function(event){
                event.preventDefault();
                $('#comment-panels > ul').tabs('select', pp);
                window.location.hash = '#comment-panels';
              }).appendTo($('#comment-panels-dummy > ul'));
            first_comments.push(parseInt($data.eq(i)
              .attr('id').match(/comment-(\d+)/)[1]));
            $pan = $(myid);
          }
          $pan.append($data.get(i));
        }
        $('#comment-update').appendTo($pan);
      }
      comment_count += $data.length;
      $('#comments-count').html(comment_count);
      $('#xomment-a').val(comment_count);
      $('#comment-update-message').html($data.length + ' new comment'
        + (($data.length>2) ? 's' : '') );
      if(space == 0)
        setTimeout(function(){
          tabsshow_hash = '#' + did;
          $ul.tabs("select", lastp);
          },10);
      else
        window.location.hash = '#' + did;
    }
    $ul.triggerHandler('xommentadd', [$data]);
    if($ul.data('selected.tabs') == lastp-1)
      callback();
    else {
      $ul.one('tabsshow', callback);
      $ul.tabs('select', lastp-1);
    }
}
function quoteComment(id) {
  $('#comment-text').addClass('submitted');
  $.get(xcurl, {__mode:'xomment',q:id}, function(responseText, statusText){
    var $ct = $('#comment-text');
    $ct.val($ct.val()+responseText).removeClass('submitted');
  });
  return true;
}
function onLoadComments(wcf) { $(function(){
  wcf(document);
  $('#comment-panels > ul').bind('tabsload', function(event, ui) {
    wcf(ui.panel);
  }).bind('xommentadd', function(event, data) {
    wcf(data);
  });
  $('#comments-form').bind('xommentadd', function(event, data) {
    wcf(data);
  });
});}
function xommentFormOkay() {
      var $form = $('#comments-form');
      /*mtRequestSubmitted = false;
      $form[0].preview_button.disabled = false;
      $form[0].post.disabled = false;
      $form[0].preview.value = '';*/
      $form.removeClass('submitted');  
}

$(function(){
  comment_count = $('#comments-count').html();
  comment_count = (comment_count == 'No') ? 0 : parseInt(comment_count);
  $('#comments').prepend('<div id="comment-last"></div>');
  $('#comments-open-footer').before('<div id="comment-preview-box"></div>');
  $('#comments-form').append('<input type="hidden" name="xomment-a" id="xomment-a" value="'+comment_count+'"/>');
  onLoadComments(function(data) {
    $(data).find('a[href*=#comment-]').click(checkHashOnClick);
  });
 
  $('#comment-panels > ul').tabs({
    spinner: '',
    cache: true,
    selected: initPanel(),
    select: function(ui) {
      $('#comment-panels').addClass("submitted");
    },
    show: function(ui) {
      $('#comment-panels-dummy > ul > li')
        .removeClass('ui-tabs-selected')
        .find('a[href$='+ui.tab.hash+']')
        .parent()
        .addClass('ui-tabs-selected');
      if(tabsshow_hash){
        window.location.hash = tabsshow_hash;
        tabsshow_hash = null;
      }
      $('#comment-panels').removeClass("submitted");
    }
  });
  
  $('#comment-panels')
    .after('<div id="comment-panels-dummy"></div>')
    .children().filter('ul').clone()
    .addClass('dummy')
    .appendTo('#comment-panels-dummy');
  $('#comment-panels-dummy > ul > li a').each(function(i) {
    $(this).click(function(event){
      event.preventDefault();
      $('#comment-panels > ul').tabs("select", i);
      window.location.hash = '#comment-panels';
    });
  });
  if(comment_count == 0)
    $('#comment-panels').add('#comment-panels-dummy').hide();
    
  $('#comments-form').ajaxForm({
    beforeSubmit: function(data, obj, opt) {
      obj.addClass('submitted');
      return true;
    },
    success: function(responseText, statusText) {
      if(statusText != "success") {
        $('#comment-preview-box').html('<div class="comment-error"><p>Comment submission or preview failed.</p></div>');
      } else if(responseText.match(/class=["']comment-preview["']/)) {
        $data = $(responseText);
        $('#comments-form').triggerHandler('xommentadd', [$data]);
        $('#comment-preview-box').html($data);
      } else if(responseText.match(/class=["']comment-error["']/)) {
        $('#comment-preview-box').html(responseText);
      } else if(responseText.match(/class=["']comment-pending["']/)) {
        $('#comment-text').val('');
        /*mtHide('comment-form-reply');
        $('#comment-reply')[0].checked = false;*/
        $('#comment-preview-box').html(responseText);
      } else if(responseText.match(/id=["']comment-\d+["']/)) {
        addComments(responseText);
        $('#comment-text').val('');
        /*mtHide('comment-form-reply');
        $('#comment-reply')[0].checked = false;*/
        $('#comment-preview-box').html('<div class="comment-success"><p>Your comment was submitted successfully.</p></div>');
      } else if(responseText.match(/id=["']generic-error['"]/)) {
        $('#comment-preview-box').html('<div class="comment-error"><p>'
          +$(responseText).find('#generic-error').contents().eq(1)
          +'</p></div>');
      } else {
          $('#comment-preview-box').html('<div class="comment-error"><p>Comment submission or preview failed: '
          +responseText+'</p></div>');
      }
      xommentFormOkay();
    }
  });
});