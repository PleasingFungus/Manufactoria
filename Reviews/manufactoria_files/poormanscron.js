// $Id: poormanscron.js,v 1.1.2.1 2009/09/29 22:31:58 davereid Exp $

/**
 * Checks to see if the cron should be automatically run.
 */
Drupal.behaviors.cronCheck = function(context) {
  if (Drupal.settings.cronCheck || false) {
    $('body:not(.cron-check-processed)', context).addClass('cron-check-processed').each(function() {
      // Only execute the cron check if its the right time.
      if (Math.round(new Date().getTime() / 1000.0) > Drupal.settings.cronCheck) {
        $.get(Drupal.settings.basePath + 'poormanscron/run-cron-check');
      }
    });
  }
};
