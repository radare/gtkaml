custom_target(
  'gtk3-smoke-test4',
  input: 'test4.gtkaml',
  output: 'test4.vala',
  command: [
    gtkamlc,
    '--pkg',
    'gtk+-3.0',
  ] + gtkamlc_markup_args + [
    '-V',
    '@INPUT@',
  ],
  build_by_default: true,
)
