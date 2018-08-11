var commentbox = ".comment";
var ctrl = false;
var last_submit;
var speed = 'fast';
var ahah = false;
var firsttime_init = true;

/**
 * Attaches the ahah behavior to each ahah form element.
 */
Drupal.behaviors.ajax_comments = function(context) {
  $('#panels-comment-form').attr('id', 'comment-form');
  $('#comment-form:not(.ajax-comments-processed)', context).addClass('ajax-comments-processed').each(function() {
    form = $(this);
    // Prepare the form when the DOM is ready.
    if ((Drupal.settings.rows_default == undefined) || (!Drupal.settings.rows_default)) {
      Drupal.settings.rows_default = $('textarea', form).attr('rows');
    }
    $('textarea', form).attr('rows', Drupal.settings.rows_default);
    if ((Drupal.settings.rows_in_reply == undefined) || (!Drupal.settings.rows_in_reply)) {
      Drupal.settings.rows_in_reply = Drupal.settings.rows_default;
    }
    if (Drupal.settings.always_expand_main_form == undefined) {
      Drupal.settings.always_expand_main_form = true;
    }
    if (Drupal.settings.blink_new == undefined) {
      Drupal.settings.blink_new = true;
    }
    
    // It's not possible to use 'click' or 'submit' events for ahah sumits, so
    // we should emulate it by up-down events. We need to check which elements
    // are actually clicked pressed, to make everything work correct.
    $('#ajax-comments-submit,#ajax-comments-preview', form).bind('mousedown keydown', function() { last_submit = $(this).attr('id'); });
    $('#ajax-comments-submit,#ajax-comments-preview', form).bind('mouseup', function() {
      if (last_submit == $(this).attr('id')) {
        ajax_comments_show_progress(context);
        ajax_comments_update_editors();
      }
    });
    $('#ajax-comments-submit,#ajax-comments-preview', form).bind('keyup', function(event) {
      if (last_submit == $(this).attr('id') && event.keyCode == 13) {
        ajax_comments_show_progress(context);
        ajax_comments_update_editors();
      }
    });
    
    // Enable comments buttons back when attachement is uploaded.
    $('#edit-attach', form).bind('mousedown keydown', function() {
      if (last_submit == $(this).attr('id')) {
        $('#ajax-comments-submit,#ajax-comments-preview', form).removeAttr('disabled');
      }
    });

    // Initializing main form.
    action = form.attr('action');

    // Creating title link.
    form.parents(".box").find("h2:not(.ajax-comments-processed),h3:not(.ajax-comments-processed),h4:not(.ajax-comments-processed)").addClass('ajax-comments-processed').each(function(){
      title = $(this).html();
      $(this).html('<a href="'+action+'" id="comment-form-title">'+title+'</a>');
      $(this).parents(".box").find(".content").attr('id','comment-form-content').removeClass("content");
    });

    // Expanding form if needed.
    page_url = document.location.toString();
    fragment = '';
    if (page_url.match('#')) {
      fragment = page_url.split('#')[1];
    }

    if ((fragment == 'comment-form'  || Drupal.settings.always_expand_main_form) && firsttime_init) {
      $('#comment-form-title', context).addClass('pressed');
      $('#comment-form-content').attr('cid', 0);
    }
    else {
      // Fast hide form.
      $('#comment-form-content', context).hide();
    }
    
    // Attaching event to title link.
    $('#comment-form-title:not(.ajax-comments-processed)', context).addClass('ajax-comments-processed').click(ajax_comments_reply_click);
    // Moving preview in a proper place.
    $('#comment-form-content').parents('.box').before($('#comment-preview'));
    if (!$('#comment-form-content').attr('cid')) {
      $('#comment-form-content').attr('cid', -1);
    }
    
    if(typeof(fix_control_size)!='undefined'){ fix_control_size(); }
  });
  
  $('.comment_reply a:not(.ajax-comments-processed)', context).addClass('ajax-comments-processed').click(ajax_comments_reply_click);
  $('.quote a:not(.ajax-comments-processed)', context).addClass('ajax-comments-processed').each(function(){
    href = $(this).attr('href');
    if (ajax_comments_is_reply_to_node(href)) {
      $(this).click(function(){
        $('#comment-form').attr('action', $(this).attr('href'));
        ajax_comments_reload_form(0);

        $('#comment-form-title', context).click();
        ajax_comments_scroll_to_comment_form();
        return false;
      });
    }
    else {
      $(this).click(ajax_comments_reply_click);
    }
  });
  
  // We should only bind ajax deletion on links with tokens to avoid CSRF attacks.
  $('.comment_delete a:not(.ajax-comments-processed)', context).each(function (){
    href = $(this).attr('href');
    if (href.indexOf('token=') > -1) {
      $(this).addClass('ajax-comments-processed').click(ajax_comments_delete_click);
    }
  });

  // Add Ctrl key listener for deletion feature.
  $(window).keydown(function(e) {
    if(e.keyCode == 17) {
      ctrl = true;
    }
  });
  $(window).keyup(function(e) {
    ctrl = false;
     // Add sending on Ctrl+Enter.
    if ((e.ctrlKey) && ((e.keyCode == 0xA) || (e.keyCode == 0xD)) && !submitted) {
      submitted = true;
      $('#ajax-comments-submit').click()
    }
 });


  firsttime_init = false;
};

/**
 * Reply link handler
 */
function ajax_comments_reply_click() {
  // We should only handle non presed links.
  if (!$(this).is('.pressed')){
    action = $(this).attr('href');
    link_cid = ajax_comments_get_cid_from_href(action);
    rows = Drupal.settings.rows_default;
    if ($('#comment-form-content').attr('cid') != link_cid) {
      // We should remove any WYSIWYG before moving controls.
      ajax_comments_remove_editors();

      // Move form from old position.
      if (ajax_comments_is_reply_to_node(action)) {
        $('#comment-form').removeClass('indented');
        if ($('#comment-form-content:visible').length) {
          $('#comment-form-content').after('<div style="height:' + $('#comment-form-content').height() + 'px;" class="sizer"></div>');
          $('.sizer').slideUp(speed, function(){ $(this).remove(); });
        }
        $(this).parents('h2,h3,h4').after($('#comment-form-content'));
        rows = Drupal.settings.rows_default;
        $('#comment-form-content').parents('.box').before($('#comment-preview'));
      }
      else {
        $('#comment-form').addClass('indented');
        if ($('#comment-form-content:visible').length) {
          $('#comment-form-content').after('<div style="height:' + $('#comment-form-content').height() + 'px;" class="sizer"></div>');
          $('.sizer').slideUp(speed, function(){ $(this).remove(); });
        }
        $(this).parents(commentbox).after($('#comment-form-content'));
        rows = Drupal.settings.rows_in_reply;
        $('#comment-form-content').prepend($('#comment-preview'));
      }
      $('#comment-form-content').hide();
    }

    // We don't need to load everything twice.
    if (!$(this).is('.last-clicked')) {
      // Reload form if preview is required.
      if ((Drupal.settings.comment_preview_required && $('#ajax-comments-submit').length) ||
        // Or if quoted comment.
        action.match('quote=1')
      ) {
        $('#comment-form').attr('action', action)
        ajax_comments_reload_form(link_cid);
      }
      else {
        ajax_comments_init_form(link_cid, rows);
      }
    }
    // ...and show the form after everything is done.
    ajax_comments_expand_form();
    
    $('.pressed').removeClass('pressed');
    $(this).addClass('pressed');
    $('.last-clicked').removeClass('last-clicked');
    $(this).addClass('last-clicked');
    $('#comment-form-content').attr('cid', link_cid);
  }
  else {
    // Handling double click.
    if ((!$(this).is('#comment-form-title')) && (Drupal.settings.always_expand_main_form)) {
      $('#comment-form-title').click();
    }
    else {
      ajax_comments_close_form();
    }
  }

  if (typeof(fix_control_size) != 'undefined'){ fix_control_size(); }
  return false;
}

/**
 * Delete links handler.
 */
function ajax_comments_delete_click() {
  if ((ctrl) || (confirm(Drupal.t('Are you sure you want to delete the comment? Any replies to this comment will be lost. This action cannot be undone.')))) {
    // Taking link's href as AJAX url.
    comment = $(this).parents(commentbox);
    action = $(this).attr('href');
    action = action.replace(/comment\/delete\//, 'ajax_comments/instant_delete/');
    if (action) {
      $(this).parents(commentbox).fadeTo(speed, 0.5);
      $.ajax({
        type: "GET",
        url: action,
        success: function(result){
          if (result == 'OK') {
            ajax_comments_close_form();

            // If comment form is expanded on this module, we should collapse it first.
            if (comment.next().is('#comment-form-content')) {
              thread = comment.next().next('.indented, div > .indented');
            }
            else {
              thread = comment.next('.indented, div > .indented');
            }
            thread.animate({height:'hide', opacity:'hide'}, speed);
            comment.animate({height:'hide', opacity:'hide'}, speed, function(){
              thread.remove();
              comment.remove();
              if (!$(commentbox).length) {
                $('#comment-controls').animate({height:'hide', opacity:'hide'}, speed, function(){ $(this).remove(); });
              }
            });
          }
          else {
            alert('Sorry, token error.');
          }
        }
      });
    }
  }
  return false;
}

// ======================================================================
// Misc. functions
// ======================================================================

/**
 * Hide comment form, reload if needed.
 */
function ajax_comments_expand_form(focus) {
  $('#comment-form-content').animate({height:'show'}, speed, function() {
    if (focus) {
      $('#comment-form textarea').focus();
    }
    if ($.browser.msie) this.style.removeAttribute('filter'); 
  });
}

/**
 * Helper function for reply handler.
 */
function ajax_comments_init_form(pid, rows){
  // Resizing and clearing textarea.
  $('#comment-form textarea').attr('rows', rows);
  $('#comment-form:not(.fresh) textarea').attr('value','');

  // Clearing form.
  $('#comment-preview').empty();
  $('#comment-form .error').removeClass('error');

  // Set proper PID.
  $('#comment-form input[name=pid]').val(pid)

  // Now we can attach previously removed editors.
  ajax_comments_attach_editors();
  submit = false;
}

/**
 * Hide comment form, reload if needed.
 */
function ajax_comments_close_form(reload) {
  pid = $('#comment-form-content').attr('cid');
  $('#comment-form-content').animate({height:'hide'}, speed, function(){
    if (reload) {
      ajax_comments_reload_form(pid);
    }
  });
  $('.pressed').removeClass('pressed');
  $('#comment-form-content').attr('cid', -1);
  ajax_comments_hide_progress();
}

/**
 * Reload comments form from server.
 */
function ajax_comments_reload_form(pid) {
  action = $('#comment-form').attr('action');
  action = action.replace('comment/reply', 'ajax_comments/js_reload');

  if (pid > 0) {
    action = action.replace(/([?])$/, '/' + pid + '?');
    action = action.replace(/#comment-form/, '');
    
    rows = Drupal.settings.rows_in_reply;
  }
  else {
    rows = Drupal.settings.rows_default;
  }
  $('#comment-preview').hide();
  ajax_comments_show_progress();

  $.ajax({
    type: "GET",
    url: action,
    success: function(result) {
      saved_class = $('#comment-form').attr('class');
      $('#comment-form-content').html(result);
      $('#comment-form').attr('class', saved_class);

      $('#comment-form').addClass('fresh');

      Drupal.attachBehaviors($('#comment-form-content form'));
      ajax_comments_init_form(pid, rows);
      ajax_comments_hide_progress();

      $('#comment-form').removeClass('fresh');
    }
  });
}

/**
 * Scrolling to a new comment.
 */
function ajax_comments_scroll_to_comment_form() {
  if ($.browser.msie) {
    height = document.documentElement.offsetHeight ;
  }
  else if (window.innerWidth && window.innerHeight) {
    height = window.innerHeight;
  }
  height = height / 2;
  offset = $('#comment-form-content').offset();
  if ((offset.top > $('html').scrollTop() + height) || (offset.top < $('html').scrollTop() - 20)) {
    $('html').animate({scrollTop: offset.top}, 'slow');
  }
}

/**
 * AHAH effect for comment previews.
 */
jQuery.fn.ajaxCommentsPreviewToggle = function() {
  var obj = $(this[0]);

  // Hide previous preview.
  $('#comment-preview > div:visible').animate({height:'hide', opacity:'hide'}, speed, function() { $(this).remove(); } );
  // Show fresh preview.
  $('#comment-preview').show();
  obj.animate({height:'show', opacity:'show'}, speed);
  ajax_comments_hide_progress();

  // Add submit button if it doesn't added yet.
  if (!$('#ajax-comments-submit').length && $('.preview-item').length) {
    $('#ajax-comments-preview').after('<input name="op" id="ajax-comments-submit" value="'+ Drupal.t("Save") +'" class="form-submit" type="submit">');
    // Re-attaching to new comment.
    Drupal.attachBehaviors($('#ajax-comments-submit'));
  }
};

/**
 * AHAH effect for comment submits.
 */
jQuery.fn.ajaxCommentsSubmitToggle = function() {
  var obj = $(this[0]);

  html = obj.html();
  if (html.indexOf('comment-new-success') > -1) {
    
    // Empty any preview before output comment.
    $('#comment-preview').slideUp(speed, function(){ $(this).empty(); });
    
    // Place new comment in proper place.
    ajax_comments_insert_new_comment(obj);

    // At last - showing it up.
    obj.animate({height:'show', opacity:'show'}, speed, function () {
      if ($.browser.msie) {
        height = document.documentElement.offsetHeight ;
      } else if (window.innerWidth && window.innerHeight) {
        height = window.innerHeight;
      }
      height = height / 2;
      offset = obj.offset();
      if ((offset.top > $('html').scrollTop() + height) || (offset.top < $('html').scrollTop() - 20)) {
        $('html').animate({scrollTop: offset.top - height}, 'slow', function(){
          // Blink a little bit to user, so he know where's his comment.
          if (Drupal.settings.blink_new) {
            obj.fadeTo('fast', 0.2).fadeTo('fast', 1).fadeTo('fast', 0.5).fadeTo('fast', 1).fadeTo('fast', 0.7).fadeTo('fast', 1, function() { if ($.browser.msie) this.style.removeAttribute('filter'); });
          }
        });
      }
      else {
        if (Drupal.settings.blink_new) {
          obj.fadeTo('fast', 0.2).fadeTo('fast', 1).fadeTo('fast', 0.5).fadeTo('fast', 1).fadeTo('fast', 0.7).fadeTo('fast', 1, function() { if ($.browser.msie) this.style.removeAttribute('filter'); });
        }
      }
      if ($.browser.msie) this.style.removeAttribute('filter');
    });

    // Re-attaching behaviors to new comment.
    Drupal.attachBehaviors(html);

    // Hiding comment form.
    ajax_comments_close_form(true);
  }
  else {
    $('#comment-preview').append(obj);
    obj.ajaxCommentsPreviewToggle(speed);
  }
};

function ajax_comments_insert_new_comment(comment) {
  if ($('#comment-form-content').attr('cid') == 0) {
    $('#comment-preview').before(comment);
  }
  else {
    if ($('#comment-form-content').next().is('.indented')) {
      $('#comment-form-content').next().append(comment);
    }
    else {
      $('#comment-form-content').before(comment);
      comment.wrap('<div class="indented"></div>');
    }
  }
}

/**
 * Remove editors from comments textarea (mostly to re-attach it).
 */
function ajax_comments_remove_editors() {
  ajax_comments_update_editors();
  if (typeof(Drupal.wysiwyg) != undefined) {
    $('#comment-form input.wysiwyg-processed:checked').each(function() {
      var params = Drupal.wysiwyg.getParams(this);
      Drupal.wysiwygDetach($(this), params);
    });
    return;
  }
  
  if (typeof(tinyMCE) != 'undefined') {
    if (tinyMCE.getInstanceById("edit-comment")) {
      tinyMCE.execCommand('mceRemoveControl', false, "edit-comment");
    }
  }
}

/**
 * Attach editors to comments textarea if needed.
 */
function ajax_comments_attach_editors() {
  if (typeof(Drupal.wysiwyg) != undefined) {
    $('#comment-form input.wysiwyg-processed:checked').each(function() {
      var params = Drupal.wysiwyg.getParams(this);
      Drupal.wysiwygAttach($(this), params);
    });
    return;
  }

  if (typeof(tinyMCE) != 'undefined') {
    tinyMCE.execCommand('mceAddControl', false, "edit-comment");
  }
}

/**
 * Update editors text to their textareas. Need to be done befor submits.
 */
function ajax_comments_update_editors() {
  // Update tinyMCE.
  if (typeof(tinyMCE) != 'undefined') {
    tinyMCE.triggerSave();
  }
  
  // Update FCKeditor.
  if (typeof(doFCKeditorSave) != 'undefined') {
    doFCKeditorSave();
  }
  if(typeof(FCKeditor_OnAfterLinkedFieldUpdate) != 'undefined'){
    FCKeditor_OnAfterLinkedFieldUpdate(FCKeditorAPI.GetInstance('edit-comment'));
  }
}



function ajax_comments_get_cid_from_href(action) {
  args = ajax_comments_get_args(action);

  // getting token params (/comment/delete/!cid!)
  if (args[1] == 'delete') {
    cid = args[2];
  }
  // getting token params (/comment/reply/nid/!cid!)
  else {
    if (typeof(args[3]) == 'undefined') {
      cid = 0;
    }
    else {
      cid = args[3];
    }
  }
  return cid;
}

function ajax_comments_is_reply_to_node(href) {
  args = ajax_comments_get_args(href);
  result = args[1] == 'reply' && args[2] && (typeof(args[3]) == 'undefined');
  return result;
}

function ajax_comments_get_args(url) {
  if (Drupal.settings.clean_url == '1') {
    var regexS = "(http(s)*:\/\/)*([^/]*)"+ Drupal.settings.basePath +"([^?#]*)";
    var regex = new RegExp( regexS );
    var results = regex.exec( url );
    args = results[4];
  }
  else {
    var regexS = "([&?])q=([^#&?]*)";
    var regex = new RegExp( regexS );
    var results = regex.exec( url );
    args = results[2];
  }
  args = args.split('/');
  if (Drupal.settings.language_mode == 1 || Drupal.settings.language_mode == 2) {
    for (l in Drupal.settings.language_list) {
      if (args[0] == Drupal.settings.language_list[l].language) {
        args.shift();
        break;
      }
    }
  }
  return args;
}

function ajax_comments_show_progress(context) {
  if (!context) {
    context = '#comment-form-content';
  }
  if (!$('#comment-form .ajax-comments-loader', context).length) {
    $('#comment-form', context).append('<div class="ajax-comments-loader"></div>');
  }
}
function ajax_comments_hide_progress(context) {
  if (!context) {
    context = '#comment-form-content';
  }
  $('#comment-form .ajax-comments-loader', context).fadeOut(speed, function(){ $(this).remove(); });
}
