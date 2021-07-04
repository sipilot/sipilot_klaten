import { defaults } from 'chart.js';
import { Controller } from 'stimulus';

import Rails from "@rails/ujs"

export default class extends Controller {
    static targets = [
        'item'
    ]

    connect() {
        console.log('hellooo')
    }
    
    setSessionValue() {
        const id = this.itemTarget.value
        const url = `/table-data/session/set?id=${id}`
        Rails.ajax({
            url: url,
            type: 'get',
        })
    }
}
