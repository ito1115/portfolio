// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import { Application } from "@hotwired/stimulus"
import Autocomplete from "stimulus-autocomplete"
import BarcodeScannerController from "./controllers/barcode_scanner_controller"

const application = Application.start()

// Register controllers
application.register("autocomplete", Autocomplete)
application.register("barcode-scanner", BarcodeScannerController)
