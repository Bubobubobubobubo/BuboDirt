# BuboDirt

This is a slightly modified version of [SuperDirt](https://github.com/musikinformatik/SuperDirt). This is the setup I use to play with [Sardine](https://sardine.raphaelforment.fr). The documentation for the original SuperDirt still applies. I'm just adding synthesizers, effects and so on when the need arises.

# Dependencies

There are a few optional dependencies that you might need to run this fork:
- [MIUgens](https://github.com/v7b1/mi-UGens) : port of Mutable Instruments Eurorack modules for SuperCollider
- [PortedPlugins](https://github.com/madskjeldgaard/portedplugins): An awesome
collection from Mads Kjeldgaard of various UGens ported to SuperCollider

# Additions

## Filter Envelope Parameters

### Overview

Filter envelopes dynamically shape the sound by modulating the filter's cutoff frequency over time. This mechanism utilizes three key parameters: `fattack`, `fdecay`, and `sweep`.

### Parameters

- **fattack (Attack Time)**
  - **Range**: Seconds.
  - Controls how quickly the filter reaches its maximum effect level. Shorter values result in a more immediate impact, while longer values allow for a gradual build-up.

- **fdecay (Decay Time)**
  - **Range**: Seconds.
  - Determines the time taken for the filter effect to diminish after peaking. Shorter decay times lead to a rapid return to the baseline, whereas longer times extend the effect's presence.

- **sweep (Frequency Modulation Range)**
  - **Range**: -1 to 1.
  - Dictates the extent and direction of the cutoff frequency modulation. Positive values raise the frequency, negative values lower it, and zero indicates no modulation.

### Example

```haskell
d1 $ sound "bd*4" # lpf 500 # resonance 0.5 # fattack 0.05 # fdecay 0.2 # sweep 0.5
```

This applies an LPF filter, where the cutoff frequency quickly ramps up to the effect level and then gradually falls back, with a noticeable sweep in the cutoff frequency.

## Vadim Filters

These filters leverage the [Vadim Filters](https://www.native-instruments.com/fileadmin/ni_media/downloads/pdf/VAFilterDesign_1.1.1.pdf) from [PortedPlugins](https://github.com/madskjeldgaard/portedplugins).

### Vadim LPF 2-pole and 4-pole (vlpf2, vlpf4)

These filters attenuate frequencies above a certain cutoff frequency, allowing lower frequencies to pass through. The 2-pole version offers a gentler slope compared to the 4-pole version, which provides a steeper cutoff.

Note that the `freq` parameter should be replaced by the filter name (_e.g_
`vlpf2`, `vlpf4`, etc). This applies for all new filters.

Parameters:

- `freq`: Cutoff frequency (in Hz). Determines the frequency above which the signal will be attenuated.
- `resonance`: Controls the resonance (or Q factor) at the cutoff frequency. Range: 0.0 to 1.0.
- `sweep`: Modulates the cutoff frequency over time, based on the fattack and fdecay envelope.
- `fattack`: Attack time (in seconds) for the frequency modulation envelope.
- `fdecay`: Decay time (in seconds) for the frequency modulation envelope.

### Vadim BPF 2-pole and 4-pole (vbpf2, vbpf4)

Same parameters, but this filter type is a band-pass filter, which allows frequencies within a certain range to pass through.

### Vadim HPF 2-pole and 4-pole (vhpf2, vhpf4)

Same parameters, but this filter type is a high-pass filter, which attenuates frequencies below a certain cutoff frequency.

### Example

To use these filters in your TidalCycles setup, you must specify the desired filter and its parameters in your TidalCycles code. For example, to apply a Vadim LPF 2-pole filter with a cutoff frequency of 500 Hz and a resonance of 0.8, you would write:

```
d1 $ sound "bd sn" # vlpf2 500 # resonance 0.8
```
