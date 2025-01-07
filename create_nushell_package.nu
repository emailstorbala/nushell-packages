#!/usr/bin/env nu
# This program prepares the nushell package

def get_pkg_info []: -> record {
  let nu_ver = run-external $"($env.HOME)/.cargo/bin/nu" ...["--version"]
  return {
    bin: "nu"
    name: "nushell"
    arch: "x86_64"
    version: $nu_ver
    vendor: "The Nushell Project Developers"
    desc: "The nushell language and shell."
    category: "nushell"
    url: "https://www.nushell.sh/"
    maintainer: "www.nushell.sh"
    license: "MIT License"
    dir: "build"
  }
}

def create_bundle_dir [] {
  echo "Creating bundle directory ..."
  let bin_path = $env.PWD | path join "usr/local/bin"
  let license_path = $env.PWD | path join "usr/share/licenses/nushell"
  let doc_path = $env.PWD | path join "usr/share/doc"
  let nu_cargo_bin_path = $env.HOME | path join ".cargo/bin/nu"
  rm -rf $bin_path $license_path $doc_path
  mkdir $bin_path $license_path $doc_path
  let contrib = "https://raw.githubusercontent.com/nushell/nushell/main/CONTRIBUTING.md"
  let readme = "https://raw.githubusercontent.com/nushell/nushell/main/README.md"
  let coc = "https://raw.githubusercontent.com/nushell/nushell/main/CODE_OF_CONDUCT.md"
  let lic = "https://raw.githubusercontent.com/nushell/nushell/main/LICENSE"
  wget ...[$contrib -q $"--directory-prefix=($doc_path)"]
  wget ...[$readme -q $"--directory-prefix=($doc_path)"]
  wget ...[$coc -q $"--directory-prefix=($doc_path)"]
  wget ...[$lic -q $"--directory-prefix=($license_path)"]

  cp $nu_cargo_bin_path $bin_path
  echo "Done."
}

def create_rpm [ iter: string, op_type: string ] {
  echo "Creating rpm ..."
  let output_dir = $env.PWD
  let input_dir = "usr"
  let pkg_info = get_pkg_info
  let fpm_args = [
    "--verbose"
    "--input-type" "dir"
    "--output-type" $op_type
    "--rpm-os" "linux"
    "--name" $pkg_info.name
    "--architecture" $pkg_info.arch
    "--version" $pkg_info.version
    "--iteration" $iter
    "--maintainer" $pkg_info.maintainer
    "--vendor" $pkg_info.vendor
    "--provides" $pkg_info.bin
    "--description" $pkg_info.desc
    "--rpm-attr" "755,root,root:/usr/local/bin/nu"
    "--rpm-attr" "644,root,root:/usr/share/licenses/nushell/LICENSE"
	  "--url" $pkg_info.url
    "--license" $pkg_info.license
    "--package" $output_dir
    $input_dir
  ]

  run-external "fpm" ...$fpm_args
  rm -rf $input_dir
  echo "Done."
}

def main [ platform: string, pkg_type: string ] {
  let iter = $"1.($platform)"
  let op_type = $pkg_type

  create_bundle_dir
  create_rpm $iter $op_type
  if $env.LAST_EXIT_CODE == 0 {
    echo $"Package created successfully! (char sun)"
  }
}
