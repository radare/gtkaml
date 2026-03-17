if build_gtk3_targets
  foreach test_data : [
    ['test0.gtkaml', 'test0.vala'],
    ['test4.gtkon', 'test4.vala'],
    ['test5.gtkon', 'test5.vala'],
    ['test7.gtkon', 'test7.vala'],
  ]
    custom_target(
      'gtk3-smoke-' + test_data[0],
      input: test_data[0],
      output: test_data[1],
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
  endforeach
endif

if build_gtk4_targets
  subdir('gtk4')
endif

if build_adwaita_targets
  subdir('adwaita')
endif
