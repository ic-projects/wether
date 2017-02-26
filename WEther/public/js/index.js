overlay = $(".blur, .slogan-overlay .container");

overlay.hover(function() {
  $(".slogan-overlay").fadeOut(300);
  $(".blur").fadeOut(300);
});

function locationSelect(latitude, longitude) {
  // Launch modal for insurance
  $("div[name=insurance-modal]").modal("show");

  // Set the longitude and latitude values for form inputs
  $("#longitude").val(longitude);
  $("#latitude").val(latitude);
}