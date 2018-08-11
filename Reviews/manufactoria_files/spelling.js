// $Id: spelling.js,v 1.1.2.1 2009/04/21 15:07:24 doq Exp $

var spelling = spelling || {};

spelling.autoAttach = function () {
  new spelling.handler();

  // Show functionality description block.
  var isKonqueror = -1 != navigator.userAgent.indexOf('Konqueror');
  if (isKonqueror) {
    // Workaround for Konqueror browser. Tested under Konqueror 3.5.
    document.getElementById('block-spelling-0').style.display = 'block';
  }
  else {
    $('#block-spelling-0').show();
  }
}

spelling.handler = function () {
  var obj = this;
  this.input = $(document);

  $(this.input)
    .keydown(function (event) { return obj.onkeydown(event) });
};

spelling.handler.prototype.onkeydown = function (e) {
  if (!e) {
    e = window.event;
  }
  // Enter and Ctrl.
  if (13 == e.keyCode && e.ctrlKey) {
    var selection = (parent.getSelection) ? parent.getSelection() : ((parent.document.getSelection) ? parent.document.getSelection() : ((document.selection.createRange) ? document.selection.createRange().text : null));
    if (!selection || '' == selection) {
      // TODO I think there should be some error handling if browser doesn't support text selection.
      alert(Drupal.t("You haven't selected any text."));
      return;
    }
    else {
      if (confirm(Drupal.t('Are you sure you want to report the text with mistake below to the site administrator?') + "\n\n" + selection)) {
        // When doing a post request, you need non-null data. Otherwise a
        // HTTP 411 or HTTP 406 (with Apache mod_security) error may result.
        $.ajax({
          type: "POST",
          url: Drupal.settings.spelling['uri'],
          data: 'text=' + Drupal.encodeURIComponent(selection) + '&uri=' + Drupal.encodeURIComponent(Drupal.settings.spelling['requestUri']),
          success: function (data) {
            // Parse response.
            var progress = Drupal.parseJson(data);
            // Display errors.
            if (progress.status == 0) {
              alert(Drupal.t('Site administrator was successfully notified about spelling mistake.'));
              return;
            }
          },
          error: function (xmlhttp) {
            alert(Drupal.t('Spelling mistake notification failed.'));
          }
        });
      }
    }


  }

}


// Global killswitch.
if (Drupal.jsEnabled) {
  $(document).ready(spelling.autoAttach);
}
