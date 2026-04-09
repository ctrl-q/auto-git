pkgname=auto-git
pkgver=0.0.1
pkgrel=1
arch=('any')
depends=('bash' 'coreutils' 'findutils' 'gawk' 'git' 'grep' 'libnotify' 'open-in-terminal')
source=('main.sh')
sha512sums=('SKIP')

package(){
	install -d "${pkgdir}/usr/local/bin"
	ln -s "$(dirname ${srcdir})/main.sh" "${pkgdir}/usr/local/bin/${pkgname}"
}

