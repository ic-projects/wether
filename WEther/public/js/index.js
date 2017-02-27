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

    /***********
     * Yahoo Weather API, hopefully
     ***********/
    setContent(Markers.find().fetch()[0].lat, Markers.find().fetch()[0].lng);

    function setContent(lat, lon) {

        // get the Weather forecast from Yahoo API
        var url = 'https://query.yahooapis.com/v1/public/yql';
        var yql = 'select title, units.temperature, item.forecast from weather.forecast where woeid in (select woeid from geo.places where text="('+ lat + ', '+ lon + ')") and u = "C" limit 5 | sort(field="item.forecast.date", descending="false");';

        $.ajax({url: url, data: {format: 'json', q: yql}, method: 'GET', dataType: 'json',
            success: function(data) {
                var forecast = '<div id="forced"><div id="weather" class="weather">';
                if (data.query.count > 0) {
                    jQuery.each(data.query.results.channel, function(idx, result) {
                        var f = result.item.forecast;
                        var u = result.units.temperature;

                        forecast += '<div class="weather_block"><div class="weather_date">' + f.date + '</div><div class="weather_temp">'  +f.low + '&#8451 - ' + f.high + '&#8451' +'</div><div class="weather_icon"><img class="weather_icon" src="'+ getUrl(f.code) +'"alt="Img not found"></div></div>';
                    });
                }

                // Update content
                console.log(forecast);
                $("#weather_forecast").html(forecast + '<div class="clearfix"></div></div></div>');
            }
        });

    }

    function getUrl(code) {
        if(code == 26 || code == 27 || code == 28) {
            return "/img/Clouds.png";
        } else if(code == 32 || code == 34) {
            return "/img/Sun.png"
        } else if(code == 30 || code == 44 || code == 23 || code == 29) {
            return "/img/Partly_Cloudy.png";
        } else if(code == 11 || code == 12 || code == 39) {
            return "/img/Rain.png";
        } else if (code == 12) {
            return "/img/Moderate_Rain.png";
        } else if (code == 31 || code == 33) {
            return "/img/Moon.png";
        } else if (code == 37) {
            return "/img/Cloud_Lighting.png";
        } else if (code == 4 || code == 38 || code == 47) {
            return "/img/Storm.png";
        } else if (code == 17) {
            return "/img/Hail.png";
        } else if (code == 47) {
            return "/img/Cloud_Lightning.png";
        } else if (code == 14 || code == 15 || code == 16 || code == 5) {
            return "/img/Light_Snow.png";
        }

        return "/img/Clouds.png";
    }

    /***********
     * End of Yahoo API, hopefully
     ***********/

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

function setContent(lat, lon) {

    // get the Weather forecast from Yahoo API
    var url = 'https://query.yahooapis.com/v1/public/yql';
    var yql = 'select title, units.temperature, item.forecast from weather.forecast where woeid in (select woeid from geo.places where text="('+ lat + ', '+ lon + ')") and u = "C" limit 5 | sort(field="item.forecast.date", descending="false");';

    $.ajax({url: url, data: {format: 'json', q: yql}, method: 'GET', dataType: 'json',
        success: function(data) {
            var forecast = '<div id="forced"><div id="weather" class="weather">';
            if (data.query.count > 0) {
                jQuery.each(data.query.results.channel, function(idx, result) {
                    var f = result.item.forecast;
                    var u = result.units.temperature;

                    forecast += '<div class="weather_block"><div class="weather_date">' + f.date + '</div><div class="weather_temp">'  +f.low + '&#8451 -- ' + f.high + '&#8451' +'</div><div class="weather_icon"><img class="weather_icon" src="'+ getUrl(f.code) +'"alt="Img not found"></div></div>';
                });
            }

            // Update content
            forecast = forecast + '<div class="clearfix"></div></div></div>';
        }
    });

}