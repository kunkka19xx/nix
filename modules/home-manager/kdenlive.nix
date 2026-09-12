{ ... }:
let
  # Stock MLT profile matching the 2560x1440p60 OBS canvas. Editing 1440p
  # footage in a 1080p project resamples every glyph, which is the same
  # quality loss the OBS canvas change removed one step earlier.
  defaultProfile = "qhd_1440p_60";

  # The stock MP4-H264/AAC preset renders at crf 23 / veryfast, which lands
  # near 0.9 Mbps at 1080p60 and destroys small text. Recordings come off OBS
  # at CQP 20, so crf 18 keeps the generation loss invisible.
  crf = 18;
  x264Preset = "medium";
  audioBitrate = "192k";
in
{
  # kdenlive rewrites this on exit, so it will replace the symlink with a
  # plain file. Each rebuild takes it back, which also resets dialog geometry.
  xdg.configFile."kdenliverc" = {
    force = true;
    text = ''
      [Recent Dirs]
      KdenliveClipFolder[$e]=$HOME/Videos,$HOME/Media/bg-music/,$HOME/Media/records/
      KdenliveProjectsFolder[$e]=$HOME/Videos,$HOME/Documents

      [UiSettings]
      ColorScheme=BreezeDark

      [unmanaged]
      default_profile=${defaultProfile}
      project_fps=60
    '';
  };

  # Custom render presets. kdenlive only writes this file when you edit a
  # preset in the GUI, so it stays put between rebuilds.
  xdg.dataFile."kdenlive/export/customprofiles.xml" = {
    force = true;
    text = ''
      <?xml version="1.0"?>
      <profiles version="0.1">
       <group renderer="avformat" type="av" id="custom">
        <name>Custom</name>
        <profile name="Screencast MP4 (crf ${toString crf})" extension="mp4"
         args="f=mp4 movflags=+faststart vcodec=libx264 crf=${toString crf} preset=${x264Preset} g=120 pix_fmt=yuv420p acodec=aac ab=${audioBitrate}"/>
       </group>
      </profiles>
    '';
  };
}
