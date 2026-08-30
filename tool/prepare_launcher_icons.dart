// Prepares launcher-icon source images from the master GGW Connect logo.
//
// Why this exists: the master logo is a circular badge whose brand text
// ("GOLF GAME WORLD" / "CONNECT") runs around the rim. Android adaptive icons
// crop the foreground to a circle and zoom it — only the inner ~61% of the
// canvas is guaranteed visible — so dropping the full-bleed logo straight in
// clips the rim text off and leaves the letters unreadable on the home screen.
//
// So we down-scale the logo onto a padded canvas: the whole badge, rim text
// included, then sits inside the adaptive safe zone and survives the crop.
//
// Run:  dart run tool/prepare_launcher_icons.dart
// Then: dart run flutter_launcher_icons
import 'dart:io';

import 'package:image/image.dart';

/// Fraction of the canvas the badge occupies.
/// Adaptive foreground: the guaranteed-visible circle is 66/108 ≈ 0.61 of the
/// canvas, so stay just inside it. Legacy icons aren't zoomed, so they can run
/// larger and only need a little breathing room from the rounded mask.
const double _adaptiveScale = 0.58;
const double _legacyScale = 0.88;
const int _canvas = 1024;

const String _source = 'assets/icons/ggw_connect_logo.png';
const String _adaptiveOut = 'assets/icons/ic_launcher_foreground.png';
const String _legacyOut = 'assets/icons/ic_launcher.png';

/// Centers [logo] on a [_canvas]-square canvas at [scale], over [background]
/// (transparent when null).
Image _compose(Image logo, double scale, {Color? background}) {
  final canvas = Image(width: _canvas, height: _canvas, numChannels: 4);
  if (background != null) {
    fill(canvas, color: background);
  } else {
    fill(canvas, color: ColorRgba8(0, 0, 0, 0));
  }

  final target = (_canvas * scale).round();
  final scaled = copyResize(
    logo,
    width: target,
    height: target,
    interpolation: Interpolation.cubic,
  );
  final offset = ((_canvas - target) / 2).round();
  compositeImage(canvas, scaled, dstX: offset, dstY: offset);
  return canvas;
}

void main() {
  final sourceFile = File(_source);
  if (!sourceFile.existsSync()) {
    stderr.writeln('Missing source logo: $_source');
    exitCode = 1;
    return;
  }

  final logo = decodePng(sourceFile.readAsBytesSync());
  if (logo == null) {
    stderr.writeln('Could not decode $_source');
    exitCode = 1;
    return;
  }
  stdout.writeln('Source logo: ${logo.width}x${logo.height}');

  // Adaptive foreground: transparent padding, background colour supplied by
  // the adaptive_icon_background setting.
  File(_adaptiveOut)
      .writeAsBytesSync(encodePng(_compose(logo, _adaptiveScale)));
  stdout.writeln('Wrote $_adaptiveOut (badge at ${_adaptiveScale * 100}%)');

  // Legacy / iOS / web icon: same badge on the logo's own white ground, since
  // these are not composited over a separate background layer.
  File(_legacyOut).writeAsBytesSync(
    encodePng(_compose(logo, _legacyScale, background: ColorRgb8(255, 255, 255))),
  );
  stdout.writeln('Wrote $_legacyOut (badge at ${_legacyScale * 100}%)');
}
