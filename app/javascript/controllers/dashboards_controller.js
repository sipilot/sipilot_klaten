import { defaults } from 'chart.js';
import { Controller } from 'stimulus';

export default class extends Controller {
    static targets = [
        "toggleable",
        "sidebarToggleableOne",
        "sidebarToggleableTwo",
        "dataTable",
        "onBehalf",
        "fullname",
        "authorityLetter",

        "landBook",
        "measuringLetter",
        "groundSketch",
        "alasHak",
        "alasHakNumber",
        "hakNumber",
        "hakType",
        "idNumber",
        "alasType",

        'uploadIdNumber',
        'uploadIdNumberErrMsg'
    ]

    headerToggled(event) {
        event.preventDefault()
        this.toggleableTarget.classList.toggle('opacity-100')
        this.toggleableTarget.classList.toggle('scale-100')
    }

    sidebarToggle(event) {
        event.preventDefault()
        this.sidebarToggleableOneTarget.classList.toggle('hidden')
        this.sidebarToggleableTwoTarget.classList.toggle('hidden')
    }

    act_for_dirisendiri(event){
        this.fullnameTarget.value = this.onBehalfTarget.value
        this.authorityLetterTarget.classList.add('hidden')
    }
    
    act_for_kuasa(event){
        this.fullnameTarget.value = ''
        this.fullnameTarget.disabled = false
        this.authorityLetterTarget.classList.remove('hidden')
    }
    
    certificate_status_sudahsertipikat(event) {
        this.alasHakTarget.classList.add('hidden')
        this.alasHakTarget.value = ""

        this.alasTypeTarget.classList.add('hidden')
        this.alasTypeTarget.value = ""

        this.groundSketchTarget.classList.add('hidden')
        this.groundSketchTarget.value = ""

        this.alasHakNumberTarget.classList.add('hidden')
        this.alasHakNumberTarget.value = ""
        
        this.hakTypeTarget.classList.remove('hidden')
        this.landBookTarget.classList.remove('hidden')
        this.idNumberTarget.classList.remove('hidden')
        this.hakNumberTarget.classList.remove('hidden')
        this.measuringLetterTarget.classList.remove('hidden')
    }

    certificate_status_belumsertipikat(event) {
        this.hakTypeTarget.classList.add('hidden')
        this.hakTypeTarget.value = ""

        this.landBookTarget.classList.add('hidden')
        this.landBookTarget.value = ""

        this.hakNumberTarget.classList.add('hidden')
        this.hakNumberTarget.value = ""

        this.measuringLetterTarget.classList.add('hidden')
        this.measuringLetterTarget.value = ""

        this.alasHakTarget.classList.remove('hidden')
        this.idNumberTarget.classList.remove('hidden')
        this.alasTypeTarget.classList.remove('hidden')
        this.groundSketchTarget.classList.remove('hidden')
        this.alasHakNumberTarget.classList.remove('hidden')
    }

    uploadIdnNumber(event){
        const file = this.uploadIdNumberTarget.files
        const fileSize = file[0].size
        const fileType = file[0].type
        const fileName = file[0].name
        const maxSize = 1000 * 1000
        let isNotValid = false
        let errMsg = ''

        if(fileType!="image/png" && fileType!="image/jpeg" && fileType!="image/jpg")
		{
			isNotValid = true;
			errMsg = "Hanya jenis file PNG dan JPG/JPEG yang disupport.";
        }

        if (fileSize >= maxSize) {
            isNotValid = true
            errMsg = '*Maksimal ukuran gambar 1MB.'
        }
    
        if (isNotValid) {
            this.uploadIdNumberErrMsgTarget.classList.toggle('hidden')
            this.uploadIdNumberErrMsgTarget.textContent = errMsg
        }
    }
}
