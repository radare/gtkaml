custom_target(
  'gtk4-smoke',
  input: 'smoke.gtkaml',
  output: 'smoke',
  command: [
    gtkamlc,
    '--pkg',
    'gtk4',
  ] + gtkamlc_markup_args + [
    '-o',
    '@OUTPUT@',
    '@INPUT@',
  ],
  build_by_default: true,
)
