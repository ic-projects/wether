overlay = $(".blur, .slogan-overlay .container");

overlay.hover(function() {
  $(".slogan-overlay").fadeOut(400);
  $(".blur").fadeOut(400);
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