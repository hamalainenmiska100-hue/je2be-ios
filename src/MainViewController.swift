import UIKit
import UniformTypeIdentifiers

class MainViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var javaToBedrockButton: UIButton!
    @IBOutlet weak var bedrockToJavaButton: UIButton!
    @IBOutlet weak var xbox360ToBedrockButton: UIButton!
    @IBOutlet weak var xbox360ToJavaButton: UIButton!
    @IBOutlet weak var ps3ToBedrockButton: UIButton!
    @IBOutlet weak var ps3ToJavaButton: UIButton!
    @IBOutlet weak var drawer: UIView!
    @IBOutlet weak var drawerTouchDetector: UIView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer!
    @IBOutlet weak var drawerCloseButon: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var aboutButton: UIButton!

    private let conversionModeControl = UISegmentedControl(items: [
        gettext("Simple"),
        gettext("Advanced"),
    ])
    private let subtitleLabel = UILabel()
    private static let advancedModeKey = "mainAdvancedModeEnabled"
    private weak var conversionButtonsStackView: UIStackView?

    private var isDrawerShown = false
    private var tempDirectory: TemporaryDirectory?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.label.text = gettext("Select conversion mode") + ":"
        setupVisualDesign()
        setupConversionModeControl()

        self.menuButton.setTitle("", for: .normal)
        self.menuButton.addTarget(self, action: #selector(menuButtonDidTouchUpInside(_:)), for: .touchUpInside)

        self.drawerCloseButon.addTarget(self, action: #selector(drawerCloseButtonDidTouchUpInside(_:)), for: .touchUpInside)
        self.drawerCloseButon.setTitle(gettext("Back"), for: .normal)

        self.aboutButton.setTitle(gettext("About je2be"), for: .normal)
        self.aboutButton.addTarget(self, action: #selector(aboutButtonDidTouchUpInside(_:)), for: .touchUpInside)

        self.versionLabel.text = "je2be for iOS " + ((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "(local)")

        self.javaToBedrockButton.setTitle(gettext("Java to Bedrock"), for: .normal)
        self.javaToBedrockButton.addTarget(self,
                                           action: #selector(javaToBedrockButtonDidTouchUpInside(_:)),
                                           for: .touchUpInside)

        self.bedrockToJavaButton.setTitle(gettext("Bedrock to Java"), for: .normal)
        self.bedrockToJavaButton.addTarget(self,
                                           action: #selector(bedrockToJavaButtonDidTouchUpInside(_:)),
                                           for: .touchUpInside)

        self.xbox360ToBedrockButton.setTitle(gettext("Xbox360 to Bedrock"), for: .normal)
        self.xbox360ToBedrockButton.addTarget(self,
                                              action: #selector(xbox360ToBedrockButtonDidTouchUpInside(_:)),
                                              for: .touchUpInside)

        self.xbox360ToJavaButton.setTitle(gettext("Xbox360 to Java"), for: .normal)
        self.xbox360ToJavaButton.addTarget(self,
                                           action: #selector(xbox360ToJavaButtonDidTouchUpInside(_:)),
                                           for: .touchUpInside)

        self.ps3ToJavaButton.setTitle(gettext("PS3 to Java"), for: .normal)
        self.ps3ToJavaButton.addTarget(self,
                                           action: #selector(ps3ToJavaButtonDidTouchUpInside(_:)),
                                           for: .touchUpInside)

        self.ps3ToBedrockButton.setTitle(gettext("PS3 to Bedrock"), for: .normal)
        self.ps3ToBedrockButton.addTarget(self,
                                              action: #selector(ps3ToBedrockButtonDidTouchUpInside(_:)),
                                              for: .touchUpInside)

        applyConversionModeVisibility()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @objc func javaToBedrockButtonDidTouchUpInside(_ sender: AnyObject) {
        disableButtons()
        let vc = ChooseInputViewController(type: .javaToBedrock,
                                           message: gettext("Choose a zip file of Java Edition world data to start conversion"),
                                           contentTypes: [UTType.zip])
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }

    @objc func bedrockToJavaButtonDidTouchUpInside(_ sender: AnyObject) {
        disableButtons()
        let contentTypes: [UTType]
        if let mcworld = UTType(filenameExtension: "mcworld") {
            contentTypes = [mcworld]
        } else {
            contentTypes = [UTType.data]
        }
        let vc = ChooseInputViewController(type: .bedrockToJava,
                                           message: gettext("Choose an mcworld file to start conversion"),
                                           contentTypes: contentTypes)
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }

    @objc func xbox360ToBedrockButtonDidTouchUpInside(_ sender: AnyObject) {
        disableButtons()
        let contentTypes: [UTType]
        if let bin = UTType(filenameExtension: "bin") {
            contentTypes = [bin]
        } else {
            contentTypes = [UTType.data]
        }
        let vc = ChooseInputViewController(type: .xbox360ToBedrock,
                                           message: gettext("Choose a bin file of Xbox 360 Edition data to start conversion"),
                                           contentTypes: contentTypes)
        vc.delegate = self
        self.present(vc, animated: true)
    }

    @objc func xbox360ToJavaButtonDidTouchUpInside(_ sender: AnyObject) {
        disableButtons()
        let contentTypes: [UTType]
        if let bin = UTType(filenameExtension: "bin") {
            contentTypes = [bin]
        } else {
            contentTypes = [UTType.data]
        }
        let vc = ChooseInputViewController(type: .xbox360ToJava,
                                           message: gettext("Choose a bin file of Xbox 360 Edition data to start conversion"),
                                           contentTypes: contentTypes)
        vc.delegate = self
        self.present(vc, animated: true)
    }

    @objc func ps3ToBedrockButtonDidTouchUpInside(_ sender: AnyObject) {
        disableButtons()
        let contentTypes: [UTType] = [.data]
        let vc = ChooseInputViewController(type: .ps3ToBedrock,
                                           message: gettext("Choose a GAMEDATA file of PS3 Edition data to start conversion"),
                                           contentTypes: contentTypes)
        vc.delegate = self
        self.present(vc, animated: true)
    }

    @objc func ps3ToJavaButtonDidTouchUpInside(_ sender: AnyObject) {
        disableButtons()
        let contentTypes: [UTType] = [.data]
        let vc = ChooseInputViewController(type: .ps3ToJava,
                                           message: gettext("Choose a GAMEDATA file of PS3 Edition data to start conversion"),
                                           contentTypes: contentTypes)
        vc.delegate = self
        self.present(vc, animated: true)
    }

    private func disableButtons() {
        self.javaToBedrockButton.isEnabled = false
        self.bedrockToJavaButton.isEnabled = false
        self.xbox360ToJavaButton.isEnabled = false
        self.xbox360ToBedrockButton.isEnabled = false
        self.ps3ToJavaButton.isEnabled = false
        self.ps3ToBedrockButton.isEnabled = false
    }

    private func enableButtons() {
        self.javaToBedrockButton.isEnabled = true
        self.bedrockToJavaButton.isEnabled = true
        self.xbox360ToJavaButton.isEnabled = true
        self.xbox360ToBedrockButton.isEnabled = true
        self.ps3ToJavaButton.isEnabled = true
        self.ps3ToBedrockButton.isEnabled = true
    }

    @IBAction func drawerTouchDetectorDidTap(_ sender: Any) {
        closeDrawer()
    }

    @IBAction func drawerTouchDetectorDidPan(_ sender: UIPanGestureRecognizer) {
        closeDrawer()
    }

    @objc private func menuButtonDidTouchUpInside(_ sender: UIButton) {
        openDrawer()
    }

    @IBAction func screenEdgeDidPan(_ sender: Any) {
        openDrawer()
    }

    @IBAction func drawerCloseButtonDidTouchUpInside(_ sender: UIButton) {
        closeDrawer()
    }

    private func openDrawer() {
        guard !isDrawerShown else {
            return
        }
        isDrawerShown = true

        self.drawer.transform = .init(translationX: -self.drawer.bounds.width, y: 0)
        self.drawerTouchDetector.alpha = 0
        self.drawerTouchDetector.isHidden = false
        self.screenEdgePanGestureRecognizer.isEnabled = false
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut, .beginFromCurrentState]) {
            self.drawer.transform = .identity
            self.drawerTouchDetector.alpha = 1
        }
        self.drawer.isHidden = false
    }

    private func closeDrawer() {
        guard isDrawerShown else {
            return
        }
        isDrawerShown = false

        self.drawer.transform = .identity
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut, .beginFromCurrentState]) {
            self.drawer.transform = .init(translationX: -self.drawer.bounds.width, y: 0)
            self.drawerTouchDetector.alpha = 0
        } completion: { done in
            if done {
                self.drawer.isHidden = true
                self.drawer.transform = .identity
                self.drawerTouchDetector.isHidden = true
                self.screenEdgePanGestureRecognizer.isEnabled = true
            }
        }
    }

    @objc private func aboutButtonDidTouchUpInside(_ sender: UIButton) {
        let vc = UIViewController(nibName: "AboutViewController", bundle: nil)
        self.present(vc, animated: true)
    }

    @objc private func conversionModeDidChange(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex == 1, forKey: Self.advancedModeKey)
        applyConversionModeVisibility()
    }

    private func setupVisualDesign() {
        self.view.backgroundColor = .systemGroupedBackground
        self.drawer.backgroundColor = .secondarySystemBackground

        self.label.font = .preferredFont(forTextStyle: .title3)
        self.label.textColor = .label
        self.versionLabel.textColor = .secondaryLabel

        self.menuButton.tintColor = .label
        self.drawerCloseButon.tintColor = .label
        self.aboutButton.tintColor = .label

        [
            self.javaToBedrockButton,
            self.bedrockToJavaButton,
            self.xbox360ToBedrockButton,
            self.xbox360ToJavaButton,
            self.ps3ToBedrockButton,
            self.ps3ToJavaButton,
        ].forEach { button in
            button.layer.cornerRadius = 12
            button.layer.masksToBounds = true
            button.configuration?.baseBackgroundColor = .systemBlue
            button.configuration?.baseForegroundColor = .white
            button.configuration?.imagePadding = 8
            button.configuration?.cornerStyle = .large
        }

        self.javaToBedrockButton.configuration?.image = UIImage(systemName: "arrow.down.right.square")
        self.bedrockToJavaButton.configuration?.image = UIImage(systemName: "arrow.up.left.square")
        self.xbox360ToBedrockButton.configuration?.image = UIImage(systemName: "xbox.logo")
        self.xbox360ToJavaButton.configuration?.image = UIImage(systemName: "xbox.logo")
        self.ps3ToBedrockButton.configuration?.image = UIImage(systemName: "gamecontroller.fill")
        self.ps3ToJavaButton.configuration?.image = UIImage(systemName: "gamecontroller.fill")
    }

    private func setupConversionModeControl() {
        self.conversionButtonsStackView = self.javaToBedrockButton.superview as? UIStackView
        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel.numberOfLines = 0
        self.subtitleLabel.textAlignment = .center
        self.subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        self.subtitleLabel.textColor = .secondaryLabel

        self.conversionModeControl.translatesAutoresizingMaskIntoConstraints = false
        self.conversionModeControl.selectedSegmentIndex = UserDefaults.standard.bool(forKey: Self.advancedModeKey) ? 1 : 0
        self.conversionModeControl.addTarget(self, action: #selector(conversionModeDidChange(_:)), for: .valueChanged)

        self.view.addSubview(self.subtitleLabel)
        self.view.addSubview(self.conversionModeControl)

        NSLayoutConstraint.activate([
            self.subtitleLabel.topAnchor.constraint(equalTo: self.label.bottomAnchor, constant: 10),
            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

            self.conversionModeControl.topAnchor.constraint(equalTo: self.subtitleLabel.bottomAnchor, constant: 12),
            self.conversionModeControl.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            self.conversionModeControl.widthAnchor.constraint(lessThanOrEqualToConstant: 320),
        ])

        if let stack = self.conversionButtonsStackView {
            if let oldConstraint = self.view.constraints.first(where: { constraint in
                (constraint.firstItem as? UIView) === stack && (constraint.secondItem as? UIView) === self.label && constraint.firstAttribute == .top && constraint.secondAttribute == .bottom
            }) {
                self.view.removeConstraint(oldConstraint)
            }
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: self.conversionModeControl.bottomAnchor, constant: 24),
            ])
        }
    }

    private func applyConversionModeVisibility() {
        let advanced = (self.conversionModeControl.selectedSegmentIndex == 1)
        self.xbox360ToBedrockButton.isHidden = !advanced
        self.xbox360ToJavaButton.isHidden = !advanced
        self.ps3ToBedrockButton.isHidden = !advanced
        self.ps3ToJavaButton.isHidden = !advanced

        self.subtitleLabel.text = advanced
        ? gettext("Advanced mode includes legacy console conversion paths and expert workflows.")
        : gettext("Simple mode shows the most common conversion paths.")
    }
}

extension MainViewController: ChooseInputViewDelegate {
    func chooseInputViewDidChoosen(sender: ChooseInputViewController, type: ConversionType, result: SecurityScopedResource, playerUuid: UUID?) {
        sender.dismiss(animated: true) { [weak self] in
            guard let self = self else {
                return
            }
            let converter: Converter
            switch type {
            case .javaToBedrock:
                converter = ConvertJavaToBedrock()
            case .bedrockToJava:
                converter = ConvertBedrockToJava(playerUuid: playerUuid)
            case .xbox360ToJava:
                converter = ConvertXbox360ToJava(playerUuid: playerUuid)
            case .xbox360ToBedrock:
                converter = ConvertXbox360ToBedrock()
            case .ps3ToJava:
                converter = ConvertPS3ToJava(playerUuid: playerUuid)
            case .ps3ToBedrock:
                converter = ConvertPS3ToBedrock()
            }
            self.presentProgressWith(input: result, converter: converter)
        }
    }

    func chooseInputViewDidCancel() {
        enableButtons()
    }

    private func presentProgressWith(input: SecurityScopedResource, converter: Converter) {
        guard let temp = TemporaryDirectory() else {
            return
        }
        let vc = ProgressViewController(input: input, tempDirectory: temp.path, converter: converter)
        self.tempDirectory = temp
        vc.modalPresentationStyle = .fullScreen
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
}

extension MainViewController: ProgressViewDelegate {
    func progressViewWillDisappear() {
        enableButtons()
    }
}
