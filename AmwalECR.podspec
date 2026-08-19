# The Amwal ECR SDK for iOS, for native apps.
#
# The same sources are published to Swift Package Manager from the
# AmwalECR-iOS-SPM repository, and consumed by the Flutter plugin `amwal_ecr` —
# one implementation of the wire protocol, three ways to depend on it.
#
# Released by tagging `vX.Y.Z` here and running:
#
#   pod trunk push AmwalECR.podspec
Pod::Spec.new do |s|
  s.name             = 'AmwalECR'
  s.version          = '0.2.0'
  s.summary          = 'Drive an Amwal POS terminal from an iOS app: sale, void, refund, inquiry, e-receipt.'
  s.description      = <<-DESC
Speaks the Amwal ECR wire protocol over TCP on the local network, so a till
running on iOS can drive a POS terminal directly.

Every operation answers with a typed outcome that keeps an unknown result apart
from a refusal: a timeout, a lost connection or an unreadable answer is never
reported as a decline, because the transaction may still have completed. Amounts
are `Decimal` throughout and converted to the wire's minor units once, half-up,
matching the Android SDK to the last minor unit.
                       DESC
  s.homepage         = 'https://github.com/amwal-pay/AmwalECR-iOS-CocoaPods'
  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.author           = { 'Amwal Pay' => 'support@amwal-pay.com' }
  s.documentation_url = 'https://github.com/amwal-pay/AmwalECR-iOS-CocoaPods/blob/main/README.md'

  s.source           = {
    :git => 'https://github.com/amwal-pay/AmwalECR-iOS-CocoaPods.git',
    :tag => "v#{s.version}"
  }
  s.source_files     = 'Sources/AmwalECR/**/*.swift'

  # The wrapper's floor, not the protocol's. Raise it here and in the SwiftPM
  # repository's Package.swift together.
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '12.0'
  s.swift_version    = '5.5'

  # Foundation and Darwin only: no third-party dependency, and nothing that
  # would drag a Flutter engine into a native app.
  s.frameworks       = 'Foundation'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }

  # The suite that keeps this pod honest against the Kotlin SDK: rounding
  # boundaries, the frozen HMAC digest, and a loopback terminal.
  #
  #   pod lib lint --include-podspecs='*.podspec' --allow-warnings
  s.test_spec 'Tests' do |ts|
    ts.source_files = 'Tests/AmwalECRTests/**/*.swift'
  end
end
