// based on : https://developers.google.com/maps/documentation/javascript/places-autocomplete
// references : https://developers.google.com/maps/documentation/javascript/markers

import { defaults } from 'chart.js';
import { keys } from 'highcharts';
import { Controller } from 'stimulus';

export default class extends Controller {
    static targets = [
        "longitude",
        "latitude",
        "address",
        "field",
        "map"
    ]

    connect() {
        if (typeof (google) != "undefined") {
            this.initializeMap()
            // this.setCurrentLocation()
        }
    }

    initializeMap() {
        this.map()
        this.marker()
        this.autocomplete()
    }

    map() {
        // -7.695160224671814, 110.60864661084307
        if (this._map == undefined){
            const lat = (this.latitudeTarget.value == '') ? -7.695160224671814 : this.latitudeTarget.value
            const lng = (this.longitudeTarget.value == '') ? 110.60864661084307 : this.longitudeTarget.value
            this._map = new google.maps.Map(this.mapTarget, {
                center: new google.maps.LatLng(
                    lat,
                    lng
                ),
                zoom: 18,
                mapTypeId: 'satellite'
            })
        }
        return this._map
    }

    marker() {
        if (this._marker == undefined) {
            const lat = (this.latitudeTarget.value == '') ? -7.695160224671814 : this.latitudeTarget.value
            const lng = (this.longitudeTarget.value == '') ? 110.60864661084307 : this.longitudeTarget.value
            this._marker = new google.maps.Marker({
                map: this.map(),
                draggable: true,
                animation: google.maps.Animation.DROP,
                anchorPoint: new google.maps.Point(0,0)
            })
            let mapLocation = {
                lat: parseFloat(lat),
                lng: parseFloat(lng)
            }
            this._marker.setPosition(mapLocation)
            this._marker.setVisible(true)
            google.maps.event.addListener(this._marker, 'dragend', event => this.updateCurrentLocation(event))
        }
        return this._marker

    // for previewing marker
    // <%= image_tag ""https://maps.googleapis.com/maps/api/staticmap?zoom=17&size=400c300&center=#{@place.latitude},#{@place.longitude}&key=#{ENV['MAPS_API_KEY]}", alt:"Map">
    }

    updateCurrentLocation(event) {
        const lat = event.latLng.lat()
        const lng = event.latLng.lng()

        this.latitudeTarget.value = lat
        this.longitudeTarget.value = lng

        let geocoder = new google.maps.Geocoder();
        let latLng   = new google.maps.LatLng(lat, lng);

        if (geocoder) {
            geocoder.geocode({ 'latLng': latLng}, function (results, status, addr) {
              if (status == google.maps.GeocoderStatus.OK) {
                  this.addressTarget.value = results[0].formatted_address
              }
              else {
                  console.log("Geocoding failed: " + status);
              }
          }.bind(this));
        }
    }

    autocomplete () {
        if (this._autocomplete == undefined) {
            this._autocomplete = new google.maps.places.Autocomplete(this.fieldTarget)
            this._autocomplete.bindTo('bounds', this.map())
            this._autocomplete.setFields(['address_components', 'geometry', 'icon', 'name'])
            this._autocomplete.addListener('place_changed', this.locationChanged.bind(this))
        }
        return this._autocomplete
    }

    preventSubmit(e){
        if (e.key == "Enter") { e.preventDefault() }
    }

    locationChanged() {
        let place = this.autocomplete().getPlace()

        if (!place.geometry) {
            // user entered the name of a place that was not suggessted and 
            // pressed the Enter keys, or the details request failed.
            window.alert("No details available for input: '" + place.name + "'");
            return;
        }
        this.map().fitBounds(place.geometry.viewport)
        this.map().setCenter(place.geometry.location)
        this.marker().setPosition(place.geometry.location)
        this.marker().setVisible(true)

        this.latitudeTarget.value   = place.geometry.location.lat()
        this.longitudeTarget.value  = place.geometry.location.lng()
        this.addressTarget.value    = this.getAddressObject(place.address_components)
    }

    
    getAddressObject(address_components) {
        let full_addr = ''
        address_components.forEach(component => {
            full_addr += component.short_name + ', '
        })
        
        return full_addr
        
        // other references : https://medium.com/@almestaadmicadiab/how-to-parse-google-maps-address-components-geocoder-response-774d1f3375d
        // but done with simple loop :)
    }
    
    setCurrentLocation() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(this.showPosition.bind(this));
            this.map()
        } else { 
            console.log("Geolocation is not supported by this browser.")
        }
    }

    showPosition(position) {
        let resultLat = position.coords.latitude
        let resultLong = position.coords.longitude
      
        this.latitudeTarget.value = resultLat
        this.longitudeTarget.value = resultLong
      
        let geocoder = new google.maps.Geocoder();
        let latLng = new google.maps.LatLng(resultLat, resultLong);

        if (geocoder) {
          const data = geocoder.geocode({ 'latLng': latLng}, function (results, status) {
             if (status == google.maps.GeocoderStatus.OK) {
               console.log(results[0].formatted_address); 
               results[0].formatted_address
             }
             else {
               console.log("Geocoding failed: " + status);
             }
          });
          data.then((value) => {

          })
        }
    }
}
