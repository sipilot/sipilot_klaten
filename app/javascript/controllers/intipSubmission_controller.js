import { defaults } from 'chart.js';
import { Controller } from 'stimulus';

export default class extends Controller {
    static targets = [

        "alasHak",
        "hakNumber",
        "hakType",
        "idNumber",
        "alasType",
        "groundSketch",
    ]

    certificate_status_sudahsertipikat(event) {
        this.alasHakTarget.classList.add('hidden')
        this.hakTypeTarget.classList.remove('hidden')
        this.hakNumberTarget.classList.remove('hidden')
        this.alasTypeTarget.classList.add('hidden')
        this.groundSketchTarget.classList.add('hidden')
    }
    
    certificate_status_belumsertipikat(event) {
        this.alasHakTarget.classList.remove('hidden')
        this.hakTypeTarget.classList.add('hidden')
        this.hakNumberTarget.classList.remove('hidden')
        this.alasTypeTarget.classList.remove('hidden')
        this.groundSketchTarget.classList.remove('hidden')
    }
}
