custom_target(
  'adwaita-smoke',
  input: 'smoke.gtkaml',
  output: 'smoke',
  command: [
    gtkamlc,
    '--pkg',
    'gtk4',
    '--pkg',
    'libadwaita-1',
  ] + gtkamlc_markup_args + [
    '-o',
    '@OUTPUT@',
    '@INPUT@',
  ],
  build_by_default: true,
)
