blitzen_markup = custom_target(
  'example-blitzen-markup',
  input: 'test.gtkon',
  output: 'test.vala',
  command: [
    gtkaml_to_vala,
    gtkamlc,
    '@INPUT@',
    '@OUTPUT@',
    '--pkg',
    'stk-1.0',
    '--vapidir',
    meson.project_source_root() / 'markuphints',
    '--implicitsdir',
    meson.project_source_root() / 'data',
  ],
  build_by_default: true,
)
