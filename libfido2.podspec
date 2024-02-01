    Pod::Spec.new do |s|
    s.name             = "libfido2"
    s.version          = "1.14.0"
    s.summary          = "Provides library functionality for FIDO2, including communication with a device over USB or NFC."
    s.homepage         = "https://github.com/Yubico/libfido2"
    s.license          = { :type => 'BSD' }
    s.author           = "Yubico"
    s.source           = { :git => "https://github.com/Yubico/libfido2.git", :tag => s.version.to_s }
    s.source_files = 'Sources/libfido2/src/*.c', 'Sources/libfido2/headers/public/**/*.h'
    s.preserve_paths = 'Sources/libfido2/headers/private/**/*.h'
    s.header_mappings_dir = 'Sources/libfido2/headers/public'
    s.vendored_libraries = 'Sources/libfido2/built-libs/libcbor/libcbor.a', 'Sources/libfido2/built-libs/openssl/libcrypto.a', 'Sources/libfido2/built-libs/openssl/libssl.a'
    s.resources = ['Sources/libfido2/built-libs/openssl/fips-arm64/fips-arm64.dylib', 'Sources/libfido2/built-libs/openssl/fips-x86_64/fips-x86_64.dylib', 'Sources/libfido2/built-libs/openssl/fips-arm64/openssl-arm64.cnf', 'Sources/libfido2/built-libs/openssl/fips-x86_64/openssl-x86_64.cnf']
    s.libraries = 'z'
    s.ios.deployment_target = '16.0'
    s.osx.deployment_target = '12.0'
    s.static_framework = true
    s.pod_target_xcconfig = {
                                'OTHER_CFLAGS' => " -D_POSIX_C_SOURCE=200809L -D_BSD_SOURCE -D_DARWIN_C_SOURCE -D__STDC_WANT_LIB_EXT1__=1 -std=c99      -DNDEBUG -D_FORTIFY_SOURCE=2 -fPIC -Wall -Wextra -Werror -Wshadow -Wcast-qual -Wwrite-strings -Wmissing-prototypes -Wbad-function-cast -Wimplicit-fallthrough -pedantic -pedantic-errors -Wshorten-64-to-32 -fstack-protector-all  $(inherited)",
                                'OTHER_CFLAGS[config=Debug]' => " -D_POSIX_C_SOURCE=200809L -D_BSD_SOURCE -D_DARWIN_C_SOURCE -D__STDC_WANT_LIB_EXT1__=1 -std=c99         -fno-omit-frame-pointer -fPIC -Wall -Wextra -Werror -Wshadow -Wcast-qual -Wwrite-strings -Wmissing-prototypes -Wbad-function-cast -Wimplicit-fallthrough -pedantic -pedantic-errors -Wshorten-64-to-32 -fstack-protector-all  $(inherited)",
                                'GCC_PREPROCESSOR_DEFINITIONS' => "'CMAKE_INTDIR=\"$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)\"' '_FIDO_MAJOR=1' '_FIDO_MINOR=14' '_FIDO_PATCH=0' HAVE_ARC4RANDOM_BUF HAVE_ASPRINTF HAVE_CLOCK_GETTIME HAVE_ERR_H HAVE_GETLINE HAVE_GETOPT HAVE_MEMSET_S HAVE_READPASSPHRASE HAVE_SIGNAL_H HAVE_STRLCAT HAVE_STRLCPY HAVE_STRSEP HAVE_SYSCONF HAVE_SYS_RANDOM_H HAVE_TIMINGSAFE_BCMP HAVE_UNISTD_H HAVE_DEV_URANDOM 'OPENSSL_API_COMPAT=0x10100000L' 'TLS=__thread' _FIDO_INTERNAL $(inherited)",
                                'GCC_PREPROCESSOR_DEFINITIONS[config=Debug]' => "'CMAKE_INTDIR=\"$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)\"' '_FIDO_MAJOR=1' '_FIDO_MINOR=14' '_FIDO_PATCH=0' HAVE_ARC4RANDOM_BUF HAVE_ASPRINTF HAVE_CLOCK_GETTIME HAVE_ERR_H HAVE_GETLINE HAVE_GETOPT HAVE_MEMSET_S HAVE_READPASSPHRASE HAVE_SIGNAL_H HAVE_STRLCAT HAVE_STRLCPY HAVE_STRSEP HAVE_SYSCONF HAVE_SYS_RANDOM_H HAVE_TIMINGSAFE_BCMP HAVE_UNISTD_H HAVE_DEV_URANDOM 'OPENSSL_API_COMPAT=0x10100000L' 'TLS=__thread' _FIDO_INTERNAL $(inherited)",
                                'USER_HEADER_SEARCH_PATHS' => '"$PODS_ROOT/libfido2/Sources/libfido2/headers/private/**"',
                                'CLANG_WARN_DOCUMENTATION_COMMENTS' => false
                            }
    end
