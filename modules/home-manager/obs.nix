{ config, pkgs, ... }:
let
  # Profile OBS actually loads. Keep the name in sync with the GUI profile,
  # otherwise these files are written for a profile nothing selects.
  profile = "Untitled";

  # Discrete RX 9060 XT. renderD129 is the Granite Ridge iGPU, which would
  # encode far slower and force a cross-GPU copy of every frame.
  vaapiDevice = "/dev/dri/renderD128";

  recordDir = "${config.home.homeDirectory}/Media/records";

  # Constant quality. Lower qp = better picture and bigger file; 20 is
  # visually clean, 23 is noticeably smaller, 16 is near-transparent.
  qp = 20;
in
{
  programs.obs-studio = {
    enable = true;

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vaapi #optional AMD hardware acceleration
      obs-gstreamer
      obs-vkcapture
      droidcam-obs
    ];
  };

  # OBS rewrites its profile on exit, so it will clobber these symlinks with
  # plain files. force = true lets the next rebuild take ownership back, which
  # also means GUI changes to the Output panel do not survive a rebuild.
  # Quit OBS before rebuilding or the running instance wins on shutdown.
  xdg.configFile = {
    "obs-studio/basic/profiles/${profile}/basic.ini" = {
      force = true;
      text = ''
        [General]
        Name=${profile}

        [Output]
        Mode=Advanced
        FilenameFormatting=%CCYY-%MM-%DD %hh-%mm-%ss
        DelayEnable=false
        DelaySec=20
        DelayPreserve=true
        Reconnect=true
        RetryDelay=2
        MaxRetries=25
        BindIP=default
        IPFamily=IPv4+IPv6
        NewSocketLoopEnable=false
        LowLatencyEnable=false

        [Stream1]
        IgnoreRecommended=false
        MultitrackVideoMaximumAggregateBitrateAuto=true
        MultitrackVideoMaximumVideoTracksAuto=true
        EnableMultitrackVideo=false

        [AdvOut]
        ApplyServiceSettings=true
        Encoder=obs_x264
        AudioEncoder=ffmpeg_aac
        TrackIndex=1
        VodTrackIndex=2
        FLVTrack=1
        StreamMultiTrackAudioMixes=1
        UseRescale=false

        RecType=Standard
        RecFilePath=${recordDir}
        RecFormat2=mkv
        RecEncoder=ffmpeg_vaapi_tex
        RecAudioEncoder=ffmpeg_aac
        RecTracks=1
        RecUseRescale=false
        RecFileNameWithoutSpace=true
        RecRescaleFilter=0

        Track1Bitrate=160
        Track2Bitrate=160
        Track3Bitrate=160
        Track4Bitrate=160
        Track5Bitrate=160
        Track6Bitrate=160

        RecSplitFileType=Time
        RecSplitFileTime=15
        RecSplitFileSize=2048
        RecRB=false
        RecRBTime=20
        RecRBSize=512

        [Video]
        # Native panel size. Any mismatch here resamples every glyph and is
        # what makes recorded text look soft, no matter how good the encoder is.
        BaseCX=2560
        BaseCY=1440
        OutputCX=2560
        OutputCY=1440
        FPSType=0
        FPSCommon=60
        FPSInt=30
        FPSNum=30
        FPSDen=1
        ScaleType=lanczos
        ColorFormat=NV12
        ColorSpace=709
        ColorRange=Partial
        SdrWhiteLevel=300
        HdrNominalPeakLevel=1000

        [Audio]
        MonitoringDeviceId=default
        MonitoringDeviceName=Default
        SampleRate=48000
        ChannelSetup=Stereo
        MeterDecayRate=23.53
        PeakMeterType=0
      '';
    };

    # Settings for RecEncoder above. profile 100 is H.264 High.
    "obs-studio/basic/profiles/${profile}/recordEncoder.json" = {
      force = true;
      text = builtins.toJSON {
        vaapi_device = vaapiDevice;
        rate_control = "CQP";
        inherit qp;
        keyint_sec = 2;
        profile = 100;
      };
    };
  };
}
