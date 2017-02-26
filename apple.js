<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="initial-scale=1,maximum-scale=1,user-scalable=no">
  <meta name="description" content="[Get started with MapView - Create a 2D map - 4.2]">
  <!--
  Using ArcGIS API for JavaScript, https://js.arcgis.com, thankssomuchguys
  -->
  <title></title>
  <style>
    html,
    body,
    #MapContainer {
      padding: 0;
      margin: 0;
      height: 100%;
      width: 100%;
    }
  </style>

  <link rel="stylesheet" href="https://js.arcgis.com/4.2/esri/css/main.css">
  <script src="https://js.arcgis.com/4.2/"></script>

  <script>

    function locationSelect(lat, lon) {
            alert(lat + " " + lon);
    }

    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(getMap, defaultLocation);
    } else {
        document.getElementbyId("MapContainer") = "Geolocation is not supported by this browser.";
        exit();
    }

    function getMap(position) {
        require([
          "esri/Map",
          "esri/views/MapView",
          "esri/widgets/Search",
          "esri/widgets/Popup",
          "esri/tasks/Locator",
          "esri/PopupTemplate",
          "dojo/domReady!"
        ], function(Map, MapView, Search, Popup, Locator, PopupTemplate) {

          /****************************
           * Instantiates the map
           ****************************/
          // Enables clicks on map
          var locatorTask = new Locator({
             url: "http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/"
          });

          // SetUp maps and views
          var map = new Map({
            basemap: "streets-vector"
          });

          var view = new MapView({
            map: map,
            container: "MapContainer",
            zoom: 14,
            center: [position.coords.longitude, position.coords.latitude],
          });

          // remove the magnifying glass
          view.popup.actions.removeAll();

          /****************************
           * Click Actions
           ****************************/


          view.on("click", function(event) {setUpPopup(event.mapPoint);});


          /****************************
           * Search Actions
           ****************************/


          // SetUp search Bar
          var searchBar = new Search({
            view: view,
            sources: [
                {
                    locator: locatorTask,
                    singleLineFieldName: "SingleLine",
                    outFields: ["City"],
                    name: "Default",
                    localSearchOptions: {
                        minScale: 300000,
                        distance: 50000
                    },
                    placeholder: "Please enter a place to ensure",
                    maxSuggestions: 3,
                    popupOpenOnSelect: false,
                }
            ]
          });

          // Integrate it
          view.ui.add(searchBar, {
              position: "top-left",
              index: 0
          });

          // Action controller for Search Bar
          searchBar.on("select-result", function(event){
            setUpPopup(event.result.feature.geometry)
          });


          /****************************
           * Popup Triggers
           ****************************/

          function setUpPopup(point) {
              // Gets the coordinates of the click on the view
              // around the decimals to 3 decimals
              let lat = Math.round(point.latitude * 10000) / 10000;
              let lon = Math.round(point.longitude * 10000) / 10000;

              view.popup.clear();
              view.popup.close();

              view.popup.open({
                title: "...",
                location: point
              });

              // Opens our custom template
              locatorTask.locationToAddress(point, 1500).then(function(response) {
                if(response.address.City == null) {
                    triggerErrorPopup();
                } else {
                    triggerPopup(response.address.City, lat, lon);
                }
              }).otherwise(function(err) {
                triggerErrorPopup();
              });
          }

          function triggerPopup(name, lat, lon) {
            view.popup.title = name;
            view.popup.content = getContent(lat, lon);

          }

          function triggerErrorPopup() {
            view.popup.title = "Oops";
            view.popup.content = "We couldn't find an address<br />Try clicking closer to a road";
          }

          function getContent(lat, lon) {
             return '<button id="insureMe" class="btn btn-primary" onclick="locationSelect('+
               lat + ', ' + lon + ')">Insure</button>';
          }


        });
    }

    function defaultLocation(err) {
      document.getElementbyId("MapContainer") = "Please give us access to your location";
      exit();
    }

  </script>

</head>

<body>
  <div id="MapContainer"></div>
</body>
</html>
