custom_target(
  'example-simpleviewer2',
  input: 'SimpleViewer2.gtkaml',
  output: 'SimpleViewer2.vala',
  command: [
    gtkaml_to_vala,
    gtkamlc,
    '@INPUT@',
    '@OUTPUT@',
    '--pkg',
    'gtk+-3.0',
    '--vapidir',
    meson.project_source_root() / 'markuphints',
    '--implicitsdir',
    meson.project_source_root() / 'data',
  ],
  build_by_default: true,
)
