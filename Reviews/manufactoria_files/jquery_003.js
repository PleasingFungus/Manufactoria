if (Drupal.jsEnabled) {
 
  paginator = function () {
 
    /**
     *  Private properties
     */
    var linkNext = null;
    var linkPrev = null;
 
    /**
     *  Private methods
     */
    var setLinks = function () {
 
      linkPrev = $("ul.pager li.pager-previous a").attr("href");
      linkNext = $("ul.pager li.pager-next a").attr("href");
 
    }
 
    var navigate = function (event) {
 
      var href = null;     
      if ( event.ctrlKey && event.keyCode == 37 ) href = linkPrev;
      if ( event.ctrlKey && event.keyCode == 39 ) href = linkNext;
      if ( href ) document.location = href;
 
    }
 
 
     /**
       *  Public methods
       */
    this.__init = function () {
 
      // Get next/prev hrefs
      setLinks();
 
      // Ctrl + arrow event handle
      $(document).keydown( function(event) {
        navigate(event);
      });
 
    }
 
  }
 
 
 
  $(document).ready(function(){
 
    var pageNavigation = new paginator();
    pageNavigation.__init();
 
  });
}