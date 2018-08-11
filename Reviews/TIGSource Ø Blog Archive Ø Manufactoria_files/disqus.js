var disqus_domain = 'disqus.com';
var disqus_shortname = 'tigsource';
var disqus_thread_slug = 'manufactoria';

(function () {
    var script = document.createElement('script');
    script.src = 'http://mediacdn.disqus.com/1025/build/loader.js';
   (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(script);
    // The WordPress plugin has placeholders for comments, so we need to
    // clear them out.
    document.getElementById('disqus_thread').innerHTML = '';
}());
