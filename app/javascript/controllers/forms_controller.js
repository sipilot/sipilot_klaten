import { defaults } from 'chart.js';
import { Controller } from 'stimulus';

export default class extends Controller {
    static targets = [
        "toggleable",
        "latitude",
        "longitude",
        "form",
        "fullAddress"
    ]

    submitForm() {

    }

    getLocation() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(this.showPosition);
        } else { 
            console.log("Geolocation is not supported by this browser.")
        }
    }

    showPosition(position) {
        let resultLat = position.coords.latitude
        let resultLong = position.coords.longitude
      
        elLat.value = resultLat
        elLong.value = resultLong
      
        let geocoder = new google.maps.Geocoder();
        let latLng = new google.maps.LatLng(resultLat, resultLong);

        if (geocoder) {
          geocoder.geocode({ 'latLng': latLng}, function (results, status) {
             if (status == google.maps.GeocoderStatus.OK) {
               console.log(results[0].formatted_address); 
               elAddress.value = results[0].formatted_address
             }
             else {
              //  elAddress.value = 'Geocoding failed: ' + status
               console.log("Geocoding failed: " + status);
             }
          });
        }
    }
}
