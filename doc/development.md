# Development

Documentation, building, testing, and continuous integration for `AmwalECR-iOS-CocoaPods`. Using the SDK is in the [README](../README.md).

## Documentation

The protocol and the operational detail are shared with the Android SDK and are
not duplicated here:

| | |
|---|---|
| **[Implementation](implementation.md)** | Plan, open, sign-on, sale, close receipt on this package |
| **[Wire protocol](https://github.com/amwal-pay/ECR-simulator/blob/main/ecr-sdk/docs/protocol.md)** | The bytes on the socket |
| **[Integration guide](https://github.com/amwal-pay/ECR-simulator/blob/main/ecr-sdk/docs/integration-guide.md)** | From an empty project to a till that reconciles properly |
| **[Troubleshooting](https://github.com/amwal-pay/ECR-simulator/blob/main/ecr-sdk/docs/troubleshooting.md)** | Symptom → cause → fix |
| **[Compatibility matrix](https://github.com/amwal-pay/amwal-ecr-flutter/blob/main/doc/compatibility-matrix.md)** | Versions, floors, and every place the platforms differ |
| **[Release policy](https://github.com/amwal-pay/amwal-ecr-flutter/blob/main/doc/release-policy.md)** | Versioning, release order, rollback |


## Building and testing

```bash
pod lib lint AmwalECR.podspec --allow-warnings
```

Unit tests share signing placeholders via `EcrTestConfigs` (aligned with
`ecr_sdk`): `SECURE_HASH_KEY_ECR_WIFI`, `SECURE_HASH_KEY_ECR_WIFI_OTHER`, and
`SECURE_HASH_KEY_WEBSERVICE`, exposed as `lan` / `lanOther` / `webService`
configs. Never commit real Amwal keys.

The suite is not incidental to the platform story: `EcrDecimalTests`,
`EcrMessageTests` and `EcrResponseReaderTests` assert this SDK against the Kotlin
SDK's own test payloads and rounding boundaries. That is what keeps "identical on
both platforms" a checkable claim.

### Continuous integration

[`codemagic.yaml`](../codemagic.yaml) runs on Codemagic:

| Workflow | When | What it does |
|---|---|---|
| `pod-verify` | every push and pull request | `pod lib lint` (iOS + macOS, with the test spec) and checks the podspec version against the top `CHANGELOG.md` entry |
| `pod-release` | a `vX.Y.Z` tag | checks the tag against the podspec, pushes to CocoaPods trunk, then reads the version back from the trunk API |

`pod-release` is idempotent: a version already on trunk is skipped, never
re-pushed. `pod trunk push` retries on transient failures (for example a GitHub
commit API timeout after trunk has already accepted the version) and treats
“already on trunk” as success.

Start a release by pushing the tag — `git push origin vX.Y.Z` — so Codemagic
receives a tag webhook (`CM_TAG` is set). A manual rebuild of a tagged commit
also works: the script falls back to `git describe` when `CM_TAG` is empty. Do
not start `pod-release` on a branch; that fails.

The trunk token lives in a Codemagic environment group named
`cocoapods_credentials`, as `COCOAPODS_TRUNK_TOKEN`; see the release policy in
[amwal-ecr-flutter](https://github.com/amwal-pay/amwal-ecr-flutter/blob/main/doc/release-policy.md).
