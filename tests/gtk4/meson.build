custom_target(
  'gtk4-smoke',
  input: 'smoke.gtkaml',
  output: 'smoke.vala',
  command: [
    gtkamlc,
    '--pkg',
    'gtk4',
  ] + gtkamlc_markup_args + [
    '-V',
    '@INPUT@',
  ],
  build_by_default: true,
)
