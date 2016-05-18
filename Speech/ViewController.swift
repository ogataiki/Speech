import UIKit
import AVFoundation

class ViewController: UIViewController, UITextViewDelegate, AVSpeechSynthesizerDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var stopButton: UIBarButtonItem!
    @IBOutlet weak var pauseButton: UIBarButtonItem!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var pitchSlider: UISlider!
    
    let synthesizer = AVSpeechSynthesizer();
    
    var isPause = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.]
    
        synthesizer.delegate = self;
        textView.delegate = self;
        
        stopButton.enabled = false;
        pauseButton.enabled = false;
        
        speedSlider.minimumValue = 0.0;
        speedSlider.maximumValue = 1.0;
        speedSlider.setValue(0.5, animated: true);

        pitchSlider.minimumValue = 0.5;
        pitchSlider.maximumValue = 2.0;
        pitchSlider.setValue(1.0, animated: true);
        
        let kbToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40));
        kbToolBar.barStyle = UIBarStyle.Default;
        kbToolBar.sizeToFit();
        let clearButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash
            , target: self
            , action: #selector(self.textClear)
        );
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil);
        let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done
            , target: self
            , action: #selector(self.commitButtonTapped)
        );
        kbToolBar.items = [clearButton, spacer, commitButton];
        textView.inputAccessoryView = kbToolBar;

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onAudioSessionRouteChange(_:))
            , name: AVAudioSessionRouteChangeNotification, object: nil);
    }
    
    func textClear() {
        self.textView.text = "";
    }
    func commitButtonTapped() {
        self.view.endEditing(true);
    }
    
    @objc func onAudioSessionRouteChange(notification :NSNotification) {
        // ここで再生をとめる処理を書く
        synthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playText(sender: AnyObject) {
        
        // 一時停止していた読み上げを再生する
        if isPause {
            synthesizer.continueSpeaking();
            isPause = false;
            playButton.enabled = false;
            pauseButton.enabled = true;
            return;
        }
        
        print(textView.text);
        let utterance = AVSpeechUtterance(string: textView.text);
        
        // 読み上げの速度を指定する
        utterance.rate = speedSlider.value;
        // 声の高さを指定する
        utterance.pitchMultiplier = pitchSlider.value;
        
        // 声のボリュームを指定する
        utterance.volume = 1.0;
        
        let voice = AVSpeechSynthesisVoice(language: "ja-JP");
        utterance.voice = voice;
        
        // 読み上げる
        synthesizer.speakUtterance(utterance);

        playButton.enabled = false;
        trashButton.enabled = false;
    }
    
    @IBAction func stopText(sender: AnyObject) {
        // 読み上げを途中で終了する（終了したところからまた再生したい場合は下のpauseを使う）
        synthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate);

        isPause = false;
    }
    
    @IBAction func pauseText(sender: AnyObject) {
        if isPause {
            return;
        }
        // 読み上げを一時停止する
        synthesizer.pauseSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        isPause = true;
        pauseButton.enabled = false;
        playButton.enabled = true;
    }
    
    @IBAction func trashText(sender: AnyObject) {
        textView.text = "喋らせたい内容を入力してください。";
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didStartSpeechUtterance utterance: AVSpeechUtterance)
    {
        stopButton.enabled = true;
        pauseButton.enabled = true;
    }
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance)
    {
        stopButton.enabled = false;
        pauseButton.enabled = false;
        playButton.enabled = true;
        trashButton.enabled = true;
    }
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didCancelSpeechUtterance utterance: AVSpeechUtterance)
    {
        stopButton.enabled = false;
        pauseButton.enabled = false;
        playButton.enabled = true;
        trashButton.enabled = true;
    }

}

