Manual steps to finish iOS Share Extension integration

1) Create a new Share Extension target in Xcode:
   - Open `ios/Runner.xcworkspace` in Xcode.
   - File → New → Target → iOS → Share Extension → Next.
   - Name it `ShareExtension` (or match the scaffolded folder).

2) Replace the generated `Info.plist` in the extension target with `ios/ShareExtension/Info.plist` (or merge as needed).

3) Add the `ShareViewController.swift` file to the new extension target. You can use the scaffolded `ios/ShareExtension/ShareViewController.swift`.

4) Configure an App Group so the extension can share data with the main app:
   - Select the Runner app target → Signing & Capabilities → + Capability → App Groups.
   - Add a group, e.g. `group.shuttle_summary`.
   - Select the Share Extension target and enable the same App Group.

5) In your host app, read the shared text from the App Group when the app becomes active. Example:

   Swift (AppDelegate/SceneDelegate):

   ```swift
   if let ud = UserDefaults(suiteName: "group.shuttle_summary") {
       if let text = ud.string(forKey: "shuttle_shared_text"), !text.isEmpty {
           // send this text to Flutter via method channel or via URL scheme handling
           ud.removeObject(forKey: "shuttle_shared_text")
       }
   }
   ```

6) Alternatively, configure a custom URL scheme for the host app (e.g. `shuttlesummary://`) and handle the incoming URL in the Flutter side to pull shared content.

7) After wiring, build and run the Share Extension on a device and test sharing plain text to your app via the iOS share sheet.

Notes:
- Automatic registration of the new extension into the Xcode project requires editing `project.pbxproj`. Creating the target via Xcode is the easiest and most reliable approach.
- The `receive_sharing_intent` plugin also documents iOS extension setup; consult its README for further details.
