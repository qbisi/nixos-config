---
name: es83xx-dts-porting
description: Use when porting ES8323/ES8388/related ES83xx audio DTS nodes from Rockchip or Firefly vendor kernels to this nixos-config tree. Covers replacing vendor-only firefly,multicodecs-card patterns with upstream simple-audio-card or other mainline bindings, mapping GPIO/amplifier/audio-routing properties, and deciding when ADC-based headset or line-in auto-detect must be dropped or reimplemented.
---

# ES83xx DTS Porting

Use this skill when migrating DTS audio support for boards using ES8323, ES8388, or similar ES83xx codecs from vendor kernels into this repository's `dts/` tree.

## Goal

Produce a mainline-friendly DTS design instead of carrying vendor-only bindings forward unchanged.

## Quick workflow

1. Find the vendor sound node and codec node.
2. Identify whether the board uses a vendor machine driver such as `firefly,multicodecs-card`.
3. Separate the properties into:
   - upstream-safe properties
   - vendor-only properties
   - board wiring facts that must be preserved in a different form
4. Check the nearest existing DTS in this repo, especially other RK3588 board files in `dts/`.
5. Rebuild the audio node using upstream bindings such as `simple-audio-card` and `simple-audio-amplifier` unless a better mainline-specific binding already exists.
6. Preserve only behaviors that mainline can express cleanly in DTS; call out any lost vendor behavior explicitly.

## Repo defaults

Prefer these bindings in this repo:
- `simple-audio-card`
- `simple-audio-amplifier`
- codec node compatible supported upstream, often `everest,es8323` or `everest,es8388`

Preserve these kinds of information:
- CPU DAI connection, usually `i2s*_8ch`
- codec phandle
- `mclk-fs` or codec clock rate if still appropriate upstream
- headphone detect GPIO if supported by the chosen mainline binding
- speaker/headphone enable GPIOs, usually as `simple-audio-amplifier` aux devices
- audio widgets and routing

Treat these as vendor-only until proven otherwise:
- `compatible = "firefly,multicodecs-card"`
- `linein-type`
- `firefly,not-use-dapm`
- audio-card-local `io-channels` used only by a vendor machine driver
- custom ADC-based mic or line-in mode selection tables in vendor drivers

## Property mapping

Common vendor-to-mainline mapping:

- `compatible = "firefly,multicodecs-card"`
  Replace with `compatible = "simple-audio-card"` if upstream board support uses simple-card.

- `rockchip,cpu = <&i2sX>;`
  Move under:
  ```dts
  simple-audio-card,cpu {
      sound-dai = <&i2sX>;
  };
  ```

- `rockchip,codec = <&es83xx>;`
  Move under:
  ```dts
  simple-audio-card,codec {
      sound-dai = <&es83xx>;
  };
  ```

- `rockchip,format = "i2s"`
  Usually becomes `simple-audio-card,format = "i2s"`.

- `rockchip,mclk-fs = <N>`
  Usually becomes `simple-audio-card,mclk-fs = <N>`.

- `hp-det-gpio` or `hp-det-gpios`
  Usually becomes `simple-audio-card,hp-det-gpio` or `simple-audio-card,hp-det-gpios`, matching the binding already used in the target DTS.

- `spk-con-gpio` and `hp-con-gpio`
  Usually become separate `simple-audio-amplifier` nodes referenced by `simple-audio-card,aux-devs`.

- `rockchip,audio-routing`
  Usually becomes `simple-audio-card,routing`.

## ADC-based detect guidance

If the vendor DTS uses sound-node `io-channels` plus properties such as `linein-type`, do not copy them to mainline blindly.

Check what consumes them:
- search this repo for the property name
- search the Linux source or vendor tree that the DTS came from
- confirm whether the behavior lives in a vendor machine driver
- verify whether mainline has any equivalent binding or driver behavior

Typical result:
- vendor `io-channels` on the sound card is used for ADC-based jack or mic/line-in classification
- `linein-type` selects a board-specific voltage threshold table
- mainline usually has no DTS-only equivalent for this custom behavior

Decision rule:
- If this repo already has a ported DTS for the same board, follow it.
- If the upstream-style port expresses only fixed routing, drop vendor ADC auto-detection and document the functional change.
- If the behavior is required, plan a driver port or a new upstreamable solution instead of stuffing vendor properties into DTS.

## Board comparison checklist

When checking a vendor board against this repo, compare:
- sound node compatible
- codec model and compatible strings
- DAI endpoint
- MCLK source and rate
- headphone detect mechanism
- external amp enable GPIOs
- widgets and routing
- whether mic jack vs onboard mic selection is fixed or auto-detected

Also check related user-space config:
- `pkgs/alsa-ucm-conf-rk3588/share/alsa/ucm2/Rockchip/es8388/`
- `hosts/by-name/3588q.nix`

## Recommended search commands

Use these locally first:
```bash
rg -n "firefly,multicodecs-card|linein-type|io-channels|hp-det-gpio|hp-det-gpios|spk-con-gpio|hp-con-gpio|audio-routing" dts
rg -n "simple-audio-card|simple-audio-amplifier|amp_headphones|amp_speaker|es8323|es8388" dts pkgs/alsa-ucm-conf-rk3588 hosts
rg -n "Headphones|Speaker|Microphone Jack|Onboard Microphone" dts pkgs/alsa-ucm-conf-rk3588
```

When the user asks for latest upstream status or Linux binding comparison, browse and prefer:
- the exact board DTS in `torvalds/linux`
- current mainline sound bindings
- codec driver support in mainline

## Repo example

Reference implementation in this repo:
- `dts/rk3588-firefly-aio-3588q.dts`

Mainline-style pattern:
```dts
analog-sound {
    compatible = "simple-audio-card";
    simple-audio-card,format = "i2s";
    simple-audio-card,mclk-fs = <384>;
    simple-audio-card,hp-det-gpios = <&gpio1 RK_PC4 GPIO_ACTIVE_LOW>;
    simple-audio-card,aux-devs = <&amp_headphones>, <&amp_speaker>;
    simple-audio-card,pin-switches = "Headphones", "Speaker";
    simple-audio-card,widgets =
        "Microphone", "Microphone Jack",
        "Microphone", "Onboard Microphone",
        "Headphone", "Headphones",
        "Speaker", "Speaker";
    simple-audio-card,routing = ...;

    simple-audio-card,cpu {
        sound-dai = <&i2s0_8ch>;
    };

    simple-audio-card,codec {
        sound-dai = <&es8323>;
        system-clock-frequency = <12288000>;
    };
};

amp_headphones: headphones-audio-amplifier {
    compatible = "simple-audio-amplifier";
    enable-gpios = <&gpio4 RK_PB0 GPIO_ACTIVE_HIGH>;
    sound-name-prefix = "Headphones Amplifier";
};

amp_speaker: speaker-audio-amplifier {
    compatible = "simple-audio-amplifier";
    enable-gpios = <&gpio3 RK_PB2 GPIO_ACTIVE_HIGH>;
    sound-name-prefix = "Speaker Amplifier";
};
```

Important: vendor `io-channels` and `linein-type` should usually be dropped in this repo's DTS ports unless you are also porting the custom ADC detection driver behavior.

## Output expectations

When applying this skill, provide:
- a short migration summary
- a table or bullet mapping of vendor properties to mainline replacements
- any behaviors that will be lost in pure-DTS migration
- a proposed DTS patch or replacement node
- references to the exact DTS, binding, and driver files consulted

## Red flags

Pause and call out risk if any of these are true:
- vendor codec name and upstream codec compatible do not match cleanly
- board relies on ADC thresholds to distinguish multiple analog input modes
- there is no nearby board DTS in this repo to copy from
- amp GPIOs are really mux or power-switch controls rather than true amplifiers
- audio routing in vendor DTS conflicts with codec datasheet pin use

## Minimal rule of thumb

If a vendor ES83xx board uses `firefly,multicodecs-card`, assume the mainline solution is a redesign around upstream audio bindings, not a literal property-by-property translation.
