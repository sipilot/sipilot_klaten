import { defaults } from 'chart.js';
import { Controller } from 'stimulus';

export default class extends Controller {
    static targets = [
        "lat",
        "lng",
        "fullname",
        "hakName",
        "map"
    ]

    connect() {
        const lat = this.latTarget.innerHTML
        const lng = this.lngTarget.innerHTML
        const fullname = this.fullnameTarget.innerHTML
        const hakName = this.hakNameTarget.innerHTML
        const myLatLng = { lat: parseFloat(lat), lng: parseFloat(lng) };
        const contentString =
            '<div id="content">' +
            '<div id="siteNotice">' +
            "</div>" +
            '<h1 id="firstHeading" class="firstHeading">Keterangan Tanah</h1>' +
            '<div id="bodyContent">' +
            `<p>Pemilik Tanah : ${fullname}</p>` +
            `<p>Jenis Hak : ${hakName}</p>` +
            "</div>" +
            "</div>";

        let infowindow;
        let map;
        let marker;

        infowindow = new google.maps.InfoWindow({
          content: contentString,
        });

        map = new google.maps.Map(this.mapTarget, {
          center: myLatLng,
          zoom: 16,
          mapTypeId: 'satellite'
        });

        marker = new google.maps.Marker({
          position: myLatLng,
          map
        });

        infowindow.open(map, marker);
    }
}