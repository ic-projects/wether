overlay = $(".blur, .slogan-overlay .container");

hideOverlay = function() {
  $(".slogan-overlay").fadeOut(400);
  $(".blur").fadeOut(400);
};

overlay.hover(function() {
  hideOverlay();
});

function locationSelect(latitude, longitude) {
  // Launch modal for insurance
  $("div[name=insurance-modal]").modal("show");

  // Set the longitude and latitude values for form inputs
  $("#longitude").val(longitude);
  $("#latitude").val(latitude);
}

function locationInsure() {
    // Launch modal for insurance
    $("div[name=insurance-modal]").modal("show");

    // Set the longitude and latitude values for form inputs
    $("#longitude").val(Markers.find().fetch()[0].lng);
    $("#latitude").val(Markers.find().fetch()[0].lat);
}

$("nav ul li a").click(function(e) {
  e.preventDefault();
  scrollToPos = ($(this).attr("href") == "") ? 0 : $("h1#" + $(this).attr("href")).offset().top;

  $("html, body").stop().animate({
    scrollTop: scrollToPos
  }, 1000, "easeInOutQuint");
});

$(window).scroll(function() {
  if ($(this).scrollTop() >= $(".map-container").height()) {
    $("nav ul li").removeClass("active");
    $(".insurances").addClass("active");
    hideOverlay();
  } else {
    $("nav ul li").removeClass("active");
    $(".addInsurance").addClass("active");
    hideOverlay();
  }
});