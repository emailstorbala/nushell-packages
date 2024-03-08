#!/usr/bin/env nu
# This program prepares the nushell rpm

def get_pkg_info [] -> record {
  return {
    bin: "nu"
    name: "nushell"
    arch: "x86_64"
    version: "0.91.0"
    iter: "1.trixie"
    vendor: "The Nushell Project Developers"
    desc: "The nushell language and shell."
    category: "nushell"
    url: "https://www.nushell.sh/"
    maintainer: "www.nushell.sh"
    license: "MIT License"
    dir: "build"
    op_type: "deb"
  }
}

def create_bundle_dir [] {
	echo "Creating bundle directory ..."
  let bin_path = $env.PWD | path join "usr/local/bin"
  let license_path = $env.PWD | path join "usr/share/licenses/nushell"
  let doc_path = $env.PWD | path join "usr/share/doc"
  rm -rf $bin_path $license_path $doc_path
  echo $"($bin_path), ($license_path), ($doc_path)"
  mkdir $bin_path $license_path $doc_path
  wget ...["https://raw.githubusercontent.com/nushell/nushell/main/CONTRIBUTING.md" -q $"--directory-prefix=($doc_path)"]
  wget ...["https://raw.githubusercontent.com/nushell/nushell/main/README.md" -q $"--directory-prefix=($doc_path)"]
  wget ...["https://raw.githubusercontent.com/nushell/nushell/main/CODE_OF_CONDUCT.md" -q $"--directory-prefix=($doc_path)"]
  wget ...["https://raw.githubusercontent.com/nushell/nushell/main/LICENSE" -q $"--directory-prefix=($license_path)"]

  cp nu $bin_path
  echo "Done."
}

def create_rpm [] {
  echo "Creating rpm ..."
  let output_dir = $env.PWD
  let input_dir = "usr"
  let pkg_info = get_pkg_info
  let fpm_args = [
    "--verbose"
    "--input-type" "dir"
    "--output-type" $pkg_info.op_type
    "--rpm-os" "linux"
    "--name" $pkg_info.name
    "--architecture" $pkg_info.arch
    "--version" $pkg_info.version
    "--iteration" $pkg_info.iter
    "--maintainer" $pkg_info.maintainer
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

def main [] {
  create_bundle_dir
  create_rpm
}
