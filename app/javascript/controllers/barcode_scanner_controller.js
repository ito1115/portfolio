import { Controller } from "@hotwired/stimulus"
import "quagga"

// QuaggaJSはグローバル変数として読み込まれます
const Quagga = window.Quagga

export default class extends Controller {
  static targets = ["modal", "scanner", "status", "input"]

  connect() {
    this.isScanning = false
  }

  disconnect() {
    this.stopScanner()
  }

  // バーコードスキャンを開始
  async startScan() {
    this.modalTarget.classList.add("active")
    this.statusTarget.textContent = "カメラを起動中..."

    try {
      await this.initQuagga()
      this.isScanning = true
      this.statusTarget.textContent = "バーコードをスキャンしてください"
    } catch (error) {
      console.error("カメラの起動に失敗しました:", error)
      this.statusTarget.textContent = "カメラの起動に失敗しました。カメラへのアクセスを許可してください。"
      setTimeout(() => this.closeModal(), 3000)
    }
  }

  // QuaggaJSを初期化
  initQuagga() {
    return new Promise((resolve, reject) => {
      Quagga.init({
        inputStream: {
          name: "Live",
          type: "LiveStream",
          target: this.scannerTarget,
          constraints: {
            width: { min: 640 },
            height: { min: 480 },
            facingMode: "environment", // リアカメラを優先
            aspectRatio: { min: 1, max: 2 }
          }
        },
        decoder: {
          readers: [
            "ean_reader", // EAN-13 (ISBN-13)
            "ean_8_reader" // EAN-8
          ],
          multiple: false
        },
        locate: true,
        locator: {
          patchSize: "medium",
          halfSample: true
        },
        numOfWorkers: navigator.hardwareConcurrency || 4,
        frequency: 10
      }, (err) => {
        if (err) {
          reject(err)
          return
        }

        // バーコード検出イベントをリスン
        Quagga.onDetected(this.onBarcodeDetected.bind(this))
        Quagga.start()
        resolve()
      })
    })
  }

  // バーコード検出時の処理
  onBarcodeDetected(result) {
    if (!this.isScanning) return

    const code = result.codeResult.code

    // ISBN形式かチェック（13桁または10桁）
    if (this.isValidISBN(code)) {
      this.isScanning = false
      this.statusTarget.textContent = `✓ ISBN検出: ${code}`

      // 検索入力欄に自動入力
      this.inputTarget.value = code

      // ビープ音（オプション）
      this.playBeep()

      // 1.5秒後にモーダルを閉じてフォーム送信
      setTimeout(() => {
        this.closeModal()
        this.submitForm()
      }, 1500)
    }
  }

  // ISBNの簡易バリデーション
  isValidISBN(code) {
    // 13桁（ISBN-13）または10桁（ISBN-10）
    return /^\d{13}$/.test(code) || /^\d{10}$/.test(code)
  }

  // ビープ音を鳴らす
  playBeep() {
    const audioContext = new (window.AudioContext || window.webkitAudioContext)()
    const oscillator = audioContext.createOscillator()
    const gainNode = audioContext.createGain()

    oscillator.connect(gainNode)
    gainNode.connect(audioContext.destination)

    oscillator.frequency.value = 800
    oscillator.type = "sine"
    gainNode.gain.value = 0.3

    oscillator.start(audioContext.currentTime)
    oscillator.stop(audioContext.currentTime + 0.1)
  }

  // フォームを送信
  submitForm() {
    const form = this.element.querySelector('form')
    if (form) {
      form.submit()
    }
  }

  // モーダルを閉じる
  closeModal() {
    this.stopScanner()
    this.modalTarget.classList.remove("active")
    this.statusTarget.textContent = ""
  }

  // スキャナーを停止
  stopScanner() {
    if (this.isScanning) {
      Quagga.stop()
      this.isScanning = false
    }
  }
}
