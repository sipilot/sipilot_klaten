import { defaults } from 'chart.js';
import { Controller } from 'stimulus';

import Rails from "@rails/ujs"

export default class extends Controller {
    static targets = [
        'input'
    ]

    connect() {
    }
    
    validate_input_number(event) {
        let currentValue = this.inputTarget.value
        let fixedValue = currentValue.replace(/[A-Za-z!@#$%^&*()]/g, '');
        this.inputTarget.value = fixedValue
    }
}