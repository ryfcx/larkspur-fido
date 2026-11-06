# larkspur fido

a small fido2 key prototype for a 16 mb rp2040 board. it's based on [pico-fido v6.6](https://github.com/polhenarejos/pico-fido/tree/v6.6), with the changes in `patches/`.

## use it

plug the board in normally. it shows up as **Larkspur FIDO Prototype**, not as a drive in finder. choose a security key when a site asks, then press and release bootsel. you can skip macos keyboard setup.

## flash it

1. unplug the board.
2. hold bootsel while plugging it back in.
3. copy `firmware/larkspur-fido-rp2040.uf2` to the `RPI-RP2` drive.
4. let it reboot, then plug it in normally.

this image targets the 16 mb rp2040 board used for this project. check your board before flashing another one.

## build it

on macos, install cmake and the arm gnu toolchain:

```sh
brew install cmake git
brew install --cask gcc-arm-embedded
./build.sh
```

the script downloads the pinned pico-fido, pico-keys-sdk, and pico-sdk sources, applies the two patches, and writes `build/larkspur-fido-rp2040.uf2`.

## attestation

the current board has its own device key and a certificate signed by the local prototype issuer. `certs/prototype-root.pem` is the public issuer certificate. the private issuer key and this board's unique device certificate are not in this repo.

flashing a different board does not give it this board's issued certificate.

this is a prototype, not a certified security key. its certificate does not make it eligible for openai daybreak. the rp2040 also cannot protect its flash from physical extraction.

## credit

this project builds on [pico-fido](https://github.com/polhenarejos/pico-fido) and [pico-keys-sdk](https://github.com/polhenarejos/pico-keys-sdk). their copyright notices stay with the upstream source. the changes here are released under the same gpl-3.0 license; see `LICENSE`.
