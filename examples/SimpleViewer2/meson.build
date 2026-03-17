custom_target(
  'example-simpleviewer2',
  input: 'SimpleViewer2.gtkaml',
  output: 'SimpleViewer2',
  command: [
    gtkamlc,
    '--pkg',
    'gtk+-3.0',
  ] + gtkamlc_markup_args + [
    '-o',
    '@OUTPUT@',
    '@INPUT@',
  ],
  build_by_default: true,
)
