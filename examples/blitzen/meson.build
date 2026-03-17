custom_target(
  'example-blitzen-markup',
  input: 'test.gtkon',
  output: 'test.vala',
  command: [
    gtkamlc,
    '--pkg',
    'stk-1.0',
  ] + gtkamlc_markup_args + [
    '-V',
    '@INPUT@',
  ],
  build_by_default: true,
)
