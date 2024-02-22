import AVFoundation
import AuthenticVisionSDK
import UIKit

class SwitchCell: UITableViewCell {
    @IBOutlet weak var switchTextLabel: UILabel!
    @IBOutlet weak var switch_: UISwitch!
}

class DemoTableViewController: UITableViewController, AVKScanViewControllerDelegate, AVKBrandingDelegate {

    // MARK: AV SDK Setup

    let scanConfig = AVKScanConfig.default()

    override func viewDidLoad() {
        super.viewDidLoad()

        // The Authentic Vision API key is provided to you by your AV contact.
        // It allows the AV SDK to contact AV backend services and scan your labels.
        #warning("please set your Authentic Vision API key here")
        scanConfig.apiKey = ""  // avck_abcdf... or clientkey:abcd...
        scanConfig.brandingDelegate = self

        // Refresh caches if you are certain that a scan happens soon by calling prepareToScan().
        scanConfig.prepareToScan()
    }

    @objc func attestationSwitchChanged(switch_: UISwitch) {
        scanConfig.attestationMode = switch_.isOn ? .managed : .none
        // CMS attestation mode for a self-hosted validation service is not covered in this sample
    }

    // MARK: AV SDK Scan

    enum LastScan {
        case pending
        case success(AVKScanResult)
        case failure(Error)
    }

    var lastScan: LastScan = .pending

    func startScan() {
        checkCameraPermission {
            do {
                let controller = try AVKScanViewController(delegate: self, config: self.scanConfig)
                controller.addCloseButton(withTarget: self, action: #selector(self.stopScan))
                self.present(controller, animated: true)
            } catch let error {
                self.displayError(error)
            }
        }
    }

    @objc func stopScan(_ sender: UIButton) {
        dismiss(animated: true)
    }

    func checkCameraPermission(_ next: @escaping () -> Void) {
        // The AV SDK has fallbacks to handle permission, but it's better user experience to guide
        // the user through granting OS permissions in your own application.
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .denied || status == .restricted {
            let alert = UIAlertController(
                title: NSLocalizedString("camera_unavailable.title", comment: "Camera unavailable error popup title"),
                message: NSLocalizedString("camera_unavailable.message", comment: "Camera unavailable error popup message"),
                preferredStyle: .alert)
            alert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("camera_unavailable.button.ignore", comment: "Button to open AV SDK anyway on camera error"),
                    style: .default,
                    handler: { action in
                        next()
                    }))
            alert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("camera_unavailable.button.open_app_settings", comment: "Button to open App Settings on camera error"),
                    style: .default,
                    handler: { action in
                        let url = URL(string: UIApplication.openSettingsURLString)!
                        UIApplication.shared.open(url)
                    }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("camera_unavailable.button.cancel", comment: "Button to cancel on camera error"), style: .cancel))
            present(alert, animated: true)
        } else {
            next()
        }
    }

    func displayError(_ error: Error) {
        let alert = UIAlertController(title: NSLocalizedString("error.title", comment: "AV SDK error popup title"), message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("error.ok", comment: "AV SDK error popup dismiss button"), style: .default))
        present(alert, animated: true)
        // You can inspect specific error states by casting error to NSError, matching the domain
        // against AVKScanErrorDomain, and inspecting its code as AVKScanError.
    }

    // MARK: AVKScanViewControllerDelegate

    func scanViewController(_ controller: AVKScanViewController, unrecoverableError error: Error) {
        lastScan = .failure(error)
        tableView.reloadData()
        dismiss(animated: true) {
            self.displayError(error)
        }
    }

    func scanViewController(_ controller: AVKScanViewController, scanDidCompleteWith result: AVKScanResult) {
        lastScan = .success(result)
        tableView.reloadData()
        dismiss(animated: true) {
            // Use of the scan result is highly specific to what you wish to accomplish with the AV SDK.
            // The following is for generic brand protection scans. Never trust the result for server-sided authentication!
            if result.isAuthentic {
                // - the label is authentic
                // - the URL to product information, optionally with a SIPv4 token, is available in result.campaignURL
                // - you can display a generic authentic message, product information, etc. at this point
            } else {
                // - the label is not authentic, but not necessarily counterfeit
                // - display instructions to the user to scan again
                // - evaluate result.authResult if you wish to explicitly check for counterfeits
            }
        }
    }

    // MARK: AVKBrandingDelegate
    // You can omit this bit to get the AV SDK's standard branding.

    @objc func imageNamed(_ name: String, compatibleWith traitCollection: UITraitCollection?) -> UIImage? {
        let bundle = Bundle(for: type(of: self))
        switch name {
        case "ScanLogo":
            // It's also fine to just not implement this and return no logo to hide the logo view.
            // The logo in this case is marked as template in Assets.xcassets, hence the universal
            // primary color is applied to it.
            return UIImage(named: "ExampleLogo", in: bundle, compatibleWith: traitCollection)!
        default:
            return nil
        }
    }

    @objc func colorNamed(_ name: String, compatibleWith traitCollection: UITraitCollection?) -> UIColor? {
        switch name {
        case "UniversalPrimary": return UIColor.systemTeal
        case "UniversalSecondary": return UIColor.white
        default: return nil
        }
    }

    // MARK: Table View
    // This and everything below exists simply for visualization of scan results in this demo.

    var lastCodeRawTypeText: String {
        guard case .success(let result) = lastScan else {
            return ""
        }
        switch result.codeRawType {
        case .undefined: return NSLocalizedString("common.undefined", comment: "Placeholder for default/undefined enum values")
        case .QR: return "QR"
        case .DM: return "DM"
        @unknown default: return NSLocalizedString("common.unhandled", comment: "Placeholder for unhandled enum values")
        }
    }

    var lastResultText: String {
        guard case .success(let result) = lastScan else {
            return ""
        }
        switch result.authResult {
        case .authentic: return NSLocalizedString("auth_result.authentic", comment: "AV SDK authentic result")
        case .contradictingEvidence: return NSLocalizedString("auth_result.inconclusive", comment: "AV SDK inconclusive result")
        case .counterfeit: return NSLocalizedString("auth_result.counterfeit", comment: "AV SDK counterfeit result")
        case .standard2DCode: return NSLocalizedString("auth_result.standard_2d_code", comment: "AV SDK standard 2D code result")
        case .timeout: return NSLocalizedString("auth_result.timeout", comment: "AV SDK timeout result")
        case .unsupportedLabel: return NSLocalizedString("auth_result.unsupported_label", comment: "AV SDK unsupported label result")
        case .other: return NSLocalizedString("auth_result.other", comment: "AV SDK other result")
        @unknown default: return NSLocalizedString("common.unhandled", comment: "Placeholder for unhandled enum values")
        }
    }

    let secStartScan = 0
    let secResult = 1
    let secVersion = 2
    let secDevice = 3
    let numSections = 4

    let resSessionID = 0
    let resSLID = 1
    let resCodeType = 2
    let resCodeText = 3
    let resResult = 4
    let resURL = 5
    let resAttestation = 6
    let numResultRows = 7

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return numSections
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case secResult: return NSLocalizedString("result.title", comment: "Scan Result section header")
        case secVersion: return NSLocalizedString("version.title", comment: "Version Information section header")
        case secDevice: return NSLocalizedString("device.title", comment: "Device Information section header")
        default: return nil
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case secStartScan: return NSLocalizedString("scan.footer", comment: "Description of attestation delay")
        case secResult: return NSLocalizedString("result.footer", comment: "Tap to copy hint")
        default: return nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case secStartScan: return 2
        case secResult: return numResultRows
        case secVersion: return 2
        case secDevice: return 2
        default: fatalError()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case secStartScan:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath)
                cell.textLabel?.text = NSLocalizedString("scan.button", comment: "Scan start button")
                cell.detailTextLabel?.text = NSLocalizedString("scan.button.subtitle", comment: "Scan description")
                cell.detailTextLabel?.textColor = .none
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
                cell.switchTextLabel.text = NSLocalizedString("scan.attestation_toggle", comment: "Scan attestation toggle")
                cell.switch_.isOn = scanConfig.attestationMode != .none
                cell.switch_.addTarget(self, action: #selector(attestationSwitchChanged), for: UIControl.Event.valueChanged)
                return cell
            default:
                fatalError()
            }

        case secResult:
            switch indexPath.row {
            case resSessionID:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ValueSmallCell", for: indexPath)
                cell.textLabel?.text = NSLocalizedString("result.session_id", comment: "Session ID row")
                if case .success(let result) = lastScan {
                    cell.detailTextLabel?.text = result.sessionID
                } else {
                    cell.detailTextLabel?.text = ""
                }
                cell.detailTextLabel?.textColor = .none
                return cell
            case resSLID:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ValueCell", for: indexPath)
                cell.textLabel?.text = "SLID"
                if case .success(let result) = lastScan {
                    cell.detailTextLabel?.text = result.slid
                } else {
                    cell.detailTextLabel?.text = ""
                }
                cell.detailTextLabel?.textColor = .none
                return cell
            case resCodeType:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ValueCell", for: indexPath)
                cell.textLabel?.text = NSLocalizedString("result.code_type", comment: "Code Type row")
                cell.detailTextLabel?.text = lastCodeRawTypeText
                cell.detailTextLabel?.textColor = .none
                return cell
            case resCodeText:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ValueSmallCell", for: indexPath)
                cell.textLabel?.text = NSLocalizedString("result.code_text", comment: "Code Text row")
                if case .success(let result) = lastScan {
                    cell.detailTextLabel?.text = result.codeRawText
                } else {
                    cell.detailTextLabel?.text = ""
                }
                cell.detailTextLabel?.textColor = .none
                return cell
            case resResult:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ValueCell", for: indexPath)
                cell.textLabel?.text = NSLocalizedString("result.auth_result", comment: "Authentication Result row")
                switch lastScan {
                case .pending:
                    cell.detailTextLabel?.text = ""
                    cell.detailTextLabel?.textColor = .none
                case .success(let result):
                    cell.detailTextLabel?.text = lastResultText
                    cell.detailTextLabel?.textColor = result.isAuthentic ? .systemGreen : .systemRed
                case .failure:
                    cell.detailTextLabel?.text = NSLocalizedString("auth_result.error", comment: "Auth error indicator")
                    cell.detailTextLabel?.textColor = .none
                }
                return cell
            case resURL:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ValueSmallCell", for: indexPath)
                switch lastScan {
                case .pending:
                    cell.textLabel?.text = NSLocalizedString("result.url.campaign", comment: "Campaign URL description")
                    cell.detailTextLabel?.text = ""
                case .success(let result):
                    cell.textLabel?.text = NSLocalizedString("result.url.campaign", comment: "Campaign URL description")
                    if let campaignURL = result.campaignURL {
                        cell.detailTextLabel?.text = campaignURL.absoluteString
                    } else {
                        cell.detailTextLabel?.text = NSLocalizedString("common.none", comment: "Placeholder for no value")
                    }
                case .failure(let error as NSError):
                    cell.textLabel?.text = NSLocalizedString("result.url.error", comment: "Error URL description")
                    if let errorURL = error.userInfo[NSURLErrorKey] {
                        cell.detailTextLabel?.text = (errorURL as! NSURL).absoluteString
                    } else {
                        cell.detailTextLabel?.text = NSLocalizedString("common.none", comment: "Placeholder for no value")
                    }
                }
                cell.detailTextLabel?.textColor = .none
                return cell
            case resAttestation:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ValueCell", for: indexPath)
                cell.textLabel?.text = NSLocalizedString("result.attestation_token", comment: "Attestation Token row")
                guard case .success(let result) = lastScan else {
                    cell.detailTextLabel?.text = ""
                    cell.detailTextLabel?.textColor = .none
                    return cell
                }
                if result.attestationToken != nil {
                    cell.detailTextLabel?.text = NSLocalizedString("result.attestation_token.received", comment: "Placeholder for available attestation token")
                    cell.detailTextLabel?.textColor = .systemGreen
                } else {
                    cell.detailTextLabel?.text = NSLocalizedString("common.none", comment: "Placeholder for no value")
                    cell.detailTextLabel?.textColor = .none
                }
                // The token would be sent to your backend service, which would authenticate
                // against a managed service to validate the token. Samples for token validation
                // in backend software are available separately.
                // It is not guaranteed that a token is available. Tokens are only issued upon
                // successful server-sided authentication.
                return cell
            default:
                fatalError()
            }

        case secVersion:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ValueCell", for: indexPath)
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "AV SDK"
                cell.detailTextLabel?.text = AVKVersionInfo.sdkVersion()
            case 1:
                cell.textLabel?.text = "libavcore"
                cell.detailTextLabel?.text = AVKVersionInfo.coreVersion()
            default:
                fatalError()
            }
            cell.detailTextLabel?.textColor = .none
            return cell

        case secDevice:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ValueCell", for: indexPath)
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = NSLocalizedString("device.compatible", comment: "Device compatible row")
                cell.detailTextLabel?.text = AVKCompatibility.isDeviceCompatible() ? NSLocalizedString("device.compatible.yes", comment: "Device compatible") : NSLocalizedString("device.compatible.no", comment: "Device not compatible")
                cell.detailTextLabel?.textColor = .none
            case 1:
                cell.textLabel?.text = NSLocalizedString("device.compatibility_level", comment: "Device compatibility level row")
                var level: String
                switch AVKCompatibility.compatibilityLevel(for: AVKScanConfig.default()) {
                case .incompatible: level = NSLocalizedString("device.compatibility_level.incompatble", comment: "Compatibility level: Incompatible")
                case .limited: level = NSLocalizedString("device.compatibility_level.limited", comment: "Compatibility level: Limited")
                case .full: level = NSLocalizedString("device.compatibility_level.full", comment: "Compatibility level: Full")
                @unknown default: level = NSLocalizedString("common.unhandled", comment: "Placeholder for unhandled enum values")
                }
                cell.detailTextLabel?.text = level
                cell.detailTextLabel?.textColor = .none
            default:
                fatalError()
            }
            return cell

        default:
            fatalError()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle table row button tap
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == secStartScan && indexPath.row == 0 {
            startScan()
        } else if indexPath.section == secResult {
            copyResultToClipboard(indexPath.row)
        }
    }

    func copyResultToClipboard(_ row: Int) {
        let pb = UIPasteboard.general

        switch row {
        case resSessionID:
            if case .success(let result) = lastScan {
                pb.string = result.sessionID
            }

        case resSLID:
            if case .success(let result) = lastScan {
                pb.string = result.slid
            }

        case resCodeType:
            pb.string = lastCodeRawTypeText

        case resCodeText:
            if case .success(let result) = lastScan {
                pb.string = result.codeRawText
            }

        case resResult:
            pb.string = lastResultText

        case resURL:
            switch lastScan {
            case .pending:
                break
            case .success(let result):
                if let campaignURL = result.campaignURL {
                    pb.string = campaignURL.absoluteString
                }
            case .failure(let error as NSError):
                if let errorURL = error.userInfo[NSURLErrorKey] {
                    pb.string = (errorURL as! NSURL).absoluteString
                }
            }

        case resAttestation:
            if case .success(let result) = lastScan {
                pb.string = result.attestationToken
            }

        default:
            fatalError()
        }
    }

}
