{ lib, ... }:
{
  # RealtimeKit is required for PipeWire's realtime scheduling
  security.rtkit.enable = lib.mkDefault true;

  services.pipewire = {
    enable = lib.mkDefault true;

    # Low-level audio layer (ALSA)
    alsa.enable = lib.mkDefault true;
    alsa.support32Bit = lib.mkDefault true;

    # PulseAudio Server emulation (for most apps)
    pulse.enable = lib.mkDefault true;

    # JACK emulation (for pro-audio apps like DAWs)
    jack.enable = lib.mkDefault true;
  };
}
