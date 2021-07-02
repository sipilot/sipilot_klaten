import { Controller } from 'stimulus';

export default class extends Controller {
    static targets = [
        "hideable"
    ]

    hide() {
        let hideable = this.hideableTarget
        if (hideable.type == 'password') {
            this.hideableTarget.type = 'text'
        } else {
            this.hideableTarget.type = 'password'
        }
    }
}

