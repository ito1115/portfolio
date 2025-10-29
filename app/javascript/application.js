// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import { Application } from "@hotwired/stimulus"
import Autocomplete from "stimulus-autocomplete"

const application = Application.start()
application.register("autocomplete", Autocomplete)
