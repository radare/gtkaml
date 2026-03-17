custom_target(
  'gtk4-smoke',
  input: 'smoke.gtkaml',
  output: ['smoke', 'smoke.vala'],
  command: [
    gtkamlc,
    '--pkg',
    'gtk4',
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
