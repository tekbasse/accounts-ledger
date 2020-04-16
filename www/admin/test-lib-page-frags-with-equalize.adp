<script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
  <script>window.jQuery || document.write('<script src="/resources/b-responsive-theme/jquery-1.8.3.min.js"><\/script>')</script>

  <script src="/resources/b-responsive-theme/equalize.min.js"></script>
<script>
  
  // smart resize - http://paulirish.com/2009/throttled-smartresize-jquery-event-handler/
  (function($,sr){
 
    // debouncing function from John Hann
    // http://unscriptable.com/index.php/2009/03/20/debouncing-javascript-methods/
    var debounce = function (func, threshold, execAsap) {
        var timeout;
   
        return function debounced () {
            var obj = this, args = arguments;
            function delayed () {
                if (!execAsap)
                    func.apply(obj, args);
                timeout = null; 
            };
   
            if (timeout)
                clearTimeout(timeout);
            else if (execAsap)
                func.apply(obj, args);
   
            timeout = setTimeout(delayed, threshold || 100); 
        };
    }
    // smartresize 
    jQuery.fn[sr] = function(fn){  return fn ? this.bind('resize', debounce(fn)) : this.trigger(sr); };
   
  })(jQuery,'smartresize');

  $(function() {
    // use equalize to equalize the heights of content elements
    $('.equalize').equalize({children:'.content-box'});

    // re-equalize on resize
    $(window).smartresize(function(){  
      $('.equalize').equalize({reset:true, children:'.content-box'});
    });

  });
</script>

<div class="grid-whole equalize">
  <div class="grid-4 m-grid-4 s-grid-12 padded">
    <div class="padded-inner content-box">
      <if @content_c1@ not nil>
        @content_c1;noquote@
      </if>
    </div>
  </div>
  <div class="grid-4 m-grid-4 s-grid-12 padded">
    <div class="padded-inner content-box">
      <if @content_c2@ not nil>
        @content_c2;noquote@
      </if>
    </div>
  </div>
  <div class="grid-4 m-grid-4 s-grid-12 padded">
    <div class="padded-inner content-box">
      <if @content_c3@ not nil>
        @content_c3;noquote@
      </if>
    </div>
  </div>
</div>

