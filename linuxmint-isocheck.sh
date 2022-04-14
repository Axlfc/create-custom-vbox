#!/usr/bin/env bash
# Linux Mint
check_gpg_signature()
{
  sha256gpgurl="$(curl --silent https://linuxmint.com/edition.php?id=292 | grep 'sha256sum.txt' | grep /sha256sum.txt | head -2 | cut -d '"' -f2 | grep '.gpg')"
  # Import the Linux Mint signing key
  gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-key "27DE B156 44C6 B3CF 3BD7  D291 300F 846B A25B AE09"
  wget "${sha256gpgurl}"
  gpg --verify sha256sum.txt.gpg sha256sum.txt
}

download_system_image()
{
  mintisourl="$(curl --silent https://linuxmint.com/edition.php?id=292 | grep href | grep "airenetworks.es" | cut -d '"' -f2- | cut -d '"' -f1)"
  wget --no-check-certificate "${mintisourl}"
}


main()
{
  if [ -f *cinnamon-64bit.iso ]; then
    rm linuxmint-*cinnamon-64bit.iso
  fi
  download_system_image
  
  sha256url="$(curl --silent https://linuxmint.com/edition.php?id=292 | grep sha256sum.txt | grep /sha256sum.txt | head -1 | cut -d '"' -f2)"
  wget "${sha256url}"
  
  contentcheck_iso="$(curl --silent $sha256url)"
  content_check_local="$(sha256sum -b linuxmint*)"
  
  if [ "$(cat sha256sum.txt | grep "${content_check_local}" | cut -d ' ' -f1)" == "$(echo $contentcheck_iso | grep -Eo "${content_check_local}")" ]; then
    echo "Checksum official correct"
	
	echo "Checking gpg signature"
    check_gpg_signature
	
    echo "Removing old sha256 files"
    rm sha256sum.txt
  else
    echo "Checksum official incorrect"
    echo "Keeping sha256 files for examination"
  fi
}

main
