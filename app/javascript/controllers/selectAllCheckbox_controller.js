import { defaults } from 'chart.js';
import { Controller } from 'stimulus';

import Rails from "@rails/ujs"

export default class extends Controller {
    static targets = [
        'allCheckbox'
    ]

    connect() {
    }
    
    set_checkbox() {
        const checkboxes = this.allCheckboxTarget.querySelectorAll('input[type=checkbox]')
        let type = ''
        for(var i = 0; i < checkboxes.length; i++) {
            if (checkboxes[i].checked == false) {
                checkboxes[i].checked = true
                type = 'set_all'
            } else {
                checkboxes[i].checked = false
                type = 'remove_all'
            }
        }

        const url = `/table-data/session/set?type=${type}`
        Rails.ajax({
            url: url,
            type: 'get',
        })
    }
}
