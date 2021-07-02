import { Controller } from 'stimulus';

export default class extends Controller {
    static targets = [
        "fadeout"
    ]

    dismiss() {
        this.fadeoutTarget.classList.toggle('hidden')
    }
}