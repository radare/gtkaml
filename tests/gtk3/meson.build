custom_target(
  'gtk3-smoke-test4',
  input: 'test4.gtkaml',
  output: ['test4', 'test4.vala'],
  command: [
    gtkamlc,
    '--pkg',
    'gtk+-3.0',
    '--vapidir',
    meson.project_source_root() / 'markuphints',
    '--dump-tree',
    '@OUTPUT1@',
    '-o',
    '@OUTPUT0@',
    '@INPUT@',
  ],
  build_by_default: true,
)
