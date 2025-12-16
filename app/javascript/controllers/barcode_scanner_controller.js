import { Controller } from "@hotwired/stimulus"
import "quagga"

// QuaggaJSはグローバル変数として読み込まれます
const Quagga = window.Quagga

// @hotwired/stimulusのControllerクラスを継承
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
    // Quaggaが利用できない場合（テスト環境など）はスキャンを開始しない
    if (!Quagga) {
      console.warn("Quagga is not available. Barcode scanner is disabled.")
      return
    }

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
        // カメラ入力の設定
        inputStream: {
          name: "Live",
          type: "LiveStream",
          target: this.scannerTarget,
          constraints: {
            width: { min: 640 },
            height: { min: 480 },
            facingMode: "environment", // リアカメラ（背面カメラ）を優先
            aspectRatio: { min: 1, max: 2 } // 縦横比：1:1〜2:1
          }
        },
        // バーコード読み取りの設定
        decoder: {
          readers: [
            "ean_reader", // EAN-13 (ISBN-13)
          ],
          multiple: false // 1つのバーコードを検出したら処理を止める
        },
        // 検出位置：画像内のバーコードの位置を自動検出
        locate: true,
        // 検出精度
        locator: {
          patchSize: "medium",
          halfSample: true
        },
        // 並列処理
        numOfWorkers: navigator.hardwareConcurrency || 4,
        // スキャン頻度：1秒に10回チェック
        frequency: 10
      }, (err) => {
        if (err) {
          reject(err)
          return
        }

        // バーコード検出後のイベントリスナー設定
        Quagga.onDetected(this.onBarcodeDetected.bind(this))
        // バーコードスキャン実行
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
    // 978または979で始まる13桁
    return /^(978|979)\d{10}$/.test(code)
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
    if (this.isScanning && Quagga) {
      Quagga.stop()
      this.isScanning = false
    }
  }
}
