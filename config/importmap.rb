# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application'
pin '@hotwired/turbo-rails', to: '@hotwired--turbo-rails.js' # @8.0.20
pin 'stimulus' # @3.2.2
pin 'stimulus-autocomplete' # @3.1.0
pin '@hotwired/stimulus', to: '@hotwired--stimulus.js' # @3.2.2
pin 'quagga', to: 'quagga.js' # @1.8.4 (QuaggaJS - Barcode Scanner)
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin '@hotwired/turbo', to: '@hotwired--turbo.js' # @8.0.20
pin '@rails/actioncable/src', to: '@rails--actioncable--src.js' # @8.1.100
