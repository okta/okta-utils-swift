#!/usr/bin/env ruby

require 'xcodeproj'
require 'fileutils'
require 'json'

arguments = {}
ARGV.each do|a|
  split = a.split("=", 2)
  arguments[split[0]] = split[1]
end
openssl_new_version = arguments["openssl"].to_s
libcbor_new_version = arguments["libcbor"].to_s
libfido2_new_version = arguments["libfido2"].to_s

if openssl_new_version.empty? || libcbor_new_version.empty? || libfido2_new_version.empty?
    puts "error - invalid arguments"
    return
end

openssl_current_version = ""
libcbor_current_version = ""
libfido2_current_version = ""

if File.exist?('manifest.json') == false
    puts "error - manifest missing"
    return
end

manifest_json = {}
File.open('manifest.json') do | manifest |
    manifest_json = JSON.parse(manifest.read)
    openssl_current_version = manifest_json["openssl"].to_s
    libcbor_current_version = manifest_json["libcbor"].to_s
    libfido2_current_version = manifest_json["libfido2"].to_s
end

if openssl_current_version.empty? || libcbor_current_version.empty? || libfido2_current_version.empty?
    puts "error - invalid manifest"
    return
end

update_openssl = Gem::Version.new(openssl_new_version.tr('openssl-','')) > Gem::Version.new(openssl_current_version.tr('openssl-',''))
update_libcbor = Gem::Version.new(libcbor_new_version.tr('v','')) > Gem::Version.new(libcbor_current_version.tr('v',''))
update_libfido2 = Gem::Version.new(libfido2_new_version) > Gem::Version.new(libfido2_current_version)

if update_openssl
    # Clone
    FileUtils.rm_rf('openssl')
    openssl_clone_cmd = "git clone --depth 1 --branch #{openssl_new_version} https://github.com/openssl/openssl.git openssl"
    system(openssl_clone_cmd)
    
    FileUtils.rm_rf('built-libs/openssl')
    FileUtils.mkdir_p('built-libs/openssl/arm64')
    FileUtils.mkdir_p('built-libs/openssl/x86_64')
    FileUtils.mkdir_p('fips-resources/arm64')
    FileUtils.mkdir_p('fips-resources/x86_64')

    # Build openssl for arm64
    Dir.chdir('openssl')
    openssl_arm64_configure_cmd = "./Configure enable-rc5 zlib darwin64-arm64-cc no-asm enable-fips -mmacosx-version-min=12.0"
    openssl_arm64_make_cmd = "make"
    
    system(openssl_arm64_configure_cmd)
    system(openssl_arm64_make_cmd)
    
    FileUtils.cp('libssl.a', '../built-libs/openssl/arm64/')
    FileUtils.cp('libcrypto.a', '../built-libs/openssl/arm64/')
    FileUtils.cp('providers/fips.dylib', '../fips-resources/arm64/')
    FileUtils.cp('providers/fipsmodule.cnf', '../fips-resources/arm64/')
    FileUtils.cp('apps/openssl.cnf', '../fips-resources/arm64/')
    system('git clean -fX')
    
    # Build openssl for x86_64
    openssl_x86_64_configure_cmd = "./Configure darwin64-x86_64-cc enable-fips -mmacosx-version-min=12.0"
    openssl_x86_64_make_cmd = "make"
    
    system(openssl_x86_64_configure_cmd)
    system(openssl_x86_64_make_cmd)
    
    FileUtils.cp('libssl.a', '../built-libs/openssl/x86_64/')
    FileUtils.cp('libcrypto.a', '../built-libs/openssl/x86_64/')
    FileUtils.cp('providers/fips.dylib', '../fips-resources/x86_64/')
    FileUtils.cp('providers/fipsmodule.cnf', '../fips-resources/x86_64/')
    FileUtils.cp('apps/openssl.cnf', '../fips-resources/x86_64/')

    # Copy fips cnf into openssl cnf
    openssl_cnf_arm64 = File.read('../fips-resources/arm64/openssl.cnf')
    fips_cnf_arm64 = File.read('../fips-resources/arm64/fipsmodule.cnf').gsub('activate = 1', '# activate = 1')
    changed_openssl_cnf_arm64 = openssl_cnf_arm64.gsub('# .include fipsmodule.cnf', fips_cnf_arm64).gsub('# fips = fips_sect', 'fips = fips_sect')
    File.open('../fips-resources/arm64/openssl.cnf', 'w') { |file| file << changed_openssl_cnf_arm64 }
    
    openssl_cnf_x86_64 = File.read('../fips-resources/x86_64/openssl.cnf')
    fips_cnf_x86_64 = File.read('../fips-resources/x86_64/fipsmodule.cnf').gsub('activate = 1', '# activate = 1')
    changed_openssl_cnf_x86_64 = openssl_cnf_x86_64.gsub('# .include fipsmodule.cnf', fips_cnf_x86_64).gsub('# fips = fips_sect', 'fips = fips_sect')
    File.open('../fips-resources/x86_64/openssl.cnf', 'w') { |file| file << changed_openssl_cnf_x86_64 }

    FileUtils.rm_f('../fips-resources/arm64/fipsmodule.cnf')
    FileUtils.rm_f('../fips-resources/x86_64/fipsmodule.cnf')
    
    # Copy the headers. Using [.h] because there are some unnecessary headers with extension .H
    FileUtils.mkdir_p('../headers/public/openssl')
    Dir.glob('*.[h]', base: 'include/openssl/') do | filename |
        FileUtils.cp('include/openssl/' + filename, '../headers/public/openssl/' + filename)
    end

    # This file is obselete, so remove it
    FileUtils.rm_f('../headers/public/openssl/asn1_mac.h')
    
    Dir.chdir('..')
    FileUtils.rm_rf('openssl')
    
    # Create fat libs
    Dir.chdir('built-libs/openssl')
    lipo_cmd_libcrypto = "lipo -create arm64/libcrypto.a x86_64/libcrypto.a -output libcrypto.a"
    lipo_cmd_libssl = "lipo -create arm64/libssl.a x86_64/libssl.a -output libssl.a"
    
    system(lipo_cmd_libcrypto)
    system(lipo_cmd_libssl)
    
    FileUtils.rm_rf('arm64')
    FileUtils.rm_rf('x86_64')
    
    Dir.chdir('../..')

    manifest_json["openssl"] = openssl_new_version
else
    puts("openssl is up to date")
end

if update_libcbor
    # Clone the repo
    FileUtils.rm_rf('libcbor')
    libcbor_clone_cmd = "git clone --depth 1 --branch #{libcbor_new_version} https://github.com/PJK/libcbor.git libcbor"
    system(libcbor_clone_cmd)
    
    # Build for both archs
    FileUtils.rm_rf('built-libs/libcbor')
    FileUtils.mkdir_p('built-libs/libcbor')
    
    Dir.chdir('libcbor')
    libcbor_cmake_cmd = "cmake \"-DCMAKE_OSX_ARCHITECTURES=x86_64;arm64\" -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 ."
    libcbor_make_cmd = "make"
    
    system(libcbor_cmake_cmd)
    system(libcbor_make_cmd)
    FileUtils.cp('src/libcbor.a', '../built-libs/libcbor/')
    
    # Copy the headers
    FileUtils.mkdir_p('../headers/public/cbor')
    FileUtils.cp('src/cbor.h', '../headers/public/cbor.h')
    FileUtils.cp('cbor/configuration.h', '../headers/public/cbor/')
    Dir.glob('*.[h]', base: 'src/cbor/') do | filename |
        FileUtils.cp('src/cbor/' + filename, '../headers/public/cbor/' + filename)
    end
    
    Dir.chdir('..')
    FileUtils.rm_rf('libcbor')
    
    manifest_json["libcbor"] = libcbor_new_version
else
    puts("libcbor is up to date")
end

if update_libfido2
    # Clone
    FileUtils.rm_rf('libfido2')
    libfido2_clone_cmd = "git clone --depth 1 --branch #{libfido2_new_version} https://github.com/Yubico/libfido2.git libfido2"
    system(libfido2_clone_cmd)

    # Create xcode project for libfido2
    FileUtils.rm_rf('project')
    Dir.mkdir('project')
    Dir.chdir('project')

    cmake_command = "cmake -G Xcode ../libfido2 -DBUILD_EXAMPLES=OFF -DBUILD_MANPAGES=OFF -DBUILD_SHARED_LIBS=OFF -DBUILD_TOOLS=OFF -DUSE_WINHELLO=OFF"
    system(cmake_command)

    Dir.chdir('..')
    
    # Identify source files using XcodeProj and copy them
    project_path = 'project/libfido2.xcodeproj'
    project = Xcodeproj::Project.open(project_path)

    FileUtils.rm_rf('src')
    Dir.mkdir('src')
    Dir.chdir('src')

    # fido2 is the name of the library target
    fido2target = nil
    project.targets.each do |target|
        if target.name == 'fido2'
            fido2target = target
        end
    end

    fido2target.source_build_phase.files_references.to_a.map do |pbx_build_file|
        filepath = pbx_build_file.path.to_s
        FileUtils.cp('../libfido2/' + filepath, '.')
    end

    Dir.chdir('..')
    FileUtils.rm_rf('project')

    # Copy libfido2 headers
    FileUtils.rm_rf('headers/private')
    FileUtils.mkdir_p('headers/private')

    Dir.glob('*.[h]', base: 'libfido2/src') do | filename |
        FileUtils.cp('libfido2/src/' + filename, 'headers/private/' + filename)
    end

    FileUtils.mkdir_p('headers/private/openbsd-compat')
    Dir.glob('*.[h]', base: 'libfido2/openbsd-compat') do | filename |
        FileUtils.cp('libfido2/openbsd-compat/' + filename, 'headers/private/openbsd-compat/' + filename)
    end
    
    FileUtils.cp_r('libfido2/src/fido', 'headers/private/')

    # We only need fido.h and the headers in fido/ folder to be public headers
    FileUtils.rm_f('headers/public/fido.h')
    FileUtils.rm_rf('headers/public/fido')
    FileUtils.mv('headers/private/fido.h', 'headers/public/fido.h')
    FileUtils.mv('headers/private/fido', 'headers/public/')

    FileUtils.rm_rf('libfido2')

    # Copy the build settings that needs to be in podspec
    # OTHER_CFLAGS and GCC_PREPROCESSOR_DEFINITIONS are the only settings
    # that have custom values for build, no others are needed
    other_cflags = fido2target.resolved_build_setting('OTHER_CFLAGS')
    preprocessor_macros = fido2target.resolved_build_setting('GCC_PREPROCESSOR_DEFINITIONS')
    debug_other_cflags = other_cflags['Debug'].join(" ")
    release_other_cflags = other_cflags['Release'].join(" ")
    debug_macros = preprocessor_macros['Debug']
    debug_macros_str = debug_macros.join(" ")
    release_macros = preprocessor_macros['Release']
    release_macros_str = release_macros.join(" ")

    # Header search paths
    headers_search_path = "$PODS_ROOT/libfido2/Sources/libfido2/headers/private/**"

    # Create podspec in root folder
    Dir.chdir('../..')
    File.open("libfido2.podspec", "w") do |f|
        f.write(
                <<-TEXT
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
    s.resources = 'Sources/libfido2/fips-resources'
    s.libraries = 'z'
    s.ios.deployment_target = '16.0'
    s.osx.deployment_target = '12.0'
    s.static_framework = true
    s.pod_target_xcconfig = {
                                'OTHER_CFLAGS' => #{release_other_cflags.dump},
                                'OTHER_CFLAGS[config=Debug]' => #{debug_other_cflags.dump},
                                'GCC_PREPROCESSOR_DEFINITIONS' => #{release_macros_str.dump},
                                'GCC_PREPROCESSOR_DEFINITIONS[config=Debug]' => #{debug_macros_str.dump},
                                'USER_HEADER_SEARCH_PATHS' => '#{headers_search_path.dump}',
                                'CLANG_WARN_DOCUMENTATION_COMMENTS' => false
                            }
    end
              TEXT
                )
        f.close
    end
    Dir.chdir('Sources/libfido2')
    
    manifest_json["libfido2"] = libfido2_new_version
else
    puts("libfido2 is up to date")
end

File.open('manifest.json', "w") do | manifest |
    manifest.write(JSON.pretty_generate(manifest_json))
end
