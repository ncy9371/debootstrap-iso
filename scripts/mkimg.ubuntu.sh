profile_ubuntu() {
	title="Ubuntu Installation Environment"
	desc="Ubuntu installation environment for debootstrap"
	profile_base
	profile_abbrev="ubuntu"
	image_ext="iso"
	arch="x86 x86_64"
	output_format="iso"
	kernel_cmdline="nomodeset"
	kernel_addons="xtables-addons"
	apks="$apks vim util-linux debootstrap xfsprogs perl"
	apkovl="genapkovl-ubuntu.sh"
}
