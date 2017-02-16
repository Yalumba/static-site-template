//= require namespace
//= require_tree ./lib
//= require_tree ./vendor

$(function() {
  $.localScroll();

  $TDF.registrationForm.init();
  $TDF.purchaseForm.init();
  

  setTimeout(function(){
    $('html').addClass('is-ready');
  }, 1200);
});
