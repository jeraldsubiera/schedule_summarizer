import UIKit
import Social

// Minimal Share Extension controller that takes incoming text, writes it to a shared UserDefaults group,
// and tries to open the main app via custom URL scheme. You must set up an App Group and URL scheme in the host app.

class ShareViewController: SLComposeServiceViewController {
    override func isContentValid() -> Bool {
        return true
    }

    override func didSelectPost() {
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            if let attachments = item.attachments {
                for provider in attachments {
                    if provider.hasItemConformingToTypeIdentifier("public.text") {
                        provider.loadItem(forTypeIdentifier: "public.text", options: nil) { (data, error) in
                            if let text = data as? String {
                                // Write to shared UserDefaults (requires App Group set in both targets)
                                let groupName = "group.shuttle_summary"
                                if let userDefaults = UserDefaults(suiteName: groupName) {
                                    userDefaults.set(text, forKey: "shuttle_shared_text")
                                    userDefaults.synchronize()
                                }

                                // Attempt to open host app using URL scheme (must be configured in the host app)
                                let urlScheme = "shuttlesummary://shared"
                                if let url = URL(string: urlScheme) {
                                    var responder: UIResponder? = self
                                    while responder != nil {
                                        if let application = responder as? UIApplication {
                                            application.perform(#selector(UIApplication.open(_:options:completionHandler:)), with: url)
                                            break
                                        }
                                        responder = responder?.next
                                    }
                                }
                            }
                        }
                        break
                    }
                }
            }
        }

        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        return []
    }
}
