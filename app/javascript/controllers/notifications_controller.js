import { defaults } from 'chart.js';
import { Controller } from 'stimulus';

export default class extends Controller {
    static targets = [
        "toggleable"
    ]

    toggle(event) {
        event.preventDefault()
        this.toggleableTarget.classList.toggle('hidden')
    }
}
