import { defaults } from 'chart.js';
import { Controller } from 'stimulus';

// Import UJS so we can access the Rails.ajax method
import Rails from "@rails/ujs";

export default class extends Controller {
    static targets = [
        "subDistrict",
        'villages',
        'hakNumber',
        'hakType'
    ]

    connect() {
    }

    setHakNumberInput() {
      let selectedOption = this.hakTypeTarget[this.hakTypeTarget.selectedIndex].text
      this.hakNumberTarget.value = ''
      if (selectedOption == 'Belum Sertifikat') {
        this.hakNumberTarget.removeAttribute('maxLength')
        this.hakNumberTarget.removeAttribute('data-controller')
      } else {
        if (!this.hakNumberTarget.hasAttribute("data-controller")) {
          this.hakNumberTarget.setAttribute("data-controller", "validationInput")          
        }
        if (!this.hakNumberTarget.hasAttribute("maxLength")) {
          this.hakNumberTarget.setAttribute("maxLength", "5")
        }
      }
    }

    setVillageData() {
        const subDistrictId = this.subDistrictTarget.value
        const url = `/api/v1/misc/villages?sub_district_id=${subDistrictId}`
        Rails.ajax({
          type: "get",
          url: url,
          success: function (data) {
              this.villagesTarget.innerHTML =''
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
}
