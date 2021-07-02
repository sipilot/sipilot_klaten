import { defaults } from 'chart.js';
import { Controller } from 'stimulus';

// Import UJS so we can access the Rails.ajax method
import Rails from "@rails/ujs";

export default class extends Controller {
    static targets = [
        'villages',
        "district",
        "subDistrict"
    ]

    connect() {
    }

    setVillageData() {
        const subDistrictId = this.subDistrictTarget.value
        const url = `/api/v1/misc/villages?sub_district_id=${subDistrictId}`
        Rails.ajax({
          type: "get",
          url: url,
          success: function (data) {
              const villages = data['results']
              villages.forEach(element => {
                const option = document.createElement("option");
                option.text = element.name;
                option.value = element.id;
                this.villagesTarget.appendChild(option)
              });
          }.bind(this)
        })
    }

    setSubDistrictData() {
        const districtId = this.districtTarget.value
        const url = `/api/v1/misc/sub_districts?district_id=${districtId}`
        Rails.ajax({
          type: "get",
          url: url,
          success: function (data) {
              const subDistricts = data['results']
              subDistricts.forEach(element => {
                const option = document.createElement("option");
                option.text = element.name;
                option.value = element.id;
                this.subDistrictTarget.appendChild(option)
              });
          }.bind(this)
        })
    }
}
