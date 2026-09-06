FROM archlinux:latest

RUN pacman -Syu --noconfirm archiso git sudo base-devel && \
  pacman -Scc --noconfirm

# CachyOS keyring + generic repos for lamX base, v3 enabled post-install on target
RUN pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com && pacman-key --lsign-key F3B607488DB35A47 && pacman -U --noconfirm \
  'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-keyring-20240331-1-any.pkg.tar.zst' \
  'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-mirrorlist-27-1-any.pkg.tar.zst' && \
  printf '\n[cachyos]\nInclude = /etc/pacman.d/cachyos-mirrorlist\n' >> /etc/pacman.conf && \
  pacman -Syu --noconfirm

WORKDIR /workspaces/lamX
